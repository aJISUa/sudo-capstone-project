"""임베딩기 factory — .env 의 EMBEDDER 로 선택."""
from __future__ import annotations

from functools import lru_cache

from app.core.config import get_settings
from app.services.embedder.base import Embedder

_REGISTRY: dict[str, type[Embedder]] = {}


def _registry() -> dict[str, type[Embedder]]:
    if not _REGISTRY:
        from app.services.embedder.gemini_embedder import GeminiEmbedder
        from app.services.embedder.hash_embedder import HashEmbedder
        from app.services.embedder.litellm_embedder import LiteLLMEmbedder
        from app.services.embedder.openai_embedder import OpenAIEmbedder
        _REGISTRY["openai"] = OpenAIEmbedder
        _REGISTRY["gemini"] = GeminiEmbedder
        _REGISTRY["litellm"] = LiteLLMEmbedder
        _REGISTRY["hash"] = HashEmbedder  # 오프라인 폴백(키 불필요)
    return _REGISTRY


@lru_cache
def _build(name: str) -> Embedder:
    reg = _registry()
    if name not in reg:
        raise ValueError(f"알 수 없는 임베더: '{name}'. 사용 가능: {list(reg.keys())}")
    return reg[name]()


def get_embedder(name: str | None = None) -> Embedder:
    """설정된 임베더를 반환. 선택된 provider 의 API 키(또는 LiteLLM 임베딩 모델)가
    없으면 오프라인 해시 임베더로 폴백한다(개발/CI/데모에서도 RAG 가 동작하도록)."""
    s = get_settings()
    chosen = (name or s.embedder).lower()
    if chosen == "openai" and not s.openai_api_key:
        chosen = "hash"
    elif chosen == "gemini" and not s.gemini_api_key:
        chosen = "hash"
    elif chosen == "litellm" and not (
        s.litellm_base_url and s.litellm_api_key and s.litellm_embed_model
    ):
        # LiteLLM 프록시에 임베딩 모델이 없으면 LiteLLMEmbedder 가 기동 중
        # RuntimeError 를 던져, 공공/개인 문서가 하나도 적재되지 않는다 → RAG 검색이
        # 비고 코치가 규칙 기반 폴백에 갇힌다. 해시 임베더로 폴백해 오프라인에서도
        # 적재·검색·코칭 경로가 동작하게 한다.
        chosen = "hash"
    return _build(chosen)
