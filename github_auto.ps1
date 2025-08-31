# GitHub 잔디 심기 자동화 스크립트 (PowerShell 버전)
# Windows PowerShell 환경에서 실행

# 사용자 설정
$REPO_OWNER = "yoonbitnara"
$REPO_NAME = "yoonbitnara.github.io"
$ACCESS_TOKEN = $env:GITHUB_TOKEN

# Git 인증 설정
git config --global credential.helper store
"https://${ACCESS_TOKEN}@github.com" | Out-File -FilePath "$env:USERPROFILE\.git-credentials" -Encoding ASCII

# commit 할 날짜 범위 설정
$startDate = [DateTime]::ParseExact("2024-03-01", "yyyy-MM-dd", $null)
$endDate = [DateTime]::ParseExact("2025-09-01", "yyyy-MM-dd", $null)

$currentDate = $startDate
$commitCount = 0

Write-Host "=== GitHub 잔디 심기 시작 ===" -ForegroundColor Green
Write-Host "시작 날짜: $($startDate.ToString('yyyy-MM-dd'))" -ForegroundColor Yellow
Write-Host "종료 날짜: $($endDate.ToString('yyyy-MM-dd'))" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Green

# 커밋 메시지 배열
$messages = @(
    "Daily commit for {0}",
    "Update: {0}",
    "Progress: {0}",
    "Learning: {0}",
    "Code: {0}"
)

while ($currentDate -lt $endDate) {
    $dateStr = $currentDate.ToString("yyyy-MM-dd")
    $progress = [Math]::Round(($commitCount * 100) / 365, 1)
    
    Write-Host "처리 중: $dateStr (진행률: $progress%)" -ForegroundColor Cyan
    
    # 커밋 메시지 선택
    $messageTemplate = $messages[$commitCount % $messages.Count]
    $commitMessage = $messageTemplate -f $dateStr
    
    # Git 날짜 설정
    $env:GIT_AUTHOR_DATE = "$dateStr 20:19:19 +0900"
    $env:GIT_COMMITTER_DATE = "$dateStr 20:19:19 +0900"
    
    # 빈 커밋 생성
    Write-Host "  커밋 생성 중..." -ForegroundColor Gray
    git commit --allow-empty -m $commitMessage --quiet
    
    # 10개마다 푸시 (너무 많은 푸시 방지)
    if ($commitCount % 10 -eq 0) {
        Write-Host "  푸시 중..." -ForegroundColor Gray
        git push origin master --quiet
    }
    
    # 다음 날짜로 이동
    $currentDate = $currentDate.AddDays(1)
    $commitCount++
    
    # 진행 상황 표시
    if ($commitCount % 50 -eq 0) {
        Write-Host "  진행 상황: $commitCount개 커밋 완료" -ForegroundColor Yellow
    }
}

# 마지막 푸시
Write-Host "최종 푸시 중..." -ForegroundColor Green
git push origin master

Write-Host "=== 완료 ===" -ForegroundColor Green
Write-Host "총 $commitCount개의 커밋이 생성되었습니다." -ForegroundColor Yellow
Write-Host "GitHub에서 잔디를 확인해보세요!" -ForegroundColor Green
