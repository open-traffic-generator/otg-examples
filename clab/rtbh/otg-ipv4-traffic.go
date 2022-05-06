/*
Test IPv4 Forwarding
- Endpoints: OTG 198.51.100.2 -----> 198.51.100.1 SUT 192.0.2.1 ------> OTG 192.0.2.129
- TCP flow from OTG: 198.51.100.2 -> 192.0.2.129

To run: go run otg-ipv4-traffic.go -dstMac=<MAC of 198.51.100.1>
*/

package main

import (
	"flag"
	"log"
	"time"

	"github.com/open-traffic-generator/snappi/gosnappi"
)

// hostname and interfaces of ixia-c-one node from containerlab topology
const (
	otgHost  = "https://172.100.100.10"
	otgPort1 = "eth1"
	otgPort2 = "eth2"
)

var (
	dstMac   = "ff:ff:ff:ff:ff:ff"
	srcMac   = "00:00:00:00:00:aa"
	pktCount = 100
)

func main() {
	// replace value of dstMac with actual MAC of DUT interface connected to otgPort1
	flag.StringVar(&dstMac, "dstMac", dstMac, "Destination MAC address to be used for all packets")
	flag.Parse()

	api, config := newConfig()

	// push traffic configuration to otgHost
	res, err := api.SetConfig(config)
	checkResponse(res, err)

	// start transmitting configured flows
	ts := api.NewTransmitState().SetState(gosnappi.TransmitStateState.START)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err)

	// fetch flow metrics and wait for received frame count to be correct
	mr := api.NewMetricsRequest()
	mr.Flow()
	waitFor(
		func() bool {
			res, err := api.GetMetrics(mr)
			checkResponse(res, err)

			fm := res.FlowMetrics().Items()[0]
			return fm.Transmit() == gosnappi.FlowMetricTransmit.STOPPED && fm.FramesRx() == int64(pktCount)
		},
		10*time.Second,
	)
}

func checkResponse(res interface{}, err error) {
	if err != nil {
		log.Fatal(err)
	}
	switch v := res.(type) {
	case gosnappi.MetricsResponse:
		log.Printf("Metrics Response:\n%s\n", v)
	case gosnappi.ResponseWarning:
		for _, w := range v.Warnings() {
			log.Println("WARNING:", w)
		}
	default:
		log.Fatal("Unknown response type:", v)
	}
}

func newConfig() (gosnappi.GosnappiApi, gosnappi.Config) {
	// create a new API handle to make API calls against otgHost
	api := gosnappi.NewApi()
	api.NewHttpTransport().SetLocation(otgHost).SetVerify(false)

	// create an empty traffic configuration
	config := api.NewConfig()
	// create traffic endpoints
	p1 := config.Ports().Add().SetName("p1").SetLocation(otgPort1)
	p2 := config.Ports().Add().SetName("p2").SetLocation(otgPort2)
	// create a flow and set the endpoints
	f1 := config.Flows().Add().SetName("p1.v4.p2")
	f1.TxRx().Port().SetTxName(p1.Name()).SetRxName(p2.Name())

	// enable per flow metrics tracking
	f1.Metrics().SetEnable(true)
	// set size, count and transmit rate for all packets in the flow
	f1.Size().SetFixed(512)
	f1.Rate().SetPps(100)
	f1.Duration().FixedPackets().SetPackets(int32(pktCount))

	// configure headers for all packets in the flow
	eth := f1.Packet().Add().Ethernet()
	ip := f1.Packet().Add().Ipv4()
	tcp := f1.Packet().Add().Tcp()

	eth.Src().SetValue(srcMac)
	eth.Dst().SetValue(dstMac)

	ip.Src().SetValue("198.51.100.2")
	ip.Dst().SetValue("192.0.2.129")

	tcp.SrcPort().SetValue(3250)
	tcp.DstPort().SetValue(8070)

	//log.Printf("OTG configuration:\n%s\n", config)
	return api, config
}

func waitFor(fn func() bool, timeout time.Duration) {
	start := time.Now()
	for {
		if fn() {
			return
		}
		if time.Since(start) > timeout {
			log.Fatal("Timeout occurred !")
		}

		time.Sleep(500 * time.Millisecond)
	}
}
