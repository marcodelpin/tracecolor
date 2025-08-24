#!/bin/bash
# Quick test script for tracecolor

echo "============================================================"
echo "TRACECOLOR QUICK TEST (Linux/WSL)"
echo "============================================================"
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Python
echo "Checking Python..."
if command -v python3 &> /dev/null; then
    python3 --version
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    python --version
    PYTHON_CMD="python"
else
    echo -e "${RED}[ERROR] Python not found${NC}"
    exit 1
fi

# Check/Install pip
echo
echo "Checking pip..."
if ! $PYTHON_CMD -m pip --version &> /dev/null; then
    echo -e "${YELLOW}Installing pip...${NC}"
    sudo apt update
    sudo apt install -y python3-pip
fi

# Install dependencies
echo
echo "Installing dependencies..."
$PYTHON_CMD -m pip install --user loguru colorlog pyyaml

# Test import
echo
echo "Testing import..."
$PYTHON_CMD -c "
from tracecolor import tracecolor
logger = tracecolor('test')
logger.info('Import successful!')
logger.trace('Trace test')
logger.progress('Progress test')
print('[OK] All basic tests passed')
"

if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}TEST SUCCESSFUL!${NC}"
    echo -e "${GREEN}============================================================${NC}"
    echo
    echo "To test UDP monitor:"
    echo "  1. Open new terminal and run: $PYTHON_CMD tracecolor/monitor.py"
    echo "  2. In another terminal run: $PYTHON_CMD tracecolor/test_udp.py"
else
    echo
    echo -e "${RED}[ERROR] Import test failed${NC}"
    exit 1
fi