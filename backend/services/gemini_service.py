"""On-Care · Gemini Vision 식단 분석 PoC (독립 실행 프로토타입)

음식 사진 1장을 입력하면 Gemini Vision(gemini-2.0-flash)이
  1) 식단 구성   2) 칼로리 추정   3) 고혈압(DASH) 관점 식단평
을 한국어로 반환합니다. Flutter 앱과는 분리된 단독 스크립트입니다.

실행:
    cd backend && pip install -r requirements.txt
    cd services && cp .env.example .env      # .env 에 GEMINI_API_KEY 입력
    python gemini_service.py

참고: Gemini API 무료 티어는 계정/지역에 따라 할당량이 0일 수 있습니다
      (429 RESOURCE_EXHAUSTED · free_tier ... limit: 0). 이는 코드 문제가 아니며,
      무료로 결과만 얻으려면 https://aistudio.google.com 웹 UI에서 직접 실행하세요.
"""

import os

from dotenv import load_dotenv
from google import genai
from PIL import Image

# ── API 키 로드 ─────────────────────────────────────────────────────────
# 프로젝트 루트(.../sudo-capstone-project)의 .env 를 읽습니다.
# override=True: 셸/IDE(예: PyCharm) 환경변수에 옛 키가 남아 있어도 .env 값을 우선합니다.
_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
load_dotenv(os.path.join(_PROJECT_ROOT, ".env"), override=True)

API_KEY = os.getenv("GEMINI_API_KEY")
MODEL_ID = "gemini-2.0-flash"

PROMPT = """당신은 전문 영양사입니다. 업로드된 사진 속의 음식을 분석하여 다음 정보를 제공해주세요:

1. 식단 구성: 사진에 포함된 모든 음식의 이름을 나열하세요.
2. 칼로리 추정: 각 음식별 예상 칼로리와 전체 총 칼로리를 계산하세요.
3. 고혈압 환자 식단평:
   - 나트륨 함량(예상)이 높은 음식을 지적하세요.
   - 고혈압 관리(DASH 식단 등) 관점에서 이 식단의 장단점을 설명하세요.
   - 고혈압 환자를 위한 개선 사항(예: '국물을 남기세요', '채소를 추가하세요')을 제안하세요.

모든 답변은 한국어로 친절하게 작성해주세요."""


def analyze_diet_for_hypertension(image_path: str) -> str:
    """음식 사진을 Gemini Vision 으로 분석해 한국어 식단평 텍스트를 반환합니다."""
    if not API_KEY:
        return "에러: GEMINI_API_KEY 가 설정되지 않았습니다. 프로젝트 루트의 .env 를 확인하세요."
    if not os.path.exists(image_path):
        return f"에러: 이미지 파일을 찾을 수 없습니다 — {image_path}"

    client = genai.Client(api_key=API_KEY)

    try:
        with Image.open(image_path) as img:
            response = client.models.generate_content(
                model=MODEL_ID,
                contents=[PROMPT, img],
            )
        return response.text

    except Exception as e:  # PoC: 오류를 사람이 읽기 쉬운 형태로 반환
        msg = str(e)
        if "free_tier" in msg and "limit: 0" in msg:
            return (
                "에러: 이 API 키 프로젝트의 '무료 티어' 할당량이 0입니다 (계정/지역 제한).\n"
                "      → 코드 문제가 아닙니다. 무료로 결과만 필요하면 https://aistudio.google.com 웹 UI에서\n"
                "         같은 프롬프트 + 이미지를 직접 실행해 출력을 받으세요.\n"
                f"      (원본 오류: {msg})"
            )
        if "429" in msg or "RESOURCE_EXHAUSTED" in msg:
            return f"에러: 사용량/쿼터 초과(429). 잠시 후 다시 시도하세요.\n      (원본 오류: {msg})"
        return f"에러 발생: {msg}"


if __name__ == "__main__":
    _here = os.path.dirname(os.path.abspath(__file__))
    _image = os.path.join(_here, "mymeal_1.jpg")
    print(analyze_diet_for_hypertension(_image))
