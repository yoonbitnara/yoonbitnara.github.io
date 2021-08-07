---
title: "JAVA 컬렉션 프레임워크 & 제네릭"
tags: JAVA JAVACollectionFramework 
---


## 컬렉션프레임워크란?
- 배열처럼 처리되지만 배열의 크기(개수)를 설정하지 않고 사용가능
- 배열은 동일한 자료형의 값 한개로 구성된 순차적 처리기법이나 컬렉션 프레임워크는 여러값으로 구성된 클래스들을 순차적으로 처리할 수 있음
<br>
<br>

## 제네릭
- 클래스나 메서드에서 사용할 내부 데이터 타입을 컴파일 시 미리 지정하는 방법
- 컬렉션, 람다식, 함수식, 소켓통신  등에 필수로 사용
<br>
<br>


```java
List<계열자료형> 변수명 = new ArrayList<계열하위클래스>();

List<String> list = new ArrayList<String>();

// 초기화
list.add();

// 반환
list.get();

// 수정
list.set();
```
<br>
<br>

## EX

```java
import java.util.ArrayList;
import java.util.List;

public class Main {

	public static void main(String[] args) {
		
		List<String> list = new ArrayList<String>();
		list.add("짜장면");
		list.add("짬뽕");
		list.add("탕수육");
		
		System.out.println("두 번째 값 : " + list.get(1));
		list.set(1, "우동");
		System.out.println("두 번째 값 : " + list.get(1));
		
		String string = list.get(0); 
		System.out.println(string);		
		}
}
```
![collection](/assets/images/collection.png)