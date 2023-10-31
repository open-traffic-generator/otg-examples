import utils
import pytest
import time
import json

THEORETICAL_MAX_LINK_SPEED = 10    #  Gbps
PACKET_LOSS_TOLERANCE      = 1.0   # percent
NO_DETERMINATION_STEPS     = 10
NO_VALIDATION_STEPS        = 5
TRIAL_RUN_TIME             = 5  # seconds
FINAL_RUN_TIME             = 30 # seconds
TEST_GAP_TIME              = 1  # seconds
VALIDATION_DECREASE_LINE_PERCENTAGE = 0.01
RESULTS_FILE_PATH          = "./throughput_results_rfc2544_n_flows.json"


def find_location_by_name(ports, name):
    for port in ports:
        if port.name == name:
            return port.location
    return None

@pytest.mark.performance
def test_throughput_rfc2544_n_flows(api, direction, frame_sizes):
    """
    RFC-2544 Throughput determination test
    """
    cfg = utils.load_test_config(api, 'throughput_rfc2544_n_flows.json')

    packet_sizes = [int(frame_size) for frame_size in frame_sizes.split(',')]

    for frame_size in packet_sizes:
        if frame_size < 64 or frame_size > 9000:
            print("Frame size: {} is out of supported interval: [64, 9000]. " \
                "Resetting frame size array.".format(frame_size))
            packet_sizes = [768, 1024, 1518, 9000]
    results = {}
    
    expected_runtime = len(packet_sizes) * ((NO_DETERMINATION_STEPS-1) * TEST_GAP_TIME + FINAL_RUN_TIME + 2 * TEST_GAP_TIME)
    print("\n" +"-" * 50)
    print("This is a throughput test (based on RFC-2544 procedure.")#. The expected runtime is minimum {}s.".format(expected_runtime))
    print("Frame sizes in the test: " + str(packet_sizes))
    print("Packet loss tolerance: " + str(PACKET_LOSS_TOLERANCE))
    print("Number of flows: " + str(len(cfg.flows)))
    print("Direction: " + direction)
    print("-" * 50)

    test_settings = {}
    test_settings["THEORETICAL_MAX_LINK_SPEED"] = str(THEORETICAL_MAX_LINK_SPEED) + " Gbps"
    test_settings["PACKET_LOSS_TOLERANCE"] = str(round(PACKET_LOSS_TOLERANCE, 3)) + "%"
    test_settings["NO_DETERMINATION_STEPS"] = NO_DETERMINATION_STEPS
    test_settings["NO_VALIDATION_STEPS"] = NO_VALIDATION_STEPS

    test_settings["TRIAL_RUN_TIME"] = str(TRIAL_RUN_TIME) + "s"
    test_settings["FINAL_RUN_TIME"] = str(FINAL_RUN_TIME) + "s"
    test_settings["VALIDATION_DECREASE_LINE_PERCENTAGE"] = str(round(VALIDATION_DECREASE_LINE_PERCENTAGE, 2)) + "%"
    test_settings["NUMBER_OF_FLOWS"] = str(len(cfg.flows)) + " flows"
    print(test_settings)
    print("-" * 50)
    print("")


    if direction == "downstream":
        for flow in cfg.flows:
            # change direction
            flow.tx_rx.port.rx_name, flow.tx_rx.port.tx_name = flow.tx_rx.port.tx_name, flow.tx_rx.port.rx_name
            flow.packet[0].dst.value, flow.packet[0].src.value = flow.packet[0].src.value, flow.packet[0].dst.value 
        

    for size in packet_sizes:
        print("\n\n--- Determining throughput for {} B packets --- ".format(size))

        for flow in cfg.flows:
            flow.size.fixed = size

        packet_loss = 0.0
        left_pps = 0.0
        right_pps = 100.0 / len(cfg.flows) # int(THEORETICAL_MAX_LINK_SPEED * 1000000000 / 8 / (size + 20) / len(cfg.flows)) # max_pps_dict[size]
        line_rate = right_pps

        max_line_percentage = 0
        max_packets_sent = 0
        max_packets_received = 0
        rcv_pkts = 0
        sent_pkts = 0
        step = 1

        # Trial tests
        while step <= NO_DETERMINATION_STEPS:
            print("")
            print("Step [{}B]: {}".format(size, step))

            line_rate = (right_pps + left_pps) / 2
            print("Current line rate search interval [PER FLOW]: [{} %; {} %]. Trial run with {} %. "
                .format(round(left_pps, 2), 
                        round(right_pps, 2), 
                        round(line_rate, 2)))
            for flow in cfg.flows:
                flow.rate.percentage = line_rate
                flow.duration.fixed_seconds.seconds = TRIAL_RUN_TIME

            utils.start_traffic(api, cfg)

            time.sleep(TRIAL_RUN_TIME)

            utils.stop_traffic(api, cfg)

            _, flow_results = utils.get_all_stats(api, None, None, False)
            rcv_pkts = sum([f.frames_rx for f in flow_results]) # flow_results[0].frames_rx
            sent_pkts = sum([f.frames_tx for f in flow_results]) # flow_results[0].frames_tx

            print("sent_pkts {}M; rcv_pkts {}M; Lost packets {}".format(round(sent_pkts / 1000000, 3), round(rcv_pkts / 1000000, 3), sent_pkts - rcv_pkts))
            print("Total actual sent throughput: {} Gbps".format(round(sent_pkts * size * 8 / 1000000000 / TRIAL_RUN_TIME, 3)))
            print("Total actual received throughput: {} Gbps".format(round(rcv_pkts * size * 8 / 1000000000 / TRIAL_RUN_TIME, 3)))
            packet_loss_p = (sent_pkts - rcv_pkts) * 100 / sent_pkts
            print("Current number of packets lost = {}".format(sent_pkts - rcv_pkts))
            print("Current packet loss percentage = " + str(round(packet_loss_p, 6)) + " %")
            # Binary search approach to determine packet loss
            if rcv_pkts > max_packets_received:
                max_packets_received = rcv_pkts

            if packet_loss_p > PACKET_LOSS_TOLERANCE:
                # exceeded packet loss limit
                right_pps = line_rate - 0.01
            elif packet_loss_p <= PACKET_LOSS_TOLERANCE:
                # minimal loss
                left_pps = line_rate + 0.01
                if line_rate > max_line_percentage:
                    max_line_percentage = line_rate

            step += 1
            time.sleep(TEST_GAP_TIME)


        max_mpps = round(max_packets_received / TRIAL_RUN_TIME / 1000000, 3)
        max_mbps = round(max_packets_received / TRIAL_RUN_TIME * size * 8 / 1000000, 0)

        max_mpps_str = str(max_mpps) + " Mpps"
        max_mbps_str = str(max_mbps) + " Mbps"

        print("- Determined Total max RX rate for {}B packets is {}. Equivalent to {}.\n"
              .format(size, max_mpps_str, max_mbps_str))

        time.sleep(TEST_GAP_TIME)

        if max_line_percentage > 0:
            # Actual test: to confirm the result determined during trial tests
            # We are running a FINAL_RUN_TIMEs test again, and check the packet loss percentage
            print("\nTo confirm the results determined during trial tests we are running " + str(FINAL_RUN_TIME) +"s tests again, and check the packet loss percentage")
            step = 0
            packet_loss_percentage = 100
            max_packets_received = 0
            max_packets_sent = 0

            while step < NO_VALIDATION_STEPS: # packet_loss_percentage > PACKET_LOSS_TOLERANCE:
                rcv_pkts = 0
                sent_pkts = 0   
                print("\nRunning with {} % line rate per flow...".format(round(max_line_percentage, 3)))
                for flow in cfg.flows:
                    flow.rate.percentage = max_line_percentage
                    flow.duration.fixed_seconds.seconds = FINAL_RUN_TIME

                utils.start_traffic(api, cfg)

                time.sleep(FINAL_RUN_TIME)

                utils.stop_traffic(api, cfg)

                _, flow_results = utils.get_all_stats(api, None, None, False)
                rcv_pkts = sum([f.frames_rx for f in flow_results]) # flow_results[0].frames_rx
                sent_pkts = sum([f.frames_tx for f in flow_results]) # flow_results[0].frames_tx

                print("flow_results[0].frames_rx = {}".format(flow_results[0].frames_rx))
                
                packet_loss_percentage = (sent_pkts - rcv_pkts) * 100 / sent_pkts
                max_packets_received = rcv_pkts
                max_packets_sent = sent_pkts

                print("sent_pkts: {} \n"
                      "size {} \n"
                      "run time {}\n".format(sent_pkts, size, FINAL_RUN_TIME)
                      )
                print("Validation: Actual sent throughput: {} Gbps".format(round(sent_pkts * size * 8 / FINAL_RUN_TIME / 1000000000, 3)))
                print("Validation: Actual received throughput: {} Gbps".format(round(rcv_pkts * size * 8 / FINAL_RUN_TIME / 1000000000, 3)))

                max_mbps = round(rcv_pkts * len(cfg.flows) * size * 8 / 1000000, 0)
                print("### {}s test result for {}B frame size: sent_pkts {}M; rcv_pkts  {}M; lost_pkts = {}; packet_loss_percentage = {} %"
                .format(FINAL_RUN_TIME, size, round(sent_pkts / 1000000, 3), round(rcv_pkts / 1000000, 3), sent_pkts - rcv_pkts, round(packet_loss_percentage, 5)))

                if packet_loss_percentage <= PACKET_LOSS_TOLERANCE:
                    print("The {}s test with {}% per flow per flow PASSED".format(FINAL_RUN_TIME, round(max_line_percentage, 3)))
                    break
                
                print("The {}s test with {} % line rate per flow did NOT pass, trying again with {} % line rate PER FLOW."
                    .format(FINAL_RUN_TIME, round(max_line_percentage, 3), round((1 - VALIDATION_DECREASE_LINE_PERCENTAGE/100) * max_line_percentage, 3)))
                max_line_percentage = ((1 - VALIDATION_DECREASE_LINE_PERCENTAGE/100) * max_line_percentage)
                time.sleep(TEST_GAP_TIME)
                step += 1

            if step == NO_VALIDATION_STEPS:
                print("\nWe have reached the maximum {} validation steps. You can: \n"
                    " a) Rerun the test for the {}B frame size or \n"
                    " b) increase the VALIDATION_DECREASE_LINE_PERCENTAGE or\n" 
                    " c) increase the NO_VALIDATION_STEPS\n\n".format(size, NO_VALIDATION_STEPS))

        else:
            packet_loss_percentage = 100.0

        max_mpps = round(max_packets_received / 1000000 / FINAL_RUN_TIME, 3)
        max_mbps = round(max_packets_received * size * 8 / 1000000 / FINAL_RUN_TIME, 0)

        max_mpps_str = str(max_mpps) + " Mpps"
        max_mbps_str = str(max_mbps) + " Mbps"

        test_pkt_loss_p_str = str(round(packet_loss_percentage, 5)) + " % loss"
        nr_packets_lost_str = str(sent_pkts - rcv_pkts) + " packets lost"
        max_line_percentage_str = str(round(max_line_percentage, 2)) + " % per flow" 
        results[str(size)] = [max_mpps_str, max_mbps_str, max_line_percentage_str, nr_packets_lost_str, test_pkt_loss_p_str]
        print(results)

        time.sleep(TEST_GAP_TIME)

    flows = {}

    for flow in cfg.flows:
        flows[flow.name] = find_location_by_name(cfg.ports, flow.tx_rx.port.tx_name) + \
                             " -> " + \
                           find_location_by_name(cfg.ports, flow.tx_rx.port.rx_name)

    results["test_settings"] = test_settings
    results["flows"] = flows
    with open(RESULTS_FILE_PATH, "w") as file:
        json.dump(results, file)
