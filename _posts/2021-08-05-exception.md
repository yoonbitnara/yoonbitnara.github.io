---
title: "JAVA 예외처리에 대하여"
tags: JAVAinterface 
---


## 예외처리
- 예외처리의 개념
	- 프로그램은 정상실행되지만 실행중에 정상종료가 되지않는 에러를 의미함.
<br>
- 처리과정
	- 정상실행중에 오류발생시 오류의 종류를 확인할 수 있음.(Exception 클래스 계열)
<br>
- 참고
	- 컴파일에러 : 실행안됨
	- 예외(Exception) : 실행은 되나 정상종료안됨.
<br>
<br>
<br>

## 수동으로 예외 발생시키기
- 커스텀메서드에서 throws 구문을 사용하여 Exception 객체를 생성하고 전달.
<br>
<br>

## Main.java
```java
package pack_Throw;

import java.util.Scanner;

public class Main {
	
	public static void main(String[] args) {
		
		Scanner scanner = new Scanner(System.in);
		System.out.println("10이하 자연수를 입력 : ");
		int num = scanner.nextInt();
		scanner.close();
		
		Custom obj = null;
		
		try {
			
			obj = new Custom(num);
			obj.mtd();
			
		} catch (Exception e) {
			
			System.out.println(e.getMessage());
		}
	}
}
```
<br>
<br>
<br>

## Custom.java
```java
package pack_Throw;

public class Custom {
	
	private int num;

	public Custom(int num) throws Exception {
		
		if (num > 0  && num <= 10) {
			
			this.num = num;			
			
		} else {
			
			// Exception 객체생성
			throw new Exception("다시 입력해주세요. 10이하의 자연수를 입력하셔야 합니다.");
		}
	}
	
	public void mtd() {
		
		System.out.println("입력값은 " + num + "입니다.");
	}
}
```
