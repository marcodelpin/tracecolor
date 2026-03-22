"""Tests for UDPSink and HTTPSink."""

import socket
import time
from unittest.mock import patch, MagicMock
from tracecolor.sinks import UDPSink, HTTPSink


def test_udp_sink_creation():
    sink = UDPSink("127.0.0.1", 9999)
    assert sink.host == "127.0.0.1"
    assert sink.port == 9999
    assert sink.sock is not None
    sink.close()


def test_udp_sink_write_no_crash_without_monitor():
    sink = UDPSink("127.0.0.1", 19876)
    sink.write("test message")
    sink.close()


def test_udp_sink_close_idempotent():
    sink = UDPSink("127.0.0.1", 9999)
    sink.close()
    sink.close()
    assert sink.sock is None


def test_udp_sink_write_after_close():
    sink = UDPSink("127.0.0.1", 9999)
    sink.close()
    sink.write("should not crash")


def test_udp_sink_rapid_fire():
    sink = UDPSink("127.0.0.1", 19877)
    for i in range(100):
        sink.write(f"Rapid message {i}\n")
    sink.close()


def test_udp_sink_large_message():
    sink = UDPSink("127.0.0.1", 19877)
    sink.write("X" * 65536)
    sink.close()


def test_udp_sink_unicode():
    sink = UDPSink("127.0.0.1", 19877)
    sink.write("Emoji: \U0001f600 Chinese: \u4f60\u597d Math: \u03c0\u221e\u2211")
    sink.write("Special: \u00f1 \u00fc \u00e9 \u00e2")
    sink.close()


def test_udp_sink_nonblocking():
    sink = UDPSink("127.0.0.1", 19877)
    start = time.time()
    for _ in range(50):
        sink.write("non-blocking test\n")
    elapsed = time.time() - start
    sink.close()
    assert elapsed < 0.5


# --- HTTPSink tests ---

def test_http_sink_creation():
    sink = HTTPSink("http://localhost:9999/fake", flush_interval=60)
    assert sink.url == "http://localhost:9999/fake"
    assert sink.batch_size == 10
    sink.close()


def test_http_sink_buffers_messages():
    sink = HTTPSink("http://localhost:9999/fake", batch_size=100, flush_interval=60)
    sink.write("test message 1")
    sink.write("test message 2")
    assert len(sink._buffer) == 2
    sink.close()


def test_http_sink_write_after_close():
    sink = HTTPSink("http://localhost:9999/fake", flush_interval=60)
    sink.close()
    sink.write("should be ignored")
    assert len(sink._buffer) == 0


@patch("tracecolor.sinks.urlopen")
def test_http_sink_flush_posts(mock_urlopen):
    sink = HTTPSink("http://localhost:9999/api", batch_size=2, flush_interval=60)
    sink.write("msg1")
    sink.write("msg2")  # triggers flush at batch_size=2
    time.sleep(0.1)  # let flush happen
    assert mock_urlopen.called
    sink.close()


def test_http_sink_no_crash_on_unreachable():
    sink = HTTPSink("http://192.0.2.1:1/unreachable", batch_size=1, flush_interval=60)
    sink.write("should not crash")
    time.sleep(0.2)
    sink.close()
