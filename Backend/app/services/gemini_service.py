import asyncio
import logging
from typing import Optional, Tuple

from google import genai
from google.genai import types

from app.config import settings

logger = logging.getLogger(__name__)


class GeminiService:
    """Service for interacting with Google Gemini Flash API."""
    
    SYSTEM_PROMPT = """You are HimalayaGPT, a helpful AI assistant focused on Nepali language and culture. You were built by a Nepali AI research team using a GPT-2 style decoder-only architecture trained on Nepali, Indic, English, code, and math data.

Rules:
- Always be helpful, accurate, and concise.
- If the user writes in Nepali (Devanagari script), respond in Nepali.
- If the user writes in English, respond in English.
- If the user writes in a mix, match their mix.
- You can help with: general questions, Nepali language, translation, coding, math, and general knowledge.
- Never claim to be ChatGPT, Gemini, or any other AI.
- You are HimalayaGPT. Always."""
    
    def __init__(self):
        """Initialize Gemini service with API client."""
        self.client = genai.Client(api_key=settings.gemini_api_key)
        self.model = settings.gemini_model
    
    async def generate(self, message: str) -> Tuple[str, Optional[int]]:
        """
        Generate a response using Google Gemini Flash API.
        
        Args:
            message: User input message
            
        Returns:
            Tuple of (reply_text, tokens_used or None)
            
        Raises:
            HTTPException: On API errors
        """
        try:
            # Build the full prompt combining system prompt and user message
            full_prompt = f"{self.SYSTEM_PROMPT}\n\nUser: {message}\nHimalayaGPT:"
            
            # Call the API using asyncio.to_thread to avoid blocking
            response = await asyncio.to_thread(
                self.client.models.generate_content,
                model=self.model,
                contents=full_prompt,
                config=types.GenerateContentConfig(
                    max_output_tokens=settings.max_output_tokens,
                    temperature=settings.temperature,
                    top_p=settings.top_p,
                ),
            )
            
            # Extract reply text
            reply = response.text.strip() if response.text else ""
            
            # Extract token count safely
            tokens = None
            if hasattr(response, "usage_metadata") and response.usage_metadata:
                tokens = response.usage_metadata.candidates_token_count
            
            logger.info(f"Gemini API response: tokens={tokens}")
            
            return reply, tokens
        
        except Exception as e:
            logger.error(f"Gemini API error: {str(e)}", exc_info=True)
            raise


# Module-level singleton
gemini_service = GeminiService()
