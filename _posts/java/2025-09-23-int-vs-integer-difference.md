---
title: "Java에서 int와 Integer 차이 분석"
date: 2025-09-23
categories: Java
tags: [Java, primitive, wrapper, Integer, int]
author: pitbull terrier
---

# Java에서 int와 Integer 차이 분석

자바를 배우다 보면 "왜 int는 null을 못 담고 Integer는 담을 수 있을까?"라는 질문이 생긴다.<br>
둘 다 숫자를 담는 건데 뭐가 다른 걸까?<br>
이런 궁금증이 있다면 이 글을 끝까지 읽어보자.<br>

## 문제의 시작

처음 자바를 배울 때 이런 코드를 써봤을 것이다.<br>

```java
int num1 = 10;
Integer num2 = 10;
System.out.println(num1 == num2);  // true

int num3 = null;  // 컴파일 에러!
Integer num4 = null;  // 정상 동작
```

"왜 int는 null이 안 되고 Integer는 될까?"<br>
많은 초보자들이 이 차이점을 헷갈려한다.<br>

## 핵심 개념

### int: 원시 타입
int는 **원시 타입(primitive type)**이다.<br>
메모리에 직접 값을 저장한다.<br>

```java
int number = 42;  // 메모리에 42가 직접 저장됨
```

### Integer: 래퍼 클래스
Integer는 **래퍼 클래스(wrapper class)**다.<br>
객체로 감싸서 사용한다.<br>

```java
Integer number = 42;  // Integer 객체가 생성되고 그 안에 42가 저장됨
```

## 메모리 구조

### int의 메모리 구조
```
Stack:
┌─────────┐
│   42    │  ← 값이 직접 저장
└─────────┘
```

### Integer의 메모리 구조
```
Stack:           Heap:
┌─────────┐      ┌─────────────┐
│  100    │ ───→ │ Integer(42) │
└─────────┘      └─────────────┘
```

int는 값 자체를 저장하고, Integer는 객체의 주소를 저장한다.<br>

## null 차이점

### int는 null 불가능
```java
int num = null;  // 컴파일 에러!
// int는 원시 타입이라 null을 가질 수 없음
```

### Integer는 null 가능
```java
Integer num = null;  // 정상 동작
// Integer는 객체라서 null 참조 가능
```

## 오토박싱과 언박싱

### 자동 변환
자바는 편의를 위해 자동으로 변환해준다.<br>

```java
// 오토박싱: int → Integer
int primitive = 10;
Integer wrapper = primitive;  // 자동으로 Integer 객체 생성

// 언박싱: Integer → int
Integer wrapper = 10;
int primitive = wrapper;  // 자동으로 int 값 추출
```

### 실제 동작 과정
```java
Integer num = 10;
// 실제로는 이렇게 동작:
// Integer num = Integer.valueOf(10);

int value = num;
// 실제로는 이렇게 동작:
// int value = num.intValue();
```

## 성능 차이

### 메모리 사용량
```java
int primitive = 42;        // 4바이트
Integer wrapper = 42;      // 4바이트(int) + 객체 헤더(8바이트) = 12바이트
```

### 연산 속도
```java
// 빠른 연산
int a = 10;
int b = 20;
int result = a + b;  // 직접 연산

// 느린 연산
Integer a = 10;
Integer b = 20;
Integer result = a + b;  // 언박싱 → 연산 → 오토박싱
```

## 실제 코드

```java
public class IntVsInteger {
    public static void main(String[] args) {
        // 원시 타입
        int num1 = 10;
        int num2 = 10;
        System.out.println(num1 == num2);  // true - 값 비교
        
        // 래퍼 클래스
        Integer num3 = 10;
        Integer num4 = 10;
        System.out.println(num3 == num4);  // true - 같은 객체 참조 (캐시 때문)
        
        // 새로운 객체 생성
        Integer num5 = new Integer(10);
        Integer num6 = new Integer(10);
        System.out.println(num5 == num6);  // false - 다른 객체
        System.out.println(num5.equals(num6));  // true - 값 비교
    }
}
```

## 언제 어떤 걸 써야 할까

### int 사용하는 경우
- **성능이 중요한 경우**: 계산이 많은 알고리즘
- **null이 필요 없는 경우**: 단순한 숫자 연산
- **메모리 효율성이 중요한 경우**: 대량의 데이터 처리

```java
// 배열이나 반복문에서
int[] numbers = new int[1000000];
for (int i = 0; i < numbers.length; i++) {
    numbers[i] = i * 2;  // 빠른 연산
}
```

### Integer 사용하는 경우
- **null이 필요한 경우**: 값이 없을 수 있는 상황
- **제네릭 사용**: List<Integer>, Map<String, Integer>
- **객체로 다뤄야 하는 경우**: equals(), hashCode() 사용

```java
// null 체크가 필요한 경우
Integer score = getScore();  // null을 반환할 수 있음
if (score != null && score > 80) {
    System.out.println("합격");
}
```

## 자주 하는 실수들

### 1. NullPointerException
```java
Integer num = null;
int value = num;  // NullPointerException 발생!

// 안전한 방법
Integer num = null;
if (num != null) {
    int value = num;
}
```

### 2. equals() vs ==
```java
Integer a = 128;
Integer b = 128;
System.out.println(a == b);  // false! (캐시 범위 벗어남)
System.out.println(a.equals(b));  // true
```

### 3. 캐시 범위 오해
```java
Integer a = 127;  // 캐시 범위 내
Integer b = 127;
System.out.println(a == b);  // true

Integer c = 128;  // 캐시 범위 밖
Integer d = 128;
System.out.println(c == d);  // false
```

## Integer 캐시의 비밀

JVM은 -128부터 127까지의 Integer 객체를 미리 생성해둔다.<br>

```java
Integer a = 100;  // 캐시된 객체 사용
Integer b = 100;  // 같은 캐시된 객체 사용
System.out.println(a == b);  // true

Integer c = 200;  // 새로운 객체 생성
Integer d = 200;  // 또 다른 새로운 객체 생성
System.out.println(c == d);  // false
```

## 컬렉션에서의 사용

### 제네릭 제약
```java
// 원시 타입은 제네릭에 사용 불가
List<int> list1;  // 컴파일 에러!

// 래퍼 클래스만 제네릭에 사용 가능
List<Integer> list2;  // 정상 동작
```

### 성능 고려사항
```java
// 비효율적
List<Integer> numbers = new ArrayList<>();
for (int i = 0; i < 1000000; i++) {
    numbers.add(i);  // 오토박싱 발생
}

// 효율적 (특수한 경우)
int[] numbers = new int[1000000];
for (int i = 0; i < numbers.length; i++) {
    numbers[i] = i;  // 직접 할당
}
```

## 실무에서의 선택 기준

### int 선택하는 경우
- 반복문의 카운터
- 배열 인덱스
- 수학 계산
- 성능이 중요한 알고리즘

### Integer 선택하는 경우
- 데이터베이스의 NULL 허용 컬럼
- JSON 파싱 (값이 없을 수 있음)
- 컬렉션 사용
- API 응답 데이터

## 결론

int와 Integer의 차이를 이해하는 건 자바의 기본이다.<br>
원시 타입과 래퍼 클래스의 특성을 알고, 상황에 맞게 선택하는 것이 중요하다.<br>

**기억하자:**
- int는 원시 타입, Integer는 래퍼 클래스
- int는 null 불가능, Integer는 null 가능
- 성능은 int가 빠르지만, 기능은 Integer가 풍부
- 오토박싱/언박싱으로 편리하지만 성능 비용 존재
- 제네릭에는 래퍼 클래스만 사용 가능

이제 int와 Integer의 차이점을 완전히 이해했을 것이다.<br>
상황에 맞는 올바른 선택을 하자.<br>
