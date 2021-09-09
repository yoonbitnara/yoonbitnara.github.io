---
title: "JAVA 두 개의 주사위(커스텀 클래스 활용)"
tags: JAVA 자바주사위 
categories: 
    - Algorithm
---


![quiz](/assets/images/cap1.PNG)
<br>
<br>

# 커스텀 클래스를 활용한 풀이

## Main.java
```java
package pack_Random;

public class Main {

	public static void main(String[] args) {
		
		Ex04 ex04 = new Ex04();
		
		int returnVar = 0;
		
		while (true) {
			returnVar = ex04.mtd();
			
			if (returnVar == 1) break;
		}
		
	}
}
```
<br>
<br>

## Ex04.java
```java
package pack_Random;

public class Ex04 {
	
	private int num1;
	private int num2;
	
	
	public int mtd() {
		
		int num1 = 0;
		int num2 = 0;
		
		num1 = (int) (Math.random() * 6+1);
		num2 = (int) (Math.random() * 6+1);
		
		int res = num1 + num2;
		
		System.out.println("(" + num1 +"," + num2 + ")");
		
		if (res == 5) return 1;
		
		return 0;
	}
}
```