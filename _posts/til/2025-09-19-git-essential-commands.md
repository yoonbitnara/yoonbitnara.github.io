---
title: "신입 개발자가 꼭 알아야 할 Git 명령어 정리"
date: 2025-09-19
categories: Til
tags: [git, version-control, beginner, development, essential-commands]
author: pitbull terrier
---

# 신입 개발자가 꼭 알아야 할 Git 명령어 정리

처음 개발자로 입사했을 때 가장 당황스러웠던 건 Git이었다. "커밋해줘", "푸시해줘", "브랜치 만들어줘" 이런 말들이 나올 때마다 정말 당황했다. "Git이 뭐야? 왜 이렇게 복잡해?"라고 생각했던 기억이 난다.

하지만 시간이 지나면서 Git이 얼마나 중요한지 깨달았다. 혼자 개발할 때는 몰랐지만, 팀으로 개발할 때는 Git 없이는 절대 불가능하다. 코드의 버전 관리, 협업, 백업까지 모든 게 Git으로 이뤄진다.

오늘은 신입 개발자들이 꼭 알아야 할 Git 명령어들을 실무 경험을 바탕으로 정리해보겠다.

## Git이 왜 중요한가?

### 버전 관리의 핵심
Git은 코드의 변화를 시간순으로 기록해주는 시스템이다. 마치 게임의 세이브 포인트처럼, 언제든지 이전 상태로 돌아갈 수 있다.

**실제 경험담**
- 내가 실수로 중요한 코드를 삭제했을 때 Git 덕분에 복구할 수 있었다
- "이전에 잘 동작했던 버전이 뭐였지?"라고 생각할 때 Git 히스토리가 정말 유용했다
- 팀원이 "어제 버전으로 롤백해줘"라고 할 때 Git 없이는 불가능했다

### 협업의 기반
여러 명이 같은 프로젝트를 작업할 때 Git이 없으면 정말 지옥이다. 누가 어떤 코드를 언제 수정했는지 추적할 수 없다.

## 기본 설정부터 시작하기

### Git 사용자 정보 설정
처음 Git을 사용할 때 가장 먼저 해야 할 일이다.

```bash
# 전역 사용자 정보 설정
git config --global user.name "본인 이름"
git config --global user.email "본인 이메일"

# 설정 확인
git config --list
```

**왜 중요한가?**
- 커밋할 때 누가 작성했는지 기록됨
- GitHub나 GitLab에서 커밋 히스토리를 볼 때 중요한 정보
- 회사에서는 반드시 회사 이메일로 설정해야 함

### 기본 에디터 설정
Git 메시지를 작성할 때 사용할 에디터를 설정한다.

```bash
# VS Code로 설정 (추천)
git config --global core.editor "code --wait"

# 또는 Vim으로 설정
git config --global core.editor "vim"
```

## 필수 Git 명령어 정리

### 1. 저장소 초기화 및 복제

#### git init
새로운 Git 저장소를 만든다.

```bash
# 현재 폴더를 Git 저장소로 만들기
git init

# 특정 폴더를 Git 저장소로 만들기
git init 프로젝트폴더
```

**언제 사용하나?**
- 새로운 프로젝트를 시작할 때
- 기존 폴더를 Git으로 관리하고 싶을 때

#### git clone
원격 저장소를 내 컴퓨터로 복사한다.

```bash
# 기본 복제
git clone https://github.com/사용자명/저장소명.git

# 특정 폴더명으로 복제
git clone https://github.com/사용자명/저장소명.git 내폴더명

# 특정 브랜치만 복제
git clone -b 브랜치명 https://github.com/사용자명/저장소명.git
```

**실무 팁**
- 회사에서는 보통 SSH 키를 사용하므로 HTTPS 대신 SSH URL 사용
- `git clone git@github.com:사용자명/저장소명.git`

### 2. 파일 상태 확인

#### git status
현재 Git 저장소의 상태를 확인한다.

```bash
# 기본 상태 확인
git status

# 간단한 형태로 확인
git status -s
```

**출력 예시**
```
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   src/App.js

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        new-file.js

no changes added to commit (use "git add" or "git commit -a")
```

**상태별 의미**
- **Untracked**: Git이 관리하지 않는 새 파일
- **Modified**: 수정된 파일
- **Staged**: 커밋 준비가 된 파일

#### git diff
파일의 변경사항을 자세히 확인한다.

```bash
# 작업 디렉토리와 스테이징 영역 비교
git diff

# 스테이징 영역과 마지막 커밋 비교
git diff --staged

# 특정 파일만 확인
git diff 파일명

# 커밋 간 비교
git diff 커밋1 커밋2
```

### 3. 파일 추가 및 커밋

#### git add
변경된 파일을 스테이징 영역에 추가한다.

```bash
# 특정 파일 추가
git add 파일명

# 모든 변경사항 추가
git add .

# 특정 확장자 파일만 추가
git add *.js

# 특정 폴더만 추가
git add src/

# 대화형으로 선택적 추가
git add -p
```

**실무 팁**
- `git add .`는 편리하지만 신중하게 사용해야 함
- 불필요한 파일까지 추가될 수 있음
- `.gitignore` 파일을 잘 관리하는 것이 중요

#### git commit
스테이징된 변경사항을 저장소에 저장한다.

```bash
# 기본 커밋
git commit -m "커밋 메시지"

# 자세한 메시지와 함께 커밋
git commit -m "제목" -m "상세 설명"

# 모든 변경사항을 자동으로 추가하고 커밋
git commit -am "커밋 메시지"

# 이전 커밋 메시지 수정
git commit --amend -m "새로운 메시지"
```

**좋은 커밋 메시지 작성법**
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 스타일 변경
refactor: 코드 리팩토링
test: 테스트 추가
chore: 빌드 프로세스나 보조 도구 변경
```

**실무 경험담**
- 커밋 메시지를 명확하게 작성하면 나중에 히스토리를 볼 때 정말 유용하다
- "수정함", "변경함" 같은 애매한 메시지는 피해야 한다
- 팀에서 커밋 메시지 규칙을 정해놓으면 협업이 훨씬 편해진다

### 4. 브랜치 관리

#### git branch
브랜치를 생성, 삭제, 조회한다.

```bash
# 브랜치 목록 보기
git branch

# 원격 브랜치까지 포함해서 보기
git branch -a

# 새 브랜치 생성
git branch 브랜치명

# 브랜치 삭제
git branch -d 브랜치명

# 강제 삭제 (병합되지 않은 브랜치)
git branch -D 브랜치명
```

#### git checkout
브랜치를 전환하거나 파일을 복원한다.

```bash
# 브랜치 전환
git checkout 브랜치명

# 새 브랜치 생성하면서 전환
git checkout -b 새브랜치명

# 특정 파일을 이전 상태로 복원
git checkout -- 파일명
```

#### git switch (Git 2.23+)
브랜치 전환 전용 명령어 (더 직관적)

```bash
# 브랜치 전환
git switch 브랜치명

# 새 브랜치 생성하면서 전환
git switch -c 새브랜치명
```

**브랜치 전략 실무 팁**
- `main` 또는 `master`: 배포 가능한 안정 버전
- `develop`: 개발 중인 기능들이 모이는 브랜치
- `feature/기능명`: 새로운 기능 개발용
- `hotfix/수정내용`: 긴급 버그 수정용

### 5. 병합 및 리베이스

#### git merge
브랜치를 병합한다.

```bash
# 현재 브랜치에 다른 브랜치 병합
git merge 브랜치명

# 병합 커밋 없이 병합 (fast-forward)
git merge --ff-only 브랜치명

# 병합 커밋 강제 생성
git merge --no-ff 브랜치명
```

#### git rebase
커밋 히스토리를 정리한다.

```bash
# 현재 브랜치를 다른 브랜치 위에 재배치
git rebase 브랜치명

# 대화형 리베이스 (최근 3개 커밋)
git rebase -i HEAD~3

# 리베이스 중단
git rebase --abort
```

**Merge vs Rebase**
- **Merge**: 히스토리를 보존하지만 복잡해질 수 있음
- **Rebase**: 깔끔한 히스토리지만 이미 푸시된 커밋은 위험

### 6. 원격 저장소 작업

#### git remote
원격 저장소를 관리한다.

```bash
# 원격 저장소 목록 보기
git remote -v

# 원격 저장소 추가
git remote add 이름 URL

# 원격 저장소 이름 변경
git remote rename 기존이름 새이름

# 원격 저장소 삭제
git remote remove 이름
```

#### git push
로컬 변경사항을 원격 저장소에 업로드한다.

```bash
# 기본 푸시
git push

# 특정 브랜치 푸시
git push origin 브랜치명

# 새 브랜치를 원격에 생성하면서 푸시
git push -u origin 브랜치명

# 강제 푸시 (주의!)
git push --force
```

#### git pull
원격 저장소의 변경사항을 가져온다.

```bash
# 기본 풀 (fetch + merge)
git pull

# 특정 브랜치에서 풀
git pull origin 브랜치명

# fetch만 하고 merge는 별도로
git fetch
git merge origin/브랜치명
```

**실무 팁**
- `git pull`은 `git fetch` + `git merge`의 조합
- 충돌이 자주 발생하는 환경에서는 `git fetch` 후 `git merge`를 권장
- 푸시하기 전에는 반드시 풀해서 최신 상태 확인

#### git fetch
원격 저장소의 변경사항만 가져온다 (병합하지 않음).

```bash
# 모든 원격 브랜치 정보 가져오기
git fetch

# 특정 원격 저장소에서 가져오기
git fetch origin

# 모든 원격 저장소에서 가져오기
git fetch --all
```

### 7. 히스토리 확인

#### git log
커밋 히스토리를 확인한다.

```bash
# 기본 로그 보기
git log

# 간단한 형태로 보기
git log --oneline

# 그래프 형태로 보기
git log --graph --oneline

# 특정 파일의 히스토리만 보기
git log 파일명

# 특정 기간의 커밋만 보기
git log --since="2023-01-01" --until="2023-12-31"
```

#### git show
특정 커밋의 상세 정보를 확인한다.

```bash
# 최신 커밋 정보 보기
git show

# 특정 커밋 정보 보기
git show 커밋해시

# 특정 커밋의 특정 파일만 보기
git show 커밋해시:파일명
```

### 8. 되돌리기 및 복구

#### git reset
커밋을 되돌린다.

```bash
# 스테이징 영역에서 파일 제거 (커밋은 유지)
git reset 파일명

# 최근 커밋을 되돌리고 변경사항은 유지
git reset --soft HEAD~1

# 최근 커밋을 되돌리고 스테이징도 해제
git reset --mixed HEAD~1

# 최근 커밋을 완전히 되돌리기 (위험!)
git reset --hard HEAD~1
```

#### git revert
커밋을 되돌리는 새로운 커밋을 생성한다.

```bash
# 특정 커밋을 되돌리는 새 커밋 생성
git revert 커밋해시

# 커밋 메시지 없이 되돌리기
git revert --no-edit 커밋해시
```

**Reset vs Revert**
- **Reset**: 히스토리를 수정하므로 이미 푸시된 커밋에는 위험
- **Revert**: 안전하게 되돌리기, 협업 시 권장

#### git stash
임시로 변경사항을 저장한다.

```bash
# 현재 변경사항을 스태시에 저장
git stash

# 메시지와 함께 저장
git stash save "작업 중인 내용"

# 스태시 목록 보기
git stash list

# 최신 스태시 적용
git stash pop

# 특정 스태시 적용
git stash apply stash@{0}

# 스태시 삭제
git stash drop stash@{0}
```

**실무 활용 예시**
- 급하게 다른 브랜치로 전환해야 할 때
- 실험적인 코드를 잠시 저장할 때
- 다른 사람의 코드를 확인하기 전에

### 9. 고급 기능들

#### git cherry-pick
특정 커밋만 선택해서 가져온다.

```bash
# 특정 커밋을 현재 브랜치에 적용
git cherry-pick 커밋해시

# 여러 커밋을 한 번에 적용
git cherry-pick 커밋1 커밋2 커밋3

# 커밋 메시지 없이 적용
git cherry-pick --no-commit 커밋해시
```

#### git blame
파일의 각 줄이 누가 언제 수정했는지 확인한다.

```bash
# 파일의 각 줄 정보 보기
git blame 파일명

# 특정 라인 범위만 보기
git blame -L 10,20 파일명
```

#### git bisect
문제가 생긴 커밋을 이진 탐색으로 찾는다.

```bash
# 이진 탐색 시작
git bisect start

# 현재 커밋이 문제가 있다고 표시
git bisect bad

# 문제가 없는 커밋 표시
git bisect good 커밋해시

# 탐색 종료
git bisect reset
```

## 실무에서 자주 마주치는 상황들

### 1. 충돌(Conflict) 해결하기

**상황**: 팀원과 같은 파일의 같은 부분을 수정했을 때

```bash
# 충돌 발생 시
git pull origin main
# CONFLICT (content): Merge conflict in 파일명

# 충돌 해결 후
git add 파일명
git commit -m "충돌 해결"
```

**충돌 해결 팁**
- IDE의 충돌 해결 도구 활용
- 팀원과 소통해서 어떤 코드를 유지할지 결정
- 충돌 해결 후 반드시 테스트 실행

### 2. 실수로 잘못된 브랜치에 커밋했을 때

```bash
# 커밋을 다른 브랜치로 이동
git log --oneline -1  # 커밋 해시 확인
git reset --hard HEAD~1  # 현재 브랜치에서 커밋 제거
git checkout 올바른브랜치
git cherry-pick 커밋해시  # 올바른 브랜치에 적용
```

### 3. 커밋 메시지를 잘못 작성했을 때

```bash
# 최근 커밋 메시지 수정 (아직 푸시하지 않은 경우)
git commit --amend -m "올바른 메시지"

# 이미 푸시한 경우 (위험!)
git commit --amend -m "올바른 메시지"
git push --force-with-lease
```

### 4. 민감한 정보를 커밋에 포함했을 때

```bash
# Git 히스토리에서 완전히 제거 (위험!)
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch 파일명' \
--prune-empty --tag-name-filter cat -- --all
```

## .gitignore 파일 관리

### 기본적인 .gitignore 패턴

```gitignore
# 의존성
node_modules/
package-lock.json

# 환경 변수
.env
.env.local
.env.production

# IDE 설정
.vscode/
.idea/
*.swp
*.swo

# OS 파일
.DS_Store
Thumbs.db

# 로그 파일
*.log
logs/

# 빌드 결과물
dist/
build/
*.jar
*.war
```

### 실무 팁
- 언어별 .gitignore 템플릿 활용
- 회사에서 사용하는 도구들의 설정 파일들도 고려
- 정기적으로 .gitignore 파일 검토

## Git 워크플로우 전략

### 1. Git Flow
- `main`: 배포 가능한 안정 버전
- `develop`: 개발 중인 기능들이 모이는 브랜치
- `feature/*`: 새로운 기능 개발
- `release/*`: 배포 준비
- `hotfix/*`: 긴급 수정

### 2. GitHub Flow
- `main`: 항상 배포 가능한 상태
- `feature/*`: 새로운 기능 개발
- Pull Request로 코드 리뷰 후 병합

### 3. GitLab Flow
- 환경별 브랜치 전략
- `production`, `staging`, `development`

## 실무에서 주의해야 할 점들

### 1. 절대 하지 말아야 할 것들
- **`git push --force`**: 이미 푸시된 커밋 히스토리 수정
- **`git reset --hard`**: 되돌릴 수 없는 변경사항 삭제
- **민감한 정보 커밋**: 비밀번호, API 키, 개인정보

### 2. 팀 협업 시 주의사항
- 커밋하기 전에 `git pull`로 최신 상태 확인
- 명확한 커밋 메시지 작성
- 작은 단위로 자주 커밋하기
- Pull Request 사용하기

### 3. 백업의 중요성
- 로컬 작업은 항상 원격에 백업
- 중요한 변경사항은 별도 브랜치로 보관
- 정기적인 원격 저장소 백업

## 마무리

Git은 처음에는 복잡해 보이지만, 실무에서 계속 사용하다 보면 자연스럽게 익숙해진다. 가장 중요한 건 두려워하지 말고 직접 사용해보는 것이다.

**처음 Git을 배울 때의 내 조언**
1. **기본 명령어부터 차근차근**: `add`, `commit`, `push`, `pull`부터 시작
2. **작은 프로젝트로 연습**: 개인 프로젝트로 Git 워크플로우 익히기
3. **실수를 두려워하지 말기**: Git은 대부분의 실수를 복구할 수 있다
4. **팀원들에게 질문하기**: 실무 경험자들의 조언이 가장 유용하다

처음에는 "왜 이렇게 복잡하지?"라고 생각했지만, 지금은 Git 없이는 개발이 불가능하다. 버전 관리, 협업, 백업까지 모든 것이 Git으로 이뤄지니까 정말 중요한 도구다.

특히 신입 개발자들, Git 때문에 스트레스받지 말고 천천히 익혀가면 된다. 다들 처음엔 그랬으니까.
