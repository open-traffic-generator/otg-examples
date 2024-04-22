import csv
import json
import os
import socket
import subprocess
import sys
import time
from datetime import datetime
import numpy

import dpkt
import snappi

if sys.version_info[0] >= 3:
    # alias str as unicode for python3 and above
    unicode = str


# path to settings.json relative root dir
SETTINGS_FILE = 'settings.json'
# path to dir containing traffic configurations relative root dir
CONFIGS_DIR = 'configs'

# path to baseline.csv
TEST_DIR = 'py'
BASELINE_CSV = 'baseline.csv'

SUDO_USER = 'root'


def get_root_dir():
    return os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    )


def get_test_config_path(config_name):
    return os.path.join(get_root_dir(), CONFIGS_DIR, config_name)


def dict_items(d):
    try:
        # python 3
        return d.items()
    except Exception:
        # python 2
        return d.iteritems()


def object_dict_items(ob):
    return dict_items(ob.__dict__)


def byteify(val):
    if isinstance(val, dict):
        return {byteify(key): byteify(value) for key, value in dict_items(val)}
    elif isinstance(val, list):
        return [byteify(element) for element in val]
    # change u'string' to 'string' only for python2
    elif isinstance(val, unicode) and sys.version_info[0] == 2:
        return val.encode('utf-8')
    else:
        return val


def load_dict_from_json_file(path):
    """
    Safely load dictionary from JSON file in both python2 and python3
    """
    with open(path, 'r') as fp:
        return json.load(fp, object_hook=byteify)


class Settings(object):
    """
    Singleton for global settings
    """

    def __init__(self):
        # these not be defined and are here only for documentation
        self.username = None
        self.http_server = None
        self.grpc_server = None
        self.ports = None
        self.soft_dut = None
        self.speed = None
        self.line_rate = None
        self.mtu = None
        self.promiscuous = None
        self.timeout_seconds = None
        self.interval_seconds = None
        self.log_level = None
        self.http_transport = None
        self.dynamic_stats_output = None
        self.capture_validation = None
        self.flow_metric_validation = None
        # might need this in future
        self.license_servers = None
        self.otlp_grpc_server = None

        self.load_from_settings_file()

    def load_from_settings_file(self):
        self.__dict__ = load_dict_from_json_file(self.get_settings_path())
        # overwrite with custom settings if it exists
        custom = os.environ.get('SETTINGS_FILE', None)
        if custom is not None and os.path.exists(custom):
            self.__dict__ = load_dict_from_json_file(custom)

    def get_settings_path(self):
        return os.path.join(get_root_dir(), SETTINGS_FILE)

    def register_pytest_command_line_options(self, parser):
        for key, val in object_dict_items(self):
            parser.addoption("--%s" % key, action="store", default=None)

    def load_from_pytest_command_line(self, config):
        for key, val in object_dict_items(self):
            new_val = config.getoption(key)
            if new_val is not None:
                if key in ['license_servers', 'ports']:
                    # items in a list are expected to be passed in as a string
                    # where each item is separated by whitespace
                    setattr(self, key, new_val.split())
                else:
                    if key in [
                        'promiscuous',
                        'dynamic_stats_output',
                        'capture_validation',
                        'flow_metric_validation',
                        'http_transport'
                    ]:
                        if new_val.lower() == 'true':
                            new_val = True
                        elif new_val.lower() == 'false':
                            new_val = False
                    setattr(self, key, new_val)


# shared global settings
settings = Settings()


def capture_validation_enabled():
    return settings.capture_validation


def flow_metric_validation_enabled():
    return settings.flow_metric_validation


def time_trace(start_time, apiname, msg=""):
    elapsed_ms = (time.time() - start_time) * 1000
    # TODO: replace with logging
    print("Time taken by %s %s: %.3f ms" % (apiname, msg, elapsed_ms))


def load_test_config(api, json_path, apply_settings=False):
    """
    Returns instance of `Config` de-serialized from its JSON counterpart.
    If `apply_settings` is true, patches config with settings provided by user.
    """
    if not os.path.exists(json_path):
        # if it's not an existing path, then it must be just a file name
        json_path = get_test_config_path(json_path)

    print('Importing config %s ...' % json_path)
    with open(json_path, 'r') as fp:
        # OpenApi generated python source provides a direct way to serialize
        # schema object to dictionary (which can be serialized to JSON) but not
        # the other way round. Although, deep down inside transport source,
        # there is a function which de-serializes HTTP response (JSON str) to
        # schema object. The catch is, it has to be a response has a data attr.
        # response = type('obj', (object, ), {'data': fp.read()})
        cfg = api.config()
        cfg.deserialize(fp.read())

        if apply_settings:
            # modify config to use port locations provided in settings.json
            for i, p in enumerate(cfg.ports):
                p.location = settings.ports[i]
            # modify speed if layer1 config exists
            if cfg.layer1 is not None:
                for i, l in enumerate(cfg.layer1):
                    l.speed = settings.speed
                    l.mtu = settings.mtu
                    l.promiscuous = settings.promiscuous
            # modify line rate
            if settings.line_rate is not None:
                for f in cfg.flows:
                    try:
                        if f.rate == 'percentage':
                            f.rate.percentage = settings.line_rate
                    except Exception:
                        pass
        return cfg


def get_capture_port_names(cfg):
    """
    Returns name of ports for which capture is enabled.
    """
    names = []
    if isinstance(cfg, str):
        cfg = json.loads(cfg)
        if 'captures' in list(cfg.keys()):
            for cap in cfg['captures']:
                if 'port_names' in list(cap.keys()):
                    for name in cap['port_names']:
                        if name not in names:
                            names.append(name)
    else:
        if cfg.captures:
            for cap in cfg.captures:
                if cap.port_names:
                    for name in cap.port_names:
                        if name not in names:
                            names.append(name)

    return names


def set_api(settings):
    if settings.http_transport:
        api = snappi.api(location=settings.http_server)
        return api
    else:
        api = snappi.api(location=settings.grpc_server,
                         transport=snappi.Transport.GRPC)
        return api


def set_config(api, cfg, return_time=False):
    start_time = time.time()
    print('Setting config ...')
    res = api.set_config(cfg)
    if len(res.warnings) > 0:
        print("Warnings: {}".format(res.warnings))
    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def update_flows(api, update_req, return_time=False):
    start_time = time.time()
    print('Updating flows ...')
    api.update_flows(update_req)
    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def start_capture(api, cfg, return_time=False):

    start_time = time.time()
    #cap_port_names = get_capture_port_names(cfg)
    cap_port_names = False
    if cap_port_names:
        print('Starting capture on ports %s ...' % str(cap_port_names))
        control_state = api.control_state()
        control_state.choice = control_state.PORT
        control_state.port.choice = control_state.port.CAPTURE
        control_state.port.capture.state = control_state.port.capture.START
        control_state.port.capture.port_names = cap_port_names
        res = api.set_control_state(control_state)
        if len(res.warnings) > 0:
            print("Warnings: {}".format(res.warnings))

    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def stop_capture(api, cfg, return_time=False):

    start_time = time.time()
    cap_port_names = get_capture_port_names(cfg)
    if cap_port_names:
        print('Stopping capture on ports %s ...' % str(cap_port_names))
        control_state = api.control_state()
        control_state.choice = control_state.PORT
        control_state.port.choice = control_state.port.CAPTURE
        control_state.port.capture.state = control_state.port.capture.STOP
        control_state.port.capture.port_names = cap_port_names
        res = api.set_control_state(control_state)
        if len(res.warnings) > 0:
            print("Warnings: {}".format(res.warnings))

    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def start_flow_transmit(api, flow_names=[], return_time=False):
    start_time = time.time()
    if len(flow_names) == 0:
        print('Starting transmit on all flows ...')
    else:
        print('Starting transmit on the flows {}'.format(flow_names))
    control_state = api.control_state()
    control_state.choice = control_state.TRAFFIC
    control_state.traffic.choice = control_state.traffic.FLOW_TRANSMIT
    control_state.traffic.flow_transmit.state = control_state.traffic.flow_transmit.START  # noqa
    control_state.traffic.flow_transmit.flow_names = flow_names
    res = api.set_control_state(control_state)
    if len(res.warnings) > 0:
        print("Warnings: {}".format(res.warnings))
    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def stop_flow_transmit(api, flow_names=[], return_time=False):
    start_time = time.time()
    print('Stopping transmit on all flows ...')
    control_state = api.control_state()
    control_state.choice = control_state.TRAFFIC
    control_state.traffic.choice = control_state.traffic.FLOW_TRANSMIT
    control_state.traffic.flow_transmit.state = control_state.traffic.flow_transmit.STOP  # noqa
    control_state.traffic.flow_transmit.flow_names = flow_names
    res = api.set_control_state(control_state)
    if len(res.warnings) > 0:
        print("Warnings: {}".format(res.warnings))
    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def start_traffic(api, cfg):
    """
    Applies configuration,starts capture and starts flows.
    """
    print('Setting config ...')
    res = api.set_config(cfg)
    if len(res.warnings) > 0:
        print("Warnings: {}".format(res.warnings))

    if capture_validation_enabled():
        cap_port_names = get_capture_port_names(cfg)
        if cap_port_names:
            print('Starting capture on ports %s ...' % str(cap_port_names))
            control_state = api.control_state()
            control_state.choice = control_state.PORT
            control_state.port.choice = control_state.port.CAPTURE
            control_state.port.capture.state = control_state.port.capture.START
            control_state.port.capture.port_names = cap_port_names
            res = api.set_control_state(control_state)
            if len(res.warnings) > 0:
                print("Warnings: {}".format(res.warnings))

    print('Starting transmit on all flows ...')
    control_state = api.control_state()
    control_state.choice = control_state.TRAFFIC
    control_state.traffic.choice = control_state.traffic.FLOW_TRANSMIT
    control_state.traffic.flow_transmit.state = control_state.traffic.flow_transmit.START  # noqa
    res = api.set_control_state(control_state)
    if len(res.warnings) > 0:
        print("Warnings: {}".format(res.warnings))


def stop_traffic(api, cfg):
    """
    Stops flows
    """

    print('stop transmit on all flows ...')
    control_state = api.control_state()
    control_state.choice = control_state.TRAFFIC
    control_state.traffic.choice = control_state.traffic.FLOW_TRANSMIT
    control_state.traffic.flow_transmit.state = control_state.traffic.flow_transmit.STOP  # noqa
    res = api.set_control_state(control_state)
    if len(res.warnings) > 0:
        print("Warnings: {}".format(res.warnings))

    if capture_validation_enabled():
        cap_port_names = get_capture_port_names(cfg)
        if cap_port_names:
            control_state = api.control_state()
            control_state.choice = control_state.PORT
            control_state.port.choice = control_state.port.CAPTURE
            control_state.port.capture.state = control_state.port.capture.STOP
            control_state.port.capture.port_names = cap_port_names
            res = api.set_control_state(control_state)
            if len(res.warnings) > 0:
                print("Warnings: {}".format(res.warnings))


def get_port_metrics(api, return_time=False):
    start_time = time.time()
    req = api.metrics_request()
    req.port.port_names = []
    print('Fetching all port stats ...')
    res = api.get_metrics(req)
    port_results = res.port_metrics
    if port_results is None:
        port_results = []
    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def get_flow_metrics(api, return_time=False):
    start_time = time.time()
    req = api.metrics_request()
    req.flow.flow_names = []
    print('Fetching all flow stats ...')
    res = api.get_metrics(req)
    flow_results = res.flow_metrics
    if flow_results is None:
        flow_results = []
    end_time = time.time()
    operation_time = (end_time - start_time) * 1000
    if return_time:
        return operation_time


def get_all_stats(api,
                  ports=None,
                  flows=None,
                  print_output=True,
                  clear_screen=None):
    """
    Returns all port and flow stats
    """
    req = api.metrics_request()
    if ports is not None:
        print('Fetching port stats for {} ...'.format(
            ports
        ))
        req.port.port_names = ports
    else:
        print('Fetching all port stats ...')
        req.port.port_names = []
    res = api.get_metrics(req)
    port_results = res.port_metrics
    if port_results is None:
        port_results = []

    if flows is not None:
        print('Fetching flows stats for {} ...'.format(
            flows
        ))
        req.flow.flow_names = flows
    else:
        req.flow.flow_names = []
        print('Fetching all flow stats ...')
    res = api.get_metrics(req)
    flow_results = res.flow_metrics
    if flow_results is None:
        flow_results = []

    if print_output:
        print_stats(port_stats=port_results,
                    flow_stats=flow_results,
                    clear_screen=clear_screen)

    return port_results, flow_results


def get_all_captures(api, cfg):
    """
    Returns a dictionary where port name is the key and value is a list of
    frames where each frame is represented as a list of bytes.
    """
    cap_dict = {}
    cap_port_names = get_capture_port_names(cfg)
    for name in cap_port_names:
        print('Fetching capture from port %s' % name)
        capture_req = api.capture_request()
        capture_req.port_name = name
        pcap_bytes = api.get_capture(capture_req)

        cap_dict[name] = []
        try:
            for ts, pkt in dpkt.pcap.Reader(pcap_bytes):
                if sys.version_info[0] == 2:
                    cap_dict[name].append([ord(b) for b in pkt])
                else:
                    cap_dict[name].append(list(pkt))
        except Exception:
            raise Exception('No packets has been captured')

    return cap_dict


def get_all_captures_as_pcap_bytes(api, cfg):
    """
    Returns a dictionary where port name is the key and value is pacp bytes.
    """
    cap_dict = {}
    cap_port_names = get_capture_port_names(cfg)
    for name in cap_port_names:
        print('Fetching capture from port %s' % name)
        capture_req = api.capture_request()
        capture_req.port_name = name
        try:
            cap_dict[name] = api.get_capture(capture_req)
        except Exception:
            raise Exception('No packets has been captured')
    return cap_dict


def get_all_captures_as_dpkt_pcap(api, cfg, port_names=None):
    """
    Returns a dictionary where port name is the key
    and value is dpkt pcap reader object.
    """
    cap_dict = {}
    if port_names is None:
        cap_port_names = get_capture_port_names(cfg)
    else:
        cap_port_names = port_names
    for name in cap_port_names:
        print('Fetching capture from port %s' % name)
        capture_req = api.capture_request()
        capture_req.port_name = name
        pcap = api.get_capture(capture_req)
        # with open('out.pcap', 'wb') as out:
        #     out.write(pcap.read())
        try:
            cap_dict[name] = dpkt.pcap.Reader(pcap)
        except Exception:
            raise Exception('No packets has been captured')
    return cap_dict


def seconds_elapsed(start_seconds):
    return int(round(time.time() - start_seconds))


def timed_out(start_seconds, timeout):
    return seconds_elapsed(start_seconds) > timeout


def wait_for(func, condition_str, interval_seconds=None, timeout_seconds=None):
    """
    Keeps calling the `func` until it returns true or `timeout_seconds` occurs
    every `interval_seconds`. `condition_str` should be a constant string
    implying the actual condition being tested.

    Usage
    -----
    If we wanted to poll for current seconds to be divisible by `n`, we would
    implement something similar to following:
    ```
    import time
    def wait_for_seconds(n, **kwargs):
        condition_str = 'seconds to be divisible by %d' % n

        def condition_satisfied():
            return int(time.time()) % n == 0

        poll_until(condition_satisfied, condition_str, **kwargs)
    ```
    """
    if interval_seconds is None:
        interval_seconds = settings.interval_seconds
    if timeout_seconds is None:
        timeout_seconds = settings.timeout_seconds
    start_seconds = int(time.time())

    print('\n\nWaiting for %s ...' % condition_str)
    while True:
        if func():
            print('Done waiting for %s' % condition_str)
            break
        if timed_out(start_seconds, timeout_seconds):
            msg = 'Time out occurred while waiting for %s' % condition_str
            raise Exception(msg)

        time.sleep(interval_seconds)


def new_logs_dir(prefix='logs'):
    """
    creates a new dir with prefix and current timestamp
    """
    file_name = prefix + "-" + datetime.strftime(
        datetime.now(), "%Y%m%d-%H%M%S"
    )
    logs_dir = os.path.join(get_root_dir(), "logs")
    csv_dir = os.path.join(logs_dir, file_name)
    # don't use exist_ok - since it's not supported in python2
    if not os.path.exists(csv_dir):
        os.makedirs(csv_dir)
    return csv_dir


def append_csv_row(dirname, filename, column_names, result_dict):
    """
    creates a new csv with column names if it doesn't exist and appends a
    single row specified by result_dict
    """
    path = os.path.join(dirname, filename)

    with open(path, 'a') as fp:
        csv_writer = csv.writer(fp)
        if os.path.getsize(path) == 0:
            csv_writer.writerow(column_names)

        csv_writer.writerow([result_dict[key] for key in column_names])


def print_csv(csv_dir, port_results, flow_results):
    # TODO: needs refactoring
    folder_path = os.path.join(csv_dir, "portstats")
    # don't use exist_ok - since it's not supported in python2
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    folder_path = os.path.join(csv_dir, "flowstats")
    # don't use exist_ok - since it's not supported in python2
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    # PortStat Fetch
    if port_results is not None:
        for port in port_results:
            csv_file = os.path.join(
                csv_dir, "portstats", port.name + "_port_stats.csv"
            )
            with open(csv_file, 'a') as csvfile:
                csv_writer = csv.writer(csvfile)
                if os.path.getsize(csv_file) == 0:
                    port_stat_columns = [
                        'timestamp', 'name', 'location', 'link', 'frames_tx',
                        'frames_rx', 'bytes_tx', 'bytes_rx', 'frames_tx_rate',
                        'frames_rx_rate', 'bytes_tx_rate',
                        'bytes_rx_rate'
                    ]
                    csv_writer.writerow(port_stat_columns)
                port_stat = [
                    str(datetime.now()),
                    port.name,
                    port.location,
                    port.link,
                    port.frames_tx,
                    port.frames_rx,
                    port.bytes_tx,
                    port.bytes_rx,
                    port.frames_tx_rate,
                    port.frames_rx_rate,
                    port.bytes_tx_rate,
                    port.bytes_rx_rate
                ]
                csv_writer.writerow(port_stat)

    # FlowStat Fetch
    if flow_results is not None:
        for flow in flow_results:
            csv_file = os.path.join(
                csv_dir, "flowstats", flow.name + "_flow_stats.csv"
            )
            with open(csv_file, 'a') as csvfile:
                csv_writer = csv.writer(csvfile)
                if os.path.getsize(csv_file) == 0:
                    flow_stat_columns = [
                        'timestamp',
                        'name',
                        'transmit',
                        'port_tx',
                        'port_rx',
                        'frames_tx',
                        'bytes_tx',
                        'frames_tx_rate',
                        'frames_rx',
                        'bytes_rx',
                        'frames_rx_rate',
                        'loss'
                    ]
                    csv_writer.writerow(flow_stat_columns)
                flow_stat = [
                    str(datetime.now()),
                    flow.name,
                    flow.transmit,
                    str(flow.port_tx),
                    str(flow.port_rx),
                    flow.frames_tx,
                    flow.bytes_tx,
                    flow.frames_tx_rate,
                    flow.frames_rx,
                    flow.bytes_rx,
                    flow.frames_rx_rate,
                    flow.loss
                ]
                csv_writer.writerow(flow_stat)


def print_stats(port_stats=None, flow_stats=None, clear_screen=None):
    if clear_screen is None:
       clear_screen = settings.dynamic_stats_output

    # if clear_screen:
    #    os.system('clear')

    if port_stats:
        row_format = "{:>15}" * 9
        border = '-' * (15 * 9 + 5)
        print('\nPort Stats')
        print(border)
        print(
            row_format.format(
                'Port', 
                'Tx Frames', 'Rx Frames', 
                'Tx Bytes', 'Rx Bytes',
                'Tx FPS', 'Rx FPS',
                'Tx Bytes Rate', 'Rx Bytes Rate'
            )
        )
        for stat in port_stats:
            print(
                row_format.format(
                    stat.name, 
                    stat.frames_tx, stat.frames_rx, 
                    stat.bytes_tx, stat.bytes_rx,
                    stat.frames_tx_rate, stat.frames_rx_rate,
                    stat.bytes_tx_rate, stat.bytes_rx_rate
                )
            )
        print(border)
        print("")
        print("")

    if flow_stats:
        latency = False
        timestamps = False
        for stat in flow_stats:
            stat_fields = list((stat._properties).keys())
            if 'latency' in stat_fields:
                latency = True
            if 'timestamps' in stat_fields:
                timestamps = True

        flow_stat_header = [
            'Flow', 
            'Tx Frames', 'Rx Frames',
            'Tx Bytes', 'Rx Bytes',
            'Tx FPS', 'Rx FPS',
            #'Transmit State',
            'Lost frames',
            'Loss']
        flow_latency_header = [
            'Min Latency',
            'Avg Latency',
            'Max Latency'
        ]
        flow_timestamp_header = [
            'First Timestamp',
            'Last Timestamp'
        ]
        if latency:
            flow_stat_header.extend(flow_latency_header)
        if timestamps:
            flow_stat_header.extend(flow_timestamp_header)

        row_format = "{:>18}" * len(flow_stat_header)
        border = '-' * (18 * len(flow_stat_header) + 5)
        print('\nFlow Stats')
        print(border)
        print(
            row_format.format(*flow_stat_header)
        )
        for stat in flow_stats:
            stat_fields = list((stat._properties).keys())
            flow_stat_values = [
                stat.name,
                stat.frames_tx, stat.frames_rx,
                stat.bytes_tx, stat.bytes_rx,
                stat.frames_tx_rate, stat.frames_rx_rate,
                # stat.transmit,
                stat.frames_tx - stat.frames_rx,
                str(round((stat.frames_tx - stat.frames_rx) * 100 / stat.frames_tx, 3)) + " %"
            ]
            if latency:
                latency_stat_values = [
                    'None',
                    'None',
                    'None'
                ]
                if 'latency' in stat_fields:
                    latency_stat_values = [
                        stat.latency.minimum_ns,
                        stat.latency.average_ns,
                        stat.latency.maximum_ns
                    ]

                flow_stat_values.extend(latency_stat_values)

            if timestamps:
                timestamp_stat_values = [
                    'None',
                    'None',
                    'None'
                ]
                if 'timestamps' in stat_fields:
                    timestamp_stat_values = [
                        stat.timestamps.first_timestamp_ns,
                        stat.timestamps.last_timestamp_ns
                    ]

                flow_stat_values.extend(timestamp_stat_values)
            print(
                row_format.format(*flow_stat_values)
            )
        print(border)
        print("")
        print("")


def flow_transmit_matches(flow_results, state):
    return len(flow_results) == len(
        list(filter(lambda f: f.transmit == state, flow_results))
    )


def total_frames_ok(port_results, flow_results, expected):
    port_tx = sum([p.frames_tx for p in port_results])
    port_rx = sum([p.frames_rx for p in port_results])
    flow_rx = sum([f.frames_rx for f in flow_results])

    return port_tx == flow_rx == expected and port_rx >= expected


def total_bytes_ok(port_results, flow_results, expected):
    port_tx = sum([p.bytes_tx for p in port_results])
    port_rx = sum([p.bytes_rx for p in port_results])
    flow_rx = sum([f.bytes_rx for f in flow_results])

    return port_tx == flow_rx == expected and port_rx >= expected


def total_bytes_in_frame_size_range(start, end, step, count):
    """
    Returns total bytes after summing up all frame sizes in the given range.
    """
    pkt_count = 0
    total_bytes = 0
    partial_bytes = 0
    for i in range(start, end + 1, step):
        total_bytes += i
        pkt_count += 1
    total_count = int(count / pkt_count)
    partial_count = count % pkt_count
    n = 0
    for i in range(start, end + 1, step):
        if n == partial_count:
            break
        partial_bytes += i
        n += 1

    return total_bytes * total_count + partial_bytes


def get_current_speed_g():
    if settings.speed == 'speed_1_gbps':
        return 1
    elif settings.speed == 'speed_10_gbps':
        return 10
    elif settings.speed == 'speed_25_gbps':
        return 25
    elif settings.speed == 'speed_40_gbps':
        return 40
    elif settings.speed == 'speed_50_gbps':
        return 50
    elif settings.speed == 'speed_100_gbps':
        return 100
    elif settings.speed == 'speed_200_gbps':
        return 200
    elif settings.speed == 'speed_400_gbps':
        return 400
    elif settings.speed in ['speed_100_fd_mbps', 'speed_100_hd_mbps']:
        return 0.1
    elif settings.speed in ['speed_10_fd_mbps', 'speed_10_hd_mbps']:
        return 0.01

    return 1


def get_frame_size_max_pps_tuples(start, end, step=64, include_1518=True):
    """
    returns a tuples (frame size, PPS) for each frame size in given range
    """
    tuples = []
    speed = get_current_speed_g()
    while start <= end:
        tuples.append((start, get_pps(start, speed)))
        start += step

    if include_1518:
        tuples.append((1518, get_pps(1518, speed)))

    return tuples


def get_pps(size, speed_g, line_rate=100):
    return speed_g * 10000000 * line_rate // ((size + 8 + 12) * 8)


def get_frame_size_min_pps_tuples(csv_file):
    """
    returns a tuples (frame size, PPS) for each frame size in given range
    """
    tuples = []
    with open(csv_file) as csvfile:
        csv_reader = csv.reader(csvfile, delimiter=',')
        next(csv_reader)
        for row in csv_reader:
            tuples.append((int(float(row[3])), int(float(row[7]))))

    return tuples


def get_baseline_csv_path():
    return os.path.join(get_root_dir(), TEST_DIR, BASELINE_CSV)


def get_island(name):
    testfile = 'test_' + name + '.py'
    tests_dir = get_root_dir()

    for dp, dn, filenames in os.walk(tests_dir):
        for f in filenames:
            if f == testfile:
                location = os.path.join(dp, f)
                island_path = os.path.dirname(location)
                island_name = island_path.split(os.path.sep)[-1]
                return island_name
    raise Exception('{}: No found'.format(testfile))


def get_baseline_details(name):
    """
    return row list for given test case from baseline.csv in list of dicts
    """

    baseline_dict = dict()
    path = get_baseline_csv_path()

    baseline_rows = csv.DictReader(open(path))
    baseline_row_list = []
    for baseline_row in baseline_rows:
        baseline_row_list.append(dict(baseline_row))
    testcase_found = False
    for row in baseline_row_list:
        if testcase_found and row['testcase']:
            break
        elif testcase_found or row['testcase'] == name:
            testcase_found = True
            stat_name = row['StatName']
            operation = row['Operation']
            value = float(row['Value'])

            if stat_name not in list(baseline_dict.keys()):
                baseline_dict[stat_name] = dict()
            baseline_dict[stat_name][operation] = {
                'value': value
            }
        else:
            continue

    return baseline_dict


def get_percentile(values, percent):
    array = numpy.array(values)
    print(array)
    percentile = numpy.percentile(array, percent)
    return percentile


def compare_with_baseline(baseline, result):
    compare_list = []
    campare_count = 0
    pass_count = 0
    overall_compare_status = 'FAILED'
    for stat_name, stat_info in list(baseline.items()):
        for operation_name, operation_info in list(stat_info.items()):
            expected_value = operation_info['value']
            output = None
            outcome = None
            output_tolerance = None
            campare_count += 1
            if 'percentile' in operation_name:
                percent = int(operation_name.split('_')[0])
                output = get_percentile(result[stat_name], percent)

            if output <= expected_value:
                outcome = 'PASSED'
                pass_count += 1
            else:
                outcome = 'FAILED'

            if output >= expected_value:
                output_tolerance = (
                    (output - expected_value) / expected_value) * 100
            else:
                output_tolerance = (
                    (expected_value - output) / expected_value) * 100 * -1

            print('{} - {} - {} - {}%- {}'.format(stat_name,
                                                  operation_name,
                                                  output,
                                                  output_tolerance,
                                                  outcome))

            compare_result = {
                'StatName': stat_name,
                'Operation': operation_name,
                'Value': expected_value,
                'Output': output,
                'Output Tolerance': output_tolerance,
                'Outcome': outcome
            }

            compare_list.append(compare_result)

    if campare_count > pass_count:
        overall_compare_status
    return compare_list, overall_compare_status


def exec_shell_over_ssh(host, user, passwd, cmd, return_status=True):
    """
    Executes a command in native shell over doing ssh to given host and returns output as str on success or,
    None on error.
    """  # noqa
    cmd = "sshpass -p '{}' ssh -o StrictHostKeyChecking=no {}@{} {}".format(
        passwd, user, host, cmd
    )

    out = exec_shell(cmd, check_return_code=return_status, passwd=passwd)
    if out is None:
        raise Exception('Failed to execute cmd {}'.format(
            cmd
        ))
    else:
        return out


def exec_shell(cmd, sudo=True, check_return_code=True, passwd=None):
    """
    Executes a command in native shell and returns output as str on success or,
    None on error.
    """
    if not sudo:
        cmd = 'sudo -u ' + SUDO_USER + ' ' + cmd

    print('Executing `%s` ...' % cmd)

    if passwd is not None:
        passwd_cmd = subprocess.Popen(['echo', passwd], stdout=subprocess.PIPE)
        p = subprocess.Popen(
            cmd.encode('utf-8', errors='ignore'),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
            stdin=passwd_cmd.stdout
        )
    else:
        p = subprocess.Popen(
            cmd.encode('utf-8', errors='ignore'),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
        )
    out, _ = p.communicate()
    out = out.decode('utf-8', errors='ignore')

    print('Output:\n%s' % out)

    if check_return_code:
        if p.returncode == 0:
            return out
        return None
    else:
        return out


def copy_file_to_remote(host, port, user, passwd, source, destination=""):
    """
    Executes a command in native shell over doing ssh to given host and returns output as str on success or,
    None on error.
    """  # noqa
    cmd = "sshpass -p {} scp -o StrictHostKeyChecking=no -r {} {}@{}:/home/{}/{}".format(  # noqa
        passwd, source, user, host, user, destination
    )
    if port:
        cmd = "sshpass -p {} scp -P {} -o StrictHostKeyChecking=no -r {} {}@{}:/home/{}/{}".format(  # noqa
            passwd, port, source, user, host, user, destination
        )

    out = exec_shell(cmd)
    if out is None:
        raise Exception('Failed to execute cmd {}'.format(
            cmd
        ))
    else:
        return out


def copy_file_from_remote(host, port, user, passwd, source, destination):
    """
    Executes a command in native shell over doing ssh to given host and returns output as str on success or,
    None on error.
    """  # noqa
    cmd = "sshpass -p {} scp -o StrictHostKeyChecking=no -r {}@{}:/home/{}/{} {}".format(  # noqa
        passwd, user, host, user, source, destination
    )
    if port:
        cmd = "sshpass -p {} scp -P {} -o StrictHostKeyChecking=no -r {}@{}:/home/{}/{} {}".format(  # noqa
            passwd, port, user, host, user, source, destination
        )

    out = exec_shell(cmd)
    if out is None:
        raise Exception('Failed to execute cmd {}'.format(
            cmd
        ))
    else:
        return out


def push_config_to_dut(settings, dut_config_json):
    dut_home_dir = "/home/keysight/ixia-c/internal-dut/"
    dut_cfg_file_location = dut_home_dir + "config/config.json"
    if not os.path.exists(dut_config_json):
        dut_config_json = get_test_config_path(dut_config_json)

    dut_host = settings.soft_dut.split(":")[0]
    dut_ssh_port = settings.soft_dut.split(":")[1]
    cmd = "sshpass -p admin scp -P {} -o StrictHostKeyChecking=no -r {} admin@{}:{}".format(  # noqa
        dut_ssh_port, dut_config_json, dut_host, dut_cfg_file_location,
    )
    out = exec_shell(cmd)
    if out is None:
        raise Exception('Failed to execute cmd {}'.format(
            cmd
        ))

    # just for safety: allowing dut to consume and act on the config
    time.sleep(2)


def get_tx_port_info(config, tx_port_info):
    if len(config.ports) == 0:
        raise Exception("No ports found in configuration...")

    for port in config.ports:
        if port.name == "tx":
            tx_port_info["host"] = port.location.split(':')[0]
            tx_port_info["port"] = port.location.split(':')[1]

    if not tx_port_info["host"] or not tx_port_info["port"]:
        raise Exception("Host/Port is not found....")

    cmd = "sudo -S docker ps | grep 'ixia-c-traffic-engine' | awk '{ print $1 }'"  # noqa
    res = exec_shell_over_ssh(
        tx_port_info['host'],
        tx_port_info['user'],
        tx_port_info['pass'],
        cmd
    )
    container_list = res.split('\n')
    if len(container_list) == 1:
        raise Exception("No such traffic-engine container found on host {}".format(  # noqa
            tx_port_info['host']
        ))

    for container in container_list[:len(container_list) - 1]:  # noqa
        cmd = "sudo -S sudo docker inspect {} | grep OPT_LISTEN_PORT=".format(
            container)
        res = (exec_shell_over_ssh(
            tx_port_info['host'],
            tx_port_info['user'],
            tx_port_info['pass'],
            cmd)).strip()
        assigned_port = ((res.replace(',', "")).replace('"', "")).replace(
            "OPT_LISTEN_PORT=", "")
        if assigned_port == tx_port_info['port']:
            tx_port_info['container_id'] = container
            cmd = "sudo -S sudo docker inspect -f {{.State.Pid}} " + container  # noqa
            pid = (exec_shell_over_ssh(
                tx_port_info['host'],
                tx_port_info['user'],
                tx_port_info['pass'],
                cmd)).strip()
            tx_port_info['process_id'] = pid

    if not tx_port_info['container_id']:
        raise Exception("No such TE container bound with port {}".format(
            container
        ))

    print("TX port details : {}".format(
        tx_port_info
    ))
    return tx_port_info


def get_container_ids():
    container_details = {}
    cmd = 'docker ps -a'
    out = exec_shell(cmd).split('\n')

    container_list = out[1:len(out) - 1]

    print(container_list)

    if len(container_list) != 3:
        raise Exception('There should be three container for CTR ,TE, AUR')

    for container in container_list:
        details_list = container.split(' ')
        container_name = None
        for detail in details_list:
            if detail.startswith('athena'):
                container_name = detail
                break

        if container is None:
            raise Exception('Container name should start with athena')

        container_name = container_name.split(":")[0].split('/')[1]

        if container_name not in list(container_details.keys()):
            container_details[container_name] = details_list[0]

    print(container_details)
    return container_details


def get_free_space_by_cont_id(container_id):
    cmd = 'docker exec -it %s free' % container_id

    out = exec_shell(cmd)

    if out is None:
        raise Exception('Failed to get memory details of container {}'.format(
            container_id
        ))

    out_details = out.split('\n')
    header_details = out_details[0].split(' ')
    headers = []

    for header in header_details:
        if header != '':
            headers.append(header)

    memory_details = out_details[1].split(' ')

    if not memory_details[0].startswith('Mem:'):
        raise Exception('Could not find Mem row in memory details')

    memory_details = memory_details[1:]
    mem_info = []

    for mem in memory_details:
        if mem != '':
            mem_info.append(mem)

    free_mem_index = headers.index('free')
    free_mem_value = mem_info[free_mem_index]

    return free_mem_value


def mac_addr(address):
    """Convert a MAC address to a readable/printable string

       Args:
           address (str): a MAC address in hex form (e.g. '\x01\x02\x03\x04\x05\x06') # noqa
       Returns:
           str: Printable/readable MAC address
    """
    return ':'.join('%02x' % dpkt.compat.compat_ord(b) for b in address)


def inet_to_str(inet):
    """Convert inet object to a string

        Args:
            inet (inet struct): inet network address
        Returns:
            str: Printable/readable IP address
    """
    # First try ipv4 and then ipv6
    try:
        return socket.inet_ntop(socket.AF_INET, inet)
    except ValueError:
        return socket.inet_ntop(socket.AF_INET6, inet)


def get_config_ok(api, exp_config):
    act_config = api.get_config()
    act_config = act_config.serialize(
        encoding='dict'
    )
    if not isinstance(exp_config, dict):
        exp_config = exp_config.serialize(
            encoding='dict'
        )
    assert is_subset(
        act_config,
        exp_config
    ), "GetConfig Mismatched!!!"


def check_eq(mast_dict, subdict):
    if not isinstance(mast_dict, (dict, list)):
        return mast_dict == subdict
    if isinstance(mast_dict, list):

        # check for nesting dictionaries in list
        return all(check_eq(x, y) for x, y in zip(mast_dict, subdict))

    # check for all keys
    return all(mast_dict.get(idx) == subdict[idx] or check_eq(
        mast_dict.get(idx), subdict[idx]) for idx in subdict)


def is_subset(mast_dict, subdict):
    if isinstance(mast_dict, list):

        # any matching dictionary in list
        return any(is_subset(idx, subdict) for idx in mast_dict)

    # any matching nested dictionary
    return check_eq(mast_dict, subdict) or (
        isinstance(mast_dict, dict) and any(
            is_subset(y, subdict) for y in mast_dict.values()))


def get_error_details(api, exception):
    err = api.from_exception(exception)
    if err is not None:
        return err.code, err.kind, err.errors
    else:
        return 0, "non-otg", [str(exception)]


def assert_errors(
        api,
        exception,
        expected_http_error_code,
        expected_grpc_error_code,
        expected_error_kind,
        expected_errors):
    error_code, error_kind, errors = get_error_details(api, exception)

    assert expected_http_error_code == error_code or expected_grpc_error_code == error_code, "wrong error code {} received".format(  # noqa
        error_code
    )

    assert expected_error_kind == error_kind, "expected error kind {} - got {}".format(  # noqa
        expected_error_kind,
        error_kind
    )

    for expected_error in expected_errors:
        found = False
        for error in errors:
            if expected_error.lower() in error.lower():
                found = True
                break
        if not found:
            raise Exception("{} not found in errors {}".format(  # noqa
                expected_error,
                errors)
            )
