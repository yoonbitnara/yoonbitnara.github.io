#!/bin/bash

# GitHub 잔디 심기 자동화 스크립트
# Windows Git Bash 환경에서 실행

# 사용자 설정 (필요시 수정)
REPO_OWNER="yoonbitnara"
REPO_NAME="yoonbitnara.github.io"
ACCESS_TOKEN="${GITHUB_TOKEN}"

# Git 인증 설정
git config --global credential.helper store
echo "https://${ACCESS_TOKEN}@github.com" > ~/.git-credentials

# commit 할 날짜 범위 설정
start_date="2024-01-01"
end_date="2025-09-01"

# 날짜 포맷 함수 (Windows Git Bash용)
add_days() {
    local date_str=$1
    local days=$2
    # Windows Git Bash에서 date 명령어 사용
    date -d "$date_str + $days days" +%Y-%m-%d 2>/dev/null || \
    date -j -v+${days}d -f "%Y-%m-%d" "$date_str" +%Y-%m-%d 2>/dev/null || \
    python3 -c "from datetime import datetime, timedelta; print((datetime.strptime('$date_str', '%Y-%m-%d') + timedelta(days=$days)).strftime('%Y-%m-%d'))" 2>/dev/null
}

current_date="$start_date"
commit_count=0

echo "=== GitHub 잔디 심기 시작 ==="
echo "시작 날짜: $start_date"
echo "종료 날짜: $end_date"
echo "================================"

while [[ "$current_date" < "$end_date" ]]; do
  echo "처리 중: $current_date (진행률: $(( (commit_count * 100) / 365 ))%)"
  
  # 커밋 메시지 생성 (다양한 메시지로 변경)
  messages=(
    "Daily commit for $current_date"
    "Update: $current_date"
    "Progress: $current_date"
    "Learning: $current_date"
    "Code: $current_date"
  )
  commit_message="${messages[$((commit_count % ${#messages[@]}))]}"
  
  # Git 날짜 설정
  export GIT_AUTHOR_DATE="$current_date 20:19:19 +0900"
  export GIT_COMMITTER_DATE="$current_date 20:19:19 +0900"
  
  # 빈 커밋 생성
  echo "  커밋 생성 중..."
  git commit --allow-empty -m "$commit_message" --quiet
  
  # 10개마다 푸시 (너무 많은 푸시 방지)
  if [ $((commit_count % 10)) -eq 0 ]; then
    echo "  푸시 중..."
    git push origin master --quiet
  fi
  
  # 다음 날짜로 이동
  next_date=$(add_days "$current_date" 1)
  if [ "$next_date" = "$current_date" ]; then
    echo "날짜 계산 오류. 스크립트를 종료합니다."
    break
  fi
  current_date="$next_date"
  commit_count=$((commit_count + 1))
  
  # 진행 상황 표시
  if [ $((commit_count % 50)) -eq 0 ]; then
    echo "  진행 상황: $commit_count개 커밋 완료"
  fi
done

# 마지막 푸시
echo "최종 푸시 중..."
git push origin master

echo "=== 완료 ==="
echo "총 $commit_count개의 커밋이 생성되었습니다."
echo "GitHub에서 잔디를 확인해보세요!"