from tracecolor import MLog
import logging
import time

def main():
    """
    Demonstrate all log levels and their filtering behavior.
    
    This script shows:
    - TRACE (5): Most verbose, below DEBUG
    - DEBUG (10): Standard debug level
    - PROGRESS (15): Between DEBUG and INFO, rate-limited
    - INFO (20): Standard info level
    - WARNING (30): Standard warning level
    - ERROR (40): Standard error level
    - CRITICAL (50): Standard critical level
    """
    # Create a logger
    logger = MLog("test_logger")
    
    # Show all log levels
    print("\n=== All log levels (logger level = TRACE = 5) ===")
    logger.setLevel(MLog.TRACE_LEVEL)
    log_all(logger)
    
    # Show rate-limiting for STRACE
    print(f"\n=== PROGRESS rate-limiting (only first message appears) ===")
    logger.setLevel(MLog.TRACE_LEVEL)
    logger.progress("First PROGRESS message")
    logger.progress("Second PROGRESS message (should be rate-limited)")
    
    # Wait 1 second to allow rate-limiting to reset
    time.sleep(1)
    logger.progress("Third PROGRESS message (after 1 second, should appear)")
    
    # Show filtering at different levels
    print(f"\n=== Filtering at DEBUG level ({logging.DEBUG}) (TRACE filtered out) ===")
    logger.setLevel(logging.DEBUG)
    log_all(logger)
    
    print(f"\n=== Filtering at PROGRESS level ({MLog.PROGRESS_LEVEL}) (TRACE and DEBUG filtered out) ===")
    logger.setLevel(MLog.PROGRESS_LEVEL)
    log_all(logger)
    
    print(f"\n=== Filtering at INFO level ({logging.INFO}) (TRACE, DEBUG, and PROGRESS filtered out) ===")
    logger.setLevel(logging.INFO)
    log_all(logger)

def log_all(logger):
    """Log messages at all levels."""
    logger.trace("TRACE message")
    logger.debug("DEBUG message")
    logger.progress("PROGRESS message")
    logger.info("INFO message")
    logger.warning("WARNING message")
    logger.error("ERROR message")
    logger.critical("CRITICAL message")

if __name__ == "__main__":
    main()