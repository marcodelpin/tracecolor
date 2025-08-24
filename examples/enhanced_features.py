#!/usr/bin/env python3
"""
Tracecolor v0.6.0 Enhanced Features Example

This example demonstrates the enhanced features available in tracecolor 0.6.0
while maintaining 100% backward compatibility.
"""

import time
import sys
from pathlib import Path

# Standard backward-compatible usage (works exactly like 0.5.0)
from tracecolor import tracecolor

# Enhanced features (requires: pip install tracecolor[enhanced])
try:
    from tracecolor import create_enhanced_logger
    ENHANCED_AVAILABLE = True
except ImportError:
    ENHANCED_AVAILABLE = False
    print("Enhanced features not available. Install with: pip install tracecolor[enhanced]")


def basic_compatibility_demo():
    """Demonstrate 100% backward compatibility"""
    print("=== BACKWARD COMPATIBILITY DEMO ===")
    print("This works exactly like tracecolor 0.5.0:\n")
    
    # Standard usage - no changes needed
    logger = tracecolor(__name__ + ".basic")
    
    logger.trace("TRACE level - most detailed")
    logger.debug("DEBUG level - debug information")
    logger.progress("PROGRESS level - rate limited")
    logger.info("INFO level - general information")
    logger.warning("WARNING level - warnings")
    logger.error("ERROR level - errors")
    logger.critical("CRITICAL level - critical errors")
    
    print("\nProgress rate limiting test (should only show first and last):")
    for i in range(5):
        logger.progress(f"Progress update {i+1}/5")
        time.sleep(0.3)  # Faster than 1 second - rate limited
    
    print("Backward compatibility verified!\n")


def enhanced_features_demo():
    """Demonstrate new enhanced features"""
    if not ENHANCED_AVAILABLE:
        print("Enhanced features require: pip install tracecolor[enhanced]")
        return
    
    print("=== ENHANCED FEATURES DEMO ===")
    print("New in tracecolor 0.6.0:\n")
    
    # Enhanced logger with UDP and file logging
    logger = create_enhanced_logger(
        name=__name__ + ".enhanced",
        enable_console=True,      # Console output (same as original)
        enable_udp=True,          # UDP remote monitoring
        enable_file=True,         # File logging with rotation
        log_dir="./logs",         # Log directory
        udp_host="127.0.0.1",     # UDP monitoring host
        udp_port=9999             # UDP monitoring port
    )
    
    logger.info("Enhanced logger created with multiple destinations")
    logger.debug("This message goes to: console + file + UDP socket")
    logger.warning("All logging APIs work identically to original tracecolor")
    logger.error("But now with enterprise-grade backend and monitoring")
    
    # Same rate limiting behavior
    print("\nProgress rate limiting (enhanced backend, same behavior):")
    for i in range(3):
        logger.progress(f"Enhanced progress {i+1}/3")
        time.sleep(0.3)
    
    print("\nTo monitor logs in real-time, run in another terminal:")
    print("python -m tracecolor.monitor")
    print("Or: python tracecolor/monitor.py")


def external_configuration_demo():
    """Demonstrate external configuration"""
    if not ENHANCED_AVAILABLE:
        return
    
    print("\n=== EXTERNAL CONFIGURATION DEMO ===")
    
    # Create sample configuration
    config_content = '''
{
    "logging": {
        "enable_console": true,
        "enable_file": false,
        "enable_udp": true,
        "udp_host": "127.0.0.1",
        "udp_port": 9999,
        "log_level": "INFO"
    }
}
'''
    
    config_file = Path("sample_config.json")
    with open(config_file, "w") as f:
        f.write(config_content)
    
    print(f"Created configuration file: {config_file}")
    
    # Use external configuration
    logger = create_enhanced_logger(__name__ + ".configured", config_file=str(config_file))
    
    logger.info("Logger configured from external JSON file")
    logger.debug("This debug message may not appear (depends on log_level in config)")
    logger.warning("Configuration-driven logging is now available")
    
    # Cleanup
    config_file.unlink()
    print("External configuration demo complete")


def migration_guide():
    """Show how existing code can be gradually migrated"""
    print("\n=== MIGRATION GUIDE ===")
    
    print("Step 1: Existing code continues to work unchanged")
    logger_old = tracecolor(__name__ + ".migration")
    logger_old.info("No code changes needed for existing projects")
    
    if ENHANCED_AVAILABLE:
        print("\nStep 2: Optionally enable enhanced features")
        logger_new = create_enhanced_logger(
            __name__ + ".migration_enhanced", 
            enable_udp=True,
            enable_file=True,
            log_dir="./logs"
        )
        logger_new.info("Same API, enhanced capabilities")
        logger_new.warning("Gradual migration path available")
    
    print("\nMigration strategy:")
    print("1. Update to tracecolor 0.6.0 - all existing code works")
    print("2. Install enhanced dependencies: pip install tracecolor[enhanced]")
    print("3. Gradually replace tracecolor() with create_enhanced_logger() where needed")
    print("4. Add external configuration files as projects mature")


def main():
    """Run all demonstrations"""
    print("TRACECOLOR v0.6.0 - BACKWARD COMPATIBLE WITH ENHANCED FEATURES\n")
    print("=" * 70)
    
    basic_compatibility_demo()
    enhanced_features_demo()
    external_configuration_demo()
    migration_guide()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed!")
    
    if ENHANCED_AVAILABLE:
        print("\nNext steps:")
        print("1. Run 'python tracecolor/monitor.py' in another terminal")
        print("2. Re-run this script to see UDP monitoring in action")
        print("3. Check ./logs/ directory for log files")
        print("4. Create your own configuration files")
    else:
        print("\nTo try enhanced features:")
        print("pip install tracecolor[enhanced]")
        print("Then re-run this example")


if __name__ == "__main__":
    main()