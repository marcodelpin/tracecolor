#!/bin/bash
# Tracecolor UDP Monitor Launcher
# Usage: ./monitor.sh [port] [host]

PORT=${1:-9999}
HOST=${2:-127.0.0.1}

echo "Starting Tracecolor UDP Monitor"
echo "Listening on $HOST:$PORT"
echo "Press Ctrl+C to stop"
echo ""

python3 -m tracecolor.monitor --port "$PORT" --host "$HOST"