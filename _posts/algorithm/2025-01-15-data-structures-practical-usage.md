---
title: "자료구조 실전 활용법"
date: 2025-01-15
categories: Algorithm
tags: [data-structure, algorithm, practical, java, javascript, 실무활용]
author: pitbull terrier
---

# 자료구조 실전 활용법

자료구조를 처음 배울 때는 그냥 외우기만 했다. "배열, 리스트, 스택, 큐..." 하지만 실제 개발을 하다 보니 언제 어떤 걸 써야 할지 모르겠더라.

오늘은 실무에서 정말 많이 쓰이는 자료구조들과 활용법을 정리해보겠다.

## 배열(Array)

배열은 가장 기본이지만 가장 강력한 자료구조다. 잘못 쓰면 성능이 엄청 떨어진다.

### 자주 하는 실수

```java
// 나쁜 예시
public int[] processData(int[] input) {
    int[] result = new int[input.length];
    
    for (int i = 0; i < input.length; i++) {
        result[i] = input[i] * 2 + 10;
    }
    
    return result;
}

// 좋은 예시
public List<Integer> processDataOptimized(List<Integer> input) {
    List<Integer> result = new ArrayList<>();
    
    for (Integer value : input) {
        result.add(value * 2 + 10);
    }
    
    return result;
}
```

### 활용

상품 목록 관리 시스템에서 배열을 활용한 예시다.

```java
// 상품 검색 결과를 효율적으로 관리
public class ProductManager {
    private Product[] products;
    private int size;
    
    // 효율적인 검색을 위한 정렬된 배열 유지
    public void addProduct(Product product) {
        if (size >= products.length) {
            resize();
        }
        
        // 삽입 정렬로 정렬 상태 유지
        int insertIndex = findInsertPosition(product);
        shiftElements(insertIndex);
        products[insertIndex] = product;
        size++;
    }
    
    // 이진 탐색으로 빠른 검색
    public Product findProduct(String productId) {
        int left = 0, right = size - 1;
        
        while (left <= right) {
            int mid = left + (right - left) / 2;
            int comparison = products[mid].getId().compareTo(productId);
            
            if (comparison == 0) {
                return products[mid];
            } else if (comparison < 0) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        
        return null;
    }
}
```

**배열을 선택한 이유:**
- **메모리 효율성**: 연속된 메모리 공간 사용으로 오버헤드 최소화
- **캐시 지역성**: CPU가 연속된 메모리를 미리 로드해서 접근 속도 향상
- **이진 탐색 가능**: 정렬된 상태를 유지하면 O(log n) 검색 가능

**배열의 한계:**
- 크기가 고정되어 있어 동적 확장이 어려움
- 중간 삽입/삭제 시 모든 요소를 이동해야 함
- 메모리 낭비 가능성 (사용하지 않는 공간)

## 리스트(List)

ArrayList vs LinkedList, 언제 뭘 써야 할까? 처음에는 ArrayList만 썼는데, 규모가 커지면서 LinkedList의 필요성을 느꼈다.

```java
// 1. ArrayList - 조회가 많은 경우
public class UserRepository {
    private List<User> users = new ArrayList<>();
    
    // 자주 호출되는 메서드
    public User findUserById(int id) {
        // ArrayList는 인덱스 접근이 O(1)
        if (id >= 0 && id < users.size()) {
            return users.get(id);
        }
        return null;
    }
    
    // 사용자 목록 조회 (자주 호출됨)
    public List<User> getAllUsers() {
        return new ArrayList<>(users); // 방어적 복사
    }
}

// 2. LinkedList - 삽입/삭제가 많은 경우
public class MessageQueue {
    private LinkedList<Message> messages = new LinkedList<>();
    
    // 메시지 추가 (많이 발생)
    public void addMessage(Message message) {
        messages.addLast(message); // O(1)
    }
    
    // 메시지 처리 (많이 발생)
    public Message getNextMessage() {
        return messages.pollFirst(); // O(1)
    }
    
    // 큐 크기 제한
    public void addMessageWithLimit(Message message, int maxSize) {
        messages.addLast(message);
        
        while (messages.size() > maxSize) {
            messages.removeFirst(); // 오래된 메시지 제거
        }
    }
}
```

### 언제 뭘 써야 할까?

**ArrayList 사용하는 경우:**
- 조회가 삽입/삭제보다 훨씬 많은 경우 (8:2 비율 이상)
- 인덱스로 직접 접근하는 경우가 많은 경우
- 메모리 사용량이 중요한 경우
- 순차 접근이 대부분인 경우

**LinkedList 사용하는 경우:**
- 중간에 삽입/삭제가 자주 발생하는 경우
- 큐나 스택의 구현체로 사용하는 경우
- 크기가 자주 변하고 예측하기 어려운 경우
- 앞쪽에서 삽입/삭제가 많은 경우

### 실제 성능 차이

```java
// 10만 개 데이터로 테스트한 결과
List<Integer> arrayList = new ArrayList<>();
List<Integer> linkedList = new LinkedList<>();

// 중간 삽입 테스트
long start = System.nanoTime();
for (int i = 0; i < 100000; i++) {
    arrayList.add(arrayList.size() / 2, i); // ArrayList: ~2초
}
long arrayTime = System.nanoTime() - start;

start = System.nanoTime();
for (int i = 0; i < 100000; i++) {
    linkedList.add(linkedList.size() / 2, i); // LinkedList: ~0.1초
}
long linkedTime = System.nanoTime() - start;

System.out.println("ArrayList 중간삽입: " + arrayTime / 1_000_000 + "ms");
System.out.println("LinkedList 중간삽입: " + linkedTime / 1_000_000 + "ms");
```

**결과**: LinkedList가 약 20배 빠름!

## 스택(Stack)

스택은 LIFO(Last In, First Out) 구조로, 가장 최근에 들어온 데이터가 가장 먼저 나간다. 웹 애플리케이션의 네비게이션 히스토리, 함수 호출, 괄호 매칭 등에 활용된다.

```javascript
class NavigationManager {
    constructor() {
        this.history = [];
        this.currentIndex = -1;
    }
    
    // 페이지 이동
    navigateTo(url) {
        // 현재 위치 이후의 히스토리 제거
        this.history = this.history.slice(0, this.currentIndex + 1);
        
        // 새 페이지 추가
        this.history.push(url);
        this.currentIndex++;
        
        this.loadPage(url);
    }
    
    // 뒤로가기
    goBack() {
        if (this.currentIndex > 0) {
            this.currentIndex--;
            const url = this.history[this.currentIndex];
            this.loadPage(url);
            return true;
        }
        return false;
    }
    
    // 앞으로가기
    goForward() {
        if (this.currentIndex < this.history.length - 1) {
            this.currentIndex++;
            const url = this.history[this.currentIndex];
            this.loadPage(url);
            return true;
        }
        return false;
    }
    
    loadPage(url) {
        // 실제 페이지 로딩 로직
        console.log(`Loading: ${url}`);
    }
}

// 사용 예시
const nav = new NavigationManager();
nav.navigateTo('/home');
nav.navigateTo('/products');
nav.navigateTo('/cart');

nav.goBack(); // '/products'로 이동
nav.goBack(); // '/home'으로 이동
nav.goForward(); // '/products'로 이동
```

### 괄호 매칭 검사기

코드 리뷰 도구에서 괄호 매칭을 검사하는 기능을 구현할 때도 스택을 사용했다.

```java
public class BracketValidator {
    private static final Map<Character, Character> BRACKET_PAIRS = Map.of(
        '(', ')',
        '[', ']',
        '{', '}'
    );
    
    public boolean isValid(String code) {
        Stack<Character> stack = new Stack<>();
        
        for (char c : code.toCharArray()) {
            if (isOpenBracket(c)) {
                stack.push(c);
            } else if (isCloseBracket(c)) {
                if (stack.isEmpty() || !isMatchingPair(stack.pop(), c)) {
                    return false;
                }
            }
        }
        
        return stack.isEmpty();
    }
    
    private boolean isOpenBracket(char c) {
        return BRACKET_PAIRS.containsKey(c);
    }
    
    private boolean isCloseBracket(char c) {
        return BRACKET_PAIRS.containsValue(c);
    }
    
    private boolean isMatchingPair(char open, char close) {
        return BRACKET_PAIRS.get(open) == close;
    }
}

// 사용 예시
BracketValidator validator = new BracketValidator();
System.out.println(validator.isValid("(a + b) * [c - d]")); // true
System.out.println(validator.isValid("(a + b) * [c - d")); // false
System.out.println(validator.isValid("((a + b) * [c - d])")); // true
```

### 스택 활용 팁

**언제 스택을 사용해야 할까?**
- 되돌리기(Undo) 기능이 필요한 경우
- 함수 호출 스택처럼 중첩된 구조를 처리할 때
- 괄호, 태그 매칭 검사
- 계산기 구현 (후위 표기법)
- 깊이 우선 탐색(DFS) 구현

**스택 구현 시 주의사항:**
- 스택 오버플로우 방지 (재귀 호출 깊이 제한)
- 빈 스택에서 pop() 호출 시 예외 처리
- 스택 크기 제한 설정 (메모리 보호)

## 큐(Queue)

큐는 FIFO(First In, First Out) 구조로, 먼저 들어온 데이터가 먼저 나간다. 대기열, 작업 스케줄링, BFS 알고리즘 등에 활용된다.

이메일 발송 시스템을 구현할 때 큐를 사용했다. 수만 명에게 이메일을 보내야 하는데, 한 번에 보내면 서버가 터진다.

```java
@Service
public class EmailQueueService {
    private final Queue<EmailTask> emailQueue = new ConcurrentLinkedQueue<>();
    private final ExecutorService executorService = Executors.newFixedThreadPool(5);
    private volatile boolean isProcessing = false;
    
    // 이메일 발송 요청
    public void sendEmail(String to, String subject, String content) {
        EmailTask task = new EmailTask(to, subject, content);
        emailQueue.offer(task);
        
        // 큐가 비어있었다면 처리 시작
        if (!isProcessing) {
            startProcessing();
        }
    }
    
    // 대량 이메일 발송
    public void sendBulkEmails(List<EmailTask> tasks) {
        emailQueue.addAll(tasks);
        
        if (!isProcessing) {
            startProcessing();
        }
    }
    
    private void startProcessing() {
        isProcessing = true;
        
        executorService.submit(() -> {
            while (!emailQueue.isEmpty()) {
                EmailTask task = emailQueue.poll();
                if (task != null) {
                    try {
                        sendEmailTask(task);
                        Thread.sleep(100); // API 제한 고려
                    } catch (Exception e) {
                        // 실패한 작업을 다시 큐에 추가
                        emailQueue.offer(task);
                        log.error("이메일 발송 실패: {}", e.getMessage());
                    }
                }
            }
            isProcessing = false;
        });
    }
    
    private void sendEmailTask(EmailTask task) {
        // 실제 이메일 발송 로직
        System.out.println("Sending email to: " + task.getTo());
    }
}
```

### BFS로 최단 경로 찾기

게임에서 플레이어가 목표 지점까지 가는 최단 경로를 찾는 알고리즘이다.

```java
public class PathFinder {
    private static final int[][] DIRECTIONS = {
        {-1, 0}, {1, 0}, {0, -1}, {0, 1} // 상하좌우
    };
    
    public List<Point> findShortestPath(int[][] map, Point start, Point end) {
        int rows = map.length;
        int cols = map[0].length;
        
        // 방문 여부와 부모 노드 추적
        boolean[][] visited = new boolean[rows][cols];
        Point[][] parent = new Point[rows][cols];
        
        Queue<Point> queue = new LinkedList<>();
        queue.offer(start);
        visited[start.x][start.y] = true;
        
        while (!queue.isEmpty()) {
            Point current = queue.poll();
            
            // 목표 지점에 도달
            if (current.equals(end)) {
                return reconstructPath(parent, start, end);
            }
            
            // 4방향 탐색
            for (int[] direction : DIRECTIONS) {
                int newX = current.x + direction[0];
                int newY = current.y + direction[1];
                
                // 유효한 좌표이고, 벽이 아니며, 방문하지 않은 경우
                if (isValid(newX, newY, rows, cols) && 
                    map[newX][newY] != 1 && 
                    !visited[newX][newY]) {
                    
                    Point next = new Point(newX, newY);
                    queue.offer(next);
                    visited[newX][newY] = true;
                    parent[newX][newY] = current;
                }
            }
        }
        
        return null; // 경로를 찾을 수 없음
    }
    
    private List<Point> reconstructPath(Point[][] parent, Point start, Point end) {
        List<Point> path = new ArrayList<>();
        Point current = end;
        
        while (current != null) {
            path.add(current);
            current = parent[current.x][current.y];
        }
        
        Collections.reverse(path);
        return path;
    }
    
    private boolean isValid(int x, int y, int rows, int cols) {
        return x >= 0 && x < rows && y >= 0 && y < cols;
    }
}

// 사용 예시
int[][] map = {
    {0, 0, 1, 0, 0},
    {0, 0, 0, 0, 1},
    {1, 1, 0, 1, 0},
    {0, 0, 0, 0, 0}
};

PathFinder finder = new PathFinder();
Point start = new Point(0, 0);
Point end = new Point(3, 4);

List<Point> path = finder.findShortestPath(map, start, end);
if (path != null) {
    System.out.println("최단 경로: " + path);
} else {
    System.out.println("경로를 찾을 수 없습니다.");
}
```

### 큐 활용 팁

**큐의 종류와 특징:**
- **일반 큐**: 기본 FIFO 구조
- **우선순위 큐**: 우선순위가 높은 요소가 먼저 나감
- **덱(Deque)**: 양쪽 끝에서 삽입/삭제 가능
- **원형 큐**: 고정 크기에서 메모리 효율적

**큐 사용 시 주의사항:**
- 큐 크기 제한 설정 (메모리 오버플로우 방지)
- 동시성 환경에서는 thread-safe 큐 사용
- 큐가 비어있을 때 처리 로직 필요
- 우선순위 큐는 정렬 기준이 중요

## 해시맵(HashMap)

해시맵은 키-값 쌍을 저장하는 자료구조로, 평균 O(1) 시간에 검색, 삽입, 삭제가 가능하다. 캐싱, 인덱싱, 빈도 계산 등에 활용된다.

자주 조회되는 데이터를 캐싱하는 시스템을 구현했다.

```java
@Component
public class CacheManager {
    private final Map<String, CacheEntry> cache = new ConcurrentHashMap<>();
    private final int maxSize;
    private final long expirationTime;
    
    public CacheManager(int maxSize, long expirationTime) {
        this.maxSize = maxSize;
        this.expirationTime = expirationTime;
    }
    
    // 캐시에서 데이터 조회
    public <T> T get(String key, Class<T> type) {
        CacheEntry entry = cache.get(key);
        
        if (entry == null) {
            return null;
        }
        
        // 만료 시간 체크
        if (System.currentTimeMillis() - entry.getTimestamp() > expirationTime) {
            cache.remove(key);
            return null;
        }
        
        return type.cast(entry.getData());
    }
    
    // 캐시에 데이터 저장
    public void put(String key, Object data) {
        // 캐시 크기 제한
        if (cache.size() >= maxSize && !cache.containsKey(key)) {
            evictOldestEntry();
        }
        
        cache.put(key, new CacheEntry(data, System.currentTimeMillis()));
    }
    
    // 가장 오래된 엔트리 제거
    private void evictOldestEntry() {
        String oldestKey = null;
        long oldestTime = Long.MAX_VALUE;
        
        for (Map.Entry<String, CacheEntry> entry : cache.entrySet()) {
            if (entry.getValue().getTimestamp() < oldestTime) {
                oldestTime = entry.getValue().getTimestamp();
                oldestKey = entry.getKey();
            }
        }
        
        if (oldestKey != null) {
            cache.remove(oldestKey);
        }
    }
    
    // 캐시 통계
    public CacheStats getStats() {
        return new CacheStats(cache.size(), maxSize, expirationTime);
    }
    
    private static class CacheEntry {
        private final Object data;
        private final long timestamp;
        
        public CacheEntry(Object data, long timestamp) {
            this.data = data;
            this.timestamp = timestamp;
        }
        
        public Object getData() { return data; }
        public long getTimestamp() { return timestamp; }
    }
}

// 사용 예시
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CacheManager cacheManager;
    
    public User getUserById(Long id) {
        String cacheKey = "user:" + id;
        
        // 캐시에서 먼저 조회
        User cachedUser = cacheManager.get(cacheKey, User.class);
        if (cachedUser != null) {
            System.out.println("캐시에서 조회: " + id);
            return cachedUser;
        }
        
        // DB에서 조회
        User user = userRepository.findById(id);
        if (user != null) {
            // 캐시에 저장
            cacheManager.put(cacheKey, user);
            System.out.println("DB에서 조회 후 캐시 저장: " + id);
        }
        
        return user;
    }
}
```

### 빈도 계산과 통계

로그 분석에서 사용자 행동 패턴을 분석할 때 해시맵을 활용했다.

```java
public class UserBehaviorAnalyzer {
    
    // 사용자별 페이지 방문 횟수
    public Map<String, Integer> getPageVisitCounts(List<LogEntry> logs) {
        Map<String, Integer> visitCounts = new HashMap<>();
        
        for (LogEntry log : logs) {
            String page = log.getPage();
            visitCounts.put(page, visitCounts.getOrDefault(page, 0) + 1);
        }
        
        return visitCounts;
    }
    
    // 가장 많이 방문한 페이지 TOP 10
    public List<Map.Entry<String, Integer>> getTopVisitedPages(List<LogEntry> logs, int topN) {
        Map<String, Integer> visitCounts = getPageVisitCounts(logs);
        
        return visitCounts.entrySet().stream()
            .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
            .limit(topN)
            .collect(Collectors.toList());
    }
    
    // 사용자별 세션 분석
    public Map<String, List<String>> getUserSessions(List<LogEntry> logs) {
        Map<String, List<String>> userSessions = new HashMap<>();
        
        for (LogEntry log : logs) {
            String userId = log.getUserId();
            String page = log.getPage();
            
            userSessions.computeIfAbsent(userId, k -> new ArrayList<>()).add(page);
        }
        
        return userSessions;
    }
    
    // 페이지 간 전환 패턴 분석
    public Map<String, Map<String, Integer>> getPageTransitionPatterns(List<LogEntry> logs) {
        Map<String, Map<String, Integer>> transitions = new HashMap<>();
        
        // 사용자별로 세션 정렬
        Map<String, List<LogEntry>> userLogs = logs.stream()
            .collect(Collectors.groupingBy(LogEntry::getUserId));
        
        for (List<LogEntry> userSession : userLogs.values()) {
            // 시간순 정렬
            userSession.sort(Comparator.comparing(LogEntry::getTimestamp));
            
            // 연속된 페이지 간 전환 계산
            for (int i = 0; i < userSession.size() - 1; i++) {
                String fromPage = userSession.get(i).getPage();
                String toPage = userSession.get(i + 1).getPage();
                
                transitions.computeIfAbsent(fromPage, k -> new HashMap<>())
                    .put(toPage, transitions.get(fromPage).getOrDefault(toPage, 0) + 1);
            }
        }
        
        return transitions;
    }
}
```

### 해시맵 활용 팁

**해시맵의 내부 동작 원리:**
- 해시 함수로 키를 배열 인덱스로 변환
- 충돌 발생 시 체이닝 또는 개방 주소법 사용
- 로드 팩터(Load Factor)가 0.75를 넘으면 크기 2배로 증가

**성능 최적화 팁:**
- 초기 용량을 예상 크기로 설정 (resize 방지)
- 적절한 해시 함수 구현 (충돌 최소화)
- 불변 객체를 키로 사용 (해시값 안정성)
- ConcurrentHashMap 사용 (동시성 환경)

**주의사항:**
- 해시 충돌로 인한 성능 저하 가능
- 키의 해시코드 변경 시 데이터 손실
- 메모리 사용량이 다른 자료구조보다 많음

## 트리(Tree)

트리는 계층적 구조를 표현하는 자료구조로, 노드와 엣지로 구성된다. 조직도, 파일 시스템, 데이터베이스 인덱스 등에 활용된다.

회사 조직도를 관리하는 시스템을 구현했다.

```java
public class OrganizationTree {
    private Node root;
    
    public static class Node {
        private Employee employee;
        private List<Node> children;
        private Node parent;
        
        public Node(Employee employee) {
            this.employee = employee;
            this.children = new ArrayList<>();
        }
        
        // 직속 부하 추가
        public void addChild(Node child) {
            child.parent = this;
            this.children.add(child);
        }
        
        // 모든 하위 직원 조회
        public List<Employee> getAllSubordinates() {
            List<Employee> subordinates = new ArrayList<>();
            
            for (Node child : children) {
                subordinates.add(child.employee);
                subordinates.addAll(child.getAllSubordinates());
            }
            
            return subordinates;
        }
        
        // 특정 직원 찾기
        public Node findEmployee(String employeeId) {
            if (this.employee.getId().equals(employeeId)) {
                return this;
            }
            
            for (Node child : children) {
                Node found = child.findEmployee(employeeId);
                if (found != null) {
                    return found;
                }
            }
            
            return null;
        }
        
        // 조직도 출력
        public void printTree(String prefix) {
            System.out.println(prefix + employee.getName() + " (" + employee.getPosition() + ")");
            
            for (int i = 0; i < children.size(); i++) {
                Node child = children.get(i);
                boolean isLast = (i == children.size() - 1);
                String childPrefix = prefix + (isLast ? "└── " : "├── ");
                child.printTree(childPrefix);
            }
        }
    }
    
    // 조직도 구축
    public void buildOrganization() {
        // CEO
        Employee ceo = new Employee("001", "김철수", "CEO");
        root = new Node(ceo);
        
        // 부사장들
        Employee vp1 = new Employee("002", "이영희", "CTO");
        Employee vp2 = new Employee("003", "박민수", "CFO");
        
        Node vp1Node = new Node(vp1);
        Node vp2Node = new Node(vp2);
        
        root.addChild(vp1Node);
        root.addChild(vp2Node);
        
        // 개발팀
        Employee devManager = new Employee("004", "최지영", "개발팀장");
        Node devManagerNode = new Node(devManager);
        vp1Node.addChild(devManagerNode);
        
        Employee dev1 = new Employee("005", "정수현", "시니어 개발자");
        Employee dev2 = new Employee("006", "강민호", "주니어 개발자");
        
        devManagerNode.addChild(new Node(dev1));
        devManagerNode.addChild(new Node(dev2));
        
        // 마케팅팀
        Employee marketingManager = new Employee("007", "윤서연", "마케팅팀장");
        Node marketingManagerNode = new Node(marketingManager);
        vp2Node.addChild(marketingManagerNode);
        
        Employee marketer = new Employee("008", "임도현", "마케터");
        marketingManagerNode.addChild(new Node(marketer));
    }
    
    // 특정 직원의 모든 부하 조회
    public List<Employee> getSubordinates(String employeeId) {
        Node node = root.findEmployee(employeeId);
        return node != null ? node.getAllSubordinates() : new ArrayList<>();
    }
    
    // 조직도 출력
    public void printOrganization() {
        root.printTree("");
    }
}

// 사용 예시
OrganizationTree orgTree = new OrganizationTree();
orgTree.buildOrganization();

// 조직도 출력
orgTree.printOrganization();

// 특정 직원의 부하들 조회
List<Employee> subordinates = orgTree.getSubordinates("004");
System.out.println("개발팀장의 부하들: " + subordinates);
```

### 트리 활용 팁

**트리의 종류:**
- **이진 트리**: 각 노드가 최대 2개의 자식을 가짐
- **이진 탐색 트리**: 왼쪽 자식 < 부모 < 오른쪽 자식
- **균형 트리**: 높이가 균형잡힌 트리 (AVL, Red-Black)
- **B-트리**: 데이터베이스 인덱스에 사용

**트리 순회 방법:**
- **전위 순회**: 루트 → 왼쪽 → 오른쪽
- **중위 순회**: 왼쪽 → 루트 → 오른쪽 (BST에서 정렬된 순서)
- **후위 순회**: 왼쪽 → 오른쪽 → 루트

**트리 사용 시 주의사항:**
- 순환 참조 방지 (부모-자식 관계 검증)
- 트리 높이 제한 (스택 오버플로우 방지)
- 균형 잡힌 트리 사용 (성능 최적화)

## 자료구조 선택 가이드

### 성능 비교

| 자료구조 | 접근 | 검색 | 삽입 | 삭제 | 공간복잡도 |
|---------|------|------|------|------|-----------|
| 배열 | O(1) | O(n) | O(n) | O(n) | O(n) |
| ArrayList | O(1) | O(n) | O(1)* | O(n) | O(n) |
| LinkedList | O(n) | O(n) | O(1) | O(1) | O(n) |
| 스택 | O(n) | O(n) | O(1) | O(1) | O(n) |
| 큐 | O(n) | O(n) | O(1) | O(1) | O(n) |
| HashMap | - | O(1) | O(1) | O(1) | O(n) |

*ArrayList의 삽입은 평균적으로 O(1)이지만, 배열 확장 시 O(n)

### 상황별 선택

**1. 조회가 많은 경우**
```java
// 사용자 정보 조회 - HashMap 사용
Map<String, User> userCache = new HashMap<>();

public User getUser(String userId) {
    return userCache.get(userId); // O(1)
}
```

**2. 순서가 중요한 경우**
```java
// 작업 순서 관리 - Queue 사용
Queue<Task> taskQueue = new LinkedList<>();

public void addTask(Task task) {
    taskQueue.offer(task); // O(1)
}

public Task getNextTask() {
    return taskQueue.poll(); // O(1)
}
```

**3. 중간 삽입/삭제가 많은 경우**
```java
// 실시간 채팅 메시지 - LinkedList 사용
List<Message> messages = new LinkedList<>();

public void insertMessage(int index, Message message) {
    messages.add(index, message); // O(1)
}

public void removeMessage(int index) {
    messages.remove(index); // O(1)
}
```

**4. 최근 데이터만 필요한 경우**
```java
// 최근 검색어 - Stack 사용
Stack<String> recentSearches = new Stack<>();

public void addSearch(String keyword) {
    recentSearches.push(keyword);
    
    // 최대 10개만 유지
    if (recentSearches.size() > 10) {
        recentSearches.remove(0);
    }
}
```

### 실제 프로젝트에서의 선택 기준

**웹 애플리케이션 개발 시:**
- **사용자 세션 관리**: HashMap (빠른 조회)
- **페이지 히스토리**: Stack (뒤로가기 기능)
- **작업 큐**: Queue (순서 보장)
- **메뉴 구조**: Tree (계층적 구조)
- **데이터 캐싱**: HashMap (키-값 저장)

**게임 개발 시:**
- **인벤토리**: ArrayList (인덱스 접근)
- **이벤트 큐**: PriorityQueue (우선순위)
- **맵 데이터**: 2D Array (좌표 접근)
- **AI 경로찾기**: Queue (BFS 알고리즘)

**데이터 분석 시:**
- **빈도 계산**: HashMap (카운팅)
- **정렬된 데이터**: TreeSet (자동 정렬)
- **대용량 데이터**: ArrayList (메모리 효율)
- **통계 계산**: Array (수치 연산)

## 마무리

자료구조는 언제, 왜 사용하는지 이해하는 게 중요하다. 처음에는 ArrayList만 썼는데, 규모가 커지면서 각 자료구조의 특성을 이해하게 됐다.

### 핵심 정리

**각 자료구조의 특징:**
- **배열**: 메모리 효율적, 인덱스 접근 빠름, 크기 고정
- **ArrayList**: 동적 크기, 인덱스 접근, 중간 삽입/삭제 느림
- **LinkedList**: 중간 삽입/삭제 빠름, 순차 접근 느림
- **스택**: LIFO, 되돌리기 기능, 괄호 매칭
- **큐**: FIFO, 대기열, BFS 알고리즘
- **HashMap**: O(1) 검색, 캐싱, 빈도 계산
- **트리**: 계층 구조, 정렬, 검색 최적화

**선택 기준:**
1. **문제 분석** - 어떤 연산이 자주 발생하는가?
2. **성능 요구사항** - 얼마나 빠르게 처리되어야 하는가?
3. **메모리 고려** - 제한된 리소스에서 최적화
4. **코드 가독성** - 복잡한 것보다 이해하기 쉬운 것 우선

자료구조는 개발자의 기본 소양이다. 더 효율적인 코드를 생각하며 작성해보자.
