#!/usr/bin/env python
"""Test UDP handling with special/problematic characters"""

from tracecolor import tracecolor
import time

# Create logger with UDP enabled
logger = tracecolor(__name__, enable_udp=True, udp_port=9999)

# Test various special characters
test_cases = [
    "Normal ASCII text",
    "Emoji test: 😀 🎉 ⚡ 🔥",
    "Chinese: 你好世界",
    "Japanese: こんにちは世界",
    "Arabic: مرحبا بالعالم",
    "Russian: Привет мир",
    "Math symbols: ∑ ∫ ∞ √ π",
    "Special chars: ñ ü é â ä à å ç ê ë",
    "Control chars: \t\n\r",
    "Invalid UTF-8 simulation: \udcff\udcfe",  # Surrogate pairs
    "Zero width: \u200b\u200c\u200d",  # Zero-width spaces
    "NULL char: \x00 test",
]

print("Testing UDP with special characters...")
print("Start the monitor with: tracecolor-monitor --port 9999")
print("-" * 50)

for i, test in enumerate(test_cases, 1):
    print(f"Test {i}: Sending...")
    logger.info(f"Test {i}: {test}")
    time.sleep(0.5)

print("-" * 50)
print("Test complete! Check monitor output for results.")