#!/usr/bin/env python3

# Copyright © 2023 Open Traffic Generator
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import sys, os
import snappi

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

def main():
    """
    Main function
    """
    API=os.environ.get('OTG_API')
    if API == None:
        API = "https://localhost:8443"

    P1_LOCATION=os.environ.get('OTG_LOCATION_P1')
    if P1_LOCATION == None:
        P1_LOCATION = "localhost:5555"

    P2_LOCATION=os.environ.get('OTG_LOCATION_P2')
    if P2_LOCATION == None:
        P2_LOCATION = "localhost:5556"

    api = snappi.api(location=API, verify=False)
    cfg = api.config()

    # config has an attribute called `ports` which holds an iterator of type
    # `snappi.PortIter`, where each item is of type `snappi.Port` (p1 and p2)
    p1, p2 = cfg.ports.port(name="p1", location=P1_LOCATION).port(name="p2", location=P2_LOCATION)

    # config has an attribute called `flows` which holds an iterator of type
    # `snappi.FlowIter`, where each item is of type `snappi.Flow` (f1, f2)
    f1, f2 = cfg.flows.flow(name="flow p1->p2").flow(name="flow p2->p1")

    # and assign source and destination ports for each
    f1.tx_rx.port.tx_name, f1.tx_rx.port.rx_name = p1.name, p2.name
    f2.tx_rx.port.tx_name, f2.tx_rx.port.rx_name = p2.name, p1.name

    # configure packet size, rate and duration for both flows
    f1.size.fixed, f2.size.fixed = 128, 256
    for f in cfg.flows:
        # send 1000 packets and stop
        f.duration.fixed_packets.packets = 1000
        # send 1000 packets per second
        f.rate.pps = 1000
        # allow fetching flow metrics
        f.metrics.enable = True

    # configure packet with Ethernet, IPv4 and UDP headers for both flows
    eth1, ip1, udp1 = f1.packet.ethernet().ipv4().udp()
    eth2, ip2, udp2 = f2.packet.ethernet().ipv4().udp()

    # set source and destination MAC addresses
    eth1.src.value, eth1.dst.value = "00:AA:00:00:04:00", "00:AA:00:00:00:AA"
    eth2.src.value, eth2.dst.value = "00:AA:00:00:00:AA", "00:AA:00:00:04:00"

    # set source and destination IPv4 addresses
    ip1.src.value, ip1.dst.value = "10.0.0.1", "10.0.0.2"
    ip2.src.value, ip2.dst.value = "10.0.0.2", "10.0.0.1"

    # set incrementing port numbers as source UDP ports
    udp1.src_port.increment.start = 5000
    udp1.src_port.increment.step = 2
    udp1.src_port.increment.count = 10

    udp2.src_port.increment.start = 6000
    udp2.src_port.increment.step = 4
    udp2.src_port.increment.count = 10

    # assign list of port numbers as destination UDP ports
    udp1.dst_port.values = [4000, 4044, 4060, 4074]
    udp2.dst_port.values = [8000, 8044, 8060, 8074, 8082, 8084]

    # print resulting otg configuration
    print(cfg)

    # push configuration to controller
    api.set_config(cfg)

    # start transmitting configured flows
    ts = api.transmit_state()
    ts.state = ts.START
    api.set_transmit_state(ts)

    # create a flow metrics request and filter based on port names
    req = api.metrics_request()
    req.flow.flow_names = [f.name for f in cfg.flows]

    # fetch flow metrics
    res = api.get_metrics(req)

    # wait for flow metrics to be as expected
    expected = sum([f.duration.fixed_packets.packets for f in cfg.flows])
    assert wait_for(lambda: flow_metrics_ok(api, req, expected)), "Metrics validation failed!"

if __name__ == '__main__':
    sys.exit(main())