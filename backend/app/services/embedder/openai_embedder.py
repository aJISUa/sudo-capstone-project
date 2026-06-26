"""OpenAI 임베딩기 (text-embedding-3-small 등)."""
from __future__ import annotations

from app.core.config import get_settings
from app.services.embedder.base import Embedder


class OpenAIEmbedder(Embedder):
    name = "openai"

    def __init__(self) -> None:
        s = get_settings()
        if not s.openai_api_key:
            raise RuntimeError("OPENAI_API_KEY 가 설정되지 않았습니다.")
        from openai import OpenAI
        self._client = OpenAI(api_key=s.openai_api_key)
        self._model = s.openai_embed_model
        self.dim = s.embed_dim

    def embed(self, texts: list[str]) -> list[list[float]]:
        if not texts:
            return []
        resp = self._client.embeddings.create(model=self._model, input=texts)
        return [d.embedding for d in resp.data]
