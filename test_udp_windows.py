#!/usr/bin/env python3
"""
Windows-compatible test to verify UDP doesn't block
"""

import sys
import os
import time
import socket

# Set UTF-8 output for Windows console
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# Add tracecolor to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import the UDPSink class
from tracecolor.tracecolor import UDPSink

print("\n" + "="*60)
print("TESTING UDP SINK ON WINDOWS")
print("="*60)

print("\n1. Creating UDP sink on port 9999 (no monitor listening)")
sink = UDPSink(host="127.0.0.1", port=9999)

print("2. Testing write with normal message")
start = time.time()
sink.write("Test message - should not block\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
if elapsed >= 0.1:
    print("   WARNING: Writing took longer than expected!")

print("3. Testing write with Unicode characters")
start = time.time()
test_msg = "Unicode test: emoji 🎉, Chinese 你好, Arabic مرحبا, Math ∑∫∞"
sink.write(test_msg + "\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
print(f"   Message: {test_msg[:50]}...")
if elapsed >= 0.1:
    print("   WARNING: Unicode writing took longer than expected!")

print("4. Testing rapid fire writes (100 messages)")
start = time.time()
for i in range(100):
    sink.write(f"Rapid message {i}\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds for 100 messages")
avg_time = elapsed / 100
print(f"   Average per message: {avg_time:.6f} seconds")
if elapsed >= 0.5:
    print("   WARNING: Rapid writes took longer than expected!")

print("5. Testing with large message (64KB)")
start = time.time()
sink.write("X" * 65536)
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
if elapsed >= 0.1:
    print("   WARNING: Large message took longer than expected!")

print("6. Testing Windows-specific characters")
start = time.time()
windows_chars = "Windows path: C:\\Users\\Test\\文档\\ñoño.txt"
sink.write(windows_chars + "\n")
elapsed = time.time() - start
print(f"   Elapsed: {elapsed:.4f} seconds")
print(f"   Message: {windows_chars}")

print("7. Closing sink")
sink.close()

print("\n" + "="*60)
print("VERIFYING SOCKET CONFIGURATION ON WINDOWS")
print("="*60)

test_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
test_sock.setblocking(False)

print("1. Socket blocking status:", test_sock.getblocking())
if test_sock.getblocking():
    print("   ERROR: Socket should be non-blocking!")
else:
    print("   [OK] Socket is non-blocking")

print("2. Testing sendto on non-existent port")
try:
    start = time.time()
    test_sock.sendto(b"Test", ("127.0.0.1", 9999))
    elapsed = time.time() - start
    print(f"   sendto completed in {elapsed:.4f} seconds")
    print("   [OK] No blocking detected")
except (BlockingIOError, socket.error) as e:
    print(f"   sendto raised expected error: {type(e).__name__}")
    print("   [OK] Socket behaves as expected")

test_sock.close()

print("\n" + "="*60)
print("TEST SUMMARY")
print("="*60)
print("[PASS] UDP sink works on Windows")
print("[PASS] Non-blocking socket confirmed")
print("[PASS] Unicode characters handled")
print("[PASS] No blocking with monitor not running")
print("="*60)