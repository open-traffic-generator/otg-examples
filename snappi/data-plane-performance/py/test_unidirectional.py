import utils
import time
import datetime

custom_round = lambda value: value if value < 0.001 else round(value, 3)

def test_unidirectional(api, duration, frame_size, line_rate_per_flow, direction):
    """
    Configure a single unidirectional flow
    """
    cfg = utils.load_test_config(
        api, 'unidirectional.json', apply_settings=True
    )

    if direction == "downstream":
        # change direction
        for flow in cfg.flows:
            flow.tx_rx.port.rx_names[0], flow.tx_rx.port.tx_name = flow.tx_rx.port.tx_name, flow.tx_rx.port.rx_names[0]
            flow.packet[0].dst.value, flow.packet[0].src.value = flow.packet[0].src.value, flow.packet[0].dst.value 
            flow.packet[1].dst.value, flow.packet[1].src.value = flow.packet[1].src.value, flow.packet[1].dst.value 

    TIMEOUT = 5

    MAX_FRAME_SIZE = 9000
    MIN_FRAME_SIZE = 64
    
    MAX_LINE_RATE_PER_FLOW = 100

    MIN_DURATION = 1

    if frame_size > MAX_FRAME_SIZE:
        print("The frame size exceeds the maximum {}B size!".format(MAX_FRAME_SIZE))
        print("\tThe frame size will be set at {}B.".format(MAX_FRAME_SIZE))
        frame_size = MAX_FRAME_SIZE

    if frame_size < MIN_FRAME_SIZE:
        print("The frame size exceeds the minimum {}B size!".format(MIN_FRAME_SIZE))
        print("\tThe frame size will be set at {}B.".format(MIN_FRAME_SIZE))
        frame_size = MIN_FRAME_SIZE

    if line_rate_per_flow > MAX_LINE_RATE_PER_FLOW:
        print("The requested line rate per flow exceeds the total capacity!")
        print("\tThe line rate per flow percentage will be set at {}%.".format(MAX_LINE_RATE_PER_FLOW))
        line_rate_per_flow = MAX_LINE_RATE_PER_FLOW

    if duration < MIN_DURATION:
        print("The duration exceeds the minimum {}s !".format(MIN_DURATION))
        print("\tThe duration will be set at {}s.".format(MIN_DURATION))
        duration = MIN_DURATION 

    print("\n\nConfiguring each flow with:\n" \
            "   Frame size:           {}B\n" \
            "   Direction:            {}\n" \
            "   Duration:             {}s\n" \
            "   Line rate percentage: {}%\n".format(frame_size, direction, duration, line_rate_per_flow))
    time.sleep(2)

    for flow in cfg.flows:
        flow.duration.fixed_seconds.seconds = duration
        flow.size.fixed = frame_size
        flow.rate.percentage = line_rate_per_flow

    sizes = []
    size = cfg.flows[0].size.fixed

    inner_header = cfg.flows[0].packet[-1]
    start_timestamp = datetime.datetime.utcnow()

    utils.start_traffic(api, cfg)
    utils.wait_for(
        lambda: results_ok(api, size),
        'stats to be as expected',
        timeout_seconds=duration + TIMEOUT
    )
    utils.stop_traffic(api, cfg)   

    _, flow_results = utils.get_all_stats(api)
    flows_total_tx = sum([flow_res.frames_tx for flow_res in flow_results])
    flows_total_rx = sum([flow_res.frames_rx for flow_res in flow_results])
    print("\n\nTest start time: {}. Duration: {} seconds.".format(start_timestamp.strftime('%Y-%m-%d %H:%M:%S UTC'), duration))
    print("Flows: {}. Line rate per flow: {}%. Direction: {}.".format(len(cfg.flows),  line_rate_per_flow, direction))
    print("Frame size {}B. Packet inner header {}".format(frame_size, type(inner_header).__name__))

    print("\nAverage total TX L2 rate {} Gbps".format(round(flows_total_tx * size * 8 / duration / 1000000000, 3)))
    print("Average total RX L2 rate {} Gbps".format(round(flows_total_rx * size * 8 / duration / 1000000000, 3)))
    print("Average total TX packet rate: {} Mpps".format(round(flows_total_tx / duration / 1000000, 3)))
    print("Average total RX packet rate: {} Mpps".format(round(flows_total_rx / duration / 1000000, 3)))
    print("Total lost packets {}".format(flows_total_tx - flows_total_rx))
    print("Average loss percentage {} %".format(custom_round((flows_total_tx - flows_total_rx) * 100 / flows_total_tx)))

def results_ok(api, size, csv_dir=None):
    """
    Returns true if stats are as expected, false otherwise.
    """
    port_results, flow_results = utils.get_all_stats(api)
    if csv_dir is not None:
        utils.print_csv(csv_dir, port_results, flow_results)
    port_tx = sum([p.frames_tx for p in port_results])
    port_rx = sum([p.frames_rx for p in port_results if p.name == 'rx'])
    ok = True
    print('-' * 22)
    for flow_res in flow_results:
        print(flow_res.name + " " + str(size) + "B:")
        print("TX Rate " + str(round(flow_res.frames_tx_rate * size * 8 / 1000000000, 3)) + " Gbps")
        print("RX Rate " + str(round(flow_res.frames_rx_rate * size * 8 / 1000000000, 3)) + " Gbps")
    print('-' * 22)
    print('\n\n\n\n\n')
    
    if utils.flow_metric_validation_enabled():
        flow_tx = sum([f.frames_tx for f in flow_results])
        flow_tx_bytes = sum([f.bytes_tx for f in flow_results])
        flow_rx = sum([f.frames_rx for f in flow_results])
        flow_rx_bytes = sum([f.bytes_rx for f in flow_results])

    return ok and all(
        [f.transmit == 'stopped' for f in flow_results]
    )
