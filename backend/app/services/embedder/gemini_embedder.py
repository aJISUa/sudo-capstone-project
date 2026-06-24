"""
Gemini 임베딩기 (text-embedding-004 등). 모델 교체 옵션.

주의: Gemini 임베딩 차원(보통 768)은 OpenAI(1536)와 다릅니다.
이 임베더로 바꾸면 .env 의 EMBED_DIM 도 맞추고 재임베딩해야 합니다.
"""
from __future__ import annotations

from app.core.config import get_settings
from app.services.embedder.base import Embedder


class GeminiEmbedder(Embedder):
    name = "gemini"

    def __init__(self) -> None:
        s = get_settings()
        if not s.gemini_api_key:
            raise RuntimeError("GEMINI_API_KEY 가 설정되지 않았습니다.")
        from google import genai
        self._client = genai.Client(api_key=s.gemini_api_key)
        self._model = "text-embedding-004"
        self.dim = s.embed_dim

    def embed(self, texts: list[str]) -> list[list[float]]:
        if not texts:
            return []
        out: list[list[float]] = []
        # Gemini 임베딩 API 는 건별 호출이 단순(배치도 가능하나 호환 위해 건별)
        for t in texts:
            r = self._client.models.embed_content(model=self._model, contents=t)
            out.append(list(r.embeddings[0].values))
        return out
