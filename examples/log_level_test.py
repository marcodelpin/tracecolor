from tracecolor import tracecolor
import logging
import time

def main():
    """
    Demonstrate all log levels and their filtering behavior.
    
    This script shows:
    - TRACE (5): Most verbose, below DEBUG
    - DEBUG (10): Standard debug level
    - PROGRESS (15): Between DEBUG (10) and INFO (20), rate-limited. Visible if logger level is TRACE, DEBUG, or PROGRESS.
    - INFO (20): Standard info level
    - WARNING (30): Standard warning level
    - ERROR (40): Standard error level
    - CRITICAL (50): Standard critical level
    """
    # Create a logger
    logger = tracecolor("test_logger")
    
    # Show all log levels
    print("\n=== All log levels (logger level = TRACE = 5) ===")
    logger.setLevel(tracecolor.TRACE_LEVEL)
    log_all(logger)
    
    # Show rate-limiting for PROGRESS
    # The logger level is TRACE (5), so PROGRESS messages (level 15) are generally visible.
    # However, PROGRESS messages are also rate-limited (by default, one per second per call site).
    print(f"\n=== PROGRESS rate-limiting (logger level: TRACE, PROGRESS level: 15) ===")
    logger.setLevel(tracecolor.TRACE_LEVEL) # Ensures PROGRESS messages are not filtered by level
    logger.progress("First PROGRESS message (should appear, level 15 >= 5)")
    logger.progress("Second PROGRESS message (should be rate-limited, even though level 15 >= 5)")
    
    # Wait 1 second to allow rate-limiting to reset
    time.sleep(1)
    logger.progress("Third PROGRESS message (after 1s, rate limit reset, should appear, level 15 >= 5)")
    
    # Show filtering at different levels
    # Logger level is DEBUG (10). PROGRESS messages (15) will be shown as 15 >= 10. TRACE (5) will be filtered.
    print(f"\n=== Filtering at DEBUG level ({logging.DEBUG}) (TRACE filtered out, PROGRESS shown) ===")
    logger.setLevel(logging.DEBUG)
    log_all(logger)
    
    # Logger level is PROGRESS (15). PROGRESS messages (15) will be shown as 15 >= 15. TRACE (5) and DEBUG (10) will be filtered.
    print(f"\n=== Filtering at PROGRESS level ({tracecolor.PROGRESS_LEVEL}) (TRACE and DEBUG filtered out, PROGRESS shown) ===")
    logger.setLevel(tracecolor.PROGRESS_LEVEL)
    time.sleep(1) # Allow rate-limiter for log_all's progress call to reset from previous section
    log_all(logger)
    
    # Logger level is INFO (20). PROGRESS messages (15) will be filtered out as 15 < 20.
    print(f"\n=== Filtering at INFO level ({logging.INFO}) (TRACE, DEBUG, and PROGRESS filtered out) ===")
    logger.setLevel(logging.INFO)
    log_all(logger)

def log_all(logger):
    """Log messages at all levels."""
    logger.trace("TRACE message")
    logger.debug("DEBUG message")
    # PROGRESS messages (level 15) are visible if the logger's current set level is <= 15.
    logger.progress("PROGRESS message")
    logger.info("INFO message")
    logger.warning("WARNING message")
    logger.error("ERROR message")
    logger.critical("CRITICAL message")

if __name__ == "__main__":
    main()