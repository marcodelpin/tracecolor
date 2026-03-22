"""Output sinks for tracecolor logging."""

import json
import socket
import threading
import time
from urllib.request import Request, urlopen
from urllib.error import URLError
from typing import List, Optional


class UDPSink:
    """Custom UDP sink for remote monitoring"""

    def __init__(self, host: str = "127.0.0.1", port: int = 9999):
        self.host = host
        self.port = port
        self.sock = None

        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sock.setblocking(False)
        except Exception:
            pass

    def write(self, message):
        """Send log message via UDP"""
        if not self.sock:
            return

        try:
            if isinstance(message, str):
                msg = message.rstrip('\n')
                data = msg.encode('utf-8', errors='replace')
                self.sock.sendto(data, (self.host, self.port))
        except (socket.error, BlockingIOError):
            pass
        except Exception:
            pass

    def close(self):
        """Close the UDP socket"""
        if self.sock:
            try:
                self.sock.close()
            except Exception:
                pass
            self.sock = None


class HTTPSink:
    """HTTP sink for remote log aggregation (Loki, Seq, generic JSON endpoint).

    Buffers log messages and flushes them in batches via HTTP POST.
    Non-blocking: flush runs in a background thread.

    Args:
        url: HTTP endpoint URL (e.g. "http://loki:3100/loki/api/v1/push")
        batch_size: Number of messages to buffer before flushing (default: 10)
        flush_interval: Max seconds between flushes (default: 5.0)
        timeout: HTTP request timeout in seconds (default: 5)
        headers: Additional HTTP headers (default: Content-Type: application/json)
    """

    def __init__(self,
                 url: str,
                 batch_size: int = 10,
                 flush_interval: float = 5.0,
                 timeout: int = 5,
                 headers: Optional[dict] = None):
        self.url = url
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.timeout = timeout
        self.headers = headers or {"Content-Type": "application/json"}

        self._buffer: List[str] = []
        self._lock = threading.Lock()
        self._closed = False

        self._timer = threading.Thread(target=self._flush_loop, daemon=True)
        self._timer.start()

    def write(self, message):
        """Buffer a log message for batch sending."""
        if self._closed:
            return

        if isinstance(message, str):
            msg = message.rstrip('\n')
            if msg:
                with self._lock:
                    self._buffer.append(msg)
                    if len(self._buffer) >= self.batch_size:
                        self._flush()

    def _flush_loop(self):
        """Background thread: flush buffer at regular intervals."""
        while not self._closed:
            time.sleep(self.flush_interval)
            with self._lock:
                if self._buffer:
                    self._flush()

    def _flush(self):
        """Send buffered messages via HTTP POST. Called with lock held."""
        if not self._buffer:
            return

        batch = self._buffer[:]
        self._buffer.clear()

        payload = json.dumps({"streams": [{"values": batch}]}).encode('utf-8')

        try:
            req = Request(self.url, data=payload, headers=self.headers, method='POST')
            urlopen(req, timeout=self.timeout)
        except (URLError, OSError):
            pass
        except Exception:
            pass

    def close(self):
        """Flush remaining messages and stop the background thread."""
        self._closed = True
        with self._lock:
            if self._buffer:
                self._flush()
