---
title: "JAVA 두 개의 주사위"
tags: JAVA 자바주사위 
categories: 
    - Algorithm
---


![quiz](/assets/images/cap1.PNG)
<br>
<br>

## 풀이
```java
package pack_Random;

public class Main {

	public static void main(String[] args) {
		
		int num1 = 0;
		int num2 = 0;
		
		while (num1 + num2 !=5) {
			num1 = (int) (Math.random() * 6+1);
			num2 = (int) (Math.random() * 6+1);
			
			System.out.println("(" + num1 +"," + num2 + ")");
			
		}
	}
}

```
<br>
<br>

## 결과
![quiz](/assets/images/cap1res.PNG)