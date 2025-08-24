#!/usr/bin/env python3
"""
Live UDP test - sends messages to monitor every 2 seconds
"""
import sys
import os
import time
from datetime import datetime

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from tracecolor import tracecolor

print("=" * 60)
print("UDP LOGGING TEST - SENDING MESSAGES TO MONITOR")
print("=" * 60)
print("Target: 127.0.0.1:9999")
print("Sending messages every 2 seconds...")
print("Press Ctrl+C to stop")
print("-" * 60)

# Create logger with UDP enabled
logger = tracecolor(
    "UDP_TEST",
    enable_console=True,  # Also show in this terminal
    enable_udp=True,
    udp_host="127.0.0.1",
    udp_port=9999
)

# Send various types of messages
messages = [
    ("info", "🚀 UDP Test Started - Monitor should receive this!"),
    ("trace", "Detailed trace information for debugging"),
    ("debug", "Debug: Processing item #42"),
    ("progress", "Progress: 25% complete"),
    ("info", f"Current time: {datetime.now().strftime('%H:%M:%S')}"),
    ("warning", "⚠️  Warning: High memory usage detected"),
    ("error", "❌ Error: Connection timeout to database"),
    ("critical", "🔴 CRITICAL: System overload detected!"),
    ("info", "Processing user request ID: 12345"),
    ("progress", "Progress: 50% complete"),
    ("debug", "Cache hit ratio: 0.87"),
    ("info", "Task completed successfully"),
    ("progress", "Progress: 75% complete"),
    ("warning", "Deprecated API endpoint used"),
    ("info", "Cleanup process initiated"),
    ("progress", "Progress: 100% complete"),
    ("info", "✅ All tests completed successfully!"),
]

try:
    for i, (level, message) in enumerate(messages, 1):
        print(f"\n[{i}/{len(messages)}] Sending {level.upper()} message...")
        
        # Send message based on level
        if level == "trace":
            logger.trace(message)
        elif level == "debug":
            logger.debug(message)
        elif level == "progress":
            logger.progress(message)
        elif level == "info":
            logger.info(message)
        elif level == "warning":
            logger.warning(message)
        elif level == "error":
            logger.error(message)
        elif level == "critical":
            logger.critical(message)
        
        # Wait before next message
        if i < len(messages):
            time.sleep(2)
            
except KeyboardInterrupt:
    print("\n\nTest interrupted by user")
    logger.info("UDP test stopped by user")

print("\n" + "=" * 60)
print("TEST COMPLETE - Check monitor window for messages")
print("=" * 60)