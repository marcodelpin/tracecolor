@echo off
echo ============================================================
echo TRACECOLOR QUICK TEST (Windows)
echo ============================================================
echo.

echo Checking Python...
python --version
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python.
    pause
    exit /b 1
)

echo.
echo Installing dependencies...
pip install loguru colorlog pyyaml
if errorlevel 1 (
    echo [WARNING] Some dependencies may have failed to install
)

echo.
echo Testing import...
python -c "from tracecolor import tracecolor; logger = tracecolor('test'); logger.info('Import successful!'); logger.trace('Trace test'); logger.progress('Progress test')"
if errorlevel 1 (
    echo [ERROR] Import test failed
    pause
    exit /b 1
)

echo.
echo ============================================================
echo TEST SUCCESSFUL!
echo ============================================================
echo.
echo To test UDP monitor:
echo   1. Open new terminal and run: tracecolor\monitor.bat
echo   2. In another terminal run: python tracecolor\test_udp.py
echo.
pause