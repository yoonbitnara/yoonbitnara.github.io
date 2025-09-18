---
title: "개발자가 알아야 할 필수 명령어들"
date: 2025-09-18
categories: Linux
tags: [linux, command-line, terminal, development, server]
author: pitbull terrier
---

# 리눅스 명령어 완전 정복: 개발자가 알아야 할 필수 명령어들

리눅스 명령어를 모르면 개발자라고 할 수 없다. 나도 처음에는 GUI만 쓰다가 서버 작업을 하면서 명령어의 필요성을 깨달았다. 터미널에서 몇 줄만 입력하면 되는 일을 GUI로는 몇 번의 클릭이 필요했다.

## 왜 리눅스 명령어를 배워야 할까?

개발자라면 서버 환경에서 작업할 일이 많다. 대부분의 서버는 리눅스 기반이고, GUI가 없는 환경에서 작업해야 한다. 명령어를 모르면 서버 관리도 못하고, 개발 환경 설정도 제대로 할 수 없다.

더 중요한 건 자동화다. 명령어를 조합하면 반복 작업을 스크립트로 만들어서 시간을 엄청나게 절약할 수 있다.

## 기본 파일 조작 명령어

### ls - 파일 목록 보기

가장 기본적인 명령어다. 현재 디렉토리의 파일들을 보여준다.

```bash
# 기본 사용법
ls

# 자세한 정보와 함께 보기
ls -l

# 숨김 파일까지 모두 보기
ls -la

# 파일 크기를 사람이 읽기 쉬운 형태로 보기
ls -lh

# 시간순으로 정렬해서 보기
ls -lt
```

실제로 사용해보면 이렇게 나온다.

```bash
$ ls -la
total 48
drwxr-xr-x  5 user user 4096 Sep 18 10:30 .
drwxr-xr-x  3 user user 4096 Sep 18 09:15 ..
-rw-r--r--  1 user user 1024 Sep 18 10:25 file1.txt
-rw-r--r--  1 user user 2048 Sep 18 10:20 file2.txt
drwxr-xr-x  2 user user 4096 Sep 18 10:15 directory1
```

### cd - 디렉토리 이동

디렉토리를 이동할 때 사용한다.

```bash
# 홈 디렉토리로 이동
cd ~

# 상위 디렉토리로 이동
cd ..

# 이전 디렉토리로 돌아가기
cd -

# 절대 경로로 이동
cd /home/user/documents

# 상대 경로로 이동
cd ./subdirectory
```

### pwd - 현재 위치 확인

현재 어느 디렉토리에 있는지 확인할 때 사용한다.

```bash
$ pwd
/home/user/documents
```

### mkdir - 디렉토리 만들기

새로운 디렉토리를 만들 때 사용한다.

```bash
# 단일 디렉토리 생성
mkdir new_folder

# 여러 디렉토리 한번에 생성
mkdir folder1 folder2 folder3

# 중간 디렉토리까지 함께 생성
mkdir -p path/to/new/folder

# 권한을 지정해서 생성
mkdir -m 755 new_folder
```

### rmdir - 빈 디렉토리 삭제

빈 디렉토리만 삭제할 수 있다. 파일이 있는 디렉토리는 삭제되지 않는다.

```bash
# 빈 디렉토리 삭제
rmdir empty_folder

# 여러 빈 디렉토리 삭제
rmdir folder1 folder2 folder3
```

## 파일 조작 명령어

### cp - 파일 복사

파일이나 디렉토리를 복사할 때 사용한다.

```bash
# 파일 복사
cp source.txt destination.txt

# 디렉토리 전체 복사
cp -r source_dir destination_dir

# 권한과 시간 정보까지 복사
cp -p source.txt destination.txt

# 강제로 덮어쓰기
cp -f source.txt destination.txt

# 복사 진행상황 보기
cp -v source.txt destination.txt
```

### mv - 파일 이동/이름 변경

파일을 이동하거나 이름을 변경할 때 사용한다.

```bash
# 파일 이름 변경
mv old_name.txt new_name.txt

# 파일 이동
mv file.txt /path/to/destination/

# 파일을 이동하면서 이름도 변경
mv file.txt /path/to/destination/new_name.txt

# 디렉토리 이름 변경
mv old_dir new_dir
```

### rm - 파일 삭제

파일이나 디렉토리를 삭제할 때 사용한다. 조심해서 사용해야 한다.

```bash
# 파일 삭제
rm file.txt

# 여러 파일 삭제
rm file1.txt file2.txt file3.txt

# 디렉토리와 내용 모두 삭제
rm -r directory

# 강제로 삭제 (확인 없이)
rm -rf directory

# 삭제 전에 확인
rm -i file.txt
```

## 파일 내용 보기 명령어

### cat - 파일 내용 출력

파일의 전체 내용을 화면에 출력한다.

```bash
# 파일 내용 보기
cat file.txt

# 여러 파일 내용 연속으로 보기
cat file1.txt file2.txt

# 줄 번호와 함께 보기
cat -n file.txt

# 빈 줄도 번호 매기기
cat -b file.txt
```

### less - 페이지 단위로 파일 보기

큰 파일을 페이지 단위로 나누어서 볼 때 사용한다.

```bash
# 파일을 페이지 단위로 보기
less file.txt

# 검색 기능 사용
# /검색어 입력 후 Enter
# n: 다음 검색 결과
# N: 이전 검색 결과
# q: 종료
```

### head - 파일 앞부분 보기

파일의 앞부분 몇 줄만 보고 싶을 때 사용한다.

```bash
# 앞 10줄 보기 (기본값)
head file.txt

# 앞 5줄만 보기
head -n 5 file.txt

# 앞 20줄 보기
head -20 file.txt
```

### tail - 파일 뒷부분 보기

파일의 뒷부분 몇 줄만 보고 싶을 때 사용한다.

```bash
# 뒤 10줄 보기 (기본값)
tail file.txt

# 뒤 5줄만 보기
tail -n 5 file.txt

# 실시간으로 파일 변화 감시
tail -f logfile.txt
```

## 텍스트 처리 명령어

### grep - 텍스트 검색

파일에서 특정 패턴을 찾을 때 사용한다.

```bash
# 파일에서 특정 문자열 검색
grep "search_term" file.txt

# 대소문자 구분 없이 검색
grep -i "search_term" file.txt

# 정확한 단어만 검색
grep -w "word" file.txt

# 줄 번호와 함께 출력
grep -n "search_term" file.txt

# 여러 파일에서 검색
grep "search_term" *.txt

# 디렉토리 전체에서 검색
grep -r "search_term" /path/to/directory
```

### sed - 스트림 편집기

텍스트를 편집할 때 사용한다.

```bash
# 첫 번째 줄의 첫 번째 "old"를 "new"로 변경
sed 's/old/new/' file.txt

# 모든 "old"를 "new"로 변경
sed 's/old/new/g' file.txt

# 특정 줄만 출력
sed -n '5,10p' file.txt

# 빈 줄 삭제
sed '/^$/d' file.txt
```

### awk - 텍스트 처리 도구

텍스트를 분석하고 처리할 때 사용한다.

```bash
# 첫 번째 컬럼 출력
awk '{print $1}' file.txt

# 특정 조건에 맞는 줄만 출력
awk '$3 > 100 {print $0}' file.txt

# 컬럼 구분자 지정
awk -F',' '{print $1, $2}' file.txt

# 여러 파일 처리
awk '{print FILENAME, $0}' *.txt
```

## 시스템 정보 명령어

### ps - 프로세스 상태 보기

현재 실행 중인 프로세스를 확인할 때 사용한다.

```bash
# 현재 사용자의 프로세스만 보기
ps

# 모든 프로세스 보기
ps aux

# 특정 프로세스 검색
ps aux | grep "process_name"

# 프로세스 트리 형태로 보기
ps auxf
```

### top - 실시간 시스템 모니터링

시스템의 실시간 상태를 모니터링할 때 사용한다.

```bash
# 실시간 시스템 상태 보기
top

# 특정 사용자의 프로세스만 보기
top -u username

# 5초마다 업데이트
top -d 5
```

### df - 디스크 사용량 확인

디스크의 사용량을 확인할 때 사용한다.

```bash
# 디스크 사용량 보기
df

# 사람이 읽기 쉬운 형태로 보기
df -h

# 특정 파일시스템만 보기
df -h /dev/sda1
```

### du - 디렉토리 사용량 확인

디렉토리의 사용량을 확인할 때 사용한다.

```bash
# 현재 디렉토리 사용량
du

# 사람이 읽기 쉬운 형태로 보기
du -h

# 최대 깊이 지정
du -h --max-depth=1

# 특정 디렉토리 사용량
du -h /path/to/directory
```

## 네트워크 명령어

### ping - 네트워크 연결 확인

네트워크 연결 상태를 확인할 때 사용한다.

```bash
# 기본 ping
ping google.com

# 5번만 ping
ping -c 5 google.com

# 1초 간격으로 ping
ping -i 1 google.com
```

### wget - 파일 다운로드

웹에서 파일을 다운로드할 때 사용한다.

```bash
# 파일 다운로드
wget https://example.com/file.zip

# 백그라운드에서 다운로드
wget -b https://example.com/file.zip

# 다운로드 진행상황 보기
wget --progress=bar https://example.com/file.zip
```

### curl - HTTP 요청

HTTP 요청을 보낼 때 사용한다.

```bash
# GET 요청
curl https://api.example.com/data

# POST 요청
curl -X POST -d "key=value" https://api.example.com/data

# 헤더 추가
curl -H "Authorization: Bearer token" https://api.example.com/data

# 응답 헤더도 보기
curl -i https://api.example.com/data
```

## 권한 관리 명령어

### chmod - 파일 권한 변경

파일의 권한을 변경할 때 사용한다.

```bash
# 소유자에게 실행 권한 부여
chmod u+x file.txt

# 모든 사용자에게 읽기 권한 부여
chmod a+r file.txt

# 숫자로 권한 설정 (755)
chmod 755 file.txt

# 디렉토리와 하위 파일 모두 권한 변경
chmod -R 755 directory
```

### chown - 파일 소유자 변경

파일의 소유자를 변경할 때 사용한다.

```bash
# 소유자 변경
chown newowner file.txt

# 소유자와 그룹 모두 변경
chown newowner:newgroup file.txt

# 디렉토리와 하위 파일 모두 변경
chown -R newowner:newgroup directory
```

## 압축 명령어

### tar - 아카이브 생성/해제

파일들을 하나로 묶거나 압축할 때 사용한다.

```bash
# tar 파일 생성
tar -cf archive.tar file1 file2 file3

# tar.gz 파일 생성 (압축)
tar -czf archive.tar.gz file1 file2 file3

# tar 파일 해제
tar -xf archive.tar

# tar.gz 파일 해제
tar -xzf archive.tar.gz

# 압축 해제하면서 진행상황 보기
tar -xzf archive.tar.gz -v
```

### zip/unzip - ZIP 압축

ZIP 형식으로 압축하거나 해제할 때 사용한다.

```bash
# ZIP 파일 생성
zip archive.zip file1 file2 file3

# 디렉토리 압축
zip -r archive.zip directory

# ZIP 파일 해제
unzip archive.zip

# 특정 디렉토리에 해제
unzip archive.zip -d /path/to/destination
```

## 실전 활용 예시

### 로그 파일 분석

웹 서버 로그를 분석하는 예시다.

```bash
# 에러 로그만 추출
grep "ERROR" /var/log/nginx/error.log

# 특정 IP의 요청만 추출
grep "192.168.1.100" /var/log/nginx/access.log

# 가장 많이 접속한 IP 상위 10개
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -10

# 오늘 날짜의 로그만 추출
grep "$(date +%d/%b/%Y)" /var/log/nginx/access.log
```

### 파일 정리 스크립트

오래된 파일들을 정리하는 스크립트다.

```bash
#!/bin/bash
# 30일 이상 된 로그 파일들을 압축해서 보관

# 30일 이상 된 .log 파일 찾기
find /var/log -name "*.log" -mtime +30 -type f | while read file; do
    # 압축 파일명 생성
    compressed_file="${file}.gz"
    
    # 압축
    gzip "$file"
    
    # 압축된 파일을 보관 디렉토리로 이동
    mv "$compressed_file" /backup/logs/
    
    echo "압축 완료: $file"
done
```

### 시스템 모니터링

시스템 상태를 모니터링하는 스크립트다.

```bash
#!/bin/bash
# 시스템 상태 체크 스크립트

echo "=== 시스템 상태 체크 ==="
echo "현재 시간: $(date)"
echo ""

echo "=== CPU 사용률 ==="
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

echo "=== 메모리 사용률 ==="
free -h | grep "Mem:" | awk '{print $3"/"$2}'

echo "=== 디스크 사용률 ==="
df -h | grep -E "/$|/var|/home" | awk '{print $5" "$6}'

echo "=== 실행 중인 프로세스 수 ==="
ps aux | wc -l

echo "=== 네트워크 연결 수 ==="
netstat -an | grep ESTABLISHED | wc -l
```

## 고급 활용 팁

### 명령어 조합하기

여러 명령어를 파이프(|)로 연결하면 강력한 작업이 가능하다.

```bash
# 가장 큰 파일 상위 10개 찾기
find /home -type f -exec ls -la {} \; | sort -k5 -nr | head -10

# 특정 프로세스의 메모리 사용량
ps aux | grep "nginx" | awk '{sum+=$6} END {print sum/1024 " MB"}'

# 로그에서 에러 패턴 분석
grep -i error /var/log/syslog | awk '{print $5}' | sort | uniq -c | sort -nr
```

### 별칭(alias) 설정

자주 사용하는 명령어를 짧게 만들어서 사용할 수 있다.

```bash
# .bashrc 파일에 추가
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# 설정 적용
source ~/.bashrc
```

### 히스토리 활용

명령어 히스토리를 활용하면 작업 효율이 크게 향상된다.

```bash
# 히스토리 검색
history | grep "grep"

# 이전 명령어 다시 실행
!!

# 히스토리에서 특정 명령어 실행
!123

# 히스토리 크기 설정
export HISTSIZE=10000
export HISTFILESIZE=20000
```

## 결론

리눅스 명령어는 개발자에게 필수다. 처음에는 어려워 보이지만, 실제로 사용해보면 GUI보다 훨씬 빠르고 효율적이다.

특히 서버 환경에서 작업할 때는 명령어를 모르면 아무것도 할 수 없다. 기본 명령어부터 차근차근 익혀서 나만의 워크플로우를 만들어보자.