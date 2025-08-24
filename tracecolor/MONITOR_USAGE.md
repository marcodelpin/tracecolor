# Tracecolor UDP Monitor - Quick Start

**Nota**: Tutti gli script del monitor si trovano nella directory `tracecolor/`

## Avviare il Monitor UDP

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

#### 1. Script Diretto (più semplice)
```bash
cd tracecolor
./monitor
```
O con porta personalizzata:
```bash
./monitor 8888
```

#### 2. Script Bash
```bash
cd tracecolor
./monitor.sh
```
O con porta e host personalizzati:
```bash
./monitor.sh 8888 0.0.0.0
```

#### 3. Modulo Python
```bash
python3 -m tracecolor.monitor
```
Con opzioni:
```bash
python3 -m tracecolor.monitor --port 8888 --host 0.0.0.0
```

#### 4. Dopo Installazione (con pip install)
```bash
tracecolor-monitor
```

## Opzioni Disponibili

- `--port PORT` o `-p PORT`: Porta UDP (default: 9999)
- `--host HOST`: Indirizzo IP (default: 127.0.0.1)
- `--help` o `-h`: Mostra aiuto

## Test Rapido

### Windows
In un terminale CMD o PowerShell avvia il monitor:
```cmd
cd tracecolor
monitor.bat
```

In un altro terminale esegui il test:
```cmd
python test_tracecolor_loop.py
```

### Linux/Mac
In un terminale avvia il monitor:
```bash
cd tracecolor
./monitor
```

In un altro terminale esegui il test:
```bash
python3 test_tracecolor_loop.py
```

## Colori Output

- **TRACE** (T): Grigio
- **DEBUG** (D): Ciano  
- **PROGRESS** (P): Blu
- **INFO** (I): Verde
- **WARNING** (W): Giallo
- **ERROR** (E): Rosso
- **CRITICAL** (C): Rosso grassetto

## Troubleshooting

Se la porta è già in uso:
```bash
lsof -i :9999
# Oppure cambia porta
cd tracecolor
./monitor 8888
```