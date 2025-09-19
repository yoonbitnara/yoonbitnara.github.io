---
title: "HTTP/2와 HTTP/3"
tags: HTTP, HTTP2, HTTP3, 웹성능, 프로토콜
date: "2025.09.19"
categories: 
    - Internet
---

# HTTP/2와 HTTP/3

웹 개발을 하다 보면 HTTP/1.1의 한계를 많이 느낀다. 특히 모바일 환경에서 여러 리소스를 로딩할 때 느려지는 걸 보면 "왜 이렇게 느릴까?"라는 생각이 든다.

HTTP/1.1은 1997년에 나온 프로토콜인데, 지금 웹의 복잡성과는 맞지 않는다. 그래서 나온 게 HTTP/2이고, 그 다음에 HTTP/3까지 나왔다.

오늘은 이 프로토콜들이 어떻게 웹 성능을 개선했는지, 실제로 어떤 차이가 있는지 알아보자.

## HTTP/1.1의 문제점

### 단일 연결의 한계

HTTP/1.1은 기본적으로 하나의 연결에서 하나의 요청만 처리할 수 있다. 이를 "Head-of-Line Blocking"이라고 한다.

예를 들어보자. 웹페이지를 로딩할 때 HTML, CSS, JavaScript 파일들을 순차적으로 다운로드한다고 하자.

```
요청 1: HTML 파일 (2초 소요)
요청 2: CSS 파일 (1초 소요)  
요청 3: JS 파일 (3초 소요)
```

HTTP/1.1에서는 총 6초가 걸린다. 각 요청이 완료되어야 다음 요청을 보낼 수 있기 때문이다.

### 연결 수 제한

브라우저마다 다르지만, 보통 도메인당 6-8개의 동시 연결만 허용한다. 이는 HTTP/1.1의 또 다른 문제점이다.

```javascript
// 이런 상황에서 문제가 생긴다
const images = [
  'image1.jpg', 'image2.jpg', 'image3.jpg',
  'image4.jpg', 'image5.jpg', 'image6.jpg',
  'image7.jpg', 'image8.jpg', 'image9.jpg'
];

// 6개까지만 동시에 로딩되고, 나머지는 대기
images.forEach(src => {
  const img = new Image();
  img.src = src;
});
```

### 불필요한 헤더 중복

HTTP/1.1에서는 매 요청마다 헤더를 보내야 한다. 쿠키나 인증 정보 같은 헤더가 매번 반복된다.

```
GET /style.css HTTP/1.1
Host: example.com
Cookie: session=abc123; user=john
User-Agent: Chrome/91.0

GET /script.js HTTP/1.1  
Host: example.com
Cookie: session=abc123; user=john  // 같은 헤더 반복
User-Agent: Chrome/91.0
```

## HTTP/2의 혁신

### 멀티플렉싱 (Multiplexing)

HTTP/2의 가장 큰 변화는 멀티플렉싱이다. 하나의 연결에서 여러 요청을 동시에 처리할 수 있다.

```
HTTP/1.1: 요청1 → 응답1 → 요청2 → 응답2 → 요청3 → 응답3
HTTP/2:   요청1 ↘
                → 응답1, 응답2, 응답3 (동시 처리)
         요청2 ↗
         요청3 ↗
```

실제로 테스트해보면 차이가 확실하다. 같은 리소스들을 로딩할 때 HTTP/1.1은 6초, HTTP/2는 3초 정도 걸린다.

### 서버 푸시 (Server Push)

HTTP/2에서는 서버가 클라이언트가 요청하기 전에 미리 리소스를 보낼 수 있다.

```html
<!-- 클라이언트가 HTML을 요청하면 -->
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="/style.css">  <!-- 서버가 미리 푸시 -->
    <script src="/script.js"></script>         <!-- 서버가 미리 푸시 -->
</head>
</html>
```

이렇게 하면 클라이언트가 CSS나 JS 파일을 별도로 요청하지 않아도 된다.

### 헤더 압축 (HPACK)

HTTP/2는 HPACK이라는 압축 알고리즘을 사용해서 헤더 크기를 줄인다.

```
HTTP/1.1: 매 요청마다 전체 헤더 전송 (500바이트 × 100개 = 50KB)
HTTP/2:   첫 번째 요청만 전체 헤더, 나머지는 압축된 인덱스만 (50KB → 5KB)
```

### 바이너리 프로토콜

HTTP/1.1은 텍스트 기반이었지만, HTTP/2는 바이너리 프로토콜이다. 파싱이 훨씬 빠르고 오류가 적다.

## HTTP/2의 한계

HTTP/2도 완벽하지 않다. 여전히 TCP 기반이라 TCP의 문제점을 그대로 가지고 있다.

### TCP Head-of-Line Blocking

HTTP/2에서도 TCP 레벨에서 패킷 손실이 발생하면 전체 연결이 멈춘다.

```
패킷 순서: [1][2][3][4][5]
패킷 3이 손실되면:
- 패킷 4, 5는 도착했지만 대기
- 패킷 3 재전송 대기
- 전체 스트림 지연
```

### 핸드셰이크 오버헤드

TCP 연결을 맺기 위해서는 3-way handshake가 필요하다. TLS까지 포함하면 더 많은 라운드트립이 필요하다.

```
TCP 3-way handshake: 1.5 RTT
TLS handshake: 2 RTT  
총 3.5 RTT 필요
```

## HTTP/3의 혁신

### QUIC 프로토콜

HTTP/3는 TCP 대신 QUIC(Quick UDP Internet Connections) 프로토콜을 사용한다. QUIC는 UDP 기반이지만 TCP의 신뢰성을 제공한다.

```
HTTP/1.1: HTTP over TCP over IP
HTTP/2:   HTTP over TCP over IP  
HTTP/3:   HTTP over QUIC over UDP over IP
```

### 연결 마이그레이션

QUIC의 큰 장점 중 하나는 연결 마이그레이션이다. 사용자가 WiFi에서 4G로 바꿔도 연결이 끊어지지 않는다.

```javascript
// 사용자 경험
// WiFi → 4G 전환 시
// HTTP/1.1/2: 연결 끊어짐, 재연결 필요
// HTTP/3: 연결 유지, 끊김 없는 서비스
```

### 0-RTT 연결 재개

이전에 연결했던 서버라면 0-RTT로 연결을 재개할 수 있다. 특히 모바일에서 유용하다.

```
첫 연결: 1 RTT (QUIC handshake)
재연결: 0 RTT (연결 상태 복원)
```

### 개선된 멀티플렉싱

QUIC는 스트림별로 독립적인 흐름 제어를 한다. 한 스트림에서 문제가 생겨도 다른 스트림에는 영향을 주지 않는다.

```
HTTP/2: 패킷 3 손실 → 모든 스트림 대기
HTTP/3: 패킷 3 손실 → 해당 스트림만 대기, 나머지는 계속 진행
```

## 실제 성능 비교

### 로딩 시간 테스트

같은 웹사이트를 다른 프로토콜로 테스트해보자.

```javascript
// 테스트 환경
const testUrls = [
  'https://http1.example.com',  // HTTP/1.1
  'https://http2.example.com',  // HTTP/2  
  'https://http3.example.com'   // HTTP/3
];

async function measureLoadTime(url) {
  const start = performance.now();
  await fetch(url);
  const end = performance.now();
  return end - start;
}

// 결과 (예시)
// HTTP/1.1: 2.3초
// HTTP/2:   1.4초 (39% 개선)
// HTTP/3:   1.1초 (52% 개선)
```

### 모바일 환경에서의 차이

모바일에서는 네트워크 불안정성이 더 크기 때문에 HTTP/3의 장점이 더 크게 나타난다.

```
WiFi 환경:
- HTTP/1.1: 1.8초
- HTTP/2:   1.2초
- HTTP/3:   1.0초

4G 환경:
- HTTP/1.1: 3.2초
- HTTP/2:   2.1초  
- HTTP/3:   1.4초 (연결 마이그레이션 효과)
```

## 브라우저 지원 현황

### HTTP/2 지원

거의 모든 현대 브라우저에서 지원한다.

```
Chrome: 41+ (2015년)
Firefox: 36+ (2015년)
Safari: 9+ (2015년)
Edge: 12+ (2015년)
```

### HTTP/3 지원

아직 완전하지 않지만 빠르게 확산되고 있다.

```
Chrome: 87+ (2020년)
Firefox: 88+ (2021년)
Safari: 14.1+ (2021년)
Edge: 87+ (2020년)
```

## 서버 설정 방법

### Nginx에서 HTTP/2 설정

```nginx
server {
    listen 443 ssl http2;  # http2 추가
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # HTTP/2 서버 푸시 설정
    location / {
        http2_push /style.css;
        http2_push /script.js;
    }
}
```

### Apache에서 HTTP/2 설정

```apache
# mod_http2 모듈 로드
LoadModule http2_module modules/mod_http2.so

<VirtualHost *:443>
    Protocols h2 http/1.1
    
    # 서버 푸시 설정
    H2PushResource /style.css
    H2PushResource /script.js
</VirtualHost>
```

### HTTP/3 설정 (Cloudflare 예시)

```javascript
// Cloudflare Workers에서 HTTP/3 지원
export default {
  async fetch(request, env) {
    // HTTP/3는 자동으로 지원됨
    const response = await fetch(request);
    
    // HTTP/3 헤더 추가
    response.headers.set('Alt-Svc', 'h3=":443"; ma=86400');
    
    return response;
  }
}
```

## 실제 적용 시 고려사항

### 호환성 문제

HTTP/2나 HTTP/3를 사용하려면 HTTPS가 필수다. HTTP에서는 사용할 수 없다.

```javascript
// HTTPS 강제 리다이렉트
if (location.protocol !== 'https:') {
  location.replace('https:' + window.location.href.substring(window.location.protocol.length));
}
```

### 서버 리소스 사용량

HTTP/2는 멀티플렉싱으로 인해 서버 리소스를 더 많이 사용한다. 연결당 메모리 사용량이 증가한다.

```bash
# 서버 모니터링
netstat -an | grep :443 | wc -l  # HTTP/2 연결 수 확인
ss -tuln | grep :443 | wc -l     # 더 정확한 연결 수
```

### 개발 도구 활용

Chrome DevTools에서 HTTP/2 사용 여부를 확인할 수 있다.

```
1. F12 → Network 탭
2. 프로토콜 컬럼에서 "h2" 확인
3. HTTP/2 사용 시 "h2"로 표시됨
```

## 마이그레이션 전략

### 단계적 적용

한 번에 모든 것을 바꾸기보다는 단계적으로 적용하는 것이 좋다.

```
1단계: HTTP/2 적용 (기존 서버 업그레이드)
2단계: 성능 모니터링 및 최적화
3단계: HTTP/3 지원 검토 (CDN 활용)
4단계: 점진적 HTTP/3 전환
```

### A/B 테스트

실제 사용자에게 미치는 영향을 측정하기 위해 A/B 테스트를 진행한다.

```javascript
// 사용자 그룹별 프로토콜 할당
const userGroup = Math.random() > 0.5 ? 'http2' : 'http3';
const apiUrl = userGroup === 'http2' ? 
  'https://api-v2.example.com' : 
  'https://api-v3.example.com';

// 성능 지표 수집
const startTime = performance.now();
fetch(apiUrl)
  .then(() => {
    const loadTime = performance.now() - startTime;
    // 분석 도구로 데이터 전송
    analytics.track('page_load_time', {
      protocol: userGroup,
      loadTime: loadTime
    });
  });
```

## 미래 전망

### HTTP/3 확산

HTTP/3는 아직 초기 단계지만 빠르게 확산되고 있다. 특히 모바일 환경에서의 장점이 크다.

```
2023년: 25% 웹사이트가 HTTP/2 사용
2024년: 15% 웹사이트가 HTTP/3 지원
2025년 예상: 30% 웹사이트가 HTTP/3 지원
```

### 새로운 기능들

HTTP/3 기반으로 더 많은 기능들이 개발될 예정이다.

- 실시간 스트리밍 개선
- 게임 서버 최적화  
- IoT 디바이스 통신
- 에지 컴퓨팅 지원

## 실무에서의 적용 팁

### 모니터링 도구

성능 변화를 정확히 측정하기 위해 적절한 모니터링 도구를 사용하자.

```javascript
// Core Web Vitals 측정
import {getCLS, getFID, getFCP, getLCP, getTTFB} from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getFCP(console.log);
getLCP(console.log);
getTTFB(console.log);
```

### 점진적 개선

모든 것을 한 번에 바꾸려 하지 말고, 중요한 페이지부터 시작하자.

```
1순위: 메인 페이지
2순위: 상품 상세 페이지
3순위: 기타 페이지들
```

## 마무리

HTTP/2와 HTTP/3는 단순한 프로토콜 업그레이드가 아니라 웹 성능의 패러다임을 바꾼 혁신이다.

특히 HTTP/3의 QUIC 프로토콜은 모바일 환경에서의 사용자 경험을 크게 개선할 것이다. 연결 마이그레이션, 0-RTT 재연결 같은 기능들은 사용자가 네트워크를 바꿔도 끊김 없는 서비스를 제공할 수 있게 해준다.

하지만 모든 기술이 그렇듯이, 무작정 최신 기술을 도입하는 것보다는 현재 상황에 맞는 적절한 선택을 하는 것이 중요하다. HTTP/2부터 시작해서 점진적으로 HTTP/3로 넘어가는 것이 현실적인 접근 방법이다.

