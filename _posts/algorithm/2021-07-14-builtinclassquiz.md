---
title: "java 프리랜서 세금 계산"
tags: java built-in class 자바내장클래스 자바세금계산
categories: 
    - Algorithm
---

> # 문제
> ![quiz](/assets/images/21-07-14-1.png)
> ![quiz](/assets/images/21-07-14.JPG)
- 천단위 구분 하기.

<br>
<br>
<br>

> # 코드
> ## Main.java
>```java
>package pack_Form;
>
>import java.util.Scanner;
>
>
>public class Main {
>
>	public static void main(String[] args) {
>		
>		Scanner scanner = new Scanner(System.in);
>		System.out.print("세전급여를 입력해 주세요(단위. 원) : ");
>		int money = scanner.nextInt();
>		scanner.close();
>		
>		Money obj = new Money(money);
>		String salary = obj.mtdMoney();
>		System.out.print("실지급액 : " + salary + " 원");
>
>	}
>
>}
>
>}
>```
> 
> ## Money.java
>```java
>package pack_Form;
>
>public class Money {
>	
>	private int money;
>
>	public Money(int money) {
>		this.money = money;
>	}
>	
>	public String mtdMoney() {
>		
>		int moneyParam = money - (int)(money*0.033);
>		Format format = new Format(moneyParam);
>		String salary = format.mtdFormat();
>		
>		return salary;
>		
>	}
>
>}
>
>```
> 
> ## Format.java
>```java
>package pack_Form;
>
>import java.text.NumberFormat;
>
>public class Format {
>	
>	private int moneyParam;
>
>	public Format(int moneyParam) {
>		this.moneyParam = moneyParam;
>	}
>	
>	public String mtdFormat() {
>		
>		String salary = NumberFormat.getInstance().format(moneyParam);
>		
>		return salary;
>	}
>
>}
>
>```
> 
<br>

> ## 결과
>![quiz](/assets/images/21-07-14-res.JPG)


