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

func Test_RTBH_IPv4_Normal_Traffic(t *testing.T) {
	api, config := initOTG("otg.yml", t)

	fps := map[string]*flowProfile{
		"Users-2-Victim":     &flowProfile{3000 * 10 * 1, 3000, true}, // pktCount (rate * sec * min), ratePPS, positiveTest
		"Attackers-2-Victim": &flowProfile{1000 * 10 * 1, 1000, true}, // pktCount (rate * sec * min), ratePPS, positiveTest
		"Users-2-Bystander":  &flowProfile{2000 * 10 * 1, 2000, true}, // pktCount (rate * sec * min), ratePPS, positiveTest
	}

	// override if requested via flags (see init.go)
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

	config = updateConfigFlows(config, fps)
	flowMetrics := runTraffic(api, config, t)
	checkPacketLoss(flowMetrics, fps, t)
}

func Test_RTBH_IPv4_DDoS_Traffic(t *testing.T) {
	api, config := initOTG("otg.yml", t)

	fps := map[string]*flowProfile{
		"Users-2-Victim":     &flowProfile{3000 * 10 * 1, 3000, false},   // pktCount (rate * sec * min), ratePPS, positiveTest
		"Attackers-2-Victim": &flowProfile{20000 * 10 * 1, 20000, false}, // pktCount (rate * sec * min), ratePPS, positiveTest
		"Users-2-Bystander":  &flowProfile{2000 * 10 * 1, 2000, true},    // pktCount (rate * sec * min), ratePPS, positiveTest
	}

	config = updateConfigFlows(config, fps)
	flowMetrics := runTraffic(api, config, t)
	checkPacketLoss(flowMetrics, fps, t)
}

func initOTG(otgfile string, t *testing.T) (gosnappi.GosnappiApi, gosnappi.Config) {
	// Read OTG config
	fmt.Printf("Loading OTG config...")
	otgbytes, err := ioutil.ReadFile(otgfile)
	if err != nil {
		t.Fatal(err)
	}

	otg := string(otgbytes)
	fmt.Println("loaded.")

	// Create a new API handle to make API calls against a traffic generator
	api := gosnappi.NewApi()

	// Set the transport protocol to either HTTP or GRPC
	api.NewHttpTransport().SetLocation(otgHost).SetVerify(false)

	// Create a new traffic configuration that will be set on traffic generator
	config := api.NewConfig()
	config.FromYaml(otg)

	return api, config
}

func runTraffic(api gosnappi.GosnappiApi, config gosnappi.Config, t *testing.T) gosnappi.MetricsResponse {
	// push traffic configuration to otgHost
	fmt.Printf("Applying OTG config...")
	log.Infof("\n%s\n", config)
	res, err := api.SetConfig(config)
	checkResponse(res, err, t)
	fmt.Println("ready.")

	// start transmitting configured flows
	fmt.Printf("Starting traffic...")
	ts := api.NewTransmitState().SetState(gosnappi.TransmitStateState.START)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err, t)
	fmt.Printf("started...")

	trafficETA := calculateTrafficETA(config)
	fmt.Printf("ETA is: %s\n", trafficETA)

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
		barname := fmt.Sprintf("%s:", f.Name())
		bar := p.AddBar(int64(f.Duration().FixedPackets().Packets()),
			mpb.PrependDecorators(
				// simple name decorator
				decor.Name(barname, decor.WCSyncSpace),
				decor.Percentage(decor.WCSyncSpace),
			),
			mpb.AppendDecorators(
				decor.Counters(0, "packets Rx: %d / %d", decor.WCSyncSpaceR),
			),
		)

		go func(f gosnappi.Flow) {
			defer flowMetricsMutex.Unlock()
			defer wg.Done()
			for {
				flowMetricsMutex.Lock()
				for _, fm := range flowMetrics.FlowMetrics().Items() {
					if fm.Name() == f.Name() {
						bar.IncrInt64(fm.FramesRx() - bar.Current())
						checkResponse(fm, err, t)
						if fm.Transmit() == gosnappi.FlowMetricTransmit.STOPPED {
							bar.Abort(false)
							return
						}
						if trafficETA*2 < time.Since(start) {
							bar.Abort(false)
							log.Infof("Traffic %s has been running twice longer than ETA, forcing to stop", fm.Name())
							return
						}
					}
				}
				flowMetricsMutex.Unlock()
				time.Sleep(500 * time.Millisecond)
			}
		}(f)
	}
	p.Wait()
	keepPulling = false // stop metrics pulling routine

	// stop transmitting traffic
	fmt.Printf("Stopping traffic...")
	ts = api.NewTransmitState().SetState(gosnappi.TransmitStateState.STOP)
	res, err = api.SetTransmitState(ts)
	checkResponse(res, err, t)
	fmt.Println("stopped.")

	return flowMetrics
}

func updateConfigFlows(config gosnappi.Config, profiles flowProfiles) gosnappi.Config {
	for _, f := range config.Flows().Items() {
		p, isProfileExist := profiles[f.Name()]
		if isProfileExist {
			count := p.pktCount
			pps := p.ratePPS
			if count > 0 { // if provided via profile, otherwise use value from the imported OTG config
				f.Duration().FixedPackets().SetPackets(count)
			}
			if pps > 0 { // if provided via profile, otherwise use value from the imported OTG config
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

func calculateTrafficETA(config gosnappi.Config) time.Duration {
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
	return trafficETA
}

// print otg api response content
func checkResponse(res interface{}, err error, t *testing.T) {
	if err != nil {
		t.Fatal(err)
	}
	switch v := res.(type) {
	case gosnappi.MetricsResponse:
		for _, fm := range v.FlowMetrics().Items() {
			log.Infof("Traffic stats for %s:\n%s\n", fm.Name(), fm)
		}
	case gosnappi.FlowMetric:
		log.Infof("Traffic stats for %s:\n%s\n", v.Name(), v)
	case gosnappi.ResponseWarning:
		for _, w := range v.Warnings() {
			log.Println("WARNING:", w)
		}
	default:
		t.Fatal("Unknown response type:", v)
	}
}

// check for packet loss
func checkPacketLoss(flowMetrics gosnappi.MetricsResponse, profiles flowProfiles, t *testing.T) {
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
