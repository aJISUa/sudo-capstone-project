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

    # --- AI 엔진 ---
    recognizer: str = "gemini"        # gemini | claude(litellm) | yolo
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.0-flash"
    coach_llm: str = "openai"         # openai | gemini | litellm
    openai_api_key: str = ""
    openai_chat_model: str = "gpt-4o"
    embedder: str = "openai"          # openai | gemini | litellm
    openai_embed_model: str = "text-embedding-3-small"

    # --- LiteLLM 프록시 (OpenAI 호환) ---
    # 하나의 Virtual Key 로 뒤의 여러 모델(claude 등)을 호출.
    # base_url 을 넣으면 OpenAI SDK 가 이 프록시를 바라봄.
    litellm_base_url: str = "http://43.201.226.184:4000"
    litellm_api_key: str = ""                       # Virtual Key
    litellm_chat_model: str = "claude-sonnet-4-6"   # 코치/인식용 채팅 모델
    litellm_embed_model: str = ""                   # 프록시에 임베딩 모델 있으면 지정
    litellm_vision_model: str = "claude-sonnet-4-6" # 식단 인식(이미지)용

    # --- RAG (STEP 7) ---
    # 임베딩 차원: 모델에 맞춰 바꿉니다. 바꾸면 재임베딩 필요(scripts/reembed).
    #   OpenAI text-embedding-3-small/large = 1536 / 3072
    #   Gemini text-embedding-004          = 768
    embed_dim: int = 1536
    # 청킹: 윈도우(문장 수)와 겹침(stride 보정). 최적값 찾으면 여기만 수정.
    chunk_window: int = 5      # 한 청크에 묶을 문장 수
    chunk_overlap: int = 1     # 청크 간 겹칠 문장 수
    # 검색: 개인 문서 / 공공 문서 각각 top-k
    retrieve_personal_k: int = 3
    retrieve_public_k: int = 3

    # --- 기타 ---
    cors_allow_origins: str = "*"
    seed_demo_data: bool = True


@lru_cache
def get_settings() -> Settings:
    return Settings()
