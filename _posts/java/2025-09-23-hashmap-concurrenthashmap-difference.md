---
title: "Java HashMap vs ConcurrentHashMap"
date: 2025-09-23
categories: Java
tags: [Java, HashMap, ConcurrentHashMap, 동시성, 멀티스레드, 컬렉션]
author: pitbull terrier
---

# Java HashMap vs ConcurrentHashMap

자바를 사용하다 보면 "왜 HashMap은 멀티스레드에서 문제가 생길까?"라는 질문이 생긴다.<br>
같은 Map인데 왜 이렇게 차이가 날까?<br>
이런 궁금증이 있다면 이 글을 끝까지 읽어보자.<br>

## 처음 겪는 혼란

처음 자바를 배울 때 이런 코드를 써봤을 것이다.<br>

```java
Map<String, Integer> map = new HashMap<>();
map.put("key1", 100);
map.put("key2", 200);
System.out.println(map.get("key1"));  // 100
```

그런데 멀티스레드 환경에서는 문제가 생긴다.<br>
여러 스레드가 동시에 HashMap을 조작하면 예상치 못한 결과가 나온다.<br>

```java
// 멀티스레드에서 HashMap 사용 시 문제
HashMap<String, Integer> map = new HashMap<>();

// 스레드 1
Thread t1 = new Thread(() -> {
    for (int i = 0; i < 1000; i++) {
        map.put("key" + i, i);
    }
});

// 스레드 2
Thread t2 = new Thread(() -> {
    for (int i = 0; i < 1000; i++) {
        map.put("key" + i, i * 2);
    }
});

t1.start();
t2.start();
// 결과를 예측할 수 없다!
```

"왜 같은 Map인데 멀티스레드에서는 문제가 생길까?"<br>
많은 개발자들이 이 차이점을 헷갈려한다.<br>

## 근본적인 차이점

HashMap과 ConcurrentHashMap의 차이는 **동기화**에 있다.<br>

HashMap은 단일 스레드를 위해 만들어진 녀석이다.<br>
동기화란 게 전혀 없다. 그래서 빠르다.<br>
하지만 여러 스레드가 동시에 건드리면 문제가 생긴다.<br>

```java
HashMap<String, Integer> map = new HashMap<>();
// 내부적으로 동기화 처리가 전혀 없다
```

반면 ConcurrentHashMap은 멀티스레드를 염두에 두고 설계되었다.<br>
전체를 잠그지 않고 부분적으로만 동기화한다.<br>
안전성과 성능을 모두 잡으려고 노력한 결과물이다.<br>

```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
// 내부적으로 세그먼트별 동기화 처리
```

## 내부적으로 어떻게 다를까

HashMap은 단순하다. 배열과 연결리스트로만 구성되어 있다.<br>

```
HashMap:
┌─────────────────────────────────────────┐
│  [0] → Node → Node → null               │
│  [1] → null                             │
│  [2] → Node → null                      │
│  [3] → Node → Node → Node → null        │
│  ...                                    │
│  [15] → null                            │
└─────────────────────────────────────────┘
```

모든 연산이 동기화 없이 수행된다.<br>
여러 스레드가 동시에 접근하면 데이터가 꼬인다.<br>

ConcurrentHashMap은 더 복잡하다. 세그먼트로 나누어 관리한다.<br>

```
ConcurrentHashMap:
┌─────────────────────────────────────────┐
│  Segment[0] → [0] → Node → Node → null  │
│  Segment[1] → [1] → null                │
│  Segment[2] → [2] → Node → null         │
│  Segment[3] → [3] → Node → Node → Node  │
│  ...                                    │
│  Segment[15] → [15] → null              │
└─────────────────────────────────────────┘
```

각 세그먼트는 독립적으로 동기화된다.<br>
전체를 잠그지 않고 필요한 부분만 잠근다.<br>

## HashMap이 멀티스레드에서 위험한 이유

HashMap을 멀티스레드에서 사용하면 여러 문제가 생긴다.<br>

### 무한 루프가 발생할 수 있다
```java
HashMap<Integer, String> map = new HashMap<>();

// 스레드 1: put 연산
Thread t1 = new Thread(() -> {
    for (int i = 0; i < 100000; i++) {
        map.put(i, "value" + i);
    }
});

// 스레드 2: put 연산
Thread t2 = new Thread(() -> {
    for (int i = 0; i < 100000; i++) {
        map.put(i, "value" + i);
    }
});
```

왜 무한 루프가 발생할까?<br>
HashMap의 내부 배열이 확장될 때 리사이징이 발생한다.<br>
여러 스레드가 동시에 리사이징을 시도하면 연결리스트가 꼬인다.<br>
순환 참조가 생기면서 무한 루프에 빠진다.<br>

### 데이터가 사라질 수 있다
```java
HashMap<String, Integer> map = new HashMap<>();

// 스레드 1
Thread t1 = new Thread(() -> {
    map.put("key", 100);
});

// 스레드 2
Thread t2 = new Thread(() -> {
    map.put("key", 200);
});
```

왜 데이터가 손실될까?<br>
두 스레드가 동시에 같은 키에 값을 저장하면<br>
하나의 값이 덮어써지거나 아예 사라질 수 있다.<br>
동기화가 없어서 원자성이 보장되지 않는다.<br>

### null 처리도 다르다
```java
HashMap<String, Integer> map = new HashMap<>();
map.put("key", null);  // 정상 동작

ConcurrentHashMap<String, Integer> concurrentMap = new ConcurrentHashMap<>();
concurrentMap.put("key", null);  // NullPointerException!
```

왜 ConcurrentHashMap은 null을 허용하지 않을까?<br>
null 값을 허용하면 "값이 없음"과 "값이 null"을 구분할 수 없다.<br>
멀티스레드 환경에서 이 구분이 중요하다.<br>
따라서 ConcurrentHashMap은 null 값을 완전히 금지한다.<br>

## ConcurrentHashMap은 어떻게 해결했을까

ConcurrentHashMap은 여러 기법을 사용해서 문제를 해결했다.<br>

### 세그먼트 락
```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

// 여러 스레드가 동시에 접근해도 안전
Thread t1 = new Thread(() -> {
    map.put("key1", 100);
});

Thread t2 = new Thread(() -> {
    map.put("key2", 200);
});
```

ConcurrentHashMap은 전체를 잠그지 않는다.<br>
세그먼트별로 독립적인 락을 사용한다.<br>
서로 다른 세그먼트에 접근하는 스레드들은 동시에 실행될 수 있다.<br>

### CAS 연산
```java
// Compare-And-Swap 연산
// 기대값과 현재값을 비교하여 같으면 새 값으로 교체
if (currentValue == expectedValue) {
    currentValue = newValue;
    return true;
} else {
    return false;
}
```

CAS 연산은 락 없이도 원자성을 보장한다.<br>
하드웨어 레벨에서 지원하는 원자적 연산이다.<br>
락보다 훨씬 빠르고 효율적이다.<br>

## 성능은 어떨까

### 읽기 성능
```java
// HashMap 읽기
HashMap<String, Integer> hashMap = new HashMap<>();
long start = System.currentTimeMillis();
for (int i = 0; i < 1000000; i++) {
    hashMap.get("key" + i);
}
long end = System.currentTimeMillis();

// ConcurrentHashMap 읽기
ConcurrentHashMap<String, Integer> concurrentMap = new ConcurrentHashMap<>();
long start2 = System.currentTimeMillis();
for (int i = 0; i < 1000000; i++) {
    concurrentMap.get("key" + i);
}
long end2 = System.currentTimeMillis();
```

단일 스레드에서는 HashMap이 더 빠르다.<br>
동기화 오버헤드가 없기 때문이다.<br>
ConcurrentHashMap은 약간의 오버헤드가 있다.<br>

### 쓰기 성능
```java
// HashMap 쓰기 (단일 스레드)
HashMap<String, Integer> hashMap = new HashMap<>();
for (int i = 0; i < 1000000; i++) {
    hashMap.put("key" + i, i);
}

// ConcurrentHashMap 쓰기 (멀티스레드)
ConcurrentHashMap<String, Integer> concurrentMap = new ConcurrentHashMap<>();
// 여러 스레드가 동시에 안전하게 쓰기 가능
```

멀티스레드 환경에서는 ConcurrentHashMap이 훨씬 빠르다.<br>
HashMap은 동시성 문제로 인해 성능이 급격히 떨어진다.<br>
ConcurrentHashMap은 병렬 처리가 가능하다.<br>

## 실제로 차이가 나는 모습

### HashMap은 위험하다
```java
public class HashMapExample {
    private static HashMap<String, Integer> map = new HashMap<>();
    
    public static void main(String[] args) throws InterruptedException {
        // 여러 스레드가 동시에 접근
        Thread[] threads = new Thread[10];
        
        for (int i = 0; i < 10; i++) {
            final int threadId = i;
            threads[i] = new Thread(() -> {
                for (int j = 0; j < 1000; j++) {
                    String key = "thread" + threadId + "_key" + j;
                    map.put(key, j);
                }
            });
        }
        
        for (Thread thread : threads) {
            thread.start();
        }
        
        for (Thread thread : threads) {
            thread.join();
        }
        
        System.out.println("HashMap size: " + map.size());
        // 예상: 10000, 실제: 예측 불가능
    }
}
```

### ConcurrentHashMap은 안전하다
```java
public class ConcurrentHashMapExample {
    private static ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
    
    public static void main(String[] args) throws InterruptedException {
        // 여러 스레드가 동시에 접근
        Thread[] threads = new Thread[10];
        
        for (int i = 0; i < 10; i++) {
            final int threadId = i;
            threads[i] = new Thread(() -> {
                for (int j = 0; j < 1000; j++) {
                    String key = "thread" + threadId + "_key" + j;
                    map.put(key, j);
                }
            });
        }
        
        for (Thread thread : threads) {
            thread.start();
        }
        
        for (Thread thread : threads) {
            thread.join();
        }
        
        System.out.println("ConcurrentHashMap size: " + map.size());
        // 예상: 10000, 실제: 10000 (정확함)
    }
}
```

## 언제 뭘 써야 할까

### HashMap을 쓸 때
- **단일 스레드 환경**: 웹 애플리케이션의 로컬 변수
- **성능이 중요한 경우**: 대량의 데이터를 빠르게 처리해야 할 때
- **동시성 문제가 없는 경우**: 한 번에 하나의 스레드만 접근

```java
// 단일 스레드에서 사용
public class DataProcessor {
    private HashMap<String, Object> cache = new HashMap<>();
    
    public void processData(List<String> data) {
        // 한 번에 하나의 스레드만 실행
        for (String item : data) {
            cache.put(item, processItem(item));
        }
    }
}
```

### ConcurrentHashMap을 쓸 때
- **멀티스레드 환경**: 여러 스레드가 동시에 접근
- **동시성이 중요한 경우**: 스레드 안전성이 필수
- **병렬 처리가 필요한 경우**: 대용량 데이터를 병렬로 처리

```java
// 멀티스레드에서 사용
public class ConcurrentDataProcessor {
    private ConcurrentHashMap<String, Object> cache = new ConcurrentHashMap<>();
    
    public void processDataConcurrently(List<String> data) {
        data.parallelStream().forEach(item -> {
            // 여러 스레드가 동시에 안전하게 접근
            cache.put(item, processItem(item));
        });
    }
}
```

## 자주 하는 실수들

### 멀티스레드에서 HashMap 사용
```java
// 잘못된 예
private static HashMap<String, Integer> map = new HashMap<>();

public void addData(String key, Integer value) {
    map.put(key, value);  // 멀티스레드에서 위험!
}

// 올바른 예
private static ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

public void addData(String key, Integer value) {
    map.put(key, value);  // 멀티스레드에서 안전
}
```

### null 값 처리
```java
// 잘못된 예
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
map.put("key", null);  // NullPointerException!

// 올바른 예
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
if (value != null) {
    map.put("key", value);
} else {
    map.remove("key");  // null 대신 remove 사용
}
```

### 성능 오해
```java
// 잘못된 생각
// "ConcurrentHashMap이 항상 느리다"

// 실제로는 상황에 따라 다름
// 단일 스레드: HashMap이 빠름
// 멀티스레드: ConcurrentHashMap이 훨씬 빠름
```

## ConcurrentHashMap의 특별한 기능들

### 원자적 연산
```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

// 원자적으로 값 증가
map.compute("counter", (key, value) -> value == null ? 1 : value + 1);

// 조건부 업데이트
map.computeIfAbsent("key", k -> 0);
map.computeIfPresent("key", (k, v) -> v + 1);
```

### 병렬 연산
```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

// 병렬로 모든 값 처리
map.forEach(1, (key, value) -> {
    System.out.println(key + " = " + value);
});

// 병렬로 검색
String result = map.search(1, (key, value) -> {
    return value > 100 ? key : null;
});
```

## 실무에서 어떻게 선택할까

### HashMap을 선택할 때
- 웹 애플리케이션의 요청 처리 (단일 스레드)
- 로컬 캐시 구현
- 성능이 중요한 알고리즘
- 동시성 문제가 없는 환경

### ConcurrentHashMap을 선택할 때
- 서버 애플리케이션의 공유 데이터
- 멀티스레드 환경의 캐시
- 병렬 데이터 처리
- 동시성이 중요한 시스템

## 결론

HashMap과 ConcurrentHashMap의 차이를 이해하는 건 자바의 핵심이다.<br>
단일 스레드와 멀티스레드 환경의 특성을 알고, 상황에 맞게 선택하는 것이 중요하다.<br>

**기억하자**
- HashMap은 단일 스레드용, ConcurrentHashMap은 멀티스레드용
- HashMap은 빠르지만 동시성 문제 존재
- ConcurrentHashMap은 안전하지만 약간의 오버헤드 존재
- 멀티스레드 환경에서는 반드시 ConcurrentHashMap 사용
- null 값 처리는 ConcurrentHashMap에서 주의 필요

