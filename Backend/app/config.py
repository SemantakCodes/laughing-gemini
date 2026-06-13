import logging
from pathlib import Path
from typing import List
from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

logger = logging.getLogger(__name__)

# Get the path to the Backend directory (parent of app directory)
BASE_DIR = Path(__file__).parent.parent
ENV_FILE = BASE_DIR / ".env"


class Settings(BaseSettings):
    """Application configuration loaded from environment variables."""
    
    gemini_api_key: str
    gemini_model: str = "gemini-2.0-flash"
    max_output_tokens: int = 1024
    temperature: float = 0.7
    top_p: float = 0.9
    allowed_origins: str = "*"  # Keep as string, parse in validator
    rate_limit_rpm: int = 12

    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE),
        case_sensitive=False
    )

    @field_validator("allowed_origins", mode="before")
    @classmethod
    def parse_allowed_origins(cls, v):
        """Convert allowed_origins to list if needed."""
        if isinstance(v, str):
            # Return the string as-is, we'll parse it after
            return v
        return v
    
    def get_allowed_origins_list(self) -> List[str]:
        """Get allowed_origins as a list."""
        if isinstance(self.allowed_origins, str):
            return [origin.strip() for origin in self.allowed_origins.split(",")]
        return self.allowed_origins


settings = Settings()
