import asyncio
import time
from typing import List


class RateLimiter:
    """In-memory sliding window rate limiter."""
    
    def __init__(self, max_requests: int, window_seconds: int = 60):
        """
        Initialize the rate limiter.
        
        Args:
            max_requests: Maximum number of requests allowed in the window
            window_seconds: Time window in seconds (default 60)
        """
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: List[float] = []
        self._lock = asyncio.Lock()
    
    async def is_allowed(self) -> bool:
        """
        Check if a request is allowed under the rate limit.
        
        Returns:
            True if allowed, False if rate limit exceeded
        """
        async with self._lock:
            now = time.time()
            # Remove timestamps outside the window
            self.requests = [t for t in self.requests if now - t < self.window_seconds]
            
            if len(self.requests) >= self.max_requests:
                return False
            
            self.requests.append(now)
            return True
    
    def remaining(self) -> int:
        """
        Get the number of requests remaining in the current window.
        
        Returns:
            Number of remaining requests
        """
        now = time.time()
        recent = [t for t in self.requests if now - t < self.window_seconds]
        return max(0, self.max_requests - len(recent))
