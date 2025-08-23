from .tracecolor import tracecolor, create_enhanced_logger, TracecolorEnhanced

__version__ = "0.6.0"
__all__ = ['tracecolor', 'create_enhanced_logger', 'TracecolorEnhanced']

# Backward compatibility - existing code using tracecolor() continues to work
# Enhanced features available via create_enhanced_logger() function