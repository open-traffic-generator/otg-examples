package tests

import (
	"flag"
	"os"
	"time"

	"github.com/sirupsen/logrus"
)

// hostname and interfaces of ixia-c-one node from containerlab topology
const (
	otgHost = "https://172.100.100.10:8443" // OTG API Endpoint
	timeout = 60 * time.Second              // Max time to wait for traffic to complete
)

var (
	dstMac   = "00:00:00:00:00:00" // Destination MAC for flows
	pktCount = 0                   // Number of packets to transmit
	ratePPS  = 0                   // Rate to transmit at in packets per second
)

// Create a new instance of the logger
var log = logrus.New()

func init() {
	// Log to file
	file, err := os.OpenFile("gosnappi.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err == nil {
		log.Out = file
	} else {
		log.Info("Failed to log to file, using default stderr")
	}

	// replace value of dstMac with actual MAC of DUT interface connected to otgPort1
	flag.StringVar(&dstMac, "dstMac", dstMac, "Destination MAC address to be used for all packets")
	// Initialize packet count to transmit
	flag.IntVar(&pktCount, "pktCount", pktCount, "Number of packets to transmit")
	// Initialize packet rate to transmit
	flag.IntVar(&ratePPS, "ratePPS", ratePPS, "Rate to transmit at in packets per second")
}
