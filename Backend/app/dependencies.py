from app.services.gemini_service import gemini_service
from app.rate_limiter import RateLimiter
from app.config import settings


def get_gemini_service():
    """Dependency function that returns the Gemini service singleton."""
    return gemini_service


# Create rate limiter singleton at module level
rate_limiter = RateLimiter(max_requests=settings.rate_limit_rpm)


def get_rate_limiter() -> RateLimiter:
    """Dependency function that returns the rate limiter singleton."""
    return rate_limiter
