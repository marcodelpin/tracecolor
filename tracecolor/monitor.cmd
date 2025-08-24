@echo off
REM Quick monitor launcher for Windows
REM Usage: monitor [port]

if "%1"=="" (
    python monitor.py
) else (
    python monitor.py --port %1
)