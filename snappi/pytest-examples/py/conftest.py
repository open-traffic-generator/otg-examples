import pytest
import snappi

import utils
from opentelemetry import trace
from opentelemetry.instrumentation.grpc import GrpcInstrumentorClient
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
)
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)


@pytest.fixture(scope="session")
def tracer():
    import warnings

    warnings.filterwarnings("ignore", category=DeprecationWarning)
    provider = TracerProvider(
        resource=Resource.create({"service.name": "otg-ci-e2e-tests"})
    )
    trace.set_tracer_provider(provider)
    if utils.settings.otlp_grpc_server is not None:
        otlp_exporter = OTLPSpanExporter(
            endpoint=utils.settings.otlp_grpc_server, insecure=True
        )
        span_processor = BatchSpanProcessor(otlp_exporter)
        provider.add_span_processor(span_processor)
    tracer = trace.get_tracer(__name__)
    GrpcInstrumentorClient().instrument()
    return tracer


@pytest.fixture()
def tracer_api(request, tracer) -> snappi.Api:
    with tracer.start_as_current_span(request.node.name):
        api = snappi.api(location=utils.settings.grpc_server,
                         transport="grpc", verify=False)
        api.request_timeout = 180
        yield api


def pytest_addoption(parser):
    # called before running tests to register command line options for pytest
    parser.addoption("--max_port_count",
                     type=int,
                     action="store",
                     default=1024)

    parser.addoption("--frame_size",
                     type=int,
                     action="store",
                     default='9000')

    parser.addoption("--frame_sizes",
                     type=str,
                     action="store",
                     default='768,1024,1518,9000')

    parser.addoption("--duration",
                     type=int,
                     action="store",
                     default='10')

    parser.addoption("--line_rate_per_flow",
                     type=float,
                     action="store",
                     default='100')
    
    parser.addoption("--direction",
                     type=str,
                     action="store",
                     default='upstream')

    parser.addoption("--te_host_user",
                     type=str,
                     action="store",
                     default='ixia_c_cicd')

    parser.addoption("--te_host_pass",
                     type=str,
                     action="store",
                     default='ixia123')

    utils.settings.register_pytest_command_line_options(parser)


def pytest_configure(config):
    # callled before running (configuring) tests to load global settings with
    # values provided over command line
    utils.settings.load_from_pytest_command_line(config)


@pytest.fixture(scope='session')
def settings():
    return utils.settings


@pytest.fixture(scope='session')
def max_port_count(pytestconfig):
    max_port_count = pytestconfig.getoption("--max_port_count")
    return max_port_count

@pytest.fixture(scope='session')
def frame_size(pytestconfig):
    frame_size = pytestconfig.getoption("--frame_size")
    return frame_size

@pytest.fixture(scope='session')
def frame_sizes(pytestconfig):
    frame_sizes = pytestconfig.getoption("--frame_sizes")
    return frame_sizes

@pytest.fixture(scope='session')
def duration(pytestconfig):
    duration = pytestconfig.getoption("--duration")
    return duration

@pytest.fixture(scope='session')
def line_rate_per_flow(pytestconfig):
    line_rate_per_flow = pytestconfig.getoption("--line_rate_per_flow")
    return line_rate_per_flow

@pytest.fixture(scope='session')
def direction(pytestconfig):
    direction = pytestconfig.getoption("--direction")
    return direction

@pytest.fixture(scope='session')
def te_host_user(pytestconfig):
    te_host_user = pytestconfig.getoption("--te_host_user")
    return te_host_user


@pytest.fixture(scope='session')
def te_host_pass(pytestconfig):
    te_host_pass = pytestconfig.getoption("--te_host_pass")
    return te_host_pass


@pytest.fixture(scope='session')
def api():
    # handle to make API calls
    if utils.settings.http_transport:
        api = snappi.api(location=utils.settings.http_server,
                         version_check=True)
        yield api
    else:
        api = snappi.api(location=utils.settings.grpc_server,
                         transport=snappi.Transport.GRPC,
                         version_check=True)
        api.request_timeout = 180
        yield api


@pytest.fixture(scope='session')
def config():
    pass
