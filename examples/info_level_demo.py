from tracecolor import tracecolor
import logging

def main():
    logger = tracecolor("demo")
    logger.setLevel(logging.INFO)  # Set level to INFO (numeric value 20)
    # Messages with a level lower than INFO (20) will not be displayed.
    # PROGRESS has a numeric value of 15. TRACE is 5, DEBUG is 10.

    # These messages have levels lower than INFO and should NOT appear:
    logger.trace("This is a TRACE message (level 5, should NOT appear because 5 < 20)")
    logger.debug("This is a DEBUG message (level 10, should NOT appear because 10 < 20)")
    # The PROGRESS level (15) is lower than INFO (20), so this message will be suppressed.
    # To see PROGRESS messages, the logger level would need to be set to
    # tracecolor.PROGRESS (15), logging.DEBUG (10), or tracecolor.TRACE (5).
    logger.progress("This is a PROGRESS message (level 15, should NOT appear because 15 < 20)")

    # These messages have levels INFO or higher and should appear:
    logger.info("This is an INFO message (level 20, should appear)")
    logger.warning("This is a WARNING message (level 30, should appear)")
    logger.error("This is an ERROR message (should appear)")
    logger.critical("This is a CRITICAL message (should appear)")

if __name__ == "__main__":
    main()