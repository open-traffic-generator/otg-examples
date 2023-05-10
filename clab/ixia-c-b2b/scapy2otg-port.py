import os
import snappi
from scapy.all import *

def port_metrics_ok(api, req, packets):
    res = api.get_metrics(req)
    print(res)
    if packets == sum([m.frames_tx for m in res.port_metrics]) and packets <= sum([m.frames_rx for m in res.port_metrics]):
        return True

def flow_metrics_ok(api, req, packets):
    res = api.get_metrics(req)
    print(res)
    if packets == sum([m.frames_tx for m in res.flow_metrics]) and packets == sum([m.frames_rx for m in res.flow_metrics]):
        return True

def wait_for(func, timeout=15, interval=0.2):
    """
    Keeps calling the `func` until it returns true or `timeout` occurs
    every `interval` seconds.
    """
    import time

    start = time.time()

    while time.time() - start <= timeout:
        if func():
            return True
        time.sleep(interval)

    print("Timeout occurred !")
    return False

OTG_API=os.environ.get('OTG_API')
if OTG_API == None:
   OTG_API = "https://localhost:8443"

P1_LOCATION=os.environ.get('OTG_LOCATION_P1')
if P1_LOCATION == None:
   P1_LOCATION = "localhost:5555"

P2_LOCATION=os.environ.get('OTG_LOCATION_P2')
if P2_LOCATION == None:
   P2_LOCATION = "localhost:5556"

api = snappi.api(location=OTG_API, verify=False)
cfg = api.config()

# config has an attribute called `ports` which holds an iterator of type
# `snappi.PortIter`, where each item is of type `snappi.Port` (p1 and p2)
p1, p2 = cfg.ports.port(name="p1", location=P1_LOCATION).port(name="p2", location=P2_LOCATION)

# config has an attribute called `captures` which holds an iterator of type
# `snappi.CaptureIter`, where each item is of type `snappi.Capture` (cp)
cp = cfg.captures.capture(name="cp")[-1]
cp.port_names = [p1.name, p2.name]

# create custom payloads with scapy
requests = [
        DNS(
            id=0,
            rd=1,
            qr=0,
            qd=DNSQR(
                qtype="A",
                qname="example.com"
            )
        ),
        DNS(
            id=1,
            rd=1,
            qr=0,
            qd=DNSQR(
                qtype="AAAA",
                qname="example.com"
            )
        ),
    ]
responses = [
        DNS(
            id=requests[0][DNS].id,
            qd=requests[0][DNS].qd,
            rd=1,
            qr=1,
            ra=1,
            qdcount=1,
            ancount=1,
            ar=DNSRR(
                type="A",
                rrname="example.com",
                ttl=600,
                rdata="1.1.1.1"
            )
        ),
        DNS(
            id=requests[1][DNS].id,
            qd=requests[1][DNS].qd,
            rd=1,
            qr=1,
            ra=1,
            qdcount=1,
            ancount=1,
            ar=DNSRR(
                type="AAAA",
                rrname="example.com",
                ttl=600,
                rdata="1111:2222:3333:444::5555"
            )
        ),
    ]

# send 10 packets per each flow
packet_count = 10

# flows for requests
for i in range(len(requests)):
    n = "request" + str(i)
    f = cfg.flows.flow(name=n)[-1]
    # will use UDP with custom payload
    eth, ip, udp, payload = f.packet.ethernet().ipv4().udp().custom()
    eth.src.value, eth.dst.value = "02:00:00:00:01:AA", "02:00:00:00:02:AA"
    ip.src.value, ip.dst.value = "192.0.2.1", "192.0.2.2"
   # increment UDP source port number for each packet
    udp.src_port.increment.start = 1024
    udp.src_port.increment.step = 1
    udp.src_port.increment.count = packet_count
    udp.dst_port.value = 53
    # copy a payload from Scapy packet into a snappi flow
    payload.bytes = requests[i].build().hex()
    # number of packets to transmit
    f.duration.fixed_packets.packets = packet_count
    # delay between flows to simulate a sequence of packets: 1ms
    f.duration.fixed_packets.delay.microseconds = 1000 * i
    # allow fetching flow metrics
    f.metrics.enable = False
    # transmit from p1, expect on p2
    f.tx_rx.port.tx_name, f.tx_rx.port.rx_name = p1.name, p2.name

# flows p2 -> p1
for i in range(len(responses)):
    n = "response" + str(i)
    f = cfg.flows.flow(name=n)[-1]
    # will use UDP with custom payload
    eth, ip, udp, payload = f.packet.ethernet().ipv4().udp().custom()
    eth.src.value, eth.dst.value = "02:00:00:00:02:AA", "02:00:00:00:01:AA"
    ip.src.value, ip.dst.value = "192.0.2.2", "192.0.2.1"
    # increment UDP destination port number for each packet
    udp.dst_port.increment.start = 1024
    udp.dst_port.increment.step = 1
    udp.dst_port.increment.count = packet_count
    udp.src_port.value = 53
    # copy a payload from Scapy packet into a snappi flow
    payload.bytes = responses[i].build().hex()
    # number of packets to transmit
    f.duration.fixed_packets.packets = packet_count
    # delay between flows to simulate a sequence of packets: 1ms, plus initial 500us to simulate a response
    f.duration.fixed_packets.delay.microseconds = 1000 * i + 500
    # allow fetching flow metrics
    f.metrics.enable = False
    # transmit from p2, expect on p1
    f.tx_rx.port.tx_name, f.tx_rx.port.rx_name = p2.name, p1.name

# print resulting otg configuration
print(cfg)

# push configuration to controller
api.set_config(cfg)

# start packet capture on configured ports
cs = api.control_state()
cs.port.capture.state = cs.port.capture.START
cs.port.capture.port_names = cp.port_names
api.set_control_state(cs)

# start transmitting configured flows
ts = api.control_state()
ts.traffic.flow_transmit.state = ts.traffic.flow_transmit.START
api.set_control_state(ts)

# create a metrics request
req = api.metrics_request()
req.port.port_names = [p.name for p in cfg.ports]

# fetch metrics
res = api.get_metrics(req)

# wait for metrics to be as expected
expected = sum([f.duration.fixed_packets.packets for f in cfg.flows])
assert wait_for(lambda: port_metrics_ok(api, req, expected)), "Metrics validation failed!"

for p in cfg.ports:
    # create capture request and filter based on port name
    req = api.capture_request()
    req.port_name = p.name
    # fetch captured pcap bytes and write it to pcap
    pcap_bytes = api.get_capture(req)
    with open(p.name + '.pcap', 'wb') as p:
        p.write(pcap_bytes.read())