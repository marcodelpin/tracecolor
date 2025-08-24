# UDP Monitor Usage Guide

## Installation

When you install tracecolor from PyPI, the monitor is automatically available as a command-line tool:

```bash
pip install tracecolor
```

## Starting the Monitor

After installation, you have **three ways** to start the UDP monitor:

### 1. Using the Console Script (Recommended)
```bash
# Default: localhost:9999
tracecolor-monitor

# Custom host and port
tracecolor-monitor --host 0.0.0.0 --port 8888

# Help
tracecolor-monitor --help
```

### 2. Using Python Module
```bash
# Default: localhost:9999
python -m tracecolor.monitor

# Custom host and port
python -m tracecolor.monitor --host 0.0.0.0 --port 8888
```

### 3. Direct Script Execution
```bash
# If you have the source code
python path/to/monitor.py --host 127.0.0.1 --port 9999
```

## Usage Examples

### Basic Setup (Two Terminals)

**Terminal 1 - Start the Monitor:**
```bash
tracecolor-monitor
```
Output:
```
========================================
Tracecolor UDP Monitor v0.7.0
========================================
Listening on 127.0.0.1:9999
Press Ctrl+C to stop
----------------------------------------
```

**Terminal 2 - Send Logs:**
```python
from tracecolor import tracecolor

# Create logger with UDP enabled
logger = tracecolor(__name__, 
                   enable_udp=True, 
                   udp_host="127.0.0.1", 
                   udp_port=9999)

# Send logs
logger.info("Application started")
logger.warning("This is a warning")
logger.error("An error occurred")
```

The monitor will display:
```
[2025-08-24 10:00:00] INFO | Application started
[2025-08-24 10:00:01] WARNING | This is a warning
[2025-08-24 10:00:02] ERROR | An error occurred
```

### Remote Monitoring

Monitor logs from another machine:

**On Monitor Machine:**
```bash
# Listen on all interfaces
tracecolor-monitor --host 0.0.0.0 --port 9999
```

**On Application Machine:**
```python
logger = tracecolor(__name__, 
                   enable_udp=True, 
                   udp_host="192.168.1.100",  # Monitor machine IP
                   udp_port=9999)
```

### Multiple Applications

Monitor multiple applications on different ports:

```bash
# Terminal 1: Web app monitor
tracecolor-monitor --port 9001

# Terminal 2: API monitor  
tracecolor-monitor --port 9002

# Terminal 3: Worker monitor
tracecolor-monitor --port 9003
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `--host` | 127.0.0.1 | IP address to bind to |
| `--port` | 9999 | UDP port to listen on |
| `--version` | - | Show version information |
| `--help` | - | Show help message |

## Troubleshooting

### "Command not found"
- Ensure tracecolor is installed: `pip show tracecolor`
- Check PATH: `echo $PATH`
- Use Python module: `python -m tracecolor.monitor`

### "Address already in use"
- Another process is using the port
- Try a different port: `tracecolor-monitor --port 9998`

### No messages received
- Check firewall settings
- Ensure logger has `enable_udp=True`
- Verify host/port match between logger and monitor
- Test with localhost first

### Windows Issues
- Windows Firewall may block UDP
- Run as Administrator if needed
- Use `127.0.0.1` instead of `localhost`

## Integration Examples

### Docker Compose
```yaml
services:
  log-monitor:
    image: python:3.10
    command: pip install tracecolor && tracecolor-monitor --host 0.0.0.0
    ports:
      - "9999:9999/udp"
```

### Systemd Service
```ini
[Unit]
Description=Tracecolor UDP Monitor
After=network.target

[Service]
Type=simple
User=logger
ExecStart=/usr/local/bin/tracecolor-monitor --host 0.0.0.0 --port 9999
Restart=always

[Install]
WantedBy=multi-user.target
```

### PM2 Process Manager
```bash
pm2 start tracecolor-monitor -- --host 0.0.0.0 --port 9999
pm2 save
pm2 startup
```

## Security Notes

- Default binding to `127.0.0.1` (localhost only) is secure
- Binding to `0.0.0.0` exposes monitor to network
- No authentication built-in - use firewall rules
- Consider VPN for remote monitoring
- UDP packets are not encrypted