---
title: "java built-in class 주민등록번호 입력 후 나이,성별 반환"
tags: java built-in class 자바내장클래스 자바주민등록번호 자바나이성별반환
categories: 
    - Algorithm
---

> # 문제
> ![quiz](/assets/images/reg.JPG)
- 주민등록번호 입력 후 나이 성별 반환

<br>
<br>
<br>

> # 코드
> ## Main.java
> ```java
>package pack_NumberFormat;
>
>import java.util.Calendar;
>import java.util.Scanner;
>
>public class Main {
>
>	public static void main(String[] args) {
>		
>		Scanner scanner = new Scanner(System.in);
>		System.out.print("주민등록번호 입력 : ");
>		String regNo = scanner.nextLine();
>		scanner.close();
>		
>		//현재 년도 
>		int year = Calendar.getInstance().get(Calendar.YEAR);
>		
>		// 나이 ex)주민등록번호 앞 두자리 추출 후 변수 저장
>		int age=Integer.parseInt(regNo.substring(0,2)); 
>		
>		// 성별 ex) 주민등록번호 뒷자리 1,2,3,4 뽑아낸 후 변수 저장
>		int gender = Integer.parseInt(regNo.substring(7,8)); 
>		
>		//나이 구하기
>		if (gender== 1 || gender== 2) {
>			age = year-(1900+age)+1;
>		} else if (gender== 3 || gender== 4 ) {
>			age = year-(2000+age)+1;
>		}
>		
>		System.out.printf("나이 : %d세", age);
>		System.out.println();
>		
>		//성별판단
>		if (gender %2 ==0) {
>			System.out.println("성별 : Female");
>		} else {
>			System.out.println("성별 : Male");
>		}
>	}
>}
>```
> 

<br>

> ## 결과
>![quiz](/assets/images/reg1.JPG)
>![quiz](/assets/images/reg2.JPG)
>![quiz](/assets/images/reg3.JPG)


