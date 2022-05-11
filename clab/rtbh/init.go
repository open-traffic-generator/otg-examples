package tests

import (
	"flag"
	"log"
)

// hostname and interfaces of ixia-c-one node from containerlab topology
const (
	otgHost = "https://172.100.100.10"
)

var (
	dstMac   = "00:00:00:00:00:00"
	pktCount = 100
)

func init() {
	log.Printf("Initializing...")
	// replace value of dstMac with actual MAC of DUT interface connected to otgPort1
	flag.StringVar(&dstMac, "dstMac", dstMac, "Destination MAC address to be used for all packets")
}
