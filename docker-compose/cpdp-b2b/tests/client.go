package tests

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"

	"github.com/open-traffic-generator/snappi/gosnappi"
)

type ApiClient struct {
	api gosnappi.GosnappiApi
}

func NewClient(location string) (*ApiClient, error) {
	client := &ApiClient{
		api: gosnappi.NewApi(),
	}

	log.Printf("Creating gosnappi client for HTTP server %s ...\n", location)
	client.api.NewHttpTransport().
		SetVerify(false).
		SetLocation(location)
	return client, nil
}

func (client *ApiClient) Api() gosnappi.GosnappiApi {
	return client.api
}

func (client *ApiClient) Close() error {
	log.Printf("Closing gosnappi client ...\n")
	return nil
	// TODO: add a Close func
}

func (client *ApiClient) LogStruct(prefix string, v interface{}) {
	if !optsDebug {
		return
	}

	log.Println(prefix + ":")
	log.Println(PrettyStructString(v))
}

func (client *ApiClient) GetConfigFromFile(location string, patch bool) (gosnappi.Config, error) {
	log.Printf("Reading gosnappi configuration %s ...\n", location)
	bytes, err := ioutil.ReadFile(location)
	if err != nil {
		return nil, fmt.Errorf("could not read configuration file %s: %v", location, err)
	}

	c := client.Api().NewConfig()
	if strings.HasSuffix(location, "json") {
		log.Println("Feeding JSON string to gosnappi config ...")
		if err := c.FromJson(string(bytes)); err != nil {
			return nil, fmt.Errorf("could not feed JSON to gosnappi config: %v", err)
		}
	} else if strings.HasSuffix(location, "yaml") {
		log.Println("Feeding YAML string to gosnappi config ...")
		if err := c.FromYaml(string(bytes)); err != nil {
			return nil, fmt.Errorf("could not feed YAML to gosnappi config: %v", err)
		}
	}

	return c, nil
}

func (client *ApiClient) GetConfig() (gosnappi.Config, error) {
	log.Println("Getting Config ...")
	v, err := client.Api().GetConfig()
	if err != nil {
		return nil, fmt.Errorf("could not GetConfig: %v", err)
	}

	if optsDebug {
		resYaml, err := v.ToYaml()
		if err != nil {
			return nil, err
		}
		log.Println("GetConfig Response: " + resYaml)
	}

	// TODO: extract warning and print it only if there's at least one
	return v, nil
}

func (client *ApiClient) SetConfig(v gosnappi.Config) error {
	log.Println("Setting Config ...")

	if optsDebug {
		reqYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetConfig Request: " + reqYaml)
	}

	res, err := client.Api().SetConfig(v)
	if err != nil {
		return fmt.Errorf("could not SetConfig: %v", err)
	}

	if optsDebug {
		resYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetConfig Response: " + resYaml)
	}

	LogWarnings(res.Warnings())
	return nil
}

func (client *ApiClient) SetTransmitState(v gosnappi.ControlState) error {
	log.Println("Setting TransmitState ...")

	if optsDebug {
		reqYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetTransmitState Request: " + reqYaml)
	}

	res, err := client.Api().SetControlState(v)
	if err != nil {
		return fmt.Errorf("could not SetTransmitState: %v", err)
	}

	if optsDebug {
		resYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetTransmitState Response: " + resYaml)
	}

	LogWarnings(res.Warnings())
	return nil
}

func (client *ApiClient) SetProtocolState(v gosnappi.ControlState) error {
	log.Println("Setting SetProtocolState ...")
	if optsDebug {
		reqYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetProtocolState Request: " + reqYaml)
	}

	res, err := client.Api().SetControlState(v)
	if err != nil {
		return fmt.Errorf("could not SetProtocolState: %v", err)
	}

	if optsDebug {
		resYaml, err := res.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetProtocolState Response: " + resYaml)
	}

	LogWarnings(res.Warnings())
	return nil
}

func (client *ApiClient) SetRouteState(v gosnappi.RouteState) error {
	log.Println("Setting RouteState ...")

	if optsDebug {
		reqYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetRouteState Request: " + reqYaml)
	}

	res, err := client.Api().SetRouteState(v)
	if err != nil {
		return fmt.Errorf("could not SetRouteState: %v", err)
	}

	if optsDebug {
		resYaml, err := res.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetRouteState Response: " + resYaml)
	}

	LogWarnings(res.Warnings())
	return nil
}

func (client *ApiClient) SetCaptureState(v gosnappi.CaptureState) error {
	log.Println("Setting CaptureState ...")

	if optsDebug {
		reqYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetCaptureState Request: " + reqYaml)
	}

	res, err := client.Api().SetCaptureState(v)
	if err != nil {
		return fmt.Errorf("could not SetCaptureState: %v", err)
	}

	if optsDebug {
		resYaml, err := res.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetCaptureState Response: " + resYaml)
	}

	LogWarnings(res.Warnings())
	return nil
}

func (client *ApiClient) SetLinkState(v gosnappi.LinkState) error {
	log.Println("Setting LinkState ...")

	if optsDebug {
		reqYaml, err := v.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetLinkState Request: " + reqYaml)
	}

	res, err := client.Api().SetLinkState(v)
	if err != nil {
		return fmt.Errorf("could not SetLinkState: %v", err)
	}

	if optsDebug {
		resYaml, err := res.ToYaml()
		if err != nil {
			return err
		}
		log.Println("SetLinkState Response: " + resYaml)
	}

	LogWarnings(res.Warnings())
	return nil
}

func (client *ApiClient) GetMetrics(r gosnappi.MetricsRequest) (gosnappi.MetricsResponse, error) {
	log.Println("Getting Metrics ...")

	if optsDebug {
		reqYaml, err := r.ToYaml()
		if err != nil {
			return nil, err
		}
		log.Println("GetMetrics Request: " + reqYaml)
	}

	res, err := client.Api().GetMetrics(r)
	if err != nil {
		return nil, fmt.Errorf("could not GetMetrics: %v", err)
	}

	if optsDebug {
		resYaml, err := res.ToYaml()
		if err != nil {
			return nil, err
		}
		log.Println("GetMetrics Response: " + resYaml)
	}

	return res, nil
}

func (client *ApiClient) GetStates(r gosnappi.StatesRequest) (gosnappi.StatesResponse, error) {
	log.Println("Getting States ...")

	if optsDebug {
		reqYaml, err := r.ToYaml()
		if err != nil {
			return nil, err
		}
		log.Println("GetStates Request: " + reqYaml)
	}

	res, err := client.Api().GetStates(r)
	if err != nil {
		return nil, fmt.Errorf("could not GetStates: %v", err)
	}

	if optsDebug {
		resYaml, err := res.ToYaml()
		if err != nil {
			return nil, err
		}
		log.Println("GetStates Response: " + resYaml)
	}

	return res, nil
}

func (client *ApiClient) GetCapture(r gosnappi.CaptureRequest) ([]byte, error) {
	log.Println("Getting Capture ...")

	if optsDebug {
		reqYaml, err := r.ToYaml()
		if err != nil {
			return nil, err
		}
		log.Println("GetCapture Request: " + reqYaml)
	}

	res, err := client.Api().GetCapture(r)
	if err != nil {
		return nil, fmt.Errorf("could not GetCapture: %v", err)
	}

	if optsDebug {
		log.Println("GetCapture Response: " + fmt.Sprint(len(res)) + " bytes")
	}

	return res, nil
}

func (client *ApiClient) StartTransmit(flowNames []string) error {
	s := client.Api().NewControlState()
	s.Traffic().FlowTransmit().SetState(gosnappi.StateTrafficFlowTransmitState.START)
	return client.SetTransmitState(s)
}

func (client *ApiClient) StopTransmit(flowNames []string) error {
	s := client.Api().NewControlState()
	s.Traffic().FlowTransmit().SetState(gosnappi.StateTrafficFlowTransmitState.STOP)
	return client.SetTransmitState(s)
}

func (client *ApiClient) StartProtocol() error {
	s := client.Api().NewControlState()
	s.Protocol().All().SetState(gosnappi.StateProtocolAllState.START)
	return client.SetProtocolState(s)
}

func (client *ApiClient) StopProtocol() error {
	s := client.Api().NewControlState()
	s.Protocol().All().SetState(gosnappi.StateProtocolAllState.STOP)
	return client.SetProtocolState(s)
}

func (client *ApiClient) AdvertiseRoutes(routeNames []string) error {
	s := client.Api().NewRouteState().
		SetNames(routeNames).
		SetState(gosnappi.RouteStateState.ADVERTISE)
	return client.SetRouteState(s)
}

func (client *ApiClient) WithdrawRoutes(routeNames []string) error {
	s := client.Api().NewRouteState().
		SetNames(routeNames).
		SetState(gosnappi.RouteStateState.WITHDRAW)
	return client.SetRouteState(s)
}

func (client *ApiClient) PauseTransmit(flowNames []string) error {
	s := client.Api().NewControlState()
	s.Traffic().FlowTransmit().SetState(gosnappi.StateTrafficFlowTransmitState.PAUSE)
	return client.SetTransmitState(s)
}

func (client *ApiClient) StartCapture(portNames []string) error {
	s := client.Api().NewCaptureState().
		SetState(gosnappi.CaptureStateState.START).
		SetPortNames(portNames)
	return client.SetCaptureState(s)
}

func (client *ApiClient) StopCapture(portNames []string) error {
	s := client.Api().NewCaptureState().
		SetState(gosnappi.CaptureStateState.STOP).
		SetPortNames(portNames)
	return client.SetCaptureState(s)
}

func (client *ApiClient) SetEmptyConfig() error {
	log.Println("Setting empty config ...")
	return client.SetConfig(client.Api().NewConfig())
}

func (client *ApiClient) GetPortMetrics(portNames []string, columnNames []string) (gosnappi.MetricsResponsePortMetricIter, error) {

	req := client.Api().NewMetricsRequest()
	req.Port().SetPortNames(portNames)

	if len(columnNames) > 0 {
		// TODO: need a way to filter column using strings instead of ENUMs
		return nil, fmt.Errorf("TODO: map strings to ENUMs for filtering column names")
	}

	res, err := client.GetMetrics(req)
	if err != nil {
		return nil, err
	}

	return res.PortMetrics(), nil
}

func (client *ApiClient) GetFlowMetrics(flowNames []string, columnNames []string) (gosnappi.MetricsResponseFlowMetricIter, error) {
	req := client.Api().NewMetricsRequest()
	req.Flow().SetFlowNames(flowNames)

	if len(columnNames) > 0 {
		// TODO: need a way to filter column using strings instead of ENUMs
		return nil, fmt.Errorf("TODO: map strings to ENUMs for filtering column names")
	}

	res, err := client.GetMetrics(req)
	if err != nil {
		return nil, err
	}

	return res.FlowMetrics(), nil
}

func (client *ApiClient) GetBgpv4Metrics(peerNames []string, columnNames []string) (gosnappi.MetricsResponseBgpv4MetricIter, error) {
	req := client.Api().NewMetricsRequest()
	req.Bgpv4().SetPeerNames(peerNames)

	if len(columnNames) > 0 {
		// TODO: need a way to filter column using strings instead of ENUMs
		return nil, fmt.Errorf("TODO: map strings to ENUMs for filtering column names")
	}

	res, err := client.GetMetrics(req)
	if err != nil {
		return nil, err
	}

	return res.Bgpv4Metrics(), nil
}

func (client *ApiClient) GetBgpv6Metrics(peerNames []string, columnNames []string) (gosnappi.MetricsResponseBgpv6MetricIter, error) {
	req := client.Api().NewMetricsRequest()
	req.Bgpv6().SetPeerNames(peerNames)

	if len(columnNames) > 0 {
		// TODO: need a way to filter column using strings instead of ENUMs
		return nil, fmt.Errorf("TODO: map strings to ENUMs for filtering column names")
	}

	res, err := client.GetMetrics(req)
	if err != nil {
		return nil, err
	}

	return res.Bgpv6Metrics(), nil
}

func (client *ApiClient) GetIsisMetrics(routerNames []string, columnNames []string) (gosnappi.MetricsResponseIsisMetricIter, error) {
	req := client.Api().NewMetricsRequest()
	req.Isis().SetRouterNames(routerNames)

	if len(columnNames) > 0 {
		// TODO: need a way to filter column using strings instead of ENUMs
		return nil, fmt.Errorf("TODO: map strings to ENUMs for filtering column names")
	}

	res, err := client.GetMetrics(req)
	if err != nil {
		return nil, err
	}

	return res.IsisMetrics(), nil
}

func (client *ApiClient) GetPortCapture(portName string) ([]byte, error) {

	req := client.Api().NewCaptureRequest().SetPortName(portName)

	res, err := client.GetCapture(req)
	if err != nil {
		return nil, err
	}

	return res, nil
}

func (client *ApiClient) GetIPv4NeighborsStates(ethernetNames []string) (gosnappi.StatesResponseNeighborsv4StateIter, error) {
	req := client.Api().NewStatesRequest()
	req.Ipv4Neighbors().SetEthernetNames(ethernetNames)

	res, err := client.GetStates(req)
	if err != nil {
		return nil, err
	}

	PrintStatesTable(&StatesTableOpts{
		ClearPrevious:       false,
		Ipv4NeighborsStates: res.Ipv4Neighbors(),
	})

	return res.Ipv4Neighbors(), nil
}

func (client *ApiClient) GetIPv6NeighborsStates(ethernetNames []string) (gosnappi.StatesResponseNeighborsv6StateIter, error) {
	req := client.Api().NewStatesRequest()
	req.Ipv6Neighbors().SetEthernetNames(ethernetNames)

	res, err := client.GetStates(req)
	if err != nil {
		return nil, err
	}

	PrintStatesTable(&StatesTableOpts{
		ClearPrevious:       false,
		Ipv6NeighborsStates: res.Ipv6Neighbors(),
	})

	return res.Ipv6Neighbors(), nil
}
