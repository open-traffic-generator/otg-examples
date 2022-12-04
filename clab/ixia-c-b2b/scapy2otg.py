import snappi
from scapy.all import *

def port_metrics_ok(api, req, packets):
    res = api.get_metrics(req)
    print(res)
    if packets == sum([m.frames_tx for m in res.port_metrics]) and packets == sum([m.frames_rx for m in res.port_metrics]):
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

api = snappi.api(location='https://clab-ixcb2b-ixia-c:8443', verify=False)
cfg = api.config()

# config has an attribute called `ports` which holds an iterator of type
# `snappi.PortIter`, where each item is of type `snappi.Port` (p1 and p2)
p1, p2 = cfg.ports.port(name="p1", location="eth1").port(name="p2", location="eth2")

# config has an attribute called `captures` which holds an iterator of type
# `snappi.CaptureIter`, where each item is of type `snappi.Capture` (cp)
cp = cfg.captures.capture(name="cp")[-1]
cp.port_names = [p1.name, p2.name]

# custom flow from scapy
packets1 = [
        IP(src="10.0.0.1", dst="10.0.0.2")/UDP(sport=1024, dport=53)/DNS(
            id=0,
            rd=1, 
            qr=0, 
            qd=DNSQR(
                qtype="A", 
                qname="example.com"
            )
        ),
        IP(src="10.0.0.1", dst="10.0.0.2")/UDP(sport=1024, dport=53)/DNS(
            id=1,
            rd=1, 
            qr=0, 
            qd=DNSQR(
                qtype="AAAA", 
                qname="example.com"
            )
        ),
    ]
packets2 = [
        IP(src="10.0.0.2", dst="10.0.0.1")/UDP(sport=53, dport=1024)/DNS(
            id=0,
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
        IP(src="10.0.0.2", dst="10.0.0.1")/UDP(sport=53, dport=1024)/DNS(
            id=1,
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

# flows p1 -> p2
for i in range(len(packets1)):
    n = "f1-" + str(i)
    f = cfg.flows.flow(name=n)[-1]
    f.tx_rx.port.tx_name, f.tx_rx.port.rx_name = p1.name, p2.name
    f.packet.ethernet().custom()
    eth = f.packet[0]
    eth.src.value, eth.dst.value = "00:AA:00:00:04:00", "00:AA:00:00:00:AA"
    eth.ether_type.value = 0x0800 #IPv4
    payload = f.packet[1]
    payload.bytes = packets1[i].build().hex()
    # send 1 packet per each flow
    f.duration.fixed_packets.packets = 1
    # delay between flows to simulate a sequence of packets: 1ms
    f.duration.fixed_packets.delay.microseconds = 1000 * i
    # allow fetching flow metrics
    f.metrics.enable = True

# flows p2 -> p1
for i in range(len(packets2)):
    n = "f2-" + str(i)
    f = cfg.flows.flow(name=n)[-1]
    f.tx_rx.port.tx_name, f.tx_rx.port.rx_name = p2.name, p1.name
    f.packet.ethernet().custom()
    eth = f.packet[0]
    eth.src.value, eth.dst.value = "00:AA:00:00:00:AA", "00:AA:00:00:04:00"
    eth.ether_type.value = 0x0800 #IPv4
    payload = f.packet[1]
    payload.bytes = packets2[i].build().hex()
    # send 1 packet per each flow
    f.duration.fixed_packets.packets = 1
    # delay between flows to simulate a sequence of packets: 1ms, plus initial 500us to simulate a response
    f.duration.fixed_packets.delay.microseconds = 1000 * i + 500
    # allow fetching flow metrics
    f.metrics.enable = True

# print resulting otg configuration
print(cfg)

# push configuration to controller
api.set_config(cfg)

# start packet capture on configured ports
cs = api.capture_state()
cs.state = cs.START
api.set_capture_state(cs)

# start transmitting configured flows
ts = api.transmit_state()
ts.state = ts.START
api.set_transmit_state(ts)

# create a port metrics request and filter based on port names
req = api.metrics_request()
req.flow.flow_names = [f.name for f in cfg.flows]

# fetch port metrics
res = api.get_metrics(req)

# wait for port metrics to be as expected
expected = sum([f.duration.fixed_packets.packets for f in cfg.flows])
assert wait_for(lambda: flow_metrics_ok(api, req, expected)), "Metrics validation failed!"

for p in cfg.ports:
    # create capture request and filter based on port name
    req = api.capture_request()
    req.port_name = p.name
    # fetch captured pcap bytes and write it to pcap
    pcap_bytes = api.get_capture(req)
    with open(p.name + '.pcap', 'wb') as p:
        p.write(pcap_bytes.read())