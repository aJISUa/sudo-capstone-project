"""오프라인 결정론적 임베더 (feature hashing).

API 키가 필요 없어 개발/CI/데모에서도 RAG(적재·검색)가 실제로 동작한다.
방식: 토큰(단어 + 한글 char bigram)을 해시로 버킷에 분배(bag-of-words hashing) 후 L2 정규화.
같은 토큰을 공유하는 문장은 코사인 유사도가 높아져 벡터 검색이 의미를 가진다.

주의: 실서비스에서 OpenAI/Gemini 키가 있으면 factory 가 진짜 임베더를 쓴다. 한 배포 안에서
임베더를 바꾸면(해시↔실모델) 기존 벡터와 의미공간이 달라 재임베딩이 필요하다.
"""
from __future__ import annotations

import hashlib
import math
import re

from app.core.config import get_settings
from app.services.embedder.base import Embedder

# 영문/숫자 토큰과 한글 토큰을 각각 추출
_TOKEN = re.compile(r"[0-9a-z]+|[가-힣]+")


def _bucket(token: str, dim: int) -> int:
    """토큰을 [0, dim) 버킷으로 해시(md5 → 프로세스 간 안정적)."""
    digest = hashlib.md5(token.encode("utf-8")).digest()
    return int.from_bytes(digest[:4], "big") % dim


def _tokens(text: str) -> list[str]:
    toks: list[str] = []
    for w in _TOKEN.findall((text or "").lower()):
        toks.append(w)
        # 한글은 띄어쓰기가 적어 char bigram 으로 부분 일치를 보강
        if len(w) >= 2:
            toks.extend(w[i:i + 2] for i in range(len(w) - 1))
    return toks


class HashEmbedder(Embedder):
    name = "hash"

    def __init__(self) -> None:
        self.dim = get_settings().embed_dim

    def embed(self, texts: list[str]) -> list[list[float]]:
        return [self._vec(t) for t in texts]

    def _vec(self, text: str) -> list[float]:
        v = [0.0] * self.dim
        for tok in _tokens(text):
            v[_bucket(tok, self.dim)] += 1.0
        norm = math.sqrt(sum(x * x for x in v))
        if norm > 0:
            v = [x / norm for x in v]
        return v
