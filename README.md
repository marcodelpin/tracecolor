# tracecolor

Enhanced Python logger with colorized output, custom levels, and production-ready features. One import, sensible defaults, enterprise capabilities when needed.

## Features

### Core
- Custom **TRACE** level (below DEBUG) and **PROGRESS** level (between DEBUG and INFO)
- Colorized console output with Loguru backend
- Rate-limiting for PROGRESS messages (1/sec per call site)
- Simple API: `logger = tracecolor(__name__)`

### v1.0 Features
- **JSON Structured Output**: Machine-parseable JSONL for ELK/Loki/Grafana (`enable_json=True`)
- **Context Binding**: Correlation IDs via `bind()` and `context()` for request tracing
- **HTTP Log Aggregation**: Push logs to Loki, Seq, or any HTTP endpoint (`enable_http=True`)
- **OpenTelemetry Integration**: Auto-inject trace_id/span_id (zero-config when `opentelemetry-api` installed)
- **UDP Remote Monitoring**: Real-time debug monitoring with `tracecolor-monitor` CLI
- **File Logging**: Automatic rotation, compression, and retention
- **Auto-Configuration**: Detects `.tracecolor`, `tracecolor.toml`, `.yml`, `.json`

## Installation

```bash
# Recommended
uv pip install tracecolor

# Or with pip
pip install tracecolor
```

### Optional Dependencies
```bash
uv pip install tracecolor[yaml]   # YAML config support
uv pip install tracecolor[otel]   # OpenTelemetry integration
uv pip install tracecolor[dev]    # Development tools
```

## Quick Start

```python
from tracecolor import tracecolor

logger = tracecolor(__name__)

logger.trace("Detailed tracing information")
logger.debug("Debugging information")
logger.progress("Progress update (rate-limited)")
logger.info("General information")
logger.warning("Warning message")
logger.error("Error message")
logger.critical("Critical error")
```

## All Features Enabled

```python
logger = tracecolor(
    __name__,
    enable_console=True,       # Colorized console (default)
    enable_file=True,          # File logging with rotation
    enable_json=True,          # JSON structured output
    enable_udp=True,           # UDP real-time monitoring
    enable_http=True,          # HTTP log aggregation
    log_dir="./logs",
    http_url="http://loki:3100/loki/api/v1/push",
)
```

## Context Binding & Correlation IDs

```python
# Persistent binding
logger = tracecolor(__name__, enable_json=True)
request_logger = logger.bind(request_id="abc-123", user_id="u42")
request_logger.info("processing request")  # includes request_id, user_id in JSON

# Scoped context
with logger.context(request_id="req-456", session_id="sess-1"):
    logger.info("within request scope")   # has request_id + session_id
logger.info("outside scope")              # no request_id/session_id

# Chaining
logger.bind(service="api").bind(version="1.0").info("chained context")
```

## JSON Structured Output

```python
# JSON to file (JSONL format)
logger = tracecolor(__name__, enable_json=True, log_dir="./logs")
# → writes to ./logs/<name>.jsonl

# JSON to specific file
logger = tracecolor(__name__, enable_json=True, json_file="app.jsonl")

# JSON to stdout (alongside colorized console on stderr)
logger = tracecolor(__name__, enable_json=True)
```

## HTTP Log Aggregation

```python
# Push to Loki
logger = tracecolor(
    __name__,
    enable_http=True,
    http_url="http://loki:3100/loki/api/v1/push"
)

# Logs are batched (10 messages) and flushed every 5 seconds
logger.info("this goes to Loki")
```

## OpenTelemetry Integration

```bash
uv pip install tracecolor[otel]
```

```python
# Zero-config: auto-detects opentelemetry-api
logger = tracecolor(__name__, enable_json=True)

# trace_id and span_id automatically injected into every log record
# Visible in JSON output as otel_trace_id and otel_span_id
```

## External Configuration

Tracecolor auto-detects config files in the current directory:
1. `.tracecolor` (auto-detects TOML/YAML/JSON)
2. `tracecolor.toml`
3. `tracecolor.yml` / `tracecolor.yaml`
4. `tracecolor.json`

```toml
# .tracecolor (TOML)
[console]
enabled = true
level = "TRACE"

[file]
enabled = true
dir = "./logs"

[json]
enabled = true
file = "./logs/app.jsonl"

[udp]
enabled = false
host = "127.0.0.1"
port = 9999
```

## UDP Remote Monitoring

```bash
# Terminal 1: your application
python your_app.py

# Terminal 2: monitor
tracecolor-monitor
tracecolor-monitor --host 0.0.0.0 --port 8888
```

## Color Scheme

| Level | Color |
|-------|-------|
| TRACE | Gray |
| DEBUG | Cyan |
| PROGRESS | Blue |
| INFO | Green |
| WARNING | Yellow |
| ERROR | Red |
| CRITICAL | Bold Red |

## Architecture (v1.0)

```
tracecolor/
├── __init__.py        # Exports: tracecolor, create_enhanced_logger
├── tracecolor.py      # Core logger class, bind/context, sink wiring
├── config.py          # Auto-config detection, TOML/YAML/JSON parsing
├── sinks.py           # UDPSink, HTTPSink (batched, non-blocking)
├── rate_limiter.py    # ProgressRateLimiter (1/sec/callsite)
└── monitor.py         # tracecolor-monitor CLI (UDP receiver)
```

## License

MIT
