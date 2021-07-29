---
title: "JAVA 방정식 4x + 5y = 60 계산"
tags: JAVA 자바방정식 
---


![quiz](/assets/images/cap2.PNG)
<br>
<br>

## 풀이
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

## 결과
![quiz](/assets/images/cap2res.PNG)