# GitHub 잔디 심기 자동화 스크립트

이 스크립트는 GitHub 잔디(커밋 히스토리)를 자동으로 생성하는 도구입니다.

## 파일 설명

- `github_auto.sh`: Linux/macOS/Windows Git Bash용 스크립트
- `github_auto.ps1`: Windows PowerShell용 스크립트

## 사용 전 준비사항

### 1. GitHub Personal Access Token 생성
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token" 클릭
3. 권한 선택: `repo` (전체 저장소 접근)
4. 토큰 생성 후 복사해두기

### 2. 환경변수 설정

#### Windows (PowerShell)
```powershell
$env:GITHUB_TOKEN = "your_token_here"
```

#### Windows (Git Bash) / Linux / macOS
```bash
export GITHUB_TOKEN="your_token_here"
```

## 사용법

### PowerShell 버전 (권장)
```powershell
# PowerShell에서 실행
.\github_auto.ps1
```

### Git Bash 버전
```bash
# Git Bash에서 실행
bash github_auto.sh
```

## 설정 변경

스크립트 상단의 설정을 수정할 수 있습니다:

```bash
# 날짜 범위 설정
start_date="2024-01-01"  # 시작 날짜
end_date="2025-09-01"    # 종료 날짜

# 저장소 정보
REPO_OWNER="yoonbitnara"
REPO_NAME="yoonbitnara.github.io"
```

## 주의사항

1. **토큰 보안**: 절대 토큰을 코드에 하드코딩하지 마세요.
2. **저장소 권한**: 토큰에 해당 저장소에 대한 쓰기 권한이 있어야 합니다.
3. **네트워크**: 안정적인 인터넷 연결이 필요합니다.
4. **Git 설정**: Git이 올바르게 설정되어 있어야 합니다.

## 문제 해결

### 날짜 계산 오류
- Windows Git Bash에서 `date` 명령어가 작동하지 않을 경우
- PowerShell 버전 사용 권장

### 인증 오류
- 토큰이 올바른지 확인
- 저장소 권한 확인
- Git 자격 증명 캐시 삭제: `git config --global --unset credential.helper`

### 푸시 실패
- 네트워크 연결 확인
- 저장소 상태 확인
- 토큰 만료 여부 확인

## 실행 예시

```
=== GitHub 잔디 심기 시작 ===
시작 날짜: 2024-01-01
종료 날짜: 2025-09-01
================================
처리 중: 2024-01-01 (진행률: 0%)
  커밋 생성 중...
처리 중: 2024-01-02 (진행률: 0.3%)
  커밋 생성 중...
...
=== 완료 ===
총 365개의 커밋이 생성되었습니다.
GitHub에서 잔디를 확인해보세요!
```
