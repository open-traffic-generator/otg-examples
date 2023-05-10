/* Test BGP Route Installation
Topology:
IXIA (40.40.40.0/24) <------> IXIA (50.50.50.0/24)
Flows:
- v4: 40.40.40.1 -> 50.50.50.1+
*/
package tests

import (
	"testing"

	"github.com/open-traffic-generator/snappi/gosnappi"
)

func TestIPv4BGPRouteInstall(t *testing.T) {
	client, err := NewClient(otgHttpLocation)
	if err != nil {
		t.Fatal(err)
	}

	defer client.Close()
	defer client.StopProtocol()

	config, expected := bgpRouteInstallConfigIPv4(client)

	if err := client.SetConfig(config); err != nil {
		t.Fatal(err)
	}

	if err := client.StartProtocol(); err != nil {
		t.Fatal(err)
	}

	WaitFor(t, func() (bool, error) { return client.AllBgp4SessionUp(expected) }, nil)

	ethernetNames := []string{"dutPort1.eth", "dutPort2.eth"}
	if _, err := client.GetIPv4NeighborsStates(ethernetNames); err != nil {
		t.Fatal(err)
	}

	flowNames := []string{"p1.v4.p2"}
	if err := client.StartTransmit(flowNames); err != nil {
		t.Fatal(err)
	}

	WaitFor(t, func() (bool, error) { return client.FlowMetricsOk(expected) }, nil)
}

func bgpRouteInstallConfigIPv4(client *ApiClient) (gosnappi.Config, ExpectedState) {
	config := client.Api().NewConfig()

	port1 := config.Ports().Add().SetName("ixia-c-port1").SetLocation(otgPort1Location)
	port2 := config.Ports().Add().SetName("ixia-c-port2").SetLocation(otgPort2Location)

	dutPort1 := config.Devices().Add().SetName("dutPort1")
	dutPort1Eth := dutPort1.Ethernets().Add().
		SetName("dutPort1.eth").
		SetMac("00:00:01:01:01:01")
	dutPort1Eth.Connection().SetPortName(port1.Name())
	dutPort1Ipv4 := dutPort1Eth.Ipv4Addresses().Add().
		SetName("dutPort1.ipv4").
		SetAddress("1.1.1.1").
		SetGateway("1.1.1.2")
	dutPort2 := config.Devices().Add().SetName("dutPort2")
	dutPort2Eth := dutPort2.Ethernets().Add().
		SetName("dutPort2.eth").
		SetMac("00:00:02:01:01:01")
	dutPort2Eth.Connection().SetPortName(port2.Name())
	dutPort2Ipv4 := dutPort2Eth.Ipv4Addresses().Add().
		SetName("dutPort2.ipv4").
		SetAddress("1.1.1.2").
		SetGateway("1.1.1.1")

	dutPort1Bgp := dutPort1.Bgp().
		SetRouterId(dutPort1Ipv4.Address())
	dutPort1Bgp4Peer := dutPort1Bgp.Ipv4Interfaces().Add().
		SetIpv4Name(dutPort1Ipv4.Name()).
		Peers().Add().
		SetName("dutPort1.bgp4.peer").
		SetPeerAddress(dutPort1Ipv4.Gateway()).
		SetAsNumber(1111).
		SetAsType(gosnappi.BgpV4PeerAsType.EBGP)

	dutPort1Bgp4PeerRoutes := dutPort1Bgp4Peer.V4Routes().Add().
		SetName("dutPort1.bgp4.peer.rr4").
		SetNextHopIpv4Address(dutPort1Ipv4.Address()).
		SetNextHopAddressType(gosnappi.BgpV4RouteRangeNextHopAddressType.IPV4).
		SetNextHopMode(gosnappi.BgpV4RouteRangeNextHopMode.MANUAL)
	dutPort1Bgp4PeerRoutes.Addresses().Add().
		SetAddress("40.40.40.0").
		SetPrefix(24).
		SetCount(5).
		SetStep(2)

	dutPort2Bgp := dutPort2.Bgp().
		SetRouterId(dutPort2Ipv4.Address())
	dutPort2BgpIf4 := dutPort2Bgp.Ipv4Interfaces().Add().
		SetIpv4Name(dutPort2Ipv4.Name())
	dutPort2Bgp4Peer := dutPort2BgpIf4.Peers().Add().
		SetName("dutPort2.bgp4.peer").
		SetPeerAddress(dutPort2Ipv4.Gateway()).
		SetAsNumber(2222).
		SetAsType(gosnappi.BgpV4PeerAsType.EBGP)

	dutPort2Bgp4PeerRoutes := dutPort2Bgp4Peer.V4Routes().Add().
		SetName("dutPort2.bgp4.peer.rr4").
		SetNextHopIpv4Address(dutPort2Ipv4.Address()).
		SetNextHopAddressType(gosnappi.BgpV4RouteRangeNextHopAddressType.IPV4).
		SetNextHopMode(gosnappi.BgpV4RouteRangeNextHopMode.MANUAL)
	dutPort2Bgp4PeerRoutes.Addresses().Add().
		SetAddress("50.50.50.0").
		SetPrefix(24).
		SetCount(5).
		SetStep(2)

	// OTG traffic configuration
	f1 := config.Flows().Add().SetName("p1.v4.p2")
	f1.Metrics().SetEnable(true)
	f1.TxRx().Device().
		SetTxNames([]string{dutPort1Bgp4PeerRoutes.Name()}).
		SetRxNames([]string{dutPort2Bgp4PeerRoutes.Name()})
	f1.Size().SetFixed(512)
	f1.Rate().SetPps(500)
	f1.Duration().FixedPackets().SetPackets(1000)
	e1 := f1.Packet().Add().Ethernet()
	e1.Src().SetValue(dutPort1Eth.Mac())
	e1.Dst().SetValue(dutPort2Eth.Mac())
	v4 := f1.Packet().Add().Ipv4()
	v4.Src().SetValue("40.40.40.1")
	v4.Dst().Increment().SetStart("50.50.50.1").SetStep("0.0.0.1").SetCount(5)

	expected := ExpectedState{
		Bgp4: map[string]ExpectedBgpMetrics{
			dutPort1Bgp4Peer.Name(): {Advertised: 5, Received: 5},
			dutPort2Bgp4Peer.Name(): {Advertised: 5, Received: 5},
		},
		Flow: map[string]ExpectedFlowMetrics{
			f1.Name(): {FramesRx: 1000, FramesRxRate: 0},
		},
	}

	return config, expected
}
