package tests

import (
	"flag"
	"time"
)

// hostname and interfaces of ixia-c-one node from containerlab topology
const (
	otgHost = "https://172.100.100.10" // OTG API Endpoint
	timeout = 60 * time.Second         // Max time to wait for traffic to complete
)

var (
	dstMac   = "00:00:00:00:00:00" // Destination MAC for flows
	pktCount = 1000                // Number of packets to transmit
	pktPPS   = 100                 // Rate to transmit at in packets per second
)

func init() {
	// replace value of dstMac with actual MAC of DUT interface connected to otgPort1
	flag.StringVar(&dstMac, "dstMac", dstMac, "Destination MAC address to be used for all packets")
	// Initialize packet count to transmit
	flag.IntVar(&pktCount, "pktCount", pktCount, "Number of packets to transmit")
	// Initialize packet rate to transmit
	flag.IntVar(&pktPPS, "pktPPS", pktPPS, "Rate to transmit at in packets per second")
}
