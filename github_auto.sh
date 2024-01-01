#!/bin/bash

# 사용자 본인이 입력해야 됨.
REPO_OWNER="yoonbitnara"
REPO_NAME="yoonbitnara.github.io"
ACCESS_TOKEN="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"

# commit 할 날짜 생성. 임의로 바꿔도 됨.
start_date="2024-01-01"
end_date="2025-09-01"

current_date="$start_date"
while [[ "$current_date" != "$end_date" ]]; do
  echo "Processing commits for $current_date..."
  
  # 커밋 메시지 생성
  commit_message="Commit for $current_date"
  
  # 임시로 날짜 변경
  export GIT_AUTHOR_DATE="$current_date 20:19:19 KST"
  export GIT_COMMITTER_DATE="$current_date 20:19:19 KST"
  
  # 커밋 생성
  echo "Creating commit..."
  git commit --allow-empty -m "$commit_message"
  
  # 푸시
  echo "Pushing commit..."
  git push origin master
  
  # 다음 날짜로 이동
  current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
done