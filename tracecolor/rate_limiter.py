"""Rate limiting for PROGRESS messages."""

import time
from typing import Dict
from collections import defaultdict


class ProgressRateLimiter:
    """Rate limiter for PROGRESS messages - 1 per second per call site"""

    def __init__(self, interval: float = 1.0):
        self.interval = interval
        self.last_times: Dict[str, float] = defaultdict(float)

    def should_log(self, call_site: str) -> bool:
        """Check if enough time has passed since last log from this call site"""
        current_time = time.time()
        last_time = self.last_times[call_site]

        if current_time - last_time >= self.interval:
            self.last_times[call_site] = current_time
            return True
        return False
