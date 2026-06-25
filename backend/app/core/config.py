"""환경 설정. .env 에서 읽어옵니다."""
from __future__ import annotations

from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # --- API ---
    api_v1_prefix: str = "/v1"
    app_version: str = "0.4.0"

    # --- Database ---
    database_url: str = "postgresql+psycopg://oncare:oncare@localhost:5432/oncare"

    # --- JWT ---
    jwt_secret: str = "CHANGE_ME_dev_only_secret_key_please_replace_in_prod"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24

    # --- AI 엔진 (이후 STEP 에서 사용) ---
    recognizer: str = "gemini"
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.0-flash"
    coach_llm: str = "openai"
    openai_api_key: str = ""
    openai_chat_model: str = "gpt-4o"
    embedder: str = "openai"
    openai_embed_model: str = "text-embedding-3-small"

    # --- 기타 ---
    cors_allow_origins: str = "*"
    seed_demo_data: bool = True


@lru_cache
def get_settings() -> Settings:
    return Settings()
