"""
Gemini 로컬 동작 진단 (코치 챗 · 임베딩 · [선택] 식단 사진 인식).

.env 의 GEMINI_API_KEY 로, 백엔드가 실제 사용하는 Gemini 클래스를 그대로 호출해
"로컬에서 Gemini 가 되는지"를 DB/서버 없이 한 번에 확인한다.

사용법 (backend/ 디렉터리에서):
  python -m scripts.check_gemini                 # 챗 + 임베딩
  python -m scripts.check_gemini food.jpg        # + 식단 사진 인식까지
"""
from __future__ import annotations

import sys


def _hint(e: Exception) -> str:
    m = str(e).lower()
    if "429" in m or "resource_exhausted" in m or "quota" in m or "rate" in m:
        return "→ 할당량/레이트리밋(429). 결제·쿼터 상태 확인."
    if "403" in m or "permission" in m or "denied" in m:
        return "→ 키 권한/리전(403). API 키·프로젝트·리전 확인."
    if "404" in m or "not found" in m:
        return "→ 모델명(404). GEMINI_MODEL / 임베딩 모델명 확인."
    if "401" in m or "api key" in m or "invalid" in m or "unauthenticated" in m:
        return "→ 키 무효(401). .env 의 GEMINI_API_KEY 확인."
    return ""


def _cos(a: list[float], b: list[float]) -> float:
    return sum(x * y for x, y in zip(a, b))


def main() -> None:
    from app.core.config import get_settings

    s = get_settings()
    print("=" * 62)
    print(f" GEMINI_API_KEY 설정됨 : {bool(s.gemini_api_key)}")
    print(f" 챗/인식 모델         : {s.gemini_model}")
    print(f" EMBED_DIM(설정)      : {s.embed_dim}  (Gemini 임베딩은 768 이어야 함)")
    print("=" * 62)
    if not s.gemini_api_key:
        print("✗ .env 에 GEMINI_API_KEY 가 비어 있습니다. 키부터 넣으세요.")
        sys.exit(1)

    ok = True

    # [1] 코치 챗 — GeminiCoachLLM
    try:
        from app.services.coach.llm import GeminiCoachLLM

        r = GeminiCoachLLM().generate(
            "너는 건강 코치야. 한 문장으로만 답해.",
            "고혈압에 좋은 아침 식사 하나만 추천해줘.",
        )
        print(f"[1] 코치 챗   ✓  model={r.model} tokens={r.total_tokens}")
        print(f"              답변: {r.text.strip()[:90]}")
    except Exception as e:  # noqa: BLE001
        ok = False
        print(f"[1] 코치 챗   ✗  {type(e).__name__}: {e}  {_hint(e)}")

    # [2] 임베딩 — GeminiEmbedder (차원 768 + 의미 유사도 sanity)
    try:
        from app.services.embedder.gemini_embedder import GeminiEmbedder

        emb = GeminiEmbedder()
        base = emb.embed_one("나트륨 관리")
        related = _cos(base, emb.embed_one("저염 식단 나트륨 줄이기"))
        unrelated = _cos(base, emb.embed_one("주말 영화 관람"))
        dim_ok = len(base) == 768
        print(f"[2] 임베딩    {'✓' if dim_ok else '✗'}  차원={len(base)} (기대 768)")
        print(f"              유사도 related={related:.3f} vs unrelated={unrelated:.3f}"
              f"  → {'의미공간 정상' if related > unrelated else '⚠ 이상'}")
        if not dim_ok:
            ok = False
            print("              ⚠ EMBED_DIM=768 로 맞추고 coach_documents 재생성 필요.")
    except Exception as e:  # noqa: BLE001
        ok = False
        print(f"[2] 임베딩    ✗  {type(e).__name__}: {e}  {_hint(e)}")

    # [3] 식단 사진 인식 — GeminiVisionRecognizer (이미지 경로를 준 경우만)
    if len(sys.argv) > 1:
        import asyncio
        import mimetypes

        path = sys.argv[1]
        try:
            from app.services.recognizer.gemini import GeminiVisionRecognizer

            with open(path, "rb") as f:
                img = f.read()
            mime = mimetypes.guess_type(path)[0] or "image/jpeg"
            res = asyncio.run(GeminiVisionRecognizer().recognize(img, mime))
            print(f"[3] 식단 인식 ✓  음식 {len(res.foods)}개 · 지연 {res.latency_ms}ms")
            for fd in res.foods[:5]:
                print(f"              - {fd.name}: {fd.calories}kcal, 나트륨 {fd.sodium_mg}mg, 당 {fd.sugar_g}g")
            if res.coach_comment:
                print(f"              코치평: {res.coach_comment[:80]}")
        except FileNotFoundError:
            print(f"[3] 식단 인식 ✗  이미지 파일 없음: {path}")
        except Exception as e:  # noqa: BLE001
            ok = False
            print(f"[3] 식단 인식 ✗  {type(e).__name__}: {e}  {_hint(e)}")
    else:
        print("[3] 식단 인식 — 건너뜀 (테스트하려면: python -m scripts.check_gemini <food.jpg>)")

    print("=" * 62)
    print(" 결과:", "✅ Gemini 로컬 정상 동작" if ok else "❌ 위 ✗ 항목 확인 필요")
    print("=" * 62)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
