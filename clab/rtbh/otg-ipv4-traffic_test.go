/*
Test IPv4 Forwarding
- Endpoints: OTG 198.51.100.2 -----> 198.51.100.1 SUT 192.0.2.1 ------> OTG 192.0.2.129
- TCP flow from OTG: 198.51.100.2 -> 192.0.2.129

To run: go test -run=TestOTGIPv4Traffic -dstMac=<MAC of 198.51.100.1>
*/

package tests

import (
	"io/ioutil"
	"log"
	"testing"
	"time"

	"github.com/open-traffic-generator/snappi/gosnappi"
)

func Test_RTBH_IPv4_Ingress_Traffic(t *testing.T) {
	// Read OTG config
	otgbytes, err := ioutil.ReadFile("RTBH_IPv4_Ingress_Traffic.yml")
	if err != nil {
		t.Fatal(err)
	}

	otg := string(otgbytes)
	log.Printf("Loaded OTG config...")

	// Create a new API handle to make API calls against a traffic generator
	api := gosnappi.NewApi()

	// Set the transport protocol to either HTTP or GRPC
	api.NewHttpTransport().SetLocation(otgHost).SetVerify(false)

	// Create a new traffic configuration that will be set on traffic generator
	config := api.NewConfig()
	config.FromYaml(otg)

	// Initialize packet counts and rates per flow if they were provided as parameters. Calculate ETA
	flowETA := time.Duration(0)
	trafficETA := time.Duration(0)
	for _, f := range config.Flows().Items() {
		pktCountFlow := f.Duration().FixedPackets().Packets()
		pktPPSFlow := f.Rate().Pps()
		if pktCount > 0 { // if provided as a flag, otherwise use value from the imported OTG config
			f.Duration().FixedPackets().SetPackets(int32(pktCount))
			pktCountFlow = int32(pktCount)
		}
		if pktPPS > 0 { // if provided as a flag, otherwise use value from the imported OTG config
			f.Rate().SetPps(int64(pktPPS))
			pktPPSFlow = int64(pktPPS)
		}
		// Calculate ETA it will take to transmit the flow
		if pktPPSFlow > 0 {
			flowETA = time.Duration(float64(int64(pktCountFlow)/pktPPSFlow)) * time.Second
		}
		if flowETA > trafficETA {
			trafficETA = flowETA // The longest flow to finish
		}
		// Set destination MAC
		for _, h := range f.Packet().Items() {
			if h.Choice() == "ethernet" {
				h.Ethernet().Dst().SetValue(dstMac)
			}
		}
	}

	log.Printf("ETA is: %s", trafficETA)

	// push traffic configuration to otgHost
	log.Printf("Applying OTG config:")
	log.Printf("\n%s", config)
	res, err := api.SetConfig(config)
	checkResponse(res, err, t)

	// start transmitting configured flows
	log.Printf("Starting traffic...")
	ts := api.NewTransmitState().SetState(gosnappi.TransmitStateState.START)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err, t)

	// fetch flow metrics and wait for received frame count to be correct
	mr := api.NewMetricsRequest()
	mr.Flow()
	waitFor(
		func(start time.Time) bool {
			res, err := api.GetMetrics(mr)
			checkResponse(res, err, t)

			fm := res.FlowMetrics().Items()[0]
			log.Printf("Time passed: %s out of %s", time.Since(start), trafficETA)
			if fm.Transmit() == gosnappi.FlowMetricTransmit.STOPPED {
				return true
			} else if trafficETA+time.Second < time.Since(start) {
				return true
			} else {
				return false
			}
		},
		timeout,
		t,
	)

	// stop transmitting traffic
	log.Printf("Stopping traffic...")
	ts = api.NewTransmitState().SetState(gosnappi.TransmitStateState.STOP)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err, t)

	// pull the final metrics and check for packet loss
	mt, err := api.GetMetrics(mr)
	checkResponse(mt, err, t)
	fm := mt.FlowMetrics().Items()[0]
	loss := float32(fm.FramesTx()-fm.FramesRx()) / float32(fm.FramesTx())
	if loss > 0.01 {
		t.Fatalf("Packet loss was detected: %f per cent", loss*100)
	}
}

// print otg api response content
func checkResponse(res interface{}, err error, t *testing.T) {
	if err != nil {
		t.Fatal(err)
	}
	switch v := res.(type) {
	case gosnappi.MetricsResponse:
		for _, fm := range v.FlowMetrics().Items() {
			log.Printf("Traffic stats for %s:\n%s\n", fm.Name(), fm)
		}
	case gosnappi.ResponseWarning:
		for _, w := range v.Warnings() {
			log.Println("WARNING:", w)
		}
	default:
		t.Fatal("Unknown response type:", v)
	}
}

// wait until inline function return true or a timeout is reached
func waitFor(fn func(time.Time) bool, timeout time.Duration, t *testing.T) {
	start := time.Now()
	for {
		if fn(start) {
			return
		}
		if time.Since(start) > timeout {
			t.Fatal("Timeout occurred !")
		}

		time.Sleep(500 * time.Millisecond)
	}
}
