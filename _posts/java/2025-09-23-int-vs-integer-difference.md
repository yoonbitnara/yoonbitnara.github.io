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

원시 타입이란 자바에서 제공하는 가장 기본적인 데이터 타입이다.<br>
총 8개가 있다. byte, short, int, long, float, double, char, boolean<br>
이들은 객체가 아니라 단순한 값이다.<br>

```java
int number = 42;  // 메모리에 42가 직접 저장됨
// number는 그냥 숫자 42 그 자체다
```

### Integer: 래퍼 클래스
Integer는 **래퍼 클래스(wrapper class)**다.<br>
객체로 감싸서 사용한다.<br>

래퍼 클래스란 원시 타입을 객체로 감싸는 클래스다.<br>
모든 원시 타입에는 대응하는 래퍼 클래스가 있다<br>
int → Integer, long → Long, double → Double, boolean → Boolean 등<br>
이들은 모두 java.lang 패키지에 있다.<br>

```java
Integer number = 42;  // Integer 객체가 생성되고 그 안에 42가 저장됨
// number는 Integer 객체의 주소를 담고 있다
```

## 메모리 구조

### int의 메모리 구조
```
Stack:
┌─────────┐
│   42    │  ← 값이 직접 저장
└─────────┘
```

int는 Stack 메모리에 값이 직접 저장된다.<br>
변수명과 값이 1:1로 대응된다.<br>
메모리 주소를 거치지 않고 바로 값에 접근한다.<br>

### Integer의 메모리 구조
```
Stack:           Heap:
┌─────────┐      ┌─────────────┐
│  100    │ ───→ │ Integer(42) │
└─────────┘      └─────────────┘
```

Integer는 두 단계를 거친다.<br>
1. Stack에 객체의 주소(100) 저장<br>
2. Heap에 실제 Integer 객체 생성, 그 안에 값(42) 저장<br>
값에 접근하려면 주소를 통해 객체를 찾아야 한다.<br>

## null 차이점

### int는 null 불가능
```java
int num = null;  // 컴파일 에러!
// int는 원시 타입이라 null을 가질 수 없음
```

왜 null이 안 될까?<br>
int는 단순한 값이기 때문이다. null은 "아무것도 가리키지 않는다"는 의미인데,<br>
int는 값을 직접 저장하는 공간이라 "아무것도 없다"는 상태를 표현할 수 없다.<br>
0은 0이고, -1은 -1이다. null은 없다.<br>

### Integer는 null 가능
```java
Integer num = null;  // 정상 동작
// Integer는 객체라서 null 참조 가능
```

왜 null이 될까?<br>
Integer는 객체의 주소를 저장하기 때문이다.<br>
null은 "아무 객체도 가리키지 않는다"는 의미다.<br>
주소 공간에 null이 들어가면 "어디도 가리키지 않는다"는 뜻이다.<br>
```
Stack:
┌─────────┐
│  null   │  ← 아무것도 가리키지 않음
└─────────┘
```

## 오토박싱과 언박싱

### 자동 변환
자바는 편의를 위해 자동으로 변환해준다.<br>

오토박싱과 언박싱은 자바 5부터 도입된 기능이다.<br>
이전에는 개발자가 직접 변환 코드를 써야 했지만, 이제는 자동으로 해준다.<br>

```java
// 오토박싱: int → Integer (값을 객체로 감싸기)
int primitive = 10;
Integer wrapper = primitive;  // 자동으로 Integer 객체 생성
// 실제로는: Integer wrapper = Integer.valueOf(primitive);

// 언박싱: Integer → int (객체에서 값 추출하기)
Integer wrapper = 10;
int primitive = wrapper;  // 자동으로 int 값 추출
// 실제로는: int primitive = wrapper.intValue();
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

왜 Integer가 더 많은 메모리를 사용할까?<br>
객체는 단순히 값만 저장하는 게 아니라 여러 정보를 함께 저장한다.<br>
- 객체 헤더 (클래스 정보, 가비지 컬렉션 정보 등)<br>
- 실제 값 (4바이트)<br>
- 기타 메타데이터<br>
따라서 int 1개 = 4바이트, Integer 1개 = 최소 12바이트가 필요하다.<br>

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

왜 Integer 연산이 느릴까?<br>
Integer 연산은 3단계를 거친다.<br>
1. **언박싱**: Integer 객체에서 int 값 추출<br>
2. **연산**: 두 int 값으로 실제 계산<br>
3. **오토박싱**: 결과를 다시 Integer 객체로 변환<br>
int는 1단계(연산)만 하면 되지만, Integer는 3단계를 거쳐야 한다.<br>

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
        // 왜 true일까? JVM이 -128~127 범위의 Integer를 미리 생성해두기 때문
        
        // 새로운 객체 생성
        Integer num5 = new Integer(10);
        Integer num6 = new Integer(10);
        System.out.println(num5 == num6);  // false - 다른 객체
        // new를 사용하면 캐시를 무시하고 새 객체를 생성한다
        System.out.println(num5.equals(num6));  // true - 값 비교
        // equals()는 객체의 내용(값)을 비교한다
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
// num이 null인데 .intValue()를 호출하려고 해서 에러

// 안전한 방법
Integer num = null;
if (num != null) {
    int value = num;  // null 체크 후 안전하게 언박싱
}
```

이 에러가 발생하는 이유<br>
Integer num = null;에서 num은 아무것도 가리키지 않는다.<br>
int value = num;은 실제로 int value = num.intValue();로 변환된다.<br>
null.intValue()를 호출하려고 하니 NullPointerException이 발생한다.<br>

### 2. equals() vs ==
```java
Integer a = 128;
Integer b = 128;
System.out.println(a == b);  // false! (캐시 범위 벗어남)
System.out.println(a.equals(b));  // true
```

왜 128에서는 ==이 false일까?<br>
JVM은 -128부터 127까지의 Integer만 미리 생성해둔다.<br>
128은 캐시 범위를 벗어나므로 각각 새로운 객체를 생성한다.<br>
==는 객체 주소를 비교하므로 false가 된다.<br>
equals()는 객체의 내용(값)을 비교하므로 true가 된다.<br>

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
이를 **Integer Cache**라고 한다.<br>
자주 사용되는 작은 숫자들을 미리 만들어두어 메모리와 성능을 최적화한다.<br>

```java
Integer a = 100;  // 캐시된 객체 사용
Integer b = 100;  // 같은 캐시된 객체 사용
System.out.println(a == b);  // true - 같은 객체를 참조

Integer c = 200;  // 새로운 객체 생성
Integer d = 200;  // 또 다른 새로운 객체 생성
System.out.println(c == d);  // false - 서로 다른 객체
```

캐시 범위는 JVM 구현에 따라 다를 수 있지만,<br>
대부분 -128부터 127까지다.<br>
이는 byte 타입의 범위와 같다.<br>

## 컬렉션에서의 사용

### 제네릭 제약
```java
// 원시 타입은 제네릭에 사용 불가
List<int> list1;  // 컴파일 에러!

// 래퍼 클래스만 제네릭에 사용 가능
List<Integer> list2;  // 정상 동작
```

왜 원시 타입은 제네릭에 사용할 수 없을까?<br>
제네릭은 **타입 소거(Type Erasure)** 방식을 사용한다.<br>
컴파일 시점에 타입 정보가 사라지고 Object로 변환된다.<br>
원시 타입은 Object의 하위 타입이 아니므로 사용할 수 없다.<br>
래퍼 클래스는 Object의 하위 타입이므로 사용 가능하다.<br>

### 성능 고려사항
```java
// 비효율적
List<Integer> numbers = new ArrayList<>();
for (int i = 0; i < 1000000; i++) {
    numbers.add(i);  // 오토박싱 발생
}
// 100만 번의 오토박싱으로 인한 성능 저하

// 효율적 (특수한 경우)
int[] numbers = new int[1000000];
for (int i = 0; i < numbers.length; i++) {
    numbers[i] = i;  // 직접 할당
}
// 오토박싱 없이 직접 할당
```

왜 List<Integer>가 비효율적일까?<br>
매번 add(i)를 호출할 때마다 오토박싱이 발생한다.<br>
int → Integer 변환 과정에서 객체 생성 비용이 발생한다.<br>
100만 번의 오토박싱은 상당한 성능 저하를 일으킨다.<br>
int[] 배열은 오토박싱 없이 직접 값을 저장한다.<br>

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
