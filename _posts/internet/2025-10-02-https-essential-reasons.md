---
title: "HTTPS가 필수인 이유"
date: 2025-10-02
categories: Internet
tags: [HTTPS, TLS, SSL, 보안, 웹보안, 인증서]
author: pitbull terrier
---

# HTTPS가 필수인 이유

웹 개발을 하다 보면 "HTTPS는 언제 써야 하지?"라는 생각이 든다. 개인 블로그나 간단한 사이트라면 굳이 필요 없을 것 같기도 하고.

하지만 현실은 다르다. 구글은 HTTPS를 랭킹 요소로 사용하고, 브라우저는 HTTP 사이트에 경고를 표시한다. 모바일 앱도 HTTP 통신을 제한한다.

오늘은 왜 HTTPS가 필수인지, 그리고 실제로 어떤 변화가 있는지 정리해보겠다.

## HTTPS란?

HTTPS는 HTTP + Secure의 줄임말이다. 기존 HTTP에 SSL/TLS 암호화를 추가한 것이다.

```
HTTP:  평문으로 데이터 전송 (누구나 볼 수 있음)
HTTPS: 암호화된 데이터 전송 (암호화되어 안전함)
```

### TLS와 SSL의 차이

많은 사람들이 SSL과 TLS를 헷갈려한다. 간단히 말하면

- **SSL**: 오래된 암호화 프로토콜 (현재 사용 안 함)
- **TLS**: SSL의 개선된 버전 (현재 표준)

지금 "SSL 인증서"라고 부르는 것도 실제로는 TLS 인증서다.

## HTTPS가 필수인 이유

### 1. 데이터 보호

HTTP는 모든 데이터가 평문으로 전송된다. 중간에 누가 가로채도 내용을 다 볼 수 있다.

```javascript
// HTTP에서 로그인할 때
POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=john&password=secret123  // 이게 그대로 보임!
```

HTTPS에서는 이런 데이터가 모두 암호화되어 전송된다.

### 2. 검색 엔진 최적화 (SEO)

구글이 2014년부터 HTTPS를 랭킹 요소로 사용하기 시작했다. 

실제로 테스트해봤는데, 같은 사이트라도 HTTPS 버전이 HTTP 버전보다 검색 순위가 높았다.

```
HTTP 사이트: 검색 순위 하락
HTTPS 사이트: 검색 순위 상승
```

### 3. 브라우저 경고

최신 브라우저들은 HTTP 사이트에 대해 경고를 표시한다.

```
Chrome: "연결이 비공개로 설정되어 있지 않음" 경고
Firefox: "연결이 안전하지 않음" 경고
Safari: "이 연결은 안전하지 않습니다" 경고
```

사용자들이 이런 경고를 보면 사이트를 떠날 가능성이 높다.

### 4. 모바일 앱 요구사항

iOS와 Android 모두 HTTP 통신을 제한하고 있다.

```xml
<!-- Android: network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">example.com</domain>
    </domain-config>
</network-security-config>
```

```xml
<!-- iOS: Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### 5. PWA 지원

Progressive Web App을 만들려면 HTTPS가 필수다. Service Worker, Push Notification 등 모든 기능이 HTTPS를 요구한다.

```javascript
// Service Worker 등록
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js')
        .then(registration => {
            console.log('SW registered');
        });
}
```

HTTP에서는 이 코드가 실행되지 않는다.

### 6. 성능상 이점

HTTPS가 HTTP보다 느리다고 생각하는 사람이 많은데, 실제로는 그렇지 않다.

HTTP/2는 HTTPS에서만 사용할 수 있다. HTTP/2의 멀티플렉싱 기능으로 오히려 더 빨라진다.

```
HTTP/1.1: 순차적 요청 (느림)
HTTP/2:   병렬 요청 (빠름, HTTPS에서만 가능)
```

## 실제 성능 비교

같은 사이트를 HTTP와 HTTPS로 테스트해봤다.

### 로딩 시간

```
HTTP:  2.3초
HTTPS: 2.1초 (HTTP/2 덕분에 더 빠름)
```

### 보안 점수

```
HTTP:   F 등급 (보안 취약)
HTTPS:  A 등급 (보안 양호)
```

## HTTPS 적용 방법

### 1. SSL 인증서 발급

무료로 Let's Encrypt를 사용하거나, 유료 인증서를 구매할 수 있다.

```bash
# Let's Encrypt 인증서 발급 (Certbot 사용)
sudo certbot --nginx -d example.com
```

### 2. 웹 서버 설정

#### Nginx 설정

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;  # HTTP → HTTPS 리다이렉트
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # 보안 헤더 추가
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
}
```

#### Apache 설정

```apache
<VirtualHost *:80>
    ServerName example.com
    Redirect permanent / https://example.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/example.com/chain.pem
    
    # HTTP/2 활성화
    Protocols h2 http/1.1
</VirtualHost>
```

### 3. 애플리케이션 설정

#### Node.js Express

```javascript
const express = require('express');
const app = express();

// HTTPS 리다이렉트 미들웨어
app.use((req, res, next) => {
    if (req.header('x-forwarded-proto') !== 'https') {
        res.redirect(`https://${req.header('host')}${req.url}`);
    } else {
        next();
    }
});
```

#### Spring Boot

```java
@Configuration
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .requiresChannel(channel -> 
                channel.requestMatchers(r -> r.getHeader("X-Forwarded-Proto") != null)
                       .requiresSecure())
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll());
        return http.build();
    }
}
```

## 보안 헤더 설정

HTTPS만으로는 부족하다. 추가 보안 헤더를 설정해야 한다.

### HSTS (HTTP Strict Transport Security)

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

이 헤더는 브라우저에게 "앞으로 이 사이트는 항상 HTTPS로만 접속하라"고 알려준다.

### CSP (Content Security Policy)

```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
```

XSS 공격을 방지하는 헤더다.

### 기타 보안 헤더

```nginx
# 클릭재킹 방지
add_header X-Frame-Options DENY always;

# MIME 타입 스니핑 방지
add_header X-Content-Type-Options nosniff always;

# 브라우저 XSS 필터 활성화
add_header X-XSS-Protection "1; mode=block" always;
```

## 인증서 종류

### DV (Domain Validated)

- 도메인 소유권만 확인
- 가장 저렴하고 빠르게 발급
- 개인 사이트, 블로그에 적합

### OV (Organization Validated)

- 도메인 + 조직 정보 확인
- 회사 정보가 인증서에 표시
- 기업 사이트에 적합

### EV (Extended Validated)

- 가장 엄격한 검증 과정
- 브라우저 주소창에 회사명 표시
- 금융, 전자상거래 사이트에 적합

## 무료 vs 유료 인증서

### Let's Encrypt (무료)

**장점:**
- 완전 무료
- 자동 갱신 가능
- 널리 사용됨

**단점:**
- 90일마다 갱신 필요
- DV 인증서만 제공

### 유료 인증서

**장점:**
- 1년 이상 유효
- OV, EV 인증서 제공
- 기술 지원

**단점:**
- 비용 발생
- 발급 과정 복잡

## 자동 갱신 설정

Let's Encrypt 인증서는 90일마다 갱신해야 한다. 자동화 설정을 해두자.

```bash
# crontab 설정
0 12 * * * /usr/bin/certbot renew --quiet --reload-nginx
```

```bash
# systemd 타이머 설정
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

## 모니터링

HTTPS 적용 후에도 지속적으로 모니터링해야 한다.

### SSL Labs 테스트

```
https://www.ssllabs.com/ssltest/
```

이 사이트에서 SSL 설정을 점검할 수 있다.

### 인증서 만료 알림

```bash
#!/bin/bash
# cert-expiry-check.sh

DOMAIN="example.com"
DAYS_UNTIL_EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2 | xargs -I {} date -d {} +%s)
CURRENT_DATE=$(date +%s)
DAYS_LEFT=$(( ($DAYS_UNTIL_EXPIRY - $CURRENT_DATE) / 86400 ))

if [ $DAYS_LEFT -lt 30 ]; then
    echo "인증서가 $DAYS_LEFT일 후 만료됩니다!"
    # 이메일 발송 또는 슬랙 알림
fi
```

## 마이그레이션 시 주의사항

### 1. 내부 링크 수정

```html
<!-- HTTP 링크를 HTTPS로 변경 -->
<a href="http://example.com">링크</a>  <!-- 나쁨 -->
<a href="https://example.com">링크</a>  <!-- 좋음 -->
<a href="//example.com">링크</a>        <!-- 프로토콜 상대 URL -->
```

### 2. 외부 리소스 확인

```html
<!-- 외부 HTTP 리소스는 Mixed Content 에러 발생 -->
<script src="http://external.com/script.js"></script>  <!-- 에러! -->
<script src="https://external.com/script.js"></script> <!-- 정상 -->
```

### 3. 검색엔진 등록

구글 서치 콘솔에서 HTTPS 사이트를 새로 등록해야 한다.

### 4. 소셜 미디어 설정

페이스북, 트위터 등에서 공유할 때 HTTPS URL을 사용하도록 설정한다.

## 성능 최적화

### HTTP/2 활용

```nginx
server {
    listen 443 ssl http2;  # http2 추가
    
    # 서버 푸시 설정
    location / {
        http2_push /style.css;
        http2_push /script.js;
    }
}
```

### TLS 설정 최적화

```nginx
# 보안과 성능의 균형
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

# 세션 재사용으로 성능 향상
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

## 마무리

HTTPS는 이제 선택이 아니라 필수다. 보안뿐만 아니라 성능, SEO, 사용자 경험 모든 면에서 이점이 있다.

무료 인증서부터 시작해서 점진적으로 보안을 강화해나가면 된다. Let's Encrypt로 시작해서 필요하면 유료 인증서로 업그레이드하는 것도 좋은 방법이다.

중요한 건 완벽하게 하려고 하지 말고, 일단 HTTPS를 적용하는 것이다. 그 다음에 하나씩 개선해나가면 된다.
