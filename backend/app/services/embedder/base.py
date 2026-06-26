"""임베딩 엔진 공통 인터페이스. 모델 교체는 factory 로."""
from __future__ import annotations

from abc import ABC, abstractmethod


class Embedder(ABC):
    name: str = "base"
    dim: int = 0

    @abstractmethod
    def embed(self, texts: list[str]) -> list[list[float]]:
        """여러 텍스트를 임베딩 벡터 리스트로 변환."""
        raise NotImplementedError

    def embed_one(self, text: str) -> list[float]:
        return self.embed([text])[0]
