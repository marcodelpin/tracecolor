from tracecolor import tracecolor



# Create a logger with the module name
logger = tracecolor(__name__)

# Log at different levels
logger.trace("This is a trace message - very detailed info")
logger.debug("This is a debug message - for developers")
logger.info("This is an info message - general information")
logger.warning("This is a warning message - potential issue")
logger.error("This is an error message - something went wrong")
logger.critical("This is a critical message - severe problem!")