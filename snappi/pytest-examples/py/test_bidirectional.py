import utils
import time

custom_round = lambda value: value if value < 0.001 else round(value, 3)

def test_ipv4_bidirectional(api, duration, frame_size, line_rate_per_flow):
    """
    Configure a single bidirectional IPV4 flow
    """
    cfg = utils.load_test_config(
        api, 'bidirectional.json', apply_settings=True
        #api, 'bidirectional2TEs.json', apply_settings=True
        #api, 'bidirectional4TEs.json', apply_settings=True
    )

    assert len(cfg.flows) % 2 == 0,  \
        "This is a bidirectional traffic test. " \
        "The config file should have an even number of flows"

    TIMEOUT = 5
    ROW_SIZE = 40

    MAX_FRAME_SIZE = 9000
    MIN_FRAME_SIZE = 64
    MAX_LINE_RATE_PER_FLOW = 100 # / len(cfg.flows) 

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
            "   Duration:             {}s\n" \
            "   Line rate percentage: {}%\n".format(frame_size, duration, line_rate_per_flow))
    time.sleep(2)

    for flow in cfg.flows:
        flow.duration.fixed_seconds.seconds = duration
        flow.size.fixed = frame_size
        flow.rate.percentage = line_rate_per_flow
    
    size = cfg.flows[0].size.fixed

    utils.start_traffic(api, cfg)
    utils.wait_for(
        lambda: results_ok(api, size),
        'stats to be as expected',
        timeout_seconds = duration + TIMEOUT
    )
    utils.stop_traffic(api, cfg)

    _, flow_results = utils.get_all_stats(api)

    middle_index = (int) (len(flow_results) / 2)
    s1_flows_results = flow_results[:middle_index]
    s2_flows_results = flow_results[middle_index:]

    frames_s1_to_s2_tx = sum([flow_res.frames_tx for flow_res in s1_flows_results])
    frames_s2_to_s1_tx = sum([flow_res.frames_tx for flow_res in s2_flows_results])
    
    frames_s1_to_s2_rx = sum([flow_res.frames_rx for flow_res in s1_flows_results])
    frames_s2_to_s1_rx = sum([flow_res.frames_rx for flow_res in s2_flows_results])

    flows_total_tx = sum([flow_res.frames_tx for flow_res in flow_results])
    flows_total_rx = sum([flow_res.frames_rx for flow_res in flow_results])
    print("\n\nFrame size: {}B".format(frame_size))
    print("Average s1 --> s2 TX L2 rate {} Gbps".format(round(frames_s1_to_s2_tx * frame_size * 8 / duration / 1000000000, 3)))
    print("Average s1 --> s2 RX L2 rate {} Gbps".format(round(frames_s1_to_s2_rx * frame_size * 8 / duration / 1000000000, 3)))
    
    print("Average s2 --> s1 TX L2 rate {} Gbps".format(round(frames_s2_to_s1_tx * frame_size * 8 / duration / 1000000000, 3)))
    print("Average s2 --> s1 RX L2 rate {} Gbps".format(round(frames_s2_to_s1_rx * frame_size * 8 / duration / 1000000000, 3)))
    
    print("Total s1 --> s2 lost packets {}".format(frames_s1_to_s2_tx - frames_s1_to_s2_rx))
    print("Total s2 --> s1 lost packets {}\n".format(frames_s2_to_s1_tx - frames_s2_to_s1_rx))

    print("-" * ROW_SIZE)
    print("Average total TX L2 rate {} Gbps".format(round(flows_total_tx * size * 8 / duration / 1000000000, 3)))
    print("Average total RX L2 rate {} Gbps".format(round(flows_total_rx * size * 8 / duration / 1000000000, 3)))
    print("Average total TX packet rate: {} Mpps".format(round(flows_total_tx / duration / 1000000, 3)))
    print("Average total RX packet rate: {} Mpps".format(round(flows_total_rx / duration / 1000000, 3)))

    print("Total lost packets {}".format(flows_total_tx - flows_total_rx))
    print("Average loss percentage {} %".format(round((flows_total_tx - flows_total_rx) * 100 / flows_total_tx, 3)))

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
