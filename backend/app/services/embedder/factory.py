"""임베딩기 factory — .env 의 EMBEDDER 로 선택."""
from __future__ import annotations

from functools import lru_cache

from app.core.config import get_settings
from app.services.embedder.base import Embedder

_REGISTRY: dict[str, type[Embedder]] = {}


def _registry() -> dict[str, type[Embedder]]:
    if not _REGISTRY:
        from app.services.embedder.openai_embedder import OpenAIEmbedder
        from app.services.embedder.gemini_embedder import GeminiEmbedder
        _REGISTRY["openai"] = OpenAIEmbedder
        _REGISTRY["gemini"] = GeminiEmbedder
    return _REGISTRY


@lru_cache
def _build(name: str) -> Embedder:
    reg = _registry()
    if name not in reg:
        raise ValueError(f"알 수 없는 임베더: '{name}'. 사용 가능: {list(reg.keys())}")
    return reg[name]()


def get_embedder(name: str | None = None) -> Embedder:
    return _build((name or get_settings().embedder).lower())
