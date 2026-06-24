"""
재임베딩 스크립트.

임베딩 모델/차원을 바꾼 뒤 실행합니다.
주의: 차원이 바뀌면 coach_documents 의 embedding 컬럼 차원도 바뀌어야 하므로,
      .env 의 EMBED_DIM 을 새 모델에 맞춘 뒤, 테이블을 재생성(또는 마이그레이션)하고
      원본 content 로 다시 임베딩해야 합니다.

이 스크립트는 기존 content 를 보존한 채 embedding 만 다시 계산합니다.
(차원 변경이 동반되면 먼저 DB 컬럼을 새 차원으로 ALTER/재생성하세요.)

사용법:  python -m scripts.reembed
"""
from __future__ import annotations

from sqlalchemy import select

from app.db.session import SessionLocal
from app.models.models import CoachDocument
from app.services.embedder.factory import get_embedder


def main() -> None:
    db = SessionLocal()
    try:
        rows = list(db.scalars(select(CoachDocument)).all())
        if not rows:
            print("재임베딩할 문서가 없습니다.")
            return
        embedder = get_embedder()
        # 배치로 임베딩
        contents = [r.content for r in rows]
        vectors = embedder.embed(contents)
        for r, v in zip(rows, vectors):
            r.embedding = v
        db.commit()
        print(f"재임베딩 완료: {len(rows)}개 청크 (embedder={embedder.name}, dim={embedder.dim})")
    finally:
        db.close()


if __name__ == "__main__":
    main()
