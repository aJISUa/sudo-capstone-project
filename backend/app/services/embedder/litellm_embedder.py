"""
LiteLLM 프록시 경유 임베더 (OpenAI 호환).

주의: LiteLLM 프록시에 '임베딩 모델'이 실제로 연결돼 있어야 동작합니다.
Claude(채팅 모델)만 붙어 있으면 임베딩은 불가하므로,
그 경우 EMBEDDER 를 openai/gemini 로 두거나 임베딩 전용 키를 별도로 쓰세요.
프록시의 임베딩 모델명은 .env 의 LITELLM_EMBED_MODEL 에 지정합니다.
"""
from __future__ import annotations

from app.core.config import get_settings
from app.services.embedder.base import Embedder


class LiteLLMEmbedder(Embedder):
    name = "litellm"

    def __init__(self) -> None:
        s = get_settings()
        if not s.litellm_api_key:
            raise RuntimeError("LITELLM_API_KEY(Virtual Key) 가 설정되지 않았습니다.")
        if not s.litellm_embed_model:
            raise RuntimeError(
                "LITELLM_EMBED_MODEL 이 비어 있습니다. "
                "LiteLLM 프록시에 임베딩 모델이 연결돼 있어야 하며, 그 모델명을 지정하세요. "
                "(임베딩 모델이 없으면 EMBEDDER=openai 또는 gemini 를 사용하세요.)"
            )
        from openai import OpenAI
        self._client = OpenAI(api_key=s.openai_api_key, timeout=20.0)
        self._model = s.litellm_embed_model
        self.dim = s.embed_dim

    def embed(self, texts: list[str]) -> list[list[float]]:
        if not texts:
            return []
        resp = self._client.embeddings.create(model=self._model, input=texts)
        return [d.embedding for d in resp.data]
