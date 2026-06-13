import logging
import time
from fastapi import APIRouter, Depends, HTTPException

from app.config import settings
from app.schemas.chat import ChatRequest, ChatResponse, HealthResponse
from app.services.gemini_service import GeminiService
from app.rate_limiter import RateLimiter
from app.dependencies import get_gemini_service, get_rate_limiter

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["chat"])


@router.post("/chat")
async def chat(
    request: ChatRequest,
    gemini_service: GeminiService = Depends(get_gemini_service),
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
) -> ChatResponse:
    """
    Chat endpoint that generates a response using Google Gemini Flash.
    
    Args:
        request: ChatRequest containing user message and user_id
        gemini_service: Injected Gemini service singleton
        rate_limiter: Injected rate limiter singleton
        
    Returns:
        ChatResponse with generated reply and metadata
    """
    try:
        # Check rate limit
        allowed = await rate_limiter.is_allowed()
        if not allowed:
            logger.warning(
                f"Rate limit exceeded for user {request.user_id[:8]}"
            )
            raise HTTPException(
                status_code=429,
                detail="Rate limit reached. Max 12 requests/minute on free tier."
            )
        
        # Log request
        logger.info(
            f"Chat request | user_id: {request.user_id[:8]} | "
            f"message_length: {len(request.message)}"
        )
        
        # Generate response
        start_time = time.time()
        reply, tokens_used = await gemini_service.generate(request.message)
        elapsed_ms = (time.time() - start_time) * 1000
        
        # Log response
        logger.info(
            f"Chat response | user_id: {request.user_id[:8]} | "
            f"tokens_used: {tokens_used} | elapsed_ms: {elapsed_ms:.2f}"
        )
        
        response = ChatResponse(
            reply=reply,
            user_id=request.user_id,
            model=settings.gemini_model,
            tokens_used=tokens_used,
            conversation_id=request.conversation_id,
        )
        
        return response
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            f"Chat error for user {request.user_id[:8]}: {str(e)}", 
            exc_info=True
        )
        raise HTTPException(
            status_code=502,
            detail="Gemini API error: " + str(e)
        )


@router.get("/health")
async def health(
    rate_limiter: RateLimiter = Depends(get_rate_limiter),
) -> HealthResponse:
    """
    Health check endpoint.
    
    Returns:
        Status information including rate limit
    """
    return HealthResponse(
        status="ok",
        model=settings.gemini_model,
        rate_limit_remaining=rate_limiter.remaining(),
    )

