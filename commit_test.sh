#!/bin/bash

REPO_OWNER="yoonbitnara"
REPO_NAME="yoonbitnara.github.io"
ACCESS_TOKEN="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"

# 2021년 1월 1일부터 12월 31일까지의 날짜 생성
start_date="2021-03-01"
end_date="2021-12-31"

current_date="$start_date"
while [[ "$current_date" != "$end_date" ]]; do
  echo "Processing commits for $current_date..."
  
  # 커밋 메시지 생성
  commit_message="Commit for $current_date"
  
  # 커밋 생성
  echo "Creating commit..."
  git commit --allow-empty -m "$commit_message"
  
  # 푸시
  echo "Pushing commit..."
  git push -f
  
  # 다음 날짜로 이동
  current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
done