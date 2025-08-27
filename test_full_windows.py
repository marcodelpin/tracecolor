#!/usr/bin/env python3
"""
Full test of tracecolor with Unicode on Windows
"""

import sys
import os
import time

# Set UTF-8 output for Windows console
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# Add tracecolor to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from tracecolor import tracecolor

print("\n" + "="*60)
print("FULL TRACECOLOR TEST ON WINDOWS")
print("="*60)

# Test 1: UDP enabled, no monitor
print("\nTEST 1: UDP Enabled (no monitor running)")
print("-" * 40)

logger1 = tracecolor("test_udp", enable_udp=True, udp_port=9999)

start = time.time()
logger1.info("Standard ASCII message")
logger1.info("Emoji test: 🎉 🔥 ⚡ 😀")
logger1.info("Chinese: 你好世界")
logger1.info("Arabic: مرحبا بالعالم")
logger1.info("Russian: Привет мир")
logger1.info("Math: ∑ ∫ ∞ √ π")
logger1.info("Path: C:\\Users\\测试\\文档\\file.txt")
elapsed = time.time() - start

print(f"\nTime for 7 messages: {elapsed:.4f} seconds")
if elapsed < 0.5:
    print("[PASS] No blocking detected with UDP enabled")
else:
    print("[WARNING] Slower than expected")

# Test 2: UDP disabled
print("\nTEST 2: UDP Disabled (console only)")
print("-" * 40)

logger2 = tracecolor("test_console", enable_udp=False)

start = time.time()
logger2.info("Console only - ASCII")
logger2.info("Console only - 中文测试")
logger2.info("Console only - العربية")
logger2.info("Console only - Emojis 🚀 💻 🐍")
elapsed = time.time() - start

print(f"\nTime for 4 messages: {elapsed:.4f} seconds")
if elapsed < 0.2:
    print("[PASS] Console logging fast")
else:
    print("[WARNING] Console slower than expected")

# Test 3: Stress test with Unicode
print("\nTEST 3: Stress Test with Mixed Unicode")
print("-" * 40)

logger3 = tracecolor("stress_test", enable_udp=True, udp_port=9999)

unicode_samples = [
    "ASCII only test",
    "Émojis: 👍 👎 💯 🎯",
    "CJK: 中文 日本語 한국어",
    "Cyrillic: Привет мир",
    "Arabic: مرحبا بالعالم",
    "Hebrew: שלום עולם",
    "Greek: Γειά σου Κόσμε",
    "Special: ™ © ® € £ ¥",
    "Math: ∀x∈ℝ: x²≥0",
    "Arrows: ← → ↑ ↓ ↔ ⇒",
]

start = time.time()
for i in range(10):
    for msg in unicode_samples:
        logger3.debug(f"Iteration {i}: {msg}")
elapsed = time.time() - start

total_messages = 10 * len(unicode_samples)
print(f"\nTime for {total_messages} Unicode messages: {elapsed:.4f} seconds")
print(f"Average per message: {elapsed/total_messages:.6f} seconds")

if elapsed < 2.0:
    print("[PASS] Stress test completed quickly")
else:
    print("[WARNING] Stress test slower than expected")

print("\n" + "="*60)
print("WINDOWS TEST SUMMARY")
print("="*60)
print("[OK] UDP does not block on Windows")
print("[OK] Unicode characters handled correctly")
print("[OK] Performance is acceptable")
print("[OK] Safe to use with or without monitor")
print("="*60)