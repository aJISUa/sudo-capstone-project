"""
공공문서 적재 스크립트.

공공기관 공식 문서(텍스트로 추출한 것)를 RAG 에 공공 문서(user_id=NULL)로 적재합니다.

사용법:
  python -m scripts.ingest_public docs/hypertension_guide.txt --domain diet --title "고혈압 식이요법 가이드"
  python -m scripts.ingest_public docs/exercise_guide.txt --domain exercise --title "운동 권고안"

PDF 라면 먼저 텍스트로 변환해서 .txt 로 넣으세요(추후 pdf 로더 추가 가능).
모델/차원을 바꾼 경우엔 reembed 스크립트로 재임베딩하세요.
"""
from __future__ import annotations

import argparse
import sys

from app.db.session import SessionLocal
from app.services.coach.rag import ingest_document


def main() -> None:
    ap = argparse.ArgumentParser(description="공공문서를 RAG 에 적재")
    ap.add_argument("path", help="텍스트 파일 경로")
    ap.add_argument("--domain", default="general", choices=["diet", "exercise", "general"])
    ap.add_argument("--title", default="", help="문서 제목(출처 표기에 사용)")
    ap.add_argument("--source", default="public", help="출처 라벨")
    args = ap.parse_args()

    try:
        with open(args.path, encoding="utf-8") as f:
            content = f.read()
    except OSError as e:
        print(f"파일을 읽을 수 없습니다: {e}", file=sys.stderr)
        sys.exit(1)

    db = SessionLocal()
    try:
        n = ingest_document(
            db, content, user_id=None,  # 공공 문서
            domain=args.domain, source=args.source, title=args.title,
        )
        print(f"적재 완료: {n}개 청크 (domain={args.domain}, title='{args.title}')")
    finally:
        db.close()


if __name__ == "__main__":
    main()
