/*
Test IPv4 Forwarding
- Endpoints: OTG 198.51.100.2 -----> 198.51.100.1 SUT 192.0.2.1 ------> OTG 192.0.2.129
- TCP flow from OTG: 198.51.100.2 -> 192.0.2.129

To run: go test -run=TestOTGIPv4Traffic -dstMac=<MAC of 198.51.100.1>
*/

package tests

import (
	"fmt"
	"io/ioutil"
	"log"
	"sync"
	"testing"
	"time"

	"github.com/open-traffic-generator/snappi/gosnappi"
	"github.com/vbauerster/mpb/v7"
	"github.com/vbauerster/mpb/v7/decor"
)

type flowProfile struct {
	pktCount     int32 // f.Duration().FixedPackets().Packets()
	ratePPS      int64 // f.Rate().Pps()
	positiveTest bool  // is successful flow completion a positive criteria (true = pass), or negattive (true = fail)
}

type flowProfiles map[string]*flowProfile

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

	fps := map[string]*flowProfile{
		"Users-2-Victim":     &flowProfile{500, 100, true},
		"Attackers-2-Victim": &flowProfile{100, 20, true},
		"Users-2-Bystander":  &flowProfile{200, 40, true},
	}

	// override if needed
	if pktCount > 0 {
		for n, fp := range fps {
			if fp.pktCount == 0 {
				fps[n].pktCount = int32(pktCount)
			}
		}
	}

	if ratePPS > 0 {
		for n, fp := range fps {
			if fp.ratePPS == 0 {
				fps[n].ratePPS = int64(ratePPS)
			}
		}
	}

	runTraffic(api, config, fps, t)

	fps = map[string]*flowProfile{
		"Attackers-2-Victim": &flowProfile{1000000, 100000, false},
	}

	runTraffic(api, config, fps, t)
}

func runTraffic(api gosnappi.GosnappiApi, config gosnappi.Config, profiles flowProfiles, t *testing.T) {

	config = updateConfigFlows(config, profiles)

	// Initialize packet counts and rates per flow if they were provided as parameters. Calculate ETA
	flowETA := time.Duration(0)
	trafficETA := time.Duration(0)
	for _, f := range config.Flows().Items() {
		pktCountFlow := f.Duration().FixedPackets().Packets()
		ratePPSFlow := f.Rate().Pps()
		// Calculate ETA it will take to transmit the flow
		if ratePPSFlow > 0 {
			flowETA = time.Duration(float64(int64(pktCountFlow)/ratePPSFlow)) * time.Second
		}
		if flowETA > trafficETA {
			trafficETA = flowETA // The longest flow to finish
		}
	}

	log.Printf("ETA is: %s", trafficETA)

	// push traffic configuration to otgHost
	log.Printf("Applying OTG config...")
	//log.Printf("\n%s", config)
	res, err := api.SetConfig(config)
	checkResponse(res, err, t)

	// start transmitting configured flows
	log.Printf("Starting traffic...")
	ts := api.NewTransmitState().SetState(gosnappi.TransmitStateState.START)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err, t)

	// initialize flow metrics
	mr := api.NewMetricsRequest()
	mr.Flow()
	flowMetrics, err := api.GetMetrics(mr)
	if err != nil {
		t.Fatal(err)
	}

	// launch a routine to periodically pull flow metrics
	var flowMetricsMutex sync.Mutex
	keepPulling := true
	go func() {
		for keepPulling {
			flowMetricsMutex.Lock()
			flowMetrics, err = api.GetMetrics(mr)
			flowMetricsMutex.Unlock()
			if err != nil {
				t.Fatal(err)
			}
			time.Sleep(500 * time.Millisecond)
		}
	}()

	// use a waitGroup to track progress of each individual flow
	var wg sync.WaitGroup
	// progress bar indicator
	p := mpb.New(mpb.WithWaitGroup(&wg))
	wg.Add(len(config.Flows().Items()))

	// wait for traffic to stop on each flow or run beyond ETA
	start := time.Now()
	for _, f := range config.Flows().Items() {
		// decorate progress bars
		barname := fmt.Sprintf("Traffic %s:", f.Name())
		bar := p.AddBar(int64(f.Duration().FixedPackets().Packets()),
			mpb.PrependDecorators(
				// simple name decorator
				decor.Name(barname),
			),
			mpb.AppendDecorators(
				// decor.DSyncWidth bit enables column width synchronization
				decor.Percentage(decor.WCSyncSpace),
			),
		)

		go func(f gosnappi.Flow) {
			defer wg.Done()
			for {
				flowMetricsMutex.Lock()
				for _, fm := range flowMetrics.FlowMetrics().Items() {
					if fm.Name() == f.Name() {
						bar.IncrBy(int(fm.FramesRx()))
						if fm.Transmit() == gosnappi.FlowMetricTransmit.STOPPED {
							flowMetricsMutex.Unlock()
							return
						} else if trafficETA+time.Second < time.Since(start) {
							log.Printf("Traffic %s has been running past ETA, forcing to stop", fm.Name())
							flowMetricsMutex.Unlock()
							return
						}
					}
				}
				flowMetricsMutex.Unlock()
				time.Sleep(500 * time.Millisecond)
			}
		}(f)
	}
	wg.Wait()
	keepPulling = false // stop metrics pulling routine

	// stop transmitting traffic
	log.Printf("Stopping traffic...")
	ts = api.NewTransmitState().SetState(gosnappi.TransmitStateState.STOP)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err, t)

	// check for packet loss
	for _, fm := range flowMetrics.FlowMetrics().Items() {
		if fm.FramesTx() > 0 {
			loss := float32(fm.FramesTx()-fm.FramesRx()) / float32(fm.FramesTx())
			positiveTest := true // default assumption is that we are testing for a flow to succeed
			p, isProfileExist := profiles[fm.Name()]
			if isProfileExist {
				positiveTest = p.positiveTest
			}
			if positiveTest { // we expect the flow to succeed
				if loss > 0.01 {
					t.Fatalf("Packet loss was detected for %s! Measured %f per cent", fm.Name(), loss*100)
				}
			} else { // we expect the flow to fail
				if loss < 0.01 {
					t.Fatalf("Packet loss was expected for %s! Measured %f per cent", fm.Name(), loss*100)
				}
			}
		}
	}
}

func updateConfigFlows(config gosnappi.Config, profiles flowProfiles) gosnappi.Config {
	for _, f := range config.Flows().Items() {
		p, isProfileExist := profiles[f.Name()]
		if isProfileExist {
			count := p.pktCount
			pps := p.ratePPS
			if count > 0 { // if provided as a flag, otherwise use value from the imported OTG config
				f.Duration().FixedPackets().SetPackets(count)
			}
			if pps > 0 { // if provided as a flag, otherwise use value from the imported OTG config
				f.Rate().SetPps(pps)
			}
		}
		// Set destination MAC
		for _, h := range f.Packet().Items() {
			if h.Choice() == "ethernet" {
				h.Ethernet().Dst().SetValue(dstMac)
			}
		}
	}

	return config
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
	case gosnappi.FlowMetric:
		log.Printf("Traffic stats for %s:\n%s\n", v.Name(), v)
	case gosnappi.ResponseWarning:
		for _, w := range v.Warnings() {
			log.Println("WARNING:", w)
		}
	default:
		t.Fatal("Unknown response type:", v)
	}
}
