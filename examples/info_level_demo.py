from tracecolor import tracecolor
import logging

def main():
    logger = tracecolor("demo")
    logger.setLevel(logging.INFO)  # Set level to INFO (numeric value 20)
    # Messages with a level lower than INFO (20) will not be displayed.

    # These messages have levels lower than INFO and should NOT appear:
    logger.trace("This is a TRACE message (level 5, should NOT appear)")
    logger.debug("This is a DEBUG message (level 10, should NOT appear)")
    logger.progress("This is a PROGRESS message (level 15, should NOT appear)")

    # These messages have levels INFO or higher and should appear:
    logger.info("This is an INFO message (level 20, should appear)")
    logger.warning("This is a WARNING message (level 30, should appear)")
    logger.error("This is an ERROR message (should appear)")
    logger.critical("This is a CRITICAL message (should appear)")

if __name__ == "__main__":
    main()