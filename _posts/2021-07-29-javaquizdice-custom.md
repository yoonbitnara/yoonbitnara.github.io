---
title: "JAVA 두 개의 주사위(커스텀 클래스 활용)"
tags: JAVA 자바주사위 
---


![quiz](/assets/images/cap1.PNG)
<br>
<br>

# 커스텀 클래스를 활용한 풀이

## Main.java
```java
package pack_Random;

public class Exercise05 {

	public static void main(String[] args) {
		
		for (int x = 0; x <= 10; x++) {
			for (int y = 0; y <= 10; y++) {
				if ((4 * x) + (5 * y) == 60) {
					System.out.println("(" + x + ", " + y + ")");
				}
			}
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