---
title: "알고리즘의 현실적 적용"
tags: 알고리즘, 실무, 검색엔진, 추천시스템, 암호화, 네비게이션
date: "2025.09.19"
categories: 
    - Algorithm
---

# 알고리즘의 현실적 적용

알고리즘을 배울 때 "이걸 언제 써먹지?"라는 생각이 들 때가 있다. 이론적인 지식이라고 생각하기 쉽지만, 알고리즘은 우리가 매일 사용하는 서비스들 속에 숨어있다.

구글이 검색 결과를 어떻게 정렬하는지, 넷플릭스가 영화를 어떻게 추천하는지, 카카오맵이 최단 경로를 어떻게 찾는지... 이 모든 것들이 알고리즘의 결과다.

오늘은 실무에서 실제로 사용되는 알고리즘들을 살펴보자.

## 검색엔진의 알고리즘 - PageRank

구글에서 "알고리즘"을 검색하면 수많은 결과가 나온다. 하지만 왜 특정 결과가 맨 위에 나타날까?

### PageRank의 핵심 아이디어

PageRank는 구글의 창립자 래리 페이지가 개발한 알고리즘이다. 웹페이지의 중요도를 측정하는 방법이다.

**기본 원리:**
1. 링크를 받는 페이지는 더 중요하다
2. 중요한 페이지에서 오는 링크는 더 가치가 있다
3. 링크의 수뿐만 아니라 품질도 중요하다

### 수학적 원리

```
PageRank(P) = (1-d)/N + d × Σ(PageRank(T)/C(T))
```

- P: 현재 페이지
- T: P로 링크하는 페이지들
- C(T): T에서 나가는 링크의 수
- d: 감쇠 인수 (보통 0.85)
- N: 전체 웹페이지 수

### 실무에서의 적용

```javascript
// 간단한 PageRank 구현 예시
class PageRankCalculator {
    constructor() {
        this.DAMPING_FACTOR = 0.85;
    }
    
    calculatePageRank(links) {
        let pageRank = {};
        const totalPages = Object.keys(links).length;
        
        // 초기값 설정
        for (const page of Object.keys(links)) {
            pageRank[page] = 1.0 / totalPages;
        }
        
        // 반복 계산 (수렴할 때까지)
        for (let i = 0; i < 100; i++) {
            const newPageRank = {};
            
            for (const page of Object.keys(links)) {
                let rank = (1 - this.DAMPING_FACTOR) / totalPages;
                
                // 이 페이지로 링크하는 모든 페이지들 확인
                for (const linkingPage of Object.keys(links)) {
                    if (links[linkingPage].includes(page)) {
                        rank += this.DAMPING_FACTOR * 
                               (pageRank[linkingPage] / links[linkingPage].length);
                    }
                }
                newPageRank[page] = rank;
            }
            pageRank = newPageRank;
        }
        
        return pageRank;
    }
}

// 사용 예시
const links = {
    'A': ['B', 'C'],
    'B': ['C'],
    'C': ['A']
};

const calculator = new PageRankCalculator();
const pageRank = calculator.calculatePageRank(links);
console.log(pageRank);
```

## 추천 시스템의 알고리즘

넷플릭스, 유튜브, 쇼핑몰... 모든 곳에서 추천 시스템을 사용한다. 어떻게 우리가 좋아할 만한 콘텐츠를 찾아낼까?

### 협업 필터링 (Collaborative Filtering)

**아이디어:** 비슷한 취향을 가진 사용자들의 행동을 분석한다.

```javascript
// 간단한 협업 필터링 예시
class CollaborativeFiltering {
    constructor() {
        this.ratings = [];
    }
    
    // 사용자 간 유사도 계산 (코사인 유사도)
    calculateSimilarity(userId, otherUserId) {
        const userRatings = this.ratings[userId];
        const otherUserRatings = this.ratings[otherUserId];
        
        // 공통으로 평가한 아이템들 찾기
        const commonItems = [];
        for (let i = 0; i < userRatings.length; i++) {
            if (userRatings[i] !== 0 && otherUserRatings[i] !== 0) {
                commonItems.push(i);
            }
        }
        
        if (commonItems.length === 0) return 0;
        
        // 코사인 유사도 계산
        let dotProduct = 0;
        let userNorm = 0;
        let otherNorm = 0;
        
        for (const item of commonItems) {
            dotProduct += userRatings[item] * otherUserRatings[item];
            userNorm += userRatings[item] * userRatings[item];
            otherNorm += otherUserRatings[item] * otherUserRatings[item];
        }
        
        userNorm = Math.sqrt(userNorm);
        otherNorm = Math.sqrt(otherNorm);
        
        if (userNorm === 0 || otherNorm === 0) return 0;
        
        return dotProduct / (userNorm * otherNorm);
    }
    
    // 추천 점수 예측
    predictRating(userId, itemId) {
        const similarities = [];
        
        // 다른 사용자들과의 유사도 계산
        for (let otherUserId = 0; otherUserId < this.ratings.length; otherUserId++) {
            if (otherUserId !== userId) {
                const similarity = this.calculateSimilarity(userId, otherUserId);
                similarities.push({ userId: otherUserId, similarity });
            }
        }
        
        // 유사한 사용자들의 평점으로 예측
        let weightedSum = 0;
        let similaritySum = 0;
        
        for (const { userId: otherUserId, similarity } of similarities) {
            if (this.ratings[otherUserId][itemId] !== 0) {
                weightedSum += similarity * this.ratings[otherUserId][itemId];
                similaritySum += Math.abs(similarity);
            }
        }
        
        return similaritySum > 0 ? weightedSum / similaritySum : 0;
    }
}

// 사용 예시
const cf = new CollaborativeFiltering();
cf.ratings = [
    [5, 3, 0, 1],  // 사용자 0
    [4, 0, 0, 1],  // 사용자 1
    [1, 1, 0, 5],  // 사용자 2
    [1, 0, 0, 4]   // 사용자 3
];

const prediction = cf.predictRating(0, 2); // 사용자 0이 아이템 2에 줄 예상 평점
console.log('예상 평점:', prediction);
```

### 콘텐츠 기반 필터링

**아이디어:** 아이템의 특성을 분석해서 비슷한 아이템을 추천한다.

```javascript
// 콘텐츠 기반 필터링 예시
class ContentBasedFiltering {
    constructor() {
        this.itemFeatures = new Map();
        this.userPreferences = new Map();
    }
    
    // 아이템의 특성 벡터 생성
    createItemFeatures(item) {
        const features = {
            genre: item.genre,
            director: item.director,
            year: item.year,
            rating: item.rating,
            duration: item.duration
        };
        this.itemFeatures.set(item.id, features);
    }
    
    // 사용자 선호도 학습
    updateUserPreferences(userId, itemId, rating) {
        if (!this.userPreferences.has(userId)) {
            this.userPreferences.set(userId, {});
        }
        
        const itemFeatures = this.itemFeatures.get(itemId);
        const userPrefs = this.userPreferences.get(userId);
        
        // 가중치 업데이트
        for (const [feature, value] of Object.entries(itemFeatures)) {
            if (!userPrefs[feature]) {
                userPrefs[feature] = 0;
            }
            userPrefs[feature] += rating * value;
        }
    }
    
    // 추천 점수 계산
    calculateRecommendationScore(userId, itemId) {
        const userPrefs = this.userPreferences.get(userId);
        const itemFeatures = this.itemFeatures.get(itemId);
        
        if (!userPrefs || !itemFeatures) return 0;
        
        let score = 0;
        let totalWeight = 0;
        
        for (const [feature, value] of Object.entries(itemFeatures)) {
            if (userPrefs[feature]) {
                score += userPrefs[feature] * value;
                totalWeight += Math.abs(userPrefs[feature]);
            }
        }
        
        return totalWeight > 0 ? score / totalWeight : 0;
    }
}
```

## 암호화 알고리즘 - HTTPS의 보안

웹사이트에 접속할 때 주소창에 자물쇠 아이콘이 보인다. 이는 HTTPS를 사용한다는 의미다. 어떻게 안전한 통신을 보장할까?

### RSA 암호화 알고리즘

**핵심 아이디어:** 큰 수의 소인수분해는 매우 어렵다는 수학적 원리

```javascript
// 간단한 RSA 구현 예시 (큰 수 처리를 위한 라이브러리 필요)
class RSAExample {
    constructor() {
        this.n = null;
        this.e = null;
        this.d = null;
    }
    
    // 키 생성 (실제로는 큰 수 라이브러리 필요)
    generateKeys() {
        // 실제 구현에서는 큰 수 라이브러리 (예: BigInt.js) 사용
        // 여기서는 간단한 예시만 보여줌
        
        // 두 개의 소수 선택 (실제로는 더 큰 수 사용)
        const p = 61n;
        const q = 53n;
        
        // n = p * q
        this.n = p * q;
        
        // φ(n) = (p-1) * (q-1)
        const phi = (p - 1n) * (q - 1n);
        
        // 공개키 e 선택 (보통 65537)
        this.e = 65537n;
        
        // 개인키 d 계산: e * d ≡ 1 (mod φ(n))
        this.d = this.modInverse(this.e, phi);
    }
    
    // 모듈러 역원 계산 (확장 유클리드 알고리즘)
    modInverse(a, m) {
        let [g, x] = this.extendedGcd(a, m);
        if (g !== 1n) {
            throw new Error('Modular inverse does not exist');
        }
        return ((x % m) + m) % m;
    }
    
    // 확장 유클리드 알고리즘
    extendedGcd(a, b) {
        if (a === 0n) {
            return [b, 0n, 1n];
        }
        const [g, x1, y1] = this.extendedGcd(b % a, a);
        const x = y1 - (b / a) * x1;
        const y = x1;
        return [g, x, y];
    }
    
    // 거듭제곱 (모듈러 연산)
    modPow(base, exponent, modulus) {
        let result = 1n;
        base = base % modulus;
        
        while (exponent > 0n) {
            if (exponent % 2n === 1n) {
                result = (result * base) % modulus;
            }
            exponent = exponent >> 1n;
            base = (base * base) % modulus;
        }
        
        return result;
    }
    
    // 암호화
    encrypt(message) {
        const messageBigInt = BigInt(message);
        return this.modPow(messageBigInt, this.e, this.n);
    }
    
    // 복호화
    decrypt(encryptedMessage) {
        return this.modPow(encryptedMessage, this.d, this.n);
    }
}

// 사용 예시
const rsa = new RSAExample();
rsa.generateKeys();

const message = 42n;
const encrypted = rsa.encrypt(message);
const decrypted = rsa.decrypt(encrypted);

console.log('원본 메시지:', message);
console.log('암호화된 메시지:', encrypted);
console.log('복호화된 메시지:', decrypted);
```

### 실무에서의 적용

```javascript
// HTTPS에서의 실제 사용
class HTTPSExample {
    constructor() {
        this.rsa = new RSAExample();
        this.rsa.generateKeys();
    }
    
    // 클라이언트-서버 통신 시뮬레이션
    simulateHTTPSCommunication() {
        // 1. 클라이언트가 서버에 연결 요청
        console.log("클라이언트: 서버에 연결 요청");
        
        // 2. 서버가 공개키 전송
        console.log("서버: 공개키 전송");
        
        // 3. 클라이언트가 대칭키를 공개키로 암호화
        const symmetricKey = "MySecretKey123";
        const encryptedKey = this.rsa.encrypt(
            this.rsa.stringToBigInteger(symmetricKey)
        );
        
        // 4. 암호화된 대칭키를 서버에 전송
        console.log("클라이언트: 암호화된 대칭키 전송");
        
        // 5. 서버가 개인키로 복호화
        const decryptedKey = this.rsa.bigIntegerToString(
            this.rsa.decrypt(encryptedKey)
        );
        
        // 6. 이후 대칭키로 통신
        console.log("서버: 대칭키 복호화 완료");
        console.log("이제 대칭키로 안전한 통신 시작");
    }
}
```

## 네비게이션 앱의 최단 경로 알고리즘

카카오맵, 구글맵에서 최단 경로를 찾는 방법은 무엇일까?

### 다익스트라 알고리즘

**핵심 아이디어:** 시작점에서 모든 점까지의 최단 거리를 순차적으로 찾는다.

```javascript
class DijkstraAlgorithm {
    constructor() {
        this.graph = {};
    }
    
    // 그래프 구성
    addEdge(start, end, weight) {
        if (!this.graph[start]) {
            this.graph[start] = {};
        }
        if (!this.graph[end]) {
            this.graph[end] = {};
        }
        
        this.graph[start][end] = weight;
        this.graph[end][start] = weight;
    }
    
    // 다익스트라 알고리즘 구현
    dijkstra(start) {
        const distances = {};
        const previous = {};
        const queue = [];
        
        // 초기화
        for (const node of Object.keys(this.graph)) {
            distances[node] = Infinity;
            previous[node] = null;
        }
        distances[start] = 0;
        queue.push({ node: start, distance: 0 });
        
        while (queue.length > 0) {
            // 가장 가까운 노드 선택
            queue.sort((a, b) => a.distance - b.distance);
            const { node: current, distance } = queue.shift();
            
            // 이미 처리된 노드는 건너뛰기
            if (distance > distances[current]) {
                continue;
            }
            
            // 인접 노드들 확인
            for (const neighbor of Object.keys(this.graph[current])) {
                const newDistance = distance + this.graph[current][neighbor];
                
                if (newDistance < distances[neighbor]) {
                    distances[neighbor] = newDistance;
                    previous[neighbor] = current;
                    queue.push({ node: neighbor, distance: newDistance });
                }
            }
        }
        
        return { distances, previous };
    }
    
    // 경로 복원
    reconstructPath(previous, start, end) {
        const path = [];
        let current = end;
        
        while (current) {
            path.unshift(current);
            current = previous[current];
        }
        
        return path;
    }
    
    // 최단 경로 찾기
    findShortestPath(start, end) {
        const { distances, previous } = this.dijkstra(start);
        const path = this.reconstructPath(previous, start, end);
        
        return {
            path: path,
            distance: distances[end]
        };
    }
}

// 실무에서의 적용 예시
class NavigationSystem {
    constructor() {
        this.dijkstra = new DijkstraAlgorithm();
        this.trafficData = {};
    }
    
    // 도로 그래프 구성
    buildRoadGraph(trafficData) {
        for (const road of trafficData) {
            const { start, end, distance, trafficFactor } = road;
            // 실제 소요 시간 = 거리 + 교통량 지연
            const actualTime = distance + (trafficFactor || 0);
            
            this.dijkstra.addEdge(start, end, actualTime);
        }
    }
    
    // 최단 경로 찾기
    findOptimalRoute(start, end) {
        return this.dijkstra.findShortestPath(start, end);
    }
    
    // 교통 정보 업데이트
    updateTrafficData(roadId, trafficFactor) {
        this.trafficData[roadId] = trafficFactor;
        // 그래프 재구성
        this.rebuildGraph();
    }
    
    rebuildGraph() {
        // 교통 정보를 반영하여 그래프 재구성
        const roads = [
            { start: '서울역', end: '강남역', distance: 30, trafficFactor: this.trafficData['road1'] || 0 },
            { start: '강남역', end: '잠실역', distance: 25, trafficFactor: this.trafficData['road2'] || 0 },
            { start: '서울역', end: '잠실역', distance: 45, trafficFactor: this.trafficData['road3'] || 0 }
        ];
        
        this.dijkstra = new DijkstraAlgorithm();
        this.buildRoadGraph(roads);
    }
}

// 사용 예시
const nav = new NavigationSystem();

// 초기 도로 정보 설정
const roads = [
    { start: '서울역', end: '강남역', distance: 30, trafficFactor: 0 },
    { start: '강남역', end: '잠실역', distance: 25, trafficFactor: 0 },
    { start: '서울역', end: '잠실역', distance: 45, trafficFactor: 0 }
];

nav.buildRoadGraph(roads);
const route = nav.findOptimalRoute('서울역', '잠실역');

console.log('최적 경로:', route.path);
console.log('예상 시간:', route.distance, '분');
```

### 실시간 경로 최적화

```javascript
// 실시간 교통 정보를 반영한 경로 최적화
class RealTimeNavigation {
    constructor() {
        this.trafficData = new Map();
        this.routeCache = new Map();
    }
    
    // 교통 정보 업데이트
    updateTrafficData(roadId, congestionLevel) {
        this.trafficData.set(roadId, congestionLevel);
        // 캐시 무효화
        this.routeCache.clear();
    }
    
    // 최적 경로 찾기
    findOptimalRoute(start, end) {
        const cacheKey = `${start}-${end}`;
        
        // 캐시 확인
        if (this.routeCache.has(cacheKey)) {
            return this.routeCache.get(cacheKey);
        }
        
        // 실시간 교통 정보를 반영한 그래프 구성
        const graph = this.buildGraphWithTraffic();
        
        // 다익스트라 알고리즘으로 최단 경로 계산
        const route = this.dijkstra(graph, start, end);
        
        // 캐시 저장
        this.routeCache.set(cacheKey, route);
        
        return route;
    }
    
    // 교통량을 고려한 그래프 구성
    buildGraphWithTraffic() {
        const graph = {};
        
        // 기본 도로 정보
        const roads = [
            { id: 'A', start: '서울역', end: '강남역', baseTime: 30 },
            { id: 'B', start: '강남역', end: '잠실역', baseTime: 25 },
            { id: 'C', start: '서울역', end: '잠실역', baseTime: 45 },
            // ... 더 많은 도로들
        ];
        
        for (const road of roads) {
            const trafficLevel = this.trafficData.get(road.id) || 1;
            const actualTime = road.baseTime * trafficLevel;
            
            if (!graph[road.start]) graph[road.start] = {};
            if (!graph[road.end]) graph[road.end] = {};
            
            graph[road.start][road.end] = actualTime;
            graph[road.end][road.start] = actualTime;
        }
        
        return graph;
    }
    
    // 다익스트라 알고리즘 구현
    dijkstra(graph, start, end) {
        const distances = {};
        const previous = {};
        const queue = [];
        
        // 초기화
        for (const node in graph) {
            distances[node] = Infinity;
            previous[node] = null;
        }
        distances[start] = 0;
        queue.push({ node: start, distance: 0 });
        
        while (queue.length > 0) {
            // 가장 가까운 노드 선택
            queue.sort((a, b) => a.distance - b.distance);
            const { node: current, distance } = queue.shift();
            
            if (current === end) break;
            
            // 인접 노드들 확인
            for (const neighbor in graph[current]) {
                const newDistance = distance + graph[current][neighbor];
                
                if (newDistance < distances[neighbor]) {
                    distances[neighbor] = newDistance;
                    previous[neighbor] = current;
                    queue.push({ node: neighbor, distance: newDistance });
                }
            }
        }
        
        // 경로 복원
        const path = [];
        let current = end;
        while (current) {
            path.unshift(current);
            current = previous[current];
        }
        
        return {
            path: path,
            totalTime: distances[end]
        };
    }
}
```

## 알고리즘의 실무적 가치

### 성능 최적화

```javascript
// 데이터베이스 쿼리 최적화 예시
class QueryOptimizer {
    
    // 인덱스 활용 최적화
    findUsersByAgeRange(minAge, maxAge) {
        // 나쁜 예: 전체 테이블 스캔
        // SELECT * FROM users WHERE age >= ? AND age <= ?
        
        // 좋은 예: 인덱스 활용
        // CREATE INDEX idx_age ON users(age);
        // SELECT * FROM users WHERE age >= ? AND age <= ?;
        
        return this.userRepository.findByAgeBetween(minAge, maxAge);
    }
    
    // 조인 최적화
    findOrdersWithUsers() {
        // 나쁜 예: N+1 쿼리 문제
        // const orders = orderRepository.findAll();
        // for (const order of orders) {
        //     const user = userRepository.findById(order.userId);
        //     order.user = user;
        // }
        
        // 좋은 예: 한 번의 쿼리로 해결
        return this.orderRepository.findAllWithUsers();
    }
}

// 메모리 효율적인 데이터 처리
class MemoryEfficientProcessor {
    
    // 메모리 효율적인 데이터 처리
    processLargeDataset(filePath) {
        // 나쁜 예: 전체 데이터를 메모리에 로드
        // const data = fs.readFileSync(filePath, 'utf8').split('\n');
        // data.forEach(line => this.processLine(line));
        
        // 좋은 예: 스트리밍 방식으로 처리
        const fs = require('fs');
        const readline = require('readline');
        
        const fileStream = fs.createReadStream(filePath);
        const rl = readline.createInterface({
            input: fileStream,
            crlfDelay: Infinity
        });
        
        rl.on('line', (line) => {
            this.processLine(line);
        });
        
        rl.on('close', () => {
            console.log('파일 처리 완료');
        });
    }
    
    processLine(line) {
        // 각 줄에 대한 처리 로직
        const data = line.trim().split(',');
        // ... 처리 로직
        return data;
    }
}

// 캐싱을 활용한 성능 최적화
class CacheOptimizer {
    constructor() {
        this.cache = new Map();
        this.maxCacheSize = 1000;
    }
    
    // 메모이제이션을 활용한 피보나치
    fibonacci(n) {
        if (this.cache.has(n)) {
            return this.cache.get(n);
        }
        
        let result;
        if (n <= 1) {
            result = n;
        } else {
            result = this.fibonacci(n - 1) + this.fibonacci(n - 2);
        }
        
        // 캐시 크기 제한
        if (this.cache.size >= this.maxCacheSize) {
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        
        this.cache.set(n, result);
        return result;
    }
    
    // LRU 캐시 구현
    set(key, value) {
        if (this.cache.has(key)) {
            this.cache.delete(key);
        } else if (this.cache.size >= this.maxCacheSize) {
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        
        this.cache.set(key, value);
    }
    
    get(key) {
        if (this.cache.has(key)) {
            const value = this.cache.get(key);
            this.cache.delete(key);
            this.cache.set(key, value);
            return value;
        }
        return null;
    }
}
```

## 마무리

알고리즘은 단순히 코딩테스트를 위한 지식이 아니다. 실무에서 만나는 문제들을 해결하는 핵심 도구다.

검색엔진의 PageRank, 추천 시스템의 협업 필터링, HTTPS의 RSA 암호화, 네비게이션의 다익스트라 알고리즘... 이 모든 것들이 우리 일상생활을 편리하게 만들어주는 알고리즘들이다.

알고리즘을 배우는 진짜 이유는 문제를 효율적으로 해결하는 사고방식을 기르는 것이다. 복잡한 문제를 단계별로 분해하고, 최적의 해결책을 찾는 능력이야말로 개발자에게 가장 중요한 역량이다.

