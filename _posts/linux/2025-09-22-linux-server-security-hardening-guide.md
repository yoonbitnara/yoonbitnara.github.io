---
layout: single
title: "Linux 서버 보안에 대하여"
date: 2025-09-22
categories: Linux
tags: [Linux, 보안, 서버, 시스템관리, 실무]
---

# Linux 서버 보안에 대하여

서버 보안은 개발자라면 반드시 알아야 하는 필수 기술이다. 오늘은 실제 운영 환경에서 바로 적용할 수 있는 Linux 서버 보안 강화 방법들을 단계별로 알아보겠다.

## 왜 서버 보안이 중요한가

최근 몇 년간 사이버 공격이 급증하고 있다. 특히 클라우드 서버를 대상으로 한 공격이 늘어나고 있는데, 대부분의 경우 기본적인 보안 설정만으로도 90% 이상의 공격을 차단할 수 있다.

실제로 내가 운영했던 서버에서도 기본적인 SSH 보안 설정만으로도 일일 수백 건의 무차별 공격을 막아낸 경험이 있다. 보안은 복잡할 필요가 없고, 체계적으로 접근하면 누구나 강력한 방어선을 구축할 수 있다.

## 1. SSH 보안 강화

SSH는 서버 관리의 핵심이자 가장 중요한 보안 요소다. 기본 설정으로는 무차별 공격에 매우 취약하다.

### 1.1 SSH 포트 변경

기본 22번 포트는 공격자들이 가장 먼저 시도하는 포트다. 다른 포트로 변경하는 것만으로도 80% 이상의 공격을 차단할 수 있다.

```bash
# SSH 설정 파일 편집
sudo nano /etc/ssh/sshd_config

# 포트 변경 (예: 2222)
Port 2222
```

### 1.2 Root 로그인 비활성화

Root 계정으로 직접 로그인하는 것은 매우 위험하다. 일반 사용자로 로그인 후 필요시 sudo를 사용하는 것이 안전하다.

```bash
# SSH 설정에서 root 로그인 비활성화
PermitRootLogin no
```

### 1.3 SSH 키 인증 설정

패스워드 인증보다 SSH 키 인증이 훨씬 안전하다. 공개키-개인키 방식으로 인증하면 패스워드 탈취 위험을 완전히 차단할 수 있다.

```bash
# 클라이언트에서 SSH 키 생성
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 공개키를 서버에 복사
ssh-copy-id -p 2222 username@server_ip

# SSH 설정에서 패스워드 인증 비활성화
PasswordAuthentication no
PubkeyAuthentication yes
```

### 1.4 SSH 접속 제한

특정 IP에서만 SSH 접속을 허용하거나, 동시 접속 수를 제한할 수 있다.

```bash
# SSH 설정에 추가
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 2

# 특정 IP만 허용 (예시)
AllowUsers admin@192.168.1.100 admin@10.0.0.50
```

## 2. 방화벽 설정 (UFW)

Ubuntu의 기본 방화벽인 UFW(Uncomplicated Firewall)를 사용하면 간단하게 방화벽을 설정할 수 있다.

### 2.1 UFW 기본 설정

```bash
# UFW 활성화
sudo ufw enable

# 기본 정책 설정
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH 포트 허용 (변경한 포트로)
sudo ufw allow 2222/tcp

# 웹 서버 포트 허용
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### 2.2 특정 IP만 허용

```bash
# 특정 IP에서만 SSH 접속 허용
sudo ufw allow from 192.168.1.100 to any port 2222

# 특정 네트워크 대역 허용
sudo ufw allow from 192.168.1.0/24 to any port 2222
```

### 2.3 UFW 상태 확인

```bash
# 방화벽 상태 확인
sudo ufw status verbose

# 방화벽 로그 확인
sudo ufw logging on
sudo tail -f /var/log/ufw.log
```

## 3. Fail2Ban 설치 및 설정

Fail2Ban은 무차별 공격을 자동으로 차단해주는 도구다. SSH, 웹 서버 등 다양한 서비스에 대해 자동으로 IP를 차단한다.

### 3.1 Fail2Ban 설치

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install fail2ban

# CentOS/RHEL
sudo yum install epel-release
sudo yum install fail2ban
```

### 3.2 SSH 보호 설정

```bash
# Fail2Ban 설정 파일 생성
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# SSH 보호 설정 편집
sudo nano /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

### 3.3 웹 서버 보호 설정

```ini
[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
logpath = /var/log/nginx/error.log
maxretry = 3
```

### 3.4 Fail2Ban 서비스 관리

```bash
# Fail2Ban 시작
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# 상태 확인
sudo fail2ban-client status

# 특정 jail 상태 확인
sudo fail2ban-client status sshd

# 차단된 IP 목록 확인
sudo fail2ban-client get sshd banip
```

## 4. 시스템 업데이트 및 패치 관리

정기적인 시스템 업데이트는 보안의 기본이다. 자동 업데이트를 설정하면 보안 패치를 놓치지 않을 수 있다.

### 4.1 자동 업데이트 설정

```bash
# Ubuntu 자동 업데이트 설치
sudo apt install unattended-upgrades

# 자동 업데이트 설정
sudo dpkg-reconfigure unattended-upgrades

# 설정 파일 편집
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```bash
# 자동 업데이트 설정
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
```

### 4.2 보안 업데이트 확인

```bash
# 보안 업데이트 확인
sudo apt list --upgradable | grep -i security

# 중요 보안 업데이트 설치
sudo apt upgrade -y
```

## 5. 로그 모니터링 및 분석

로그를 정기적으로 모니터링하면 공격 시도나 이상 징후를 조기에 발견할 수 있다.

### 5.1 주요 로그 파일 모니터링

```bash
# SSH 로그 모니터링
sudo tail -f /var/log/auth.log

# 시스템 로그 모니터링
sudo tail -f /var/log/syslog

# 웹 서버 로그 모니터링
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 5.2 로그 분석 스크립트

```bash
#!/bin/bash
# 보안 이벤트 모니터링 스크립트

# SSH 실패 로그인 시도 확인
echo "=== SSH 실패 로그인 시도 ==="
sudo grep "Failed password" /var/log/auth.log | tail -10

# 의심스러운 IP 확인
echo "=== 의심스러운 IP 목록 ==="
sudo grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | head -10

# 최근 로그인 성공 기록
echo "=== 최근 로그인 성공 기록 ==="
sudo grep "Accepted password" /var/log/auth.log | tail -5
```

### 5.3 로그 로테이션 설정

```bash
# logrotate 설정 확인
sudo nano /etc/logrotate.conf

# SSH 로그 로테이션 설정
sudo nano /etc/logrotate.d/rsyslog
```

```bash
/var/log/auth.log
{
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
```

## 6. 네트워크 보안 강화

### 6.1 네트워크 인터페이스 보안

```bash
# 네트워크 인터페이스 상태 확인
ip addr show

# 불필요한 네트워크 서비스 비활성화
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
```

### 6.2 포트 스캔 및 서비스 확인

```bash
# 열린 포트 확인
sudo netstat -tlnp
sudo ss -tlnp

# 특정 포트 스캔
nmap -sT -O localhost
```

## 7. 파일 시스템 보안

### 7.1 파일 권한 설정

```bash
# 중요한 파일 권한 확인 및 설정
sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 644 /etc/passwd
sudo chmod 000 /etc/shadow
sudo chmod 644 /etc/group
```

### 7.2 불필요한 파일 제거

```bash
# 불필요한 패키지 제거
sudo apt autoremove --purge

# 임시 파일 정리
sudo find /tmp -type f -atime +7 -delete
sudo find /var/tmp -type f -atime +7 -delete
```

## 8. 보안 모니터링 도구

### 8.1 AIDE (파일 무결성 검사)

```bash
# AIDE 설치
sudo apt install aide

# 초기 데이터베이스 생성
sudo aideinit

# 파일 무결성 검사
sudo aide --check
```

### 8.2 Lynis 보안 감사

```bash
# Lynis 설치
sudo apt install lynis

# 시스템 보안 감사 실행
sudo lynis audit system

# 결과 확인
sudo cat /var/log/lynis.log
```

## 9. 백업 및 복구 계획

보안은 방어뿐만 아니라 공격을 받았을 때의 복구 계획도 중요하다.

### 9.1 시스템 백업

```bash
# 전체 시스템 백업 스크립트
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# 중요한 설정 파일 백업
tar -czf $BACKUP_DIR/etc_backup.tar.gz /etc/
tar -czf $BACKUP_DIR/home_backup.tar.gz /home/
tar -czf $BACKUP_DIR/var_backup.tar.gz /var/

# 백업 파일 압축
tar -czf "/backup/system_backup_$(date +%Y%m%d).tar.gz" $BACKUP_DIR
```

### 9.2 복구 계획 수립

```bash
# 복구 시나리오 문서화
# 1. 시스템 복구 절차
# 2. 데이터 복구 절차  
# 3. 서비스 재시작 순서
# 4. 보안 설정 재적용 절차
```

## 10. 보안 사고 대응 절차

보안 설정을 완료했다고 해서 끝이 아니다. 실제 공격을 받았을 때 어떻게 대응해야 하는지 미리 계획을 세워두자.

### 10.1 공격 탐지 시 즉시 조치

공격을 탐지했을 때 가장 먼저 해야 할 일은 피해를 최소화하는 것이다.

```bash
# 즉시 네트워크 연결 차단
sudo iptables -A INPUT -s [공격자IP] -j DROP

# 의심스러운 프로세스 확인
ps aux | grep -E "(nc|netcat|wget|curl)"
netstat -tlnp | grep LISTEN

# 시스템 리소스 확인
top
df -h
free -h
```

### 10.2 포렌식 증거 수집

공격 후에는 반드시 증거를 수집해야 한다. 나중에 분석과 재발 방지에 도움이 된다.

```bash
# 시스템 로그 백업
sudo cp /var/log/auth.log /backup/auth_$(date +%Y%m%d_%H%M%S).log
sudo cp /var/log/syslog /backup/syslog_$(date +%Y%m%d_%H%M%S).log

# 네트워크 연결 상태 저장
sudo netstat -tlnp > /backup/netstat_$(date +%Y%m%d_%H%M%S).txt
sudo ss -tlnp > /backup/ss_$(date +%Y%m%d_%H%M%S).txt

# 실행 중인 프로세스 목록 저장
ps aux > /backup/processes_$(date +%Y%m%d_%H%M%S).txt
```

### 10.3 시스템 복구 절차

공격을 차단한 후에는 시스템을 안전하게 복구해야 한다.

```bash
# 1. 모든 비밀번호 변경
sudo passwd root
sudo passwd [사용자명]

# 2. SSH 키 재생성
rm ~/.ssh/id_rsa*
ssh-keygen -t rsa -b 4096

# 3. 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 4. 보안 설정 재검토
sudo ufw status
sudo fail2ban-client status
```

### 10.4 사후 분석 및 개선

공격이 끝난 후에는 반드시 분석을 통해 보안을 개선해야 한다.

```bash
# 공격 로그 분석
sudo grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr

# 시스템 변경사항 확인
sudo find /etc -name "*.bak" -o -name "*~" -o -name "*.orig"

# 의심스러운 파일 검색
sudo find / -name "*.php" -perm -002 2>/dev/null
sudo find / -name "*.sh" -perm -002 2>/dev/null
```

## 11. 고급 보안 기법

기본 보안 설정을 넘어서 더 강력한 보안을 원한다면 다음 기법들을 고려해보자.

### 11.1 SELinux/AppArmor 활용

SELinux나 AppArmor는 시스템 레벨에서 애플리케이션의 권한을 제한하는 강력한 도구다.

```bash
# Ubuntu에서 AppArmor 상태 확인
sudo aa-status

# AppArmor 프로파일 활성화
sudo aa-enforce /etc/apparmor.d/usr.sbin.nginx
```

### 11.2 2단계 인증 (2FA)

SSH에 2단계 인증을 추가하면 보안이 크게 향상된다.

```bash
# Google Authenticator 설치
sudo apt install libpam-google-authenticator

# 설정 파일 수정
sudo nano /etc/pam.d/sshd
```

```bash
# SSH 설정에 추가
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

### 11.3 침입 탐지 시스템 (IDS)

Snort나 Suricata 같은 침입 탐지 시스템을 설치하면 네트워크 레벨에서 공격을 탐지할 수 있다.

```bash
# Suricata 설치
sudo apt install suricata

# 설정 파일 수정
sudo nano /etc/suricata/suricata.yaml
```

### 11.4 보안 스캔 도구

정기적으로 보안 취약점을 스캔하는 도구를 사용하자.

```bash
# OpenVAS 설치 (무료 버전)
sudo apt install openvas

# Nessus 설치 (상용)
# https://www.tenable.com/products/nessus
```

## 12. 클라우드 환경 보안

AWS, Azure, GCP 같은 클라우드 환경에서는 추가적인 보안 고려사항이 있다.

### 12.1 클라우드 방화벽 설정

```bash
# AWS Security Group 예시
# SSH: 포트 22 (또는 변경한 포트) - 특정 IP만 허용
# HTTP: 포트 80 - 모든 IP 허용
# HTTPS: 포트 443 - 모든 IP 허용
# 기타 포트: 모두 차단
```

### 12.2 클라우드 모니터링

```bash
# CloudWatch, Azure Monitor, Stackdriver 등 활용
# 로그 집중화 및 알림 설정
# 비정상적인 리소스 사용량 모니터링
```

### 12.3 백업 및 재해복구

```bash
# 클라우드 네이티브 백업 도구 활용
# AWS: EBS 스냅샷, RDS 백업
# Azure: Azure Backup, Site Recovery
# GCP: Cloud Backup, Cloud SQL 백업
```

## 마무리

서버 보안은 한 번 설정하고 끝나는 것이 아니다. 정기적인 모니터링과 업데이트가 필요하며, 새로운 위협에 대비해 지속적으로 보안 정책을 개선해야 한다.

위에서 소개한 방법들을 단계별로 적용하면 대부분의 일반적인 공격으로부터 서버를 보호할 수 있다. 특히 SSH 보안과 방화벽 설정만 제대로 해도 90% 이상의 공격을 차단할 수 있다는 점을 기억하자.
