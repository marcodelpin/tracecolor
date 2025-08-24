# Tracecolor UDP Monitor - Quick Start

**Note**: All monitor scripts are located in the `tracecolor/` directory

## Starting the UDP Monitor

### Windows

#### 1. Batch File (CMD)
```cmd
cd tracecolor
monitor.bat
monitor.bat 8888
monitor.bat 8888 0.0.0.0
```

#### 2. PowerShell
```powershell
cd tracecolor
.\monitor.ps1
.\monitor.ps1 -Port 8888
.\monitor.ps1 -Port 8888 -Host 0.0.0.0
```

#### 3. Python (Cross-platform)
```cmd
cd tracecolor
python run_monitor.py
python run_monitor.py 8888
python run_monitor.py 8888 0.0.0.0
```

### Linux/Mac

#### 1. Direct Script (simplest)
```bash
cd tracecolor
./monitor
```
Or with custom port:
```bash
./monitor 8888
```

#### 2. Script Bash
```bash
cd tracecolor
./monitor.sh
```
Or with custom port and host:
```bash
./monitor.sh 8888 0.0.0.0
```

#### 3. Python Module
```bash
python3 -m tracecolor.monitor
```
With options:
```bash
python3 -m tracecolor.monitor --port 8888 --host 0.0.0.0
```

#### 4. After Installation (with pip install)
```bash
tracecolor-monitor
```

## Available Options

- `--port PORT` or `-p PORT`: UDP port (default: 9999)
- `--host HOST`: IP address (default: 127.0.0.1)
- `--help` or `-h`: Show help

## Quick Test

### Windows
In a CMD or PowerShell terminal, start the monitor:
```cmd
cd tracecolor
monitor.bat
```

In another terminal, run the test:
```cmd
python test_tracecolor_loop.py
```

### Linux/Mac
In a terminal, start the monitor:
```bash
cd tracecolor
./monitor
```

In another terminal, run the test:
```bash
python3 test_tracecolor_loop.py
```

## Output Colors

- **TRACE** (T): Gray
- **DEBUG** (D): Cyan  
- **PROGRESS** (P): Blue
- **INFO** (I): Green
- **WARNING** (W): Yellow
- **ERROR** (E): Red
- **CRITICAL** (C): Bold red

## Troubleshooting

If the port is already in use:
```bash
lsof -i :9999
# Or change port
cd tracecolor
./monitor 8888
```