# Test Instructions for Tracecolor

## Prerequisites

Before testing, ensure you have the required dependencies installed:

### Option 1: Windows (PowerShell/CMD)
```powershell
# Navigate to public directory
cd S:\Commesse\60-69_Miei\61_Miei\61.02_Personal_GitHub_Projects\mlog-github-repo\public

# Install dependencies
pip install loguru colorlog pyyaml

# Install tracecolor in development mode
pip install -e .
```

### Option 2: WSL/Linux
```bash
# Install pip if not available
sudo apt update
sudo apt install python3-pip

# Navigate to public directory
cd /mnt/s/Commesse/60-69_Miei/61_Miei/61.02_Personal_GitHub_Projects/mlog-github-repo/public

# Install dependencies
pip3 install loguru colorlog pyyaml

# Install tracecolor in development mode
pip3 install -e .
```

## Testing Components

### 1. Basic Functionality Test
```bash
# From public directory
python test_all_features.py
```

### 2. UDP Monitor Test

**Terminal 1 - Start Monitor:**
```bash
# Windows
python tracecolor\monitor.py --host 127.0.0.1 --port 9999

# Or use the batch file
tracecolor\monitor.bat

# WSL/Linux
python3 tracecolor/monitor.py --host 127.0.0.1 --port 9999
```

**Terminal 2 - Send Test Messages:**
```bash
# Windows
python tracecolor\test_udp.py

# WSL/Linux
python3 tracecolor/test_udp.py
```

### 3. Quick Import Test
```python
# Test from Python interpreter
python
>>> from tracecolor import tracecolor
>>> logger = tracecolor(__name__)
>>> logger.info("Test message")
>>> logger.trace("Trace level test")
>>> logger.progress("Progress test")
>>> exit()
```

### 4. File Logging Test
```python
# Create a test script
from tracecolor import tracecolor
logger = tracecolor(__name__, enable_file=True, log_dir="logs")
logger.info("This should appear in logs/tracecolor_*.log")
```

## Expected Results

✅ **Console Output**: Colorized log messages with timestamps
✅ **UDP Monitor**: Real-time log streaming to monitor window
✅ **File Logging**: Rotating log files in specified directory
✅ **Progress Messages**: Rate-limited to 1 per second per call site
✅ **All Log Levels**: TRACE, DEBUG, PROGRESS, INFO, WARNING, ERROR, CRITICAL

## Troubleshooting

### "No module named 'loguru'"
Install loguru: `pip install loguru`

### "No module named 'tracecolor'"
Install in development mode: `pip install -e .` from public directory

### UDP Monitor not receiving messages
- Check firewall settings
- Ensure both scripts use same host/port (default: 127.0.0.1:9999)
- Try using localhost instead of 127.0.0.1

### Permission denied on monitor scripts
```bash
# Make executable on Linux/WSL
chmod +x tracecolor/monitor.sh
chmod +x tracecolor/monitor
```

## Complete Test Checklist

- [ ] Install dependencies (loguru, colorlog, pyyaml)
- [ ] Install tracecolor in development mode
- [ ] Run basic functionality test
- [ ] Test UDP monitor (two terminals)
- [ ] Test file logging
- [ ] Test import from different directory
- [ ] Verify all log levels work
- [ ] Check progress rate limiting