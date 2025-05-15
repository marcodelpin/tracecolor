from tracecolor import tracecolor
import logging

LEVELS = [
    ("TRACE", tracecolor.TRACE_LEVEL),
    ("DEBUG", logging.DEBUG),
    ("PROGRESS", tracecolor.PROGRESS_LEVEL),
    ("INFO", logging.INFO),
    ("WARNING", logging.WARNING),
    ("ERROR", logging.ERROR),
    ("CRITICAL", logging.CRITICAL),
]

def log_all(logger):
    # Log messages in numerical order of levels
    logger.trace("TRACE message")      # Level 5
    logger.debug("DEBUG message")      # Level 10
    logger.progress("PROGRESS message")  # Level 15
    logger.info("INFO message")       # Level 20
    logger.warning("WARNING message")    # Level 30
    logger.error("ERROR message")      # Level 40
    logger.critical("CRITICAL message")  # Level 50

def main():
    for name, level in LEVELS:
        print(f"\n=== Logger set to {name} ({level}) ===")
        logger = tracecolor(f"demo_{name}")
        logger.setLevel(level)
        log_all(logger)

if __name__ == "__main__":
    main()