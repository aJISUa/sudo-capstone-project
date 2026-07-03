"""환경 설정. .env 에서 읽어옵니다."""
from __future__ import annotations

from functools import lru_cache

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# 개발 기본 시크릿(운영에서 그대로 쓰면 기동 차단)
DEFAULT_JWT_SECRET = "CHANGE_ME_dev_only_secret_key_please_replace_in_prod"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # --- 환경 ---
    env: str = "dev"  # dev | staging | prod

    # --- API ---
    api_v1_prefix: str = "/v1"
    app_version: str = "0.4.0"

    # --- Database ---
    database_url: str = "postgresql+psycopg://oncare:oncare@localhost:5432/oncare"
    # 앱 기동 시 create_all() 로 테이블 생성 여부(개발 편의). 운영은 Alembic 을 정답으로 → false 권장.
    auto_create_tables: bool = True

    # --- JWT ---
    jwt_secret: str = DEFAULT_JWT_SECRET
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

    @property
    def is_prod(self) -> bool:
        return self.env.strip().lower() in ("prod", "production")

    @model_validator(mode="after")
    def _guard_prod_secrets(self) -> "Settings":
        """운영 환경에서 안전하지 않은 기본값을 쓰면 기동을 막는다(fail-fast)."""
        if self.is_prod:
            if not self.jwt_secret or self.jwt_secret == DEFAULT_JWT_SECRET:
                raise ValueError(
                    "운영(env=prod)에서는 JWT_SECRET 을 안전한 값으로 반드시 설정해야 합니다."
                )
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
