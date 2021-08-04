---
title: "JAVA interface quiz"
tags: JAVAinterface 
---


![interface](/assets/images/quiz_interface.PNG)
<br>
<br>
<br>

## ExamJava.java (메인클래스)
```java
package pack_Yaksu;

public class ExamJava {

	public static void main(String[] args) {
		
		int rndValParam;
		rndValParam = (int)((20-10+1)*Math.random() + 10);
		
		YaksuList objSuper = new YaksuList(rndValParam);
		YaksuSum objSub = new YaksuSum(rndValParam);
		
		
		System.out.println("[결과화면]\n");
		System.out.println("생성된 랜덤 값 : " + rndValParam);
		
		objSuper.mtdYaksu();
		objSub.mtdYaksu();
	}
}
```
<br>
<br>
<br>

## Yaksu.java (인터페이스)
```java
package pack_Yaksu;

public interface Yaksu {
	
	public void mtdYaksu();

}
```
<br>
<br>
<br>

## YaksuList.java (슈퍼클래스)
```java
package pack_Yaksu;

public class YaksuList implements Yaksu {
	
	private int rndNum;

	public YaksuList(int rndNum) {
		this.rndNum = rndNum;
	}

	@Override
	public void mtdYaksu() {
		System.out.println();
		System.out.println("약수");
		
		for (int i = 1; i <= rndNum; i++) {
			
			if (rndNum % i  == 0) {
				System.out.print(i);
				
				if (i < rndNum) {
					System.out.print("  ");
				}
			}
		}
		System.out.println();
		System.out.println();
	}

	public int getRndNum() {
		return rndNum;
	}
}
```
<br>
<br>
<br>

## YaksuSum.java (서브클래스)
```java
package pack_Yaksu;

public class YaksuSum extends YaksuList {
	
	public YaksuSum(int rndNum) {
		super(rndNum);
	}

	@Override
	public void mtdYaksu() {
		
		int sum = 0;
		
		int rndNum = super.getRndNum();
		
		for (int i = 1; i <= rndNum; i++) {
			
			if (rndNum % i  == 0) {
				sum += i;
			}
		}
		System.out.println("약수의 합 : " + sum);
	}
}
```
<br>
<br>
<br>

## 결과
![interface_res](/assets/images/interface_res.PNG)