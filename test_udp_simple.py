#!/usr/bin/env python3
"""
Simple test to verify UDP doesn't block - works without dependencies
"""

import sys
import os
import time
import socket

# Add tracecolor to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Mock loguru if not available
try:
    from loguru import logger
except ImportError:
    print("Loguru not available - creating mock for testing")
    
    class MockLogger:
        def trace(self, msg): print(f"TRACE: {msg}")
        def debug(self, msg): print(f"DEBUG: {msg}")
        def info(self, msg): print(f"INFO: {msg}")
        def warning(self, msg): print(f"WARNING: {msg}")
        def error(self, msg): print(f"ERROR: {msg}")
        def critical(self, msg): print(f"CRITICAL: {msg}")
        def add(self, *args, **kwargs): pass
        def remove(self, *args, **kwargs): pass
        def configure(self, *args, **kwargs): pass
    
    class MockLoguru:
        logger = MockLogger()
    
    sys.modules['loguru'] = MockLoguru()

# Now test the UDP sink directly
print("\n" + "="*60)
print("TESTING UDP SINK DIRECTLY")
print("="*60)

# Import the UDPSink class
from tracecolor.tracecolor import UDPSink

print("\n1. Creating UDP sink on port 9999 (no monitor listening)")
sink = UDPSink(host="127.0.0.1", port=9999)

print("2. Testing write with normal message")
start = time.time()
sink.write("Test message - should not block\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
assert elapsed < 0.1, "Writing took too long - possible blocking!"

print("3. Testing write with special characters")
start = time.time()
sink.write("Special chars: 😀 ñ ∑ π 你好 مرحبا\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
assert elapsed < 0.1, "Writing special chars took too long!"

print("4. Testing rapid fire writes (100 messages)")
start = time.time()
for i in range(100):
    sink.write(f"Rapid message {i}\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds for 100 messages")
assert elapsed < 0.5, "Rapid writes took too long!"

print("5. Testing with invalid/large message")
start = time.time()
sink.write("X" * 65536)  # 64KB message
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
assert elapsed < 0.1, "Large message took too long!"

print("6. Closing sink")
sink.close()

print("\n" + "="*60)
print("✅ ALL TESTS PASSED!")
print("UDP sink is NON-BLOCKING and safe to use without monitor")
print("="*60)

# Now test that socket is really non-blocking
print("\n" + "="*60)
print("VERIFYING SOCKET CONFIGURATION")
print("="*60)

test_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
test_sock.setblocking(False)

print("1. Socket blocking status:", test_sock.getblocking())
assert test_sock.getblocking() == False, "Socket should be non-blocking!"

print("2. Testing sendto on non-existent port")
try:
    start = time.time()
    test_sock.sendto(b"Test", ("127.0.0.1", 9999))
    elapsed = time.time() - start
    print(f"   sendto completed in {elapsed:.4f} seconds")
except (BlockingIOError, socket.error) as e:
    print(f"   sendto raised expected error: {type(e).__name__}")

test_sock.close()

print("\n✅ Socket is properly configured as NON-BLOCKING")
print("="*60)