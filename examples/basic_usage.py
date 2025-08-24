from tracecolor import tracecolor



# Create a logger with the module name
# By default, the logger level is set to DEBUG, so TRACE, PROGRESS, and DEBUG messages will be visible.
logger = tracecolor(__name__)

# Log at different levels
logger.trace("This is a trace message - very detailed info")
logger.debug("This is a debug message - for developers")
# PROGRESS messages are useful for indicating the status of long-running operations.
# They are visible if the logger level is TRACE, PROGRESS, or DEBUG.
logger.progress("This is a progress message - for long-running tasks")
logger.info("This is an info message - general information")
logger.warning("This is a warning message - potential issue")
logger.error("This is an error message - something went wrong")
logger.critical("This is a critical message - severe problem!")