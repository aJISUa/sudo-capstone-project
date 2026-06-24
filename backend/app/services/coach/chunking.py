"""
청킹 유틸 — 문장 단위 슬라이딩 윈도우.

설정(config)에서 window/overlap 을 읽으므로, 최적값을 찾으면 .env 만 수정.
  chunk_window  : 한 청크에 묶을 문장 수 (기본 5)
  chunk_overlap : 청크 간 겹칠 문장 수 (기본 1)
"""
from __future__ import annotations

import re

from app.core.config import get_settings

# 한국어/영어 문장 분리 (마침표/물음표/느낌표/줄바꿈 기준의 단순 분리)
_SENT_SPLIT = re.compile(r"(?<=[.!?。\n])\s+")


def split_sentences(text: str) -> list[str]:
    parts = [s.strip() for s in _SENT_SPLIT.split(text) if s.strip()]
    return parts


def chunk_text(text: str, window: int | None = None, overlap: int | None = None) -> list[str]:
    """문장 슬라이딩 윈도우로 청크 생성."""
    s = get_settings()
    w = window if window is not None else s.chunk_window
    ov = overlap if overlap is not None else s.chunk_overlap
    if w <= 0:
        w = 5
    if ov >= w:
        ov = max(0, w - 1)

    sentences = split_sentences(text)
    if not sentences:
        return []

    step = w - ov
    chunks: list[str] = []
    i = 0
    while i < len(sentences):
        chunk = " ".join(sentences[i : i + w])
        if chunk:
            chunks.append(chunk)
        if i + w >= len(sentences):
            break
        i += step
    return chunks
