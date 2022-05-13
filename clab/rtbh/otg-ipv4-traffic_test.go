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

var (
	pktCount = 1000             // Number of packets to transmit
	pktPPS   = 100              // Rate in packets per second to transmit at
	timeout  = 15 * time.Second // How long to wait for traffic to complete
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

	for _, f := range config.Flows().Items() {
		f.Duration().FixedPackets().SetPackets(int32(pktCount))
		f.Rate().SetPps(int64(pktPPS))
		for _, h := range f.Packet().Items() {
			if h.Choice() == "ethernet" {
				h.Ethernet().Dst().SetValue(dstMac)
			}
		}
	}

	// push traffic configuration to otgHost
	log.Printf("Applying OTG config...")
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
		func() bool {
			res, err := api.GetMetrics(mr)
			checkResponse(res, err, t)

			fm := res.FlowMetrics().Items()[0]
			return fm.Transmit() == gosnappi.FlowMetricTransmit.STOPPED && fm.FramesRx() == int64(pktCount)
		},
		timeout,
		t,
	)
}

func checkResponse(res interface{}, err error, t *testing.T) {
	if err != nil {
		t.Fatal(err)
	}
	switch v := res.(type) {
	case gosnappi.MetricsResponse:
		log.Printf("Metrics Response:\n%s\n", v)
	case gosnappi.ResponseWarning:
		for _, w := range v.Warnings() {
			log.Println("WARNING:", w)
		}
	default:
		t.Fatal("Unknown response type:", v)
	}
}

func waitFor(fn func() bool, timeout time.Duration, t *testing.T) {
	start := time.Now()
	for {
		if fn() {
			return
		}
		if time.Since(start) > timeout {
			t.Fatal("Timeout occurred !")
		}

		time.Sleep(500 * time.Millisecond)
	}
}
