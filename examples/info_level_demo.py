from tracecolor import MLog
import logging

def main():
    logger = MLog("demo")
    logger.setLevel(logging.DEBUG)  # Enable DEBUG level

    logger.trace("This is a TRACE message (should NOT appear)")
    logger.debug("This is a DEBUG message (should NOT appear)")
    logger.info("This is an INFO message (should appear)")
    logger.warning("This is a WARNING message (should appear)")
    logger.error("This is an ERROR message (should appear)")
    logger.critical("This is a CRITICAL message (should appear)")

if __name__ == "__main__":
    main()