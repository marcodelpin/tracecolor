#!/bin/bash
# Quick script to run UDP test with dependencies

echo "Installing dependencies..."
pip3 install --user loguru colorlog pyyaml 2>/dev/null || pip install --user loguru colorlog pyyaml

echo
echo "Starting UDP test..."
echo "Make sure monitor is running in another terminal!"
echo
sleep 2

cd /mnt/s/Commesse/60-69_Miei/61_Miei/61.02_Personal_GitHub_Projects/mlog-github-repo/public
python3 test_udp_live.py