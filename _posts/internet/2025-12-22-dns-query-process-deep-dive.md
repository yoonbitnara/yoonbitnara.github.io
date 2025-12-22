---
title: "DNS가 느린 진짜 이유 - 쿼리 과정 뜯어보기"
date: 2025-12-22
categories: Internet
tags: [DNS, 네트워크, 쿼리, 성능최적화, 인터넷기초]
author: pitbull terrier
---

# DNS가 느린 진짜 이유 - 쿼리 과정 뜯어보기

웹사이트 주소를 브라우저에 입력하면 페이지가 뜬다. 당연한 일이다.

하지만 그 사이에 뭔가 일어난다. 도메인 이름을 IP 주소로 바꾸는 과정. DNS 쿼리다.

이 과정이 생각보다 복잡하다. 그리고 느리다.

왜 느린지, 어떻게 동작하는지 알아보자.

## 도메인 입력하고 페이지 뜨기까지

브라우저에 `google.com`을 입력하면 무슨 일이 일어날까?

대부분은 이렇게 생각한다. "도메인을 IP로 바꾸고, 그 IP로 요청 보내면 되지?"

맞다. 하지만 그 과정이 단순하지 않다.

```
┌─────────┐
│ 브라우저 │
└────┬────┘
     │ "google.com의 IP 주소가 뭐야?"
     ▼
┌─────────┐
│ DNS서버  │
└────┬────┘
     │ "8.8.8.8이야"
     ▼
┌─────────┐
│ 브라우저 │
└────┬────┘
     │ HTTP 요청
     ▼
┌─────────┐
│  서버   │
└────┬────┘
     │ HTML 응답
     ▼
```

이게 전부가 아니다. 실제로는 더 복잡하다.

## DNS 쿼리의 두 가지 방식

DNS 쿼리는 두 가지 방식이 있다.

### Recursive Query (재귀 쿼리)

클라이언트가 DNS 서버에게 "알아서 찾아줘"라고 요청하는 방식이다.

```
┌──────────┐
│ 클라이언트 │
└─────┬─────┘
      │ "google.com의 IP 주소 알려줘"
      ▼
┌──────────┐      ┌──────┐  ┌──────┐  ┌──────┐
│ DNS서버   │─────▶│루트서버│─▶│.com서버│─▶│google│
│(Resolver) │      └──────┘  └──────┘  └──────┘
└─────┬─────┘
      │ "8.8.8.8이야"
      ▼
┌──────────┐
│ 클라이언트 │
└──────────┘
```

클라이언트는 한 번만 물어본다. DNS 서버가 알아서 찾아준다.

### Iterative Query (반복 쿼리)

DNS 서버가 직접 루트 서버부터 차례로 물어보는 방식이다.

```
┌──────────┐
│ DNS서버   │
└─────┬─────┘
      │ ① ".com 서버 어디 있어?"
      ▼
┌──────────┐
│ 루트서버  │
└─────┬─────┘
      │ ② ".com 서버는 여기 있어"
      ▼
┌──────────┐
│ DNS서버   │
└─────┬─────┘
      │ ③ "google.com 서버 어디 있어?"
      ▼
┌──────────┐
│ .com서버  │
└─────┬─────┘
      │ ④ "google.com 서버는 여기 있어"
      ▼
┌──────────┐
│ DNS서버   │
└─────┬─────┘
      │ ⑤ "IP 주소 뭐야?"
      ▼
┌──────────┐
│google서버 │
└─────┬─────┘
      │ ⑥ "8.8.8.8이야"
      ▼
```

여러 번 왕복한다. 그래서 느리다.

## 실제 DNS 쿼리 과정

브라우저에 `www.google.com`을 입력하면 무슨 일이 일어날까?

전체 과정을 그림으로 보면 이렇다.

```
┌──────────┐
│ 브라우저  │
└─────┬─────┘
      │ ① 로컬 캐시 확인
      │
      ├─[캐시 있음]─▶ 바로 사용 (0ms) 
      │
      └─[캐시 없음]─▶ ② OS 캐시 확인
                      │
                      ├─[캐시 있음]─▶ 바로 사용 (1-2ms) 
                      │
                      └─[캐시 없음]─▶ ③ Resolver 서버
                                      │
                                      ▼
                              ┌─────────────┐
                              │ 루트 서버    │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │ .com 서버    │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │google.com서버│
                              └──────┬──────┘
                                     │
                                     ▼
                              IP 주소 반환 (150ms)
```

### 1단계: 로컬 캐시 확인

브라우저는 먼저 자신의 캐시를 확인한다. 이전에 조회한 적이 있으면 캐시에서 바로 가져온다.

```
┌──────────┐
│ 브라우저  │
│  캐시    │
└─────┬────┘
      │
      ├─[있음]─▶ 바로 사용 (0ms) 
      │
      └─[없음]─▶ 다음 단계
```

캐시가 있으면 DNS 쿼리 자체가 발생하지 않는다. 가장 빠르다.

### 2단계: OS 캐시 확인

브라우저 캐시에 없으면 OS의 DNS 캐시를 확인한다.

Windows는 `ipconfig /displaydns`로 확인할 수 있다.

```
OS 캐시 → 있으면? 바로 사용 (1-2ms)
        → 없으면? 다음 단계
```

### 3단계: Resolver 서버에 요청

OS 캐시에도 없으면 Resolver 서버에 요청한다. 보통 ISP가 제공하는 DNS 서버다.

```
클라이언트 → Resolver: "www.google.com의 IP 주소 알려줘"
```

Resolver 서버는 Recursive Query를 수행한다. 클라이언트는 기다린다.

### 4단계: 루트 서버 조회

Resolver는 루트 서버부터 시작한다.

```
Resolver → 루트 서버: ".com의 네임서버 어디 있어?"
루트 서버 → Resolver: ".com 네임서버는 a.gtld-servers.net이야"
```

루트 서버는 13개가 있다. 전 세계에 분산되어 있다.

### 5단계: TLD 서버 조회

`.com` 서버를 찾았다. 이제 `.com` 서버에게 물어본다.

```
Resolver → .com 서버: "google.com의 네임서버 어디 있어?"
.com 서버 → Resolver: "google.com 네임서버는 ns1.google.com이야"
```

TLD는 Top-Level Domain이다. `.com`, `.net`, `.org` 같은 것들.

### 6단계: Authoritative 서버 조회

마지막으로 `google.com`의 네임서버에게 물어본다.

```
Resolver → ns1.google.com: "www.google.com의 IP 주소 뭐야?"
ns1.google.com → Resolver: "172.217.31.196이야"
```

이제 IP 주소를 얻었다.

### 7단계: 클라이언트에 응답

Resolver는 클라이언트에게 IP 주소를 알려준다.

```
Resolver → 클라이언트: "www.google.com은 172.217.31.196이야"
```

이제 클라이언트는 IP 주소를 알았으니 HTTP 요청을 보낼 수 있다.

## 왜 이렇게 복잡한가

왜 이렇게 여러 서버를 거쳐야 할까?

### 분산 구조의 이유

DNS는 분산 구조다. 하나의 서버에 모든 도메인 정보를 저장하지 않는다.

```
루트 서버: TLD 정보만 저장 (.com, .net 등)
TLD 서버: 도메인 네임서버 정보만 저장 (google.com의 네임서버)
Authoritative 서버: 실제 IP 주소 저장
```

이렇게 나누는 이유는 부하 분산과 확장성 때문이다.

모든 도메인을 하나의 서버에 저장하면? 서버가 터진다. 전 세계의 모든 도메인 조회를 처리해야 한다.

### 계층 구조의 장점

계층 구조를 쓰면 각 서버가 자신의 영역만 관리하면 된다.

```
루트 서버: TLD 정보만 관리
.com 서버: .com 도메인들의 네임서버 정보만 관리
google.com 서버: google.com의 IP 주소만 관리
```

각 서버의 부담이 줄어든다.

## DNS가 느린 이유

DNS 쿼리가 느린 이유는 여러 단계를 거치기 때문이다.

### RTT (Round Trip Time)의 누적

각 단계마다 네트워크 왕복 시간이 필요하다.

```
루트 서버 조회: 50ms (한국 → 미국)
.com 서버 조회: 50ms (한국 → 미국)
google.com 서버 조회: 50ms (한국 → 미국)

총: 150ms
```

각 단계가 순차적으로 진행되면 시간이 누적된다.

### 캐시가 없을 때

캐시가 없으면 매번 이 과정을 거쳐야 한다.

```
첫 번째 요청: 150ms (캐시 없음)
두 번째 요청: 0ms (캐시 있음)
```

첫 요청이 느린 이유다.

## DNS 캐싱의 중요성

DNS 캐싱이 얼마나 중요한지 보자.

### TTL (Time To Live)

DNS 레코드에는 TTL이 있다. 이 시간 동안 캐시에 저장된다.

```
google.com A 172.217.31.196 TTL 300
```

TTL이 300초면, 300초 동안 캐시에 저장된다.

### 캐시 계층

DNS 캐시는 여러 계층에 있다.

```
1. 브라우저 캐시 (가장 빠름)
2. OS 캐시
3. Resolver 캐시
4. 각 DNS 서버의 캐시
```

각 계층에서 캐시를 확인한다. 상위 계층에 캐시가 있으면 하위 계층까지 가지 않는다.

## 실제 측정해보기

DNS 쿼리 시간을 실제로 측정해보자.

### dig 명령어로 측정

```bash
$ dig google.com

; <<>> DiG 9.16.1 <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	172.217.31.196

;; Query time: 45 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Dec 22 10:00:00 KST 2025
;; MSG SIZE  rcvd: 55
```

Query time이 45ms다. 캐시가 있을 때는 더 빠르다.

### nslookup으로 확인

```bash
$ nslookup google.com

Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	google.com
Address: 172.217.31.196
```

Non-authoritative answer는 캐시에서 가져온 답변이다.

## DNS 최적화 방법

DNS 쿼리를 빠르게 만드는 방법들.

### 1. DNS 서버 변경

기본 DNS 서버보다 빠른 서버를 쓰면 빨라진다.

```
기본 DNS (ISP): 50ms
Google DNS (8.8.8.8): 20ms
Cloudflare DNS (1.1.1.1): 15ms
```

가까운 DNS 서버를 쓰면 빨라진다.

### 2. DNS Prefetch

HTML에 DNS Prefetch를 추가하면 미리 조회한다.

```html
<link rel="dns-prefetch" href="//fonts.googleapis.com">
```

페이지 로드 전에 DNS를 미리 조회한다.

### 3. DNS over HTTPS (DoH)

DNS 쿼리를 HTTPS로 암호화해서 보낸다. 보안뿐만 아니라 성능도 개선될 수 있다.

```
일반 DNS: UDP로 전송
DoH: HTTPS로 전송 (캐싱 최적화 가능)
```

### 4. CDN 사용

CDN을 쓰면 DNS 조회도 최적화된다.

```
일반 서버: 한국 → 미국 서버 (150ms)
CDN: 한국 → 한국 CDN 노드 (10ms)
```

가까운 CDN 노드를 쓰면 DNS 조회도 빨라진다.

## DNS 쿼리 로그 분석

실제 DNS 쿼리가 어떻게 진행되는지 로그로 확인해보자.

### tcpdump로 캡처

```bash
$ sudo tcpdump -i any -n port 53

10:00:00.123456 IP 192.168.1.100.54321 > 8.8.8.8.53: 
    UDP, length 32: 12345+ A? google.com. (28)

10:00:00.145678 IP 8.8.8.8.53 > 192.168.1.100.54321: 
    UDP, length 48: 12345 1/0/0 A 172.217.31.196 (44)
```

첫 번째 패킷은 질의, 두 번째 패킷은 응답이다.

### Wireshark로 분석

Wireshark로 DNS 패킷을 자세히 볼 수 있다.

```
DNS Query:
  Transaction ID: 0x1234
  Questions: 1
  Question: google.com, type A, class IN

DNS Response:
  Transaction ID: 0x1234
  Answers: 1
  Answer: google.com, type A, class IN, TTL 300, 
          Address: 172.217.31.196
```

패킷 구조를 직접 볼 수 있다.

## DNS가 실패하는 경우

DNS 쿼리가 실패하는 경우들.

### 1. 네임서버 문제

도메인의 네임서버가 다운되면 조회가 실패한다.

```
Resolver → ns1.example.com: "www.example.com의 IP 주소 뭐야?"
ns1.example.com: (응답 없음 - 서버 다운)
```

### 2. TTL 만료 후 서버 다운

TTL이 만료되어 다시 조회했는데 서버가 다운된 경우.

```
캐시: (TTL 만료)
Resolver → ns1.example.com: (서버 다운)
```

### 3. 잘못된 도메인

존재하지 않는 도메인을 조회하면 NXDOMAIN을 받는다.

```
Resolver → 루트 서버: "nonexistent.xyz 어디 있어?"
루트 서버 → Resolver: "없어요 (NXDOMAIN)"
```

## 마무리

DNS 쿼리는 생각보다 복잡하다. 여러 서버를 거치고, 여러 단계를 거친다.

그래서 느리다. 하지만 캐싱 덕분에 대부분의 경우 빠르다.

DNS를 이해하면 웹 성능 최적화도 쉬워진다. DNS Prefetch, CDN 선택, DNS 서버 선택. 모두 DNS를 이해해야 한다.

다음에 웹사이트가 느리다고 느낄 때, DNS 쿼리 시간도 확인해보자. 생각보다 많은 시간을 차지할 수 있다.

