---
title: "Java에서 == vs equals() 차이 분석"
date: 2025-09-23
categories: Java
tags: [Java, 문자열, 비교, equals, ==]
author: pitbull terrier
---

# Java에서 == vs equals() 차이 분석

자바를 처음 배울 때 가장 헷갈리는 부분 중 하나가 바로 문자열 비교다.<br>
"abc" == "abc"가 true인데, 왜 "abc" == new String("abc")는 false일까?<br>
이런 질문을 해본 적이 있다면 이 글을 끝까지 읽어보자.<br>

## 문제의 시작

처음 자바를 배울 때 이런 코드를 써봤을 것이다.<br>

```java
String str1 = "hello";
String str2 = "hello";
System.out.println(str1 == str2);  // true

String str3 = new String("hello");
System.out.println(str1 == str3);  // false <- 여기서 멘붕
```

"똑같은 문자열인데 왜 false가 나오지?"<br>
많은 초보자들이 이 순간에서 멘붕한다. 나도 그랬다.<br>

## 핵심 개념

### == 연산자
== 연산자는 **참조(주소)를 비교**한다.<br>
즉, 두 변수가 같은 메모리 주소를 가리키고 있는지 확인한다.<br>

```java
String a = "test";
String b = "test";
String c = new String("test");

System.out.println(a == b);  // true - 같은 주소
System.out.println(a == c);  // false - 다른 주소
```

### equals() 메서드
equals() 메서드는 **실제 값을 비교**한다.<br>
문자열의 내용이 같은지 확인한다.<br>

```java
String a = "test";
String b = new String("test");

System.out.println(a.equals(b));  // true - 내용이 같음
```

## String Pool

왜 "hello" == "hello"는 true일까?<br>
이건 **String Pool** 때문이다.<br>

### String Pool이란?
JVM은 문자열 리터럴을 특별한 메모리 영역인 String Pool에 저장한다.<br>
같은 내용의 문자열 리터럴은 하나의 인스턴스만 생성하고 재사용한다.<br>

```java
String str1 = "hello";  // String Pool에 "hello" 생성
String str2 = "hello";  // 기존 "hello" 재사용 (같은 주소)
String str3 = new String("hello");  // 새로운 객체 생성 (다른 주소)
```

### 메모리 구조

```
String Pool:           Heap:
┌─────────────┐        ┌─────────────┐
│ "hello"     │        │ "hello"     │
│ (주소: 100) │         │ (주소: 200)  │
└─────────────┘        └─────────────┘
      ↑                       ↑
   str1, str2               str3
```

str1과 str2는 같은 주소(100)를 가리키지만, str3는 다른 주소(200)를 가리킨다.<br>

## 실제 코드

```java
public class StringComparison {
    public static void main(String[] args) {
        // 리터럴 방식
        String literal1 = "java";
        String literal2 = "java";
        System.out.println("리터럴 비교: " + (literal1 == literal2));  // true
        
        // new 연산자 방식
        String new1 = new String("java");
        String new2 = new String("java");
        System.out.println("new 비교: " + (new1 == new2));  // false
        
        // 리터럴 vs new
        System.out.println("리터럴 vs new: " + (literal1 == new1));  // false
        
        // equals() 비교
        System.out.println("equals 비교: " + literal1.equals(new1));  // true
    }
}
```

## 언제 어떤 걸 써야 할까

### == 사용하는 경우
- **null 체크**: `if (str == null)`
- **같은 객체인지 확인**: 객체의 정체성 확인

```java
String str = null;
if (str == null) {
    System.out.println("문자열이 null입니다");
}
```

### equals() 사용하는 경우
- **문자열 내용 비교**: 실제 데이터 비교
- **대부분의 경우**: 99%는 equals()를 써야 한다

```java
String input = "admin";
if ("admin".equals(input)) {  // null 안전
    System.out.println("관리자입니다");
}
```

## null 안전한 비교 방법

```java
// 위험한 방법
String str = null;
if (str.equals("test")) {  // NullPointerException 발생 가능
    // ...
}

// 안전한 방법 1
if ("test".equals(str)) {  // null 안전
    // ...
}

// 안전한 방법 2 (Java 7+)
if (Objects.equals(str, "test")) {  // 완전히 안전
    // ...
}
```

## 실무에서 자주 하는 실수들

### 1. 대소문자 구분 없는 비교
```java
// 잘못된 방법
if (input.equals("YES")) {  // "yes", "Yes" 등은 false

// 올바른 방법
if ("YES".equalsIgnoreCase(input)) {  // 모든 경우 처리
```

### 2. 공백 무시하고 비교
```java
String userInput = "  hello  ";
if (userInput.equals("hello")) {  // false

// 올바른 방법
if (userInput.trim().equals("hello")) {  // true
```

### 3. StringBuilder/StringBuffer와 비교
```java
StringBuilder sb = new StringBuilder("hello");
if (sb.equals("hello")) {  // false - 타입이 다름

// 올바른 방법
if (sb.toString().equals("hello")) {  // true
```

## 성능 관점

== 연산자가 equals()보다 빠르다.<br>
하지만 올바른 결과를 위해 equals()를 써야 한다.<br>

```java
// 빠르지만 위험
if (str1 == str2) {  // O(1) - 주소 비교만

// 느리지만 안전
if (str1.equals(str2)) {  // O(n) - 문자 하나씩 비교
```

## 결론

==와 equals()의 차이를 이해하는 건 자바의 기본이다.<br>
String Pool의 존재를 알고, 언제 어떤 비교 방법을 써야 하는지 아는 것이 중요하다.<br>

**기억하자:**
- ==는 참조 비교, equals()는 값 비교
- 문자열 비교는 거의 항상 equals() 사용
- null 안전성을 고려한 비교 방법 선택
- String Pool의 동작 원리 이해

이제 "abc" == new String("abc")가 false인 이유를 완전히 이해했을 것이다.<br>
같은 내용이지만 다른 객체이기 때문이다.<br>
