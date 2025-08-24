#!/usr/bin/env python3
"""
Test script to verify all tracecolor features work correctly.
Run this before pushing to GitHub/PyPI.
"""

import sys
import os
import time
import threading
import socket
from pathlib import Path

# Add current directory to path for testing
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

print("=" * 60)
print("TRACECOLOR COMPREHENSIVE TEST")
print("=" * 60)

# Check if Loguru is available
try:
    import loguru
    print("[OK] Loguru is installed")
except ImportError:
    print("[WARNING] Loguru not installed - install with: pip install loguru")
    print("Some features will be limited without Loguru")

# Test 1: Basic Import
print("\n1. Testing basic import...")
try:
    from tracecolor import tracecolor, create_enhanced_logger
    print("[OK] Import successful")
except Exception as e:
    print(f"[FAIL] Import failed: {e}")
    sys.exit(1)

# Test 2: Basic Logging
print("\n2. Testing basic logging (console output)...")
try:
    logger = tracecolor(__name__)
    logger.trace("This is a TRACE message")
    logger.debug("This is a DEBUG message")
    logger.info("This is an INFO message")
    logger.warning("This is a WARNING message")
    logger.error("This is an ERROR message")
    logger.critical("This is a CRITICAL message")
    print("[OK] Basic logging works")
except Exception as e:
    print(f"[FAIL] Basic logging failed: {e}")

# Test 3: Progress Logging (Rate Limited)
print("\n3. Testing PROGRESS logging (rate limited)...")
try:
    for i in range(3):
        logger.progress(f"Progress update {i+1}")
        time.sleep(0.5)  # Should be rate limited to 1/sec
    print("[OK] Progress logging works")
except Exception as e:
    print(f"[FAIL] Progress logging failed: {e}")

# Test 4: File Logging
print("\n4. Testing file logging...")
try:
    log_dir = Path("test_logs")
    logger_file = tracecolor("test_file", enable_file=True, log_dir=log_dir)
    logger_file.info("Test message to file")
    
    # Check if log file was created
    if log_dir.exists() and any(log_dir.glob("*.log")):
        print(f"[OK] Log file created in {log_dir}")
        # Clean up
        import shutil
        shutil.rmtree(log_dir)
    else:
        print("[WARNING] Log file not created")
except Exception as e:
    print(f"[FAIL] File logging failed: {e}")

# Test 5: UDP Monitor (Start monitor separately)
print("\n5. Testing UDP logging...")
print("   To test UDP monitor:")
print("   1. Open a new terminal")
print("   2. Run: python tracecolor/monitor.py --host 127.0.0.1 --port 9999")
print("   3. Then run this test again to see UDP messages")

def test_udp():
    try:
        # Create logger with UDP enabled
        logger_udp = tracecolor("test_udp", enable_udp=True, udp_host="127.0.0.1", udp_port=9999)
        
        # Send some test messages
        logger_udp.info("UDP Test: INFO message")
        logger_udp.warning("UDP Test: WARNING message")
        logger_udp.error("UDP Test: ERROR message")
        
        print("[OK] UDP messages sent (check monitor window)")
    except Exception as e:
        print(f"[FAIL] UDP logging failed: {e}")

test_udp()

# Test 6: Enhanced Logger Factory
print("\n6. Testing enhanced logger factory...")
try:
    enhanced = create_enhanced_logger(
        "enhanced_test",
        enable_console=True,
        enable_file=False,
        enable_udp=False,
        log_level="DEBUG"
    )
    enhanced.debug("Enhanced logger test message")
    print("[OK] Enhanced logger factory works")
except Exception as e:
    print(f"[FAIL] Enhanced logger failed: {e}")

# Test 7: Exception Logging
print("\n7. Testing exception logging...")
try:
    logger_exc = tracecolor("test_exception")
    try:
        # Intentionally cause an error
        result = 1 / 0
    except Exception:
        logger_exc.exception("Caught an exception")
    print("[OK] Exception logging works")
except Exception as e:
    print(f"[FAIL] Exception logging failed: {e}")

print("\n" + "=" * 60)
print("TEST SUMMARY")
print("=" * 60)
print("All basic tests completed.")
print("\nTo fully test UDP monitoring:")
print("1. Start monitor: python tracecolor/monitor.py")
print("2. Run test_udp.py in tracecolor directory")
print("\nTo test installation:")
print("1. pip install -e . (from public directory)")
print("2. Test import from another directory")
print("=" * 60)