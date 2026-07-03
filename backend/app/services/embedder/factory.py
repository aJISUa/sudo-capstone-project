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
        from app.services.embedder.openai_embedder import OpenAIEmbedder
        _REGISTRY["openai"] = OpenAIEmbedder
        _REGISTRY["gemini"] = GeminiEmbedder
        _REGISTRY["hash"] = HashEmbedder  # 오프라인 폴백(키 불필요)
    return _REGISTRY


@lru_cache
def _build(name: str) -> Embedder:
    reg = _registry()
    if name not in reg:
        raise ValueError(f"알 수 없는 임베더: '{name}'. 사용 가능: {list(reg.keys())}")
    return reg[name]()


def get_embedder(name: str | None = None) -> Embedder:
    """설정된 임베더를 반환. 선택된 provider 의 API 키가 없으면 오프라인 해시
    임베더로 폴백한다(개발/CI/데모에서도 RAG 가 동작하도록)."""
    s = get_settings()
    chosen = (name or s.embedder).lower()
    if chosen == "openai" and not s.openai_api_key:
        chosen = "hash"
    elif chosen == "gemini" and not s.gemini_api_key:
        chosen = "hash"
    return _build(chosen)
