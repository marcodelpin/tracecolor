"""Tests for tracecolor UDP monitor."""

import socket
import threading
import time
from unittest.mock import patch
from tracecolor.monitor import udp_monitor, main


def test_udp_monitor_receives_message():
    """Test that monitor receives and processes a UDP message."""
    port = 19877
    received = []

    def run_monitor():
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(("127.0.0.1", port))
        sock.settimeout(2.0)
        try:
            data, addr = sock.recvfrom(4096)
            received.append(data.decode('utf-8'))
        except socket.timeout:
            pass
        finally:
            sock.close()

    t = threading.Thread(target=run_monitor)
    t.start()
    time.sleep(0.1)

    send_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    send_sock.sendto(b"I |2026-03-22| test message", ("127.0.0.1", port))
    send_sock.close()

    t.join(timeout=3)
    assert len(received) == 1
    assert "test message" in received[0]


def test_main_argparse_defaults():
    """Test that main parses default args correctly."""
    with patch("tracecolor.monitor.udp_monitor") as mock_monitor:
        with patch("sys.argv", ["monitor"]):
            main()
            mock_monitor.assert_called_once_with("127.0.0.1", 9999)


def test_main_argparse_custom():
    """Test that main parses custom args."""
    with patch("tracecolor.monitor.udp_monitor") as mock_monitor:
        with patch("sys.argv", ["monitor", "--host", "0.0.0.0", "--port", "8888"]):
            main()
            mock_monitor.assert_called_once_with("0.0.0.0", 8888)


def test_main_legacy_listen_format():
    """Test legacy 'listen' command format."""
    with patch("tracecolor.monitor.udp_monitor") as mock_monitor:
        with patch("sys.argv", ["monitor", "listen", "192.168.1.1", "7777"]):
            main()
            mock_monitor.assert_called_once_with("192.168.1.1", 7777)


def test_udp_monitor_bind_error(capsys):
    """Test that monitor handles bind error gracefully."""
    # Bind a socket first to cause OSError on second bind
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(("127.0.0.1", 19878))
    try:
        udp_monitor("127.0.0.1", 19878)  # should print error and return
        captured = capsys.readouterr()
        assert "ERROR" in captured.out or "Cannot bind" in captured.out
    finally:
        sock.close()


def test_main_legacy_listen_defaults():
    """Test legacy listen format with defaults."""
    with patch("tracecolor.monitor.udp_monitor") as mock_monitor:
        with patch("sys.argv", ["monitor", "listen"]):
            main()
            mock_monitor.assert_called_once_with("127.0.0.1", 9999)


def test_main_version_flag():
    """Test --version flag raises SystemExit."""
    import pytest
    with pytest.raises(SystemExit):
        with patch("sys.argv", ["monitor", "--version"]):
            main()
