@echo off
REM Tracecolor UDP Monitor Launcher for Windows
REM Usage: monitor.bat [port] [host]

set PORT=%1
set HOST=%2

if "%PORT%"=="" set PORT=9999
if "%HOST%"=="" set HOST=127.0.0.1

echo Starting Tracecolor UDP Monitor
echo Listening on %HOST%:%PORT%
echo Press Ctrl+C to stop
echo.

python monitor.py --port %PORT% --host %HOST%