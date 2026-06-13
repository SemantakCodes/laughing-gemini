import asyncio
import logging
from typing import Optional, Tuple

from google import genai
from google.genai import types

from app.config import settings

logger = logging.getLogger(__name__)


class GeminiService:
    """Service for interacting with Google Gemini Flash API."""
    
    SYSTEM_PROMPT = """You are Sakshi AI, a helpful AI assistant. You were built by a research team using a GPT-2 style decoder-only architecture trained on Nepali, Indic, English, code, and math data.

Rules:
- Always be helpful, accurate, and concise.
- If the user writes in Nepali (Devanagari script), respond in Nepali.
- If the user writes in English, respond in English.
- If the user writes in a mix, match their mix.
- You can help with: general questions, Nepali language, translation, coding, math, and general knowledge.
- Never claim to be ChatGPT, Gemini, or any other AI.
- You are Sakshi AI. Always."""
    
    def __init__(self):
        """Initialize Gemini service with API client."""
        self.client = None
        if settings.gemini_api_key:
            try:
                self.client = genai.Client(api_key=settings.gemini_api_key)
            except Exception as e:
                logger.warning(f"Failed to initialize default Gemini client: {e}")
        self.model = settings.gemini_model
    
    async def generate(self, message: str, custom_api_key: Optional[str] = None) -> Tuple[str, Optional[int]]:
        """
        Generate a response using Google Gemini Flash API.
        
        Args:
            message: User input message
            custom_api_key: Optional custom API key from the user
            
        Returns:
            Tuple of (reply_text, tokens_used or None)
            
        Raises:
            HTTPException: On API errors
        """
        try:
            # Build the full prompt combining system prompt and user message
            full_prompt = f"{self.SYSTEM_PROMPT}\n\nUser: {message}\nSakshi AI:"
            
            client_to_use = self.client
            if custom_api_key:
                try:
                    client_to_use = genai.Client(api_key=custom_api_key)
                except Exception as e:
                    logger.warning(f"Failed to initialize custom Gemini client: {e}")
            
            if not client_to_use:
                raise ValueError("No Gemini API Key provided. Please provide one in the frontend settings.")
            
            # Call the API using asyncio.to_thread to avoid blocking
            response = await asyncio.to_thread(
                client_to_use.models.generate_content,
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
