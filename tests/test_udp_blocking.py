#!/usr/bin/env python3
"""
Test that tracecolor doesn't block with UDP enabled/disabled
even when no monitor is listening
"""

import time
import threading
from tracecolor import tracecolor

def test_udp_enabled_no_monitor():
    """Test with UDP enabled but no monitor running"""
    print("\n" + "="*60)
    print("TEST 1: UDP ENABLED - NO MONITOR RUNNING")
    print("="*60)
    
    logger = tracecolor("test_udp_on", enable_udp=True, udp_port=9999)
    
    start = time.time()
    
    # Test various log levels with different content
    logger.trace("TRACE: Testing with UDP enabled, no monitor")
    logger.debug("DEBUG: Special chars: 😀 ñ ∑ π")
    logger.info("INFO: Normal logging should not block")
    logger.progress("PROGRESS: Rate-limited message")
    logger.warning("WARNING: Even without monitor listening")
    logger.error("ERROR: Everything should work fine")
    logger.critical("CRITICAL: No blocking should occur!")
    
    # Rapid fire test - should not accumulate or block
    for i in range(100):
        logger.info(f"Rapid test {i}: UDP should be fire-and-forget")
    
    elapsed = time.time() - start
    print(f"\n✓ Test completed in {elapsed:.3f} seconds")
    
    if elapsed > 1.0:
        print("⚠️ WARNING: Test took longer than expected! Possible blocking issue.")
        return False
    else:
        print("✓ PASS: No blocking detected with UDP enabled")
        return True

def test_udp_disabled():
    """Test with UDP disabled (default behavior)"""
    print("\n" + "="*60)
    print("TEST 2: UDP DISABLED")
    print("="*60)
    
    logger = tracecolor("test_udp_off", enable_udp=False)
    
    start = time.time()
    
    # Same tests but with UDP disabled
    logger.trace("TRACE: Testing with UDP disabled")
    logger.debug("DEBUG: Should work normally")
    logger.info("INFO: Console output only")
    logger.progress("PROGRESS: Rate-limited as usual")
    logger.warning("WARNING: No network activity")
    logger.error("ERROR: Pure local logging")
    logger.critical("CRITICAL: Fast and responsive")
    
    # Rapid fire test
    for i in range(100):
        logger.info(f"Rapid test {i}: Local logging only")
    
    elapsed = time.time() - start
    print(f"\n✓ Test completed in {elapsed:.3f} seconds")
    
    if elapsed > 1.0:
        print("⚠️ WARNING: Test took longer than expected!")
        return False
    else:
        print("✓ PASS: Normal operation with UDP disabled")
        return True

def test_threading():
    """Test that UDP doesn't cause threading issues"""
    print("\n" + "="*60)
    print("TEST 3: MULTI-THREADED WITH UDP ENABLED")
    print("="*60)
    
    logger = tracecolor("test_threads", enable_udp=True, udp_port=9999)
    
    def worker(thread_id):
        for i in range(20):
            logger.info(f"Thread {thread_id}: Message {i}")
            time.sleep(0.01)
    
    start = time.time()
    
    # Create multiple threads all logging simultaneously
    threads = []
    for i in range(5):
        t = threading.Thread(target=worker, args=(i,))
        threads.append(t)
        t.start()
    
    # Wait for all threads
    for t in threads:
        t.join()
    
    elapsed = time.time() - start
    print(f"\n✓ Test completed in {elapsed:.3f} seconds")
    
    if elapsed > 2.0:
        print("⚠️ WARNING: Threading test took longer than expected!")
        return False
    else:
        print("✓ PASS: No threading issues with UDP enabled")
        return True

def test_config_file():
    """Test with config file enabling UDP"""
    print("\n" + "="*60)
    print("TEST 4: CONFIG FILE WITH UDP ENABLED")
    print("="*60)
    
    # Create a test config file
    with open("test_config.yml", "w") as f:
        f.write("""
log_level: DEBUG
enable_udp: true
udp_host: 127.0.0.1
udp_port: 9999
enable_console: true
""")
    
    logger = tracecolor("test_config", config_file="test_config.yml")
    
    start = time.time()
    logger.info("Testing with config file")
    logger.debug("UDP should be enabled via config")
    elapsed = time.time() - start
    
    # Cleanup
    import os
    os.remove("test_config.yml")
    
    print(f"\n✓ Test completed in {elapsed:.3f} seconds")
    
    if elapsed > 0.1:
        print("⚠️ WARNING: Config test took longer than expected!")
        return False
    else:
        print("✓ PASS: Config file with UDP works fine")
        return True

if __name__ == "__main__":
    print("\n" + "🔍"*30)
    print("TRACECOLOR UDP BLOCKING TEST SUITE")
    print("Testing that UDP doesn't block when no monitor is listening")
    print("🔍"*30)
    
    results = []
    
    # Run all tests
    results.append(test_udp_enabled_no_monitor())
    results.append(test_udp_disabled())
    results.append(test_threading())
    results.append(test_config_file())
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    
    passed = sum(results)
    total = len(results)
    
    if passed == total:
        print(f"✅ ALL TESTS PASSED ({passed}/{total})")
        print("✓ tracecolor does NOT block with UDP enabled/disabled")
        print("✓ Safe to use UDP without a monitor running")
    else:
        print(f"❌ SOME TESTS FAILED ({passed}/{total} passed)")
        print("⚠️ There may be blocking issues!")
    
    print("="*60)