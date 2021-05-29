#!/bin/bash

REPO_OWNER="yoonbitnara"
REPO_NAME="yoonbitnara.github.io"
ACCESS_TOKEN="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"

# commit 할 날짜 생성
start_date="2021-01-01"
end_date="2022-01-01"

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