"""
Enhanced logger with colorized output and TRACE/PROGRESS levels.
Powered by Loguru backend for superior performance and features.
"""

import inspect
import sys
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Dict, Optional, Union
from loguru import logger as _loguru_logger

from .rate_limiter import ProgressRateLimiter
from .sinks import UDPSink, HTTPSink
from .config import find_config_file, load_config

# Optional OpenTelemetry integration (zero-config auto-detect)
try:
    from opentelemetry import trace as _otel_trace
    _OTEL_AVAILABLE = True
except ImportError:
    _OTEL_AVAILABLE = False


def _otel_patcher(record):
    """Inject OpenTelemetry trace_id and span_id into log record extras."""
    if _OTEL_AVAILABLE:
        span = _otel_trace.get_current_span()
        ctx = span.get_span_context()
        if ctx and ctx.trace_id:
            record["extra"]["otel_trace_id"] = format(ctx.trace_id, '032x')
            record["extra"]["otel_span_id"] = format(ctx.span_id, '016x')
        else:
            record["extra"]["otel_trace_id"] = "0" * 32
            record["extra"]["otel_span_id"] = "0" * 16
    else:
        record["extra"]["otel_trace_id"] = ""
        record["extra"]["otel_span_id"] = ""


class tracecolor:
    """
    Enhanced logger with colorized output and TRACE/PROGRESS levels.
    Powered by Loguru backend for superior performance and features.

    Usage:
    ```python
    from tracecolor import tracecolor

    logger = tracecolor(__name__)
    logger.trace("Detailed trace message")
    logger.debug("Debug information")
    logger.progress("Progress update (rate-limited)")
    logger.info("General information")
    ```
    """
    TRACE_LEVEL = 5
    PROGRESS_LEVEL = 15
    PROGRESS_INTERVAL: float = 1

    def __init__(self,
                 name: str,
                 enable_console: bool = True,
                 enable_file: bool = False,
                 enable_udp: bool = False,
                 enable_json: bool = False,
                 enable_http: bool = False,
                 log_dir: Optional[Union[str, Path]] = None,
                 json_file: Optional[Union[str, Path]] = None,
                 udp_host: str = "127.0.0.1",
                 udp_port: int = 9999,
                 http_url: Optional[str] = None,
                 log_level: str = "TRACE",
                 config_file: Optional[str] = None):

        self.name = name
        self.progress_limiter = ProgressRateLimiter()
        self.udp_sink = None
        self.http_sink = None
        self._logger_id = id(self)

        self._init_backend(enable_console, enable_file, enable_udp, enable_json,
                           enable_http, log_dir, json_file, udp_host, udp_port,
                           http_url, log_level, config_file)

    def _init_backend(self, enable_console, enable_file, enable_udp, enable_json,
                      enable_http, log_dir, json_file, udp_host, udp_port,
                      http_url, log_level, config_file):
        """Initialize Loguru backend with configured sinks."""
        if not config_file:
            config_file = find_config_file()

        if config_file:
            config = load_config(config_file)
            enable_console = config.get("enable_console", enable_console)
            enable_file = config.get("enable_file", enable_file)
            enable_udp = config.get("use_udp", config.get("enable_udp", enable_udp))
            enable_json = config.get("enable_json", enable_json)
            enable_http = config.get("enable_http", enable_http)
            log_dir = config.get("log_dir", log_dir)
            json_file = config.get("json_file", json_file)
            udp_host = config.get("udp_host", udp_host)
            udp_port = config.get("udp_port", udp_port)
            http_url = config.get("http_url", http_url)
            log_level = config.get("log_level", log_level)

        self.logger = _loguru_logger.bind(name=self.name, logger_id=self._logger_id)
        _loguru_logger.remove()

        try:
            _loguru_logger.level("PROGRESS", no=15, color="<blue>")
        except (TypeError, ValueError):
            pass

        # Apply OpenTelemetry patcher if available (auto-inject trace_id/span_id)
        if _OTEL_AVAILABLE:
            _loguru_logger.configure(patcher=_otel_patcher)

        if enable_console:
            self._add_console_sink(log_level)

        if enable_file and log_dir:
            self._add_file_sink(log_dir, log_level)

        if enable_json:
            self._add_json_sink(log_level, json_file, log_dir)

        if enable_udp:
            self._add_udp_sink(udp_host, udp_port, log_level)

        if enable_http and http_url:
            self._add_http_sink(http_url, log_level)

        self.logger = _loguru_logger.bind(name=self.name, logger_id=self._logger_id)

    def _add_console_sink(self, log_level):
        """Add colorized console output sink."""
        console_format = (
            "<dim>{level.name[0]}</dim> "
            "|<dim>{time:YYYY-MM-DD HH:mm:ss.SSS}</dim>| "
            "<level>{message}</level>"
        )
        _loguru_logger.add(
            sink=sys.stderr,
            format=console_format,
            level=log_level,
            colorize=True,
            filter=self._instance_filter
        )

    def _add_file_sink(self, log_dir, log_level):
        """Add file logging sink with rotation."""
        log_path = Path(log_dir)
        log_path.mkdir(exist_ok=True, parents=True)

        file_format = (
            "{level.name[0]} |{time:YYYY-MM-DD HH:mm:ss.SSS}| "
            "[{name}:{function}:{line}] {message}"
        )
        _loguru_logger.add(
            sink=str(log_path / f"{self.name}.log"),
            format=file_format,
            level=log_level,
            rotation="10 MB",
            retention="7 days",
            compression="zip",
            filter=lambda record: record["extra"].get("logger_id") == self._logger_id
        )

    def _add_json_sink(self, log_level, json_file=None, log_dir=None):
        """Add JSON structured output sink using Loguru serialize."""
        if json_file:
            sink = str(json_file)
        elif log_dir:
            log_path = Path(log_dir)
            log_path.mkdir(exist_ok=True, parents=True)
            sink = str(log_path / f"{self.name}.jsonl")
        else:
            sink = sys.stdout

        kwargs = {
            "level": log_level,
            "serialize": True,
            "filter": lambda record: record["extra"].get("logger_id") == self._logger_id,
        }

        if isinstance(sink, str):
            kwargs["rotation"] = "10 MB"
            kwargs["retention"] = "7 days"
            kwargs["compression"] = "zip"

        _loguru_logger.add(sink=sink, **kwargs)

    def _add_udp_sink(self, udp_host, udp_port, log_level):
        """Add UDP remote monitoring sink."""
        try:
            self.udp_sink = UDPSink(udp_host, udp_port)

            udp_format = (
                "{level.name[0]} "
                "|{time:YYYY-MM-DD HH:mm:ss.SSS}| "
                "[{extra[name]}:{function}:{line}] "
                "{message}"
            )
            _loguru_logger.add(
                sink=self.udp_sink,
                level=log_level,
                format=udp_format,
                filter=lambda record: record["extra"].get("logger_id") == self._logger_id
            )
        except Exception:
            pass

    def _add_http_sink(self, http_url, log_level):
        """Add HTTP remote aggregation sink (Loki, Seq, generic)."""
        try:
            self.http_sink = HTTPSink(http_url)
            _loguru_logger.add(
                sink=self.http_sink,
                level=log_level,
                serialize=True,
                filter=lambda record: record["extra"].get("logger_id") == self._logger_id
            )
        except Exception:
            pass

    def _instance_filter(self, record):
        """Filter: only process records from this logger instance."""
        return record["extra"].get("logger_id") == self._logger_id

    def trace(self, message, *args, **kwargs):
        """Log a message with severity 'TRACE'."""
        self.logger.trace(message, *args, **kwargs)

    def progress(self, message, *args, **kwargs):
        """Log a message with severity 'PROGRESS' (rate-limited per call site)."""
        frame = inspect.currentframe().f_back
        call_site = f"{frame.f_code.co_filename}:{frame.f_code.co_name}:{frame.f_lineno}"

        if not self.progress_limiter.should_log(call_site):
            return

        self.logger.log("PROGRESS", message, *args, **kwargs)

    def debug(self, message, *args, **kwargs):
        """Log a message with severity 'DEBUG'."""
        self.logger.debug(message, *args, **kwargs)

    def info(self, message, *args, **kwargs):
        """Log a message with severity 'INFO'."""
        self.logger.info(message, *args, **kwargs)

    def warning(self, message, *args, **kwargs):
        """Log a message with severity 'WARNING'."""
        self.logger.warning(message, *args, **kwargs)

    def error(self, message, *args, **kwargs):
        """Log a message with severity 'ERROR'."""
        self.logger.error(message, *args, **kwargs)

    def critical(self, message, *args, **kwargs):
        """Log a message with severity 'CRITICAL'."""
        self.logger.critical(message, *args, **kwargs)

    def exception(self, message, *args, **kwargs):
        """Log exception with traceback"""
        self.logger.exception(message, *args, **kwargs)

    def bind(self, **kwargs) -> 'tracecolor':
        """Bind context fields to all subsequent log messages.

        Returns a new tracecolor instance with the bound fields.
        Fields appear in JSON output and in {extra[key]} format strings.

        Usage:
            logger = tracecolor(__name__).bind(request_id="abc-123")
            logger.info("processing")  # includes request_id in output
        """
        new = object.__new__(tracecolor)
        new.name = self.name
        new.progress_limiter = self.progress_limiter
        new.udp_sink = self.udp_sink
        new.http_sink = self.http_sink
        new._logger_id = self._logger_id
        new.logger = self.logger.bind(**kwargs)
        return new

    @contextmanager
    def context(self, **kwargs):
        """Context manager for scoped correlation IDs.

        All log messages within the context include the bound fields.
        Fields are removed when the context exits.

        Usage:
            with logger.context(request_id="abc-123", user_id="u42"):
                logger.info("within context")  # has request_id + user_id
            logger.info("outside context")  # no request_id/user_id
        """
        original_logger = self.logger
        self.logger = self.logger.bind(**kwargs)
        try:
            yield self
        finally:
            self.logger = original_logger


def create_enhanced_logger(name: str,
                           enable_console: bool = True,
                           enable_file: bool = False,
                           enable_udp: bool = False,
                           enable_json: bool = False,
                           enable_http: bool = False,
                           log_dir: Optional[Union[str, Path]] = None,
                           json_file: Optional[Union[str, Path]] = None,
                           udp_host: str = "127.0.0.1",
                           udp_port: int = 9999,
                           http_url: Optional[str] = None,
                           log_level: str = "TRACE",
                           config_file: Optional[str] = None) -> 'tracecolor':
    """
    Convenience function to create a tracecolor logger with enhanced features.

    Args:
        name: Logger name (typically __name__)
        enable_console: Enable console output (default: True)
        enable_file: Enable file logging (default: False)
        enable_udp: Enable UDP remote monitoring (default: False)
        enable_json: Enable JSON structured output (default: False)
        enable_http: Enable HTTP log aggregation (default: False)
        log_dir: Directory for log files
        json_file: Path for JSON output file (default: log_dir/<name>.jsonl)
        udp_host: UDP host for remote monitoring
        udp_port: UDP port for remote monitoring
        http_url: HTTP endpoint URL for log aggregation (Loki, Seq, etc.)
        log_level: Minimum log level (default: "TRACE")
        config_file: External configuration file (TOML/YAML/JSON)

    Returns:
        tracecolor instance with specified features enabled
    """
    return tracecolor(
        name=name,
        enable_console=enable_console,
        enable_file=enable_file,
        enable_udp=enable_udp,
        enable_json=enable_json,
        enable_http=enable_http,
        log_dir=log_dir,
        json_file=json_file,
        udp_host=udp_host,
        udp_port=udp_port,
        http_url=http_url,
        log_level=log_level,
        config_file=config_file
    )
