import pytest
import logging
from tracecolor import MLog
import io
import sys
import re

def test_mlog_creation():
    """Test basic logger creation."""
    logger = MLog("test_logger")
    assert isinstance(logger, MLog)
    assert isinstance(logger, logging.Logger)
    assert logger.name == "test_logger"

def test_log_levels():
    """Test all log levels are properly defined."""
    logger = MLog("test_logger")
    assert logger.TRACE_LEVEL == 5
    assert logging.getLevelName(logger.TRACE_LEVEL) == "TRACE"
    
    # Test standard levels still work
    assert logger.level <= logging.DEBUG
    assert logger.level <= logging.INFO
    assert logger.level <= logging.WARNING
    assert logger.level <= logging.ERROR
    assert logger.level <= logging.CRITICAL

def test_log_output(capsys):
    """Test that log messages are properly formatted."""
    # Redirect stdout to capture log messages
    old_stdout = sys.stdout
    sys.stdout = io.StringIO()
    
    try:
        logger = MLog("test_output")
        logger.info("Test info message")
        
        # Use capsys to capture stderr (where logging outputs by default)
        captured = capsys.readouterr()
        output = captured.err
        # Remove ANSI color codes for assertion
        ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
        clean_output = ansi_escape.sub('', output)
        # Check for basic format
        assert "I |" in clean_output
        assert "Test info message" in clean_output
        
        # Check timestamp format using regex
        timestamp_pattern = r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}"
        assert re.search(timestamp_pattern, output) is not None
        
    finally:
        sys.stdout = old_stdout

def test_trace_rate_limiting():
    """Test that trace messages are rate-limited."""
    logger = MLog("test_rate_limit")
    
    # Capture all handler calls
    calls = []
    
    class MockHandler(logging.Handler):
        def emit(self, record):
            calls.append(record)
    
    mock_handler = MockHandler()
    logger.handlers = [mock_handler]  # Replace the default handler
    
    # Two immediate trace calls should result in only one log
    logger.trace("First trace message")
    logger.trace("Second trace message")
    
    assert len(calls) == 1

@pytest.mark.parametrize("set_level,expected_levels", [
    (MLog.TRACE_LEVEL, ["TRACE", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]),
    (logging.DEBUG, ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]),
    (logging.INFO, ["INFO", "WARNING", "ERROR", "CRITICAL"]),
    (logging.WARNING, ["WARNING", "ERROR", "CRITICAL"]),
    (logging.ERROR, ["ERROR", "CRITICAL"]),
    (logging.CRITICAL, ["CRITICAL"]),
])
def test_log_level_filtering(set_level, expected_levels, capsys):
    logger = MLog("test_level_filter")
    logger.setLevel(set_level)
    
    # Map level names to log calls
    log_calls = [
        ("TRACE", lambda: logger.trace("trace message")),
        ("DEBUG", lambda: logger.debug("debug message")),
        ("INFO", lambda: logger.info("info message")),
        ("WARNING", lambda: logger.warning("warning message")),
        ("ERROR", lambda: logger.error("error message")),
        ("CRITICAL", lambda: logger.critical("critical message")),
    ]
    
    # Patch time to avoid rate-limiting for TRACE
    import time as _time
    orig_time = _time.time
    _time.time = lambda: 0
    try:
        # Ensure TRACE is not rate-limited by resetting _last_trace_log_time
        logger._last_trace_log_time = -1000
        for idx, (level, call) in enumerate(log_calls):
            if level == "TRACE":
                logger._last_trace_log_time = -1000
            call()
    finally:
        _time.time = orig_time
    
    captured = capsys.readouterr().err
    # Remove ANSI color codes for assertion
    import re
    ansi_escape = re.compile(r'\x1b\[[0-9;]*m')
    clean_captured = ansi_escape.sub('', captured)
    for level, _ in log_calls:
        if level in expected_levels:
            assert f"{level[0]} |" in clean_captured or (level == "TRACE" and "T |" in clean_captured)
        else:
            assert f"{level[0]} |" not in clean_captured and not (level == "TRACE" and "T |" in clean_captured)