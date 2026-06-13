import asyncio
import logging
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routes import chat as chat_routes

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager for startup and shutdown events.
    """
    # Startup
    logger.info("Sakshi AI API starting...")
    logger.info(f"Model: {settings.gemini_model}")
    logger.info(f"Rate limit: {settings.rate_limit_rpm} RPM")
    logger.info("API ready.")
    
    yield
    
    # Shutdown
    logger.info("Shutting down.")


# Create FastAPI application
app = FastAPI(
    title="Sakshi AI API",
    version="1.0.0",
    description="Nepali AI powered by Gemini Flash (free tier)",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_allowed_origins_list(),
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
    allow_credentials=False,
)

# Include routers
app.include_router(chat_routes.router)


@app.get("/")
async def root() -> dict:
    """Root endpoint."""
    return {
        "message": "Sakshi AI API",
        "docs": "/docs",
        "model": settings.gemini_model,
        "status": "running"
    }


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)

