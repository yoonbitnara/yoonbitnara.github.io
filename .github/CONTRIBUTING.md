# Contributing

이 레포는 개인 블로그 소스코드임.  
크게 외부 기여 받는 구조 아님. 그래도 뭔가 수정이나 개선 제안하고 싶으면 아래 참고하면 됨.  

---

## 원칙
- 코드 포맷 깨지지 않게 할 것  
- 불필요한 라이브러리 추가하지 말 것  
- 주석은 최소한으로, 내용만 남길 것  

---

## 글 추가
- `_posts/` 폴더에 Markdown 파일 생성  
- 파일명 규칙: `YYYY-MM-DD-title.md`  
- front matter(제일 위 `---` 블록) 꼭 넣을 것  
  ```yaml
  ---
  layout: single
  title: "글 제목"
  categories: [카테고리]
  ---
