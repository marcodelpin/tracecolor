"""Tests for ProgressRateLimiter."""

import time
import pytest
from tracecolor.rate_limiter import ProgressRateLimiter


def test_first_call_always_passes():
    limiter = ProgressRateLimiter(interval=1.0)
    assert limiter.should_log("site_a") is True


def test_rapid_calls_blocked():
    limiter = ProgressRateLimiter(interval=1.0)
    limiter.should_log("site_a")
    assert limiter.should_log("site_a") is False


def test_different_sites_independent():
    limiter = ProgressRateLimiter(interval=1.0)
    assert limiter.should_log("site_a") is True
    assert limiter.should_log("site_b") is True


def test_passes_after_interval():
    limiter = ProgressRateLimiter(interval=0.1)
    assert limiter.should_log("site_a") is True
    time.sleep(0.15)
    assert limiter.should_log("site_a") is True
