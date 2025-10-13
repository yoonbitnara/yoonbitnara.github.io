---
title: "WebSocket vs SSE vs Long Polling"
excerpt: "실시간 웹 통신, 어떤 기술을 써야 할까? WebSocket, SSE, Long Polling의 동작 원리부터 실전 활용까지"

categories:
  - Internet
tags:
  - [WebSocket, SSE, Long Polling, 실시간통신, 웹소켓]

toc: true
toc_sticky: true

date: 2025-10-13
last_modified_at: 2025-10-13
---

# 실시간 통신 기술 비교 - WebSocket vs SSE vs Long Polling

코인 거래소 사이트를 보다가 신기했다. 가격이 새로고침 없이도 계속 바뀐다. 페이지를 열어만 두면 실시간으로 가격이 업데이트된다.

"어떻게 구현하는 거지?" 궁금해서 개발자 도구를 열어봤다. Network 탭을 보니 뭔가 계속 통신하고 있었다. 그때부터 실시간 웹에 대해 알아보기 시작했다.

알아보니 방법이 여러 가지였다. WebSocket, SSE, Long Polling. 이름만 들어서는 뭐가 뭔지 모르겠더라. 하지만 각각 완전히 다른 방식으로 작동하고, 쓰임새도 달랐다.

## 전통적인 방식의 문제점

일반적인 HTTP 통신은 클라이언트가 요청해야 서버가 응답한다. 서버가 먼저 데이터를 보낼 수 없다.

```javascript
// 이런 식으로 계속 물어봐야 한다
setInterval(() => {
  fetch('/api/messages')
    .then(response => response.json())
    .then(data => {
      if (data.newMessages) {
        updateUI(data.newMessages);
      }
    });
}, 1000); // 1초마다 요청
```

이 방식의 문제점
- 새 메시지가 없어도 계속 요청
- 서버 리소스 낭비
- 네트워크 트래픽 증가
- 실시간성 떨어짐 (최대 1초 지연)

채팅방에 사용자 100명이 있다면? 1초에 100번의 요청이 발생한다. 새 메시지가 없어도 말이다.

## Long Polling - 기다리는 방식

Long Polling은 이런 비효율을 개선한 첫 번째 시도다.

### 동작 원리

클라이언트가 요청을 보내면, 서버는 바로 응답하지 않고 새 데이터가 생길 때까지 기다린다.

```
클라이언트: "새 메시지 있어요?" (요청 전송)
서버: (응답 보류... 새 메시지 올 때까지 대기)
[새 메시지 도착]
서버: "네, 있어요!" (응답 전송)
클라이언트: "또 새 메시지 있어요?" (바로 다시 요청)
```

### 구현 예제

**서버 코드 (Node.js/Express)**

```javascript
const express = require('express');
const app = express();

let clients = [];
let messages = [];

app.get('/api/messages/poll', (req, res) => {
  const lastMessageId = parseInt(req.query.lastId) || 0;
  
  // 새 메시지가 있는지 확인
  const newMessages = messages.filter(msg => msg.id > lastMessageId);
  
  if (newMessages.length > 0) {
    // 새 메시지가 있으면 바로 응답
    res.json({ messages: newMessages });
  } else {
    // 없으면 클라이언트 정보 저장하고 대기
    const client = { res, lastMessageId };
    clients.push(client);
    
    // 30초 후 타임아웃
    setTimeout(() => {
      const index = clients.indexOf(client);
      if (index > -1) {
        clients.splice(index, 1);
        res.json({ messages: [] });
      }
    }, 30000);
  }
});

// 새 메시지 전송 API
app.post('/api/messages', express.json(), (req, res) => {
  const message = {
    id: messages.length + 1,
    text: req.body.text,
    timestamp: Date.now()
  };
  
  messages.push(message);
  
  // 대기 중인 모든 클라이언트에게 응답
  clients.forEach(client => {
    if (client.lastMessageId < message.id) {
      client.res.json({ messages: [message] });
    }
  });
  
  clients = [];
  res.json({ success: true });
});
```

**클라이언트 코드:**

```javascript
let lastMessageId = 0;

function startLongPolling() {
  fetch(`/api/messages/poll?lastId=${lastMessageId}`)
    .then(response => response.json())
    .then(data => {
      if (data.messages.length > 0) {
        data.messages.forEach(msg => {
          displayMessage(msg);
          lastMessageId = msg.id;
        });
      }
      // 응답 받으면 바로 다시 요청
      startLongPolling();
    })
    .catch(error => {
      console.error('Error:', error);
      // 에러 시 3초 후 재시도
      setTimeout(startLongPolling, 3000);
    });
}

startLongPolling();
```

### 장단점

**장점**
- 일반 HTTP 요청이라 구현이 쉽다
- 방화벽이나 프록시 이슈가 적다
- 모든 브라우저에서 작동

**단점**
- 여전히 요청/응답 반복이 필요
- 서버 리소스 많이 사용 (연결 유지)
- 양방향 통신이 아님 (클라이언트→서버만 진짜 실시간)

## Server-Sent Events (SSE): 한 방향 실시간

SSE는 서버에서 클라이언트로만 데이터를 보내는 단방향 통신이다.

### 동작 원리

클라이언트가 한 번 연결하면, 서버가 계속해서 이벤트를 푸시할 수 있다.

```
클라이언트: "연결할게요" (연결 요청)
서버: "OK, 연결 유지" (연결 수락)
서버: "새 메시지 1" (푸시)
서버: "새 메시지 2" (푸시)
서버: "새 메시지 3" (푸시)
```

### 구현 예제

**서버 코드**

```javascript
const express = require('express');
const app = express();

let clients = [];

app.get('/api/events', (req, res) => {
  // SSE 헤더 설정
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Access-Control-Allow-Origin': '*'
  });

  // 연결 확인용 초기 메시지
  res.write('data: {"type":"connected"}\n\n');

  // 클라이언트 정보 저장
  const clientId = Date.now();
  const newClient = {
    id: clientId,
    res
  };
  
  clients.push(newClient);

  // 연결 끊김 처리
  req.on('close', () => {
    clients = clients.filter(client => client.id !== clientId);
  });
});

// 메시지 전송 함수
function sendToAllClients(data) {
  clients.forEach(client => {
    client.res.write(`data: ${JSON.stringify(data)}\n\n`);
  });
}

// 새 메시지 API
app.post('/api/messages', express.json(), (req, res) => {
  const message = {
    type: 'message',
    text: req.body.text,
    timestamp: Date.now()
  };
  
  // 모든 클라이언트에게 전송
  sendToAllClients(message);
  
  res.json({ success: true });
});

// 주기적으로 heartbeat 전송 (연결 유지)
setInterval(() => {
  sendToAllClients({ type: 'heartbeat' });
}, 30000);
```

**클라이언트 코드**

```javascript
// EventSource API 사용
const eventSource = new EventSource('/api/events');

eventSource.onopen = () => {
  console.log('SSE 연결 성공');
};

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  if (data.type === 'message') {
    displayMessage(data);
  } else if (data.type === 'heartbeat') {
    console.log('Heartbeat received');
  }
};

eventSource.onerror = (error) => {
  console.error('SSE 에러:', error);
  // 자동으로 재연결 시도
};

// 연결 종료
function closeConnection() {
  eventSource.close();
}
```

### 실전 활용 예제: 실시간 알림

```javascript
// 서버: 알림 시스템
app.post('/api/notifications/send', async (req, res) => {
  const { userId, message } = req.body;
  
  // 특정 사용자에게만 알림 전송
  const userClients = clients.filter(c => c.userId === userId);
  
  const notification = {
    type: 'notification',
    message: message,
    timestamp: Date.now()
  };
  
  userClients.forEach(client => {
    client.res.write(`data: ${JSON.stringify(notification)}\n\n`);
  });
  
  res.json({ success: true, sent: userClients.length });
});

// 클라이언트: 알림 수신
const eventSource = new EventSource('/api/events');

eventSource.addEventListener('notification', (event) => {
  const data = JSON.parse(event.data);
  
  // 브라우저 알림 표시
  if (Notification.permission === 'granted') {
    new Notification('새 알림', {
      body: data.message,
      icon: '/icon.png'
    });
  }
  
  // UI 업데이트
  addNotificationToUI(data);
});
```

### 장단점

**장점**
- 구현이 간단 (EventSource API)
- HTTP 기반이라 호환성 좋음
- 자동 재연결 기능 내장
- 텍스트 데이터 전송에 효율적

**단점**
- 단방향 통신만 가능 (서버→클라이언트)
- 바이너리 데이터 전송 불가
- IE/Edge(구버전) 미지원
- HTTP/1.1에서 브라우저당 연결 수 제한 (도메인당 6개)

## WebSocket - 진짜 양방향 실시간

WebSocket은 완전한 양방향 통신을 제공한다. 서버와 클라이언트가 동등하게 데이터를 주고받을 수 있다.

### 동작 원리

HTTP로 시작하지만, 핸드셰이크 후 WebSocket 프로토콜로 업그레이드된다.

```
클라이언트: "WebSocket으로 업그레이드할게요" (HTTP Upgrade 요청)
서버: "OK, 업그레이드 완료" (101 Switching Protocols)
[이제부터 WebSocket 프로토콜]
클라이언트 ←→ 서버 (양방향 자유롭게 통신)
```

### 구현 예제

**서버 코드 (ws 라이브러리)**

```javascript
const express = require('express');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const clients = new Map();

wss.on('connection', (ws, req) => {
  const clientId = Date.now();
  console.log(`새 클라이언트 연결: ${clientId}`);
  
  // 클라이언트 정보 저장
  clients.set(clientId, {
    ws,
    username: null,
    room: null
  });
  
  // 메시지 수신
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      handleMessage(clientId, data);
    } catch (error) {
      console.error('메시지 파싱 에러:', error);
    }
  });
  
  // 연결 종료
  ws.on('close', () => {
    console.log(`클라이언트 연결 종료: ${clientId}`);
    
    const client = clients.get(clientId);
    if (client && client.room) {
      // 방에 퇴장 알림
      broadcastToRoom(client.room, {
        type: 'user-left',
        username: client.username
      }, clientId);
    }
    
    clients.delete(clientId);
  });
  
  // 에러 처리
  ws.on('error', (error) => {
    console.error('WebSocket 에러:', error);
  });
  
  // 연결 확인 메시지
  ws.send(JSON.stringify({
    type: 'connected',
    clientId: clientId
  }));
});

// 메시지 처리 함수
function handleMessage(clientId, data) {
  const client = clients.get(clientId);
  
  switch (data.type) {
    case 'join':
      // 방 입장
      client.username = data.username;
      client.room = data.room;
      
      broadcastToRoom(data.room, {
        type: 'user-joined',
        username: data.username
      }, clientId);
      break;
      
    case 'message':
      // 메시지 전송
      broadcastToRoom(client.room, {
        type: 'message',
        username: client.username,
        text: data.text,
        timestamp: Date.now()
      }, clientId);
      break;
      
    case 'typing':
      // 타이핑 중 알림
      broadcastToRoom(client.room, {
        type: 'typing',
        username: client.username
      }, clientId);
      break;
  }
}

// 같은 방의 모든 클라이언트에게 전송
function broadcastToRoom(room, message, excludeClientId = null) {
  clients.forEach((client, id) => {
    if (client.room === room && id !== excludeClientId) {
      if (client.ws.readyState === WebSocket.OPEN) {
        client.ws.send(JSON.stringify(message));
      }
    }
  });
}

// 모든 클라이언트에게 전송
function broadcast(message) {
  clients.forEach(client => {
    if (client.ws.readyState === WebSocket.OPEN) {
      client.ws.send(JSON.stringify(message));
    }
  });
}

server.listen(3000, () => {
  console.log('서버 시작: http://localhost:3000');
});
```

**클라이언트 코드**

```javascript
class ChatClient {
  constructor(url) {
    this.url = url;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }
  
  connect() {
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('WebSocket 연결 성공');
      this.reconnectAttempts = 0;
      this.onConnected();
    };
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket 에러:', error);
    };
    
    this.ws.onclose = () => {
      console.log('WebSocket 연결 종료');
      this.onDisconnected();
      this.reconnect();
    };
  }
  
  reconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.log(`재연결 시도 ${this.reconnectAttempts}/${this.maxReconnectAttempts}`);
      
      setTimeout(() => {
        this.connect();
      }, 1000 * this.reconnectAttempts);
    } else {
      console.error('재연결 실패');
      this.onReconnectFailed();
    }
  }
  
  send(type, data) {
    if (this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({
        type,
        ...data
      }));
    } else {
      console.error('WebSocket 연결 안 됨');
    }
  }
  
  joinRoom(username, room) {
    this.send('join', { username, room });
  }
  
  sendMessage(text) {
    this.send('message', { text });
  }
  
  sendTyping() {
    this.send('typing', {});
  }
  
  handleMessage(data) {
    switch (data.type) {
      case 'connected':
        console.log('서버 연결 완료:', data.clientId);
        break;
        
      case 'user-joined':
        this.onUserJoined(data.username);
        break;
        
      case 'user-left':
        this.onUserLeft(data.username);
        break;
        
      case 'message':
        this.onMessage(data);
        break;
        
      case 'typing':
        this.onTyping(data.username);
        break;
    }
  }
  
  // 이벤트 핸들러 (오버라이드해서 사용)
  onConnected() {}
  onDisconnected() {}
  onReconnectFailed() {}
  onUserJoined(username) {}
  onUserLeft(username) {}
  onMessage(data) {}
  onTyping(username) {}
}

// 사용 예제
const chat = new ChatClient('ws://localhost:3000');

chat.onConnected = () => {
  console.log('채팅 연결됨');
  chat.joinRoom('홍길동', 'general');
};

chat.onMessage = (data) => {
  const messageElement = document.createElement('div');
  messageElement.className = 'message';
  messageElement.innerHTML = `
    <strong>${data.username}</strong>: ${data.text}
    <span class="time">${new Date(data.timestamp).toLocaleTimeString()}</span>
  `;
  document.getElementById('messages').appendChild(messageElement);
};

chat.onUserJoined = (username) => {
  console.log(`${username}님이 입장했습니다`);
};

chat.onTyping = (username) => {
  console.log(`${username}님이 입력 중...`);
};

chat.connect();

// 메시지 전송
document.getElementById('sendButton').onclick = () => {
  const input = document.getElementById('messageInput');
  chat.sendMessage(input.value);
  input.value = '';
};

// 타이핑 이벤트
let typingTimeout;
document.getElementById('messageInput').oninput = () => {
  clearTimeout(typingTimeout);
  chat.sendTyping();
  
  typingTimeout = setTimeout(() => {
    // 타이핑 중지
  }, 1000);
};
```

### 실전 활용 - 화상 채팅 시그널링

WebSocket은 WebRTC 시그널링에도 많이 사용된다.

```javascript
// 서버: WebRTC 시그널링
wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    const data = JSON.parse(message);
    
    switch (data.type) {
      case 'offer':
      case 'answer':
      case 'ice-candidate':
        // 상대방에게 전달
        const targetClient = clients.get(data.targetId);
        if (targetClient) {
          targetClient.ws.send(JSON.stringify(data));
        }
        break;
    }
  });
});

// 클라이언트: WebRTC 연결
const peerConnection = new RTCPeerConnection();
const ws = new WebSocket('ws://localhost:3000');

// Offer 생성 및 전송
async function createOffer(targetId) {
  const offer = await peerConnection.createOffer();
  await peerConnection.setLocalDescription(offer);
  
  ws.send(JSON.stringify({
    type: 'offer',
    targetId: targetId,
    offer: offer
  }));
}

// ICE Candidate 전송
peerConnection.onicecandidate = (event) => {
  if (event.candidate) {
    ws.send(JSON.stringify({
      type: 'ice-candidate',
      targetId: targetUserId,
      candidate: event.candidate
    }));
  }
};
```

### 장단점

**장점**
- 완전한 양방향 통신
- 낮은 지연시간
- 바이너리 데이터 전송 가능
- 오버헤드가 적음 (헤더가 작음)
- 연결 수 제한 없음

**단점**
- 구현이 복잡
- 상태 관리 필요 (재연결 등)
- 오래된 프록시/방화벽에서 문제 가능
- HTTP와 다른 프로토콜 (캐싱, 압축 등 직접 구현)

## 성능 비교

실제로 세 가지 방식의 성능을 비교해보자.

### 네트워크 트래픽

100개의 메시지를 전송할 때

```
Long Polling:
- 요청 수: 100회
- 헤더 크기: ~500 bytes × 100 = 50KB
- 총 데이터: 메시지 + 50KB

SSE:
- 요청 수: 1회 (초기 연결)
- 헤더 크기: ~500 bytes
- 총 데이터: 메시지 + 500 bytes

WebSocket:
- 요청 수: 1회 (초기 연결)
- 헤더 크기: 2-14 bytes × 100 = 최대 1.4KB
- 총 데이터: 메시지 + 1.4KB
```

WebSocket이 압도적으로 효율적이다.

### 지연시간

```javascript
// 벤치마크 코드
async function measureLatency(method, iterations = 100) {
  const latencies = [];
  
  for (let i = 0; i < iterations; i++) {
    const start = performance.now();
    
    await method();
    
    const end = performance.now();
    latencies.push(end - start);
  }
  
  const avg = latencies.reduce((a, b) => a + b) / latencies.length;
  const min = Math.min(...latencies);
  const max = Math.max(...latencies);
  
  return { avg, min, max };
}

// 결과 (예시)
// Long Polling: 평균 150ms, 최소 50ms, 최대 30000ms
// SSE: 평균 20ms, 최소 5ms, 최대 100ms
// WebSocket: 평균 5ms, 최소 1ms, 최대 20ms
```

### 서버 리소스

```javascript
// 동시 접속자 1000명 기준 메모리 사용량 (대략적인 추정)
const resourceUsage = {
  longPolling: {
    connections: 1000,
    memory: '~100MB', // 연결당 ~100KB
    cpu: 'High' // 계속 요청/응답
  },
  
  sse: {
    connections: 1000,
    memory: '~50MB', // 연결당 ~50KB
    cpu: 'Medium' // 데이터 있을 때만 전송
  },
  
  webSocket: {
    connections: 1000,
    memory: '~30MB', // 연결당 ~30KB
    cpu: 'Low' // 이벤트 기반
  }
};
```

## 어떤 걸 써야 할까?

각 기술은 특정 상황에 최적화되어 있다.

### Long Polling을 쓰는 경우

```javascript
// 1. 레거시 브라우저 지원 필요
if (isIE9OrOlder()) {
  useLongPolling();
}

// 2. 방화벽/프록시 제약이 심한 환경
if (strictCorporateNetwork()) {
  useLongPolling();
}

// 3. 단순한 알림 정도만 필요
setInterval(() => {
  checkForNotifications();
}, 10000); // 10초마다
```

**사용 예**
- 간단한 알림 시스템
- 레거시 시스템 통합
- 업데이트 빈도가 낮은 경우

### SSE를 쓰는 경우

```javascript
// 1. 서버→클라이언트 단방향만 필요
const eventSource = new EventSource('/api/stock-prices');

eventSource.onmessage = (event) => {
  const price = JSON.parse(event.data);
  updateStockPrice(price);
};

// 2. 자동 재연결이 중요
// EventSource는 자동으로 재연결 시도

// 3. HTTP/2 환경
// HTTP/2에서는 연결 수 제한 문제 해결
```

**사용 예**
- 뉴스 피드
- 주식 가격 업데이트
- 소셜 미디어 타임라인
- 서버 로그 스트리밍
- 진행 상황 표시 (파일 업로드 등)

### WebSocket을 쓰는 경우

```javascript
// 1. 양방향 실시간 통신 필요
const gameSocket = new WebSocket('ws://game-server.com');

gameSocket.send(JSON.stringify({
  action: 'move',
  direction: 'north'
}));

gameSocket.onmessage = (event) => {
  const gameState = JSON.parse(event.data);
  updateGameState(gameState);
};

// 2. 낮은 지연시간이 중요
// 게임, 화상 채팅 등

// 3. 바이너리 데이터 전송
const binaryData = new Uint8Array([1, 2, 3, 4]);
gameSocket.send(binaryData);
```

**사용 예**
- 채팅 애플리케이션
- 멀티플레이어 게임
- 협업 도구 (실시간 문서 편집)
- 화상 회의 (시그널링)
- 금융 거래 시스템

### 채팅 서비스의 선택

많은 채팅 서비스들이 처음엔 Long Polling으로 시작한다. 구현이 쉽기 때문이다. 하지만 사용자가 늘어나면 서버 부하가 문제가 된다.

```javascript
// Long Polling의 문제
// 사용자 100명 × 1초마다 요청 = 초당 100 요청
// 서버 CPU 사용률: 60%

// WebSocket으로 전환하면
// 사용자 100명, 메시지 있을 때만 전송
// 서버 CPU 사용률: 15%
```

Slack 같은 서비스들이 WebSocket을 사용하는 이유다. 서버 비용을 70% 가까이 줄일 수 있다.

### 모니터링 대시보드

서버 상태를 실시간으로 보여주는 대시보드라면 SSE가 적합하다.

```javascript
// SSE로 서버 지표 스트리밍
const eventSource = new EventSource('/api/server-status');

eventSource.addEventListener('cpu', (event) => {
  updateCPUChart(JSON.parse(event.data));
});

eventSource.addEventListener('memory', (event) => {
  updateMemoryChart(JSON.parse(event.data));
});

eventSource.addEventListener('disk', (event) => {
  updateDiskChart(JSON.parse(event.data));
});
```

Grafana, Datadog 같은 모니터링 도구들이 이런 방식을 사용한다. 단방향 통신만 필요하고, 자동 재연결이 중요하기 때문이다.

### 온라인 게임

멀티플레이어 게임에서는 WebSocket이 필수다.

```javascript
class GameClient {
  constructor() {
    this.ws = new WebSocket('ws://game-server.com');
    this.latency = 0;
  }
  
  // 지연시간 측정
  measureLatency() {
    const start = Date.now();
    
    this.ws.send(JSON.stringify({
      type: 'ping',
      timestamp: start
    }));
    
    this.ws.addEventListener('message', (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'pong') {
        this.latency = Date.now() - data.timestamp;
        console.log(`Latency: ${this.latency}ms`);
      }
    });
  }
  
  // 플레이어 이동
  move(x, y) {
    this.ws.send(JSON.stringify({
      type: 'move',
      x, y,
      timestamp: Date.now()
    }));
  }
}
```

5ms 이하의 지연시간이 필요했는데, WebSocket으로만 달성할 수 있었다.

## 트러블슈팅

### WebSocket 연결이 자주 끊길 때

```javascript
class RobustWebSocket {
  constructor(url) {
    this.url = url;
    this.reconnectDelay = 1000;
    this.heartbeatInterval = 30000;
    this.connect();
  }
  
  connect() {
    this.ws = new WebSocket(this.url);
    
    this.ws.onopen = () => {
      console.log('Connected');
      this.reconnectDelay = 1000;
      this.startHeartbeat();
    };
    
    this.ws.onclose = () => {
      console.log('Disconnected');
      this.stopHeartbeat();
      this.reconnect();
    };
    
    this.ws.onerror = (error) => {
      console.error('Error:', error);
    };
  }
  
  reconnect() {
    setTimeout(() => {
      console.log('Reconnecting...');
      this.connect();
      this.reconnectDelay = Math.min(this.reconnectDelay * 2, 30000);
    }, this.reconnectDelay);
  }
  
  startHeartbeat() {
    this.heartbeatTimer = setInterval(() => {
      if (this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: 'ping' }));
      }
    }, this.heartbeatInterval);
  }
  
  stopHeartbeat() {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
    }
  }
}
```

### SSE가 작동하지 않을 때

```javascript
// nginx 설정 필요
// location /api/events {
//     proxy_pass http://backend;
//     proxy_buffering off;
//     proxy_cache off;
//     proxy_set_header Connection '';
//     proxy_http_version 1.1;
// }

// 서버에서 반드시 설정해야 할 헤더
res.writeHead(200, {
  'Content-Type': 'text/event-stream',
  'Cache-Control': 'no-cache',
  'Connection': 'keep-alive',
  'X-Accel-Buffering': 'no' // nginx용
});
```

### Long Polling 타임아웃 문제

```javascript
// 서버
app.get('/api/poll', (req, res) => {
  const timeout = setTimeout(() => {
    // 30초 후 빈 응답
    res.json({ data: null });
  }, 30000);
  
  // 새 데이터 발생 시
  eventEmitter.once('data', (data) => {
    clearTimeout(timeout);
    res.json({ data });
  });
  
  // 연결 끊김 처리
  req.on('close', () => {
    clearTimeout(timeout);
  });
});
```

## 보안 고려사항

### WebSocket 보안

```javascript
// 1. wss:// 사용 (암호화)
const ws = new WebSocket('wss://secure-server.com');

// 2. Origin 검증 (서버)
wss.on('connection', (ws, req) => {
  const origin = req.headers.origin;
  
  if (!isAllowedOrigin(origin)) {
    ws.close(1008, 'Unauthorized origin');
    return;
  }
});

// 3. 인증 토큰 사용
const ws = new WebSocket('wss://server.com?token=' + authToken);

// 또는 첫 메시지로 인증
ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    token: authToken
  }));
};
```

### SSE 보안

```javascript
// 인증이 필요한 SSE
const eventSource = new EventSource('/api/events', {
  withCredentials: true // 쿠키 포함
});

// 서버: 인증 확인
app.get('/api/events', authenticateUser, (req, res) => {
  if (!req.user) {
    return res.status(401).send('Unauthorized');
  }
  
  // SSE 시작
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    // ...
  });
});
```

## 마무리

세 가지 기술 모두 "실시간 통신"이라는 같은 목표를 가지고 있지만, 접근 방식이 완전히 다르다.

**Long Polling**은 가장 단순하지만 비효율적이다. 호환성이 중요하거나 업데이트가 드문 경우에만 사용하자.

**SSE**는 서버에서 클라이언트로 데이터를 푸시하는 용도로 완벽하다. 구현도 쉽고 자동 재연결도 지원한다. 뉴스 피드나 알림 같은 단방향 통신에 최적이다.

**WebSocket**은 진짜 실시간 양방향 통신이 필요할 때 사용한다. 채팅, 게임, 협업 도구처럼 지연시간이 중요하고 양쪽에서 데이터를 주고받아야 하는 경우에 적합하다.

결국 "어떤 게 제일 좋은가?"라는 질문에 대한 답은 "상황에 따라 다르다"이다. 프로젝트의 요구사항을 정확히 파악하고, 각 기술의 장단점을 이해한 후 선택해야 한다.

처음에는 간단한 걸로 시작해서, 필요할 때 더 복잡한 솔루션으로 넘어가는 것도 좋은 전략이다. SSE로 시작했다가 나중에 WebSocket으로 전환하는 것도 충분히 가능하다.

중요한 건 기술 그 자체가 아니라, 사용자에게 좋은 경험을 제공하는 것이다.

