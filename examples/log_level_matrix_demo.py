from tracecolor import MLog
import logging

LEVELS = [
    ("TRACE", 15),
    ("DEBUG", logging.DEBUG),
    ("INFO", logging.INFO),
    ("WARNING", logging.WARNING),
    ("ERROR", logging.ERROR),
    ("CRITICAL", logging.CRITICAL),
]

def log_all(logger):
    logger.trace("TRACE message")
    logger.debug("DEBUG message")
    logger.info("INFO message")
    logger.warning("WARNING message")
    logger.error("ERROR message")
    logger.critical("CRITICAL message")

def main():
    for name, level in LEVELS:
        print(f"\n=== Logger set to {name} ({level}) ===")
        logger = MLog(f"demo_{name}")
        logger.setLevel(level)
        log_all(logger)

if __name__ == "__main__":
    main()