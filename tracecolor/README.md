# Tracecolor

Enhanced Python logging library with colorized output, custom log levels (TRACE, PROGRESS), and UDP remote monitoring support.

## Features

- **Custom Log Levels**: TRACE (5) and PROGRESS (15) in addition to standard levels
- **Colorized Console Output**: Different colors for each log level
- **Rate Limiting**: Automatic rate limiting for PROGRESS messages (1 per second per call site)
- **UDP Remote Monitoring**: Real-time log streaming over UDP
- **Dual Backend Support**: Loguru (preferred) or standard logging fallback
- **File Logging**: Rotation, compression, and retention policies
- **External Configuration**: JSON/YAML configuration file support

## Installation

### Prerequisites

```bash
# Optional but recommended for enhanced features
pip install loguru>=0.7.2

# Optional for YAML config support
pip install pyyaml
```

### Usage

```python
from tracecolor import tracecolor

# Basic usage
logger = tracecolor(__name__)
logger.trace("Detailed trace information")
logger.debug("Debug message")
logger.progress("Progress update (rate-limited)")
logger.info("Information message")
logger.warning("Warning message")
logger.error("Error message")
logger.critical("Critical message")
```

## UDP Remote Monitoring

### Enable UDP Logging

```python
from tracecolor import tracecolor

# Enable UDP logging
logger = tracecolor(
    __name__,
    enable_udp=True,
    udp_host="127.0.0.1",
    udp_port=9999
)

logger.info("This message will be sent via UDP")
```

### Run the UDP Monitor

```bash
# In a separate terminal, start the monitor
python -m tracecolor.monitor

# Or with custom host/port
python -m tracecolor.monitor --host 0.0.0.0 --port 8888
```

### UDP Message Format

Messages are sent in plain text format:
```
{level[0]} |{timestamp}| [{logger}:{function}:{line}] {message}
```

Example:
```
I |2024-01-15 10:23:45.123| [myapp:main:42] Application started
```

## Enhanced Features

### File Logging

```python
logger = tracecolor(
    __name__,
    enable_file=True,
    log_dir="./logs",
    log_level="DEBUG"
)
```

Features:
- Automatic rotation at 10MB
- 7 days retention
- ZIP compression of old logs

### External Configuration

Create a `logging.json`:
```json
{
    "logging": {
        "enable_console": true,
        "enable_file": true,
        "enable_udp": true,
        "log_dir": "./logs",
        "udp_host": "127.0.0.1",
        "udp_port": 9999,
        "log_level": "TRACE"
    }
}
```

Use it:
```python
logger = tracecolor(__name__, config_file="logging.json")
```

### Multiple Loggers

Each logger instance is independent:

```python
logger1 = tracecolor("module1", enable_udp=True)
logger2 = tracecolor("module2", enable_udp=True)

logger1.info("From module1")  # Only sent from logger1
logger2.info("From module2")  # Only sent from logger2
```

## Testing UDP Functionality

Run the test suite:

```bash
# Terminal 1: Start the monitor
python -m tracecolor.monitor

# Terminal 2: Run tests
python tracecolor/test_udp.py
```

## Log Levels

| Level | Value | Color | Single Char | Description |
|-------|-------|-------|-------------|-------------|
| TRACE | 5 | Gray | T | Detailed debugging |
| DEBUG | 10 | Cyan | D | Debug information |
| PROGRESS | 15 | Blue | P | Progress updates (rate-limited) |
| INFO | 20 | Green | I | General information |
| WARNING | 30 | Yellow | W | Warning messages |
| ERROR | 40 | Red | E | Error messages |
| CRITICAL | 50 | Bright Red | C | Critical errors |

## Progress Rate Limiting

PROGRESS messages are automatically rate-limited to 1 message per second per call site:

```python
for i in range(100):
    logger.progress(f"Processing item {i}")  # Only logs once per second
    time.sleep(0.1)
```

## Troubleshooting

### UDP Messages Not Received

1. **Check monitor is running**: Start `python -m tracecolor.monitor` first
2. **Verify port availability**: Ensure port 9999 (or custom port) is not in use
3. **Firewall settings**: UDP port must be open for local communication
4. **Network issues**: Test with `127.0.0.1` first before using network addresses

### Socket Errors

The UDP sink uses non-blocking sockets and silently ignores network errors to prevent disrupting the main application. If UDP fails, logging continues to console/file normally.

## Architecture

```
tracecolor/
├── tracecolor.py      # Main logger implementation
├── monitor.py         # UDP monitor for receiving logs
├── test_udp.py        # Test suite for UDP functionality
└── README.md          # This file
```

## Version History

- **0.6.0**: Fixed UDP logging, improved monitor, added test suite
- **0.5.0**: Initial release with Loguru backend support

## License

Internal use - Marco Del Pin projects