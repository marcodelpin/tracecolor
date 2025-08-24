@echo off
REM Quick test for UDP monitor on Windows
REM Sends a test message to the monitor

echo Testing UDP Monitor...
echo.

python -c "import socket; sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); sock.sendto(b'I |2025-01-01 12:00:00.000| [test:main:1] Test message from Windows', ('127.0.0.1', 9999)); print('Test message sent to localhost:9999')"

echo.
echo If the monitor is running, you should see the test message there.
pause