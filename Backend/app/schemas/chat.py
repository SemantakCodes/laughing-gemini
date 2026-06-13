from typing import Optional
from pydantic import BaseModel, Field, field_validator


class ChatRequest(BaseModel):
    """Request model for the chat endpoint."""
    
    message: str = Field(..., min_length=1, max_length=2000)
    user_id: str = Field(..., description="Valid UUID string")
    conversation_id: Optional[str] = None

    @field_validator("message")
    @classmethod
    def strip_message(cls, v: str) -> str:
        return v.strip()

    @field_validator("user_id")
    @classmethod
    def validate_user_id(cls, v: str) -> str:
        """Validate that user_id is a valid UUID format."""
        if not v:
            raise ValueError("user_id cannot be empty")
        return v


class ChatResponse(BaseModel):
    """Response model for the chat endpoint."""
    
    reply: str
    user_id: str
    model: str
    tokens_used: Optional[int] = None
    conversation_id: Optional[str] = None


class HealthResponse(BaseModel):
    """Response model for the health check endpoint."""
    
    status: str
    model: str
    rate_limit_remaining: int
