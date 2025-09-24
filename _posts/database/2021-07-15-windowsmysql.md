---
title: "윈도우10 Mysql 설치"
tags: mysql설치 윈도우mysql설치 mysql
categories: Database
---

> # 윈도우10에 mysql을 설치해보자.
>[https://www.mysql.com/](https://www.mysql.com/ "mysql")에 접속한다.
> ![mysqlsite](/assets/images/mysql_com.JPG)
> <br>
> <br>
> <br>
> 하단에 있는 MySQL Community Server 클릭
>![mysqlsite](/assets/images/mysql_com2.JPG)
> <br>
> <br>
> <br>
>Windows(x86, 32 & 64-bit), MySQL Installer MSI 옆에 Go to Download Page 클릭
>![mysqlsite](/assets/images/mysql_com3.JPG)
> <br>
> <br>
> <br>
>제일 용량이 큰 파일을 다운 받는다.
>![mysqlsite](/assets/images/mysql_com4.JPG)
> <br>
> <br>
> <br>
>다운받은 설치파일을 더블클릭 하면 이렇게 나온다. Server only를 선택해주고 next
>![mysql](/assets/images/mysql1.JPG)
> <br>
> <br>
> <br>
>next ~~
>![mysql](/assets/images/mysql2.JPG)
> <br>
> <br>
> <br>
>Port는 3306으로 되어있을거다. next 누르자.
>![mysql](/assets/images/mysql3.JPG)
> <br>
> <br>
> <br>
>next ~~
>![mysql](/assets/images/mysql4.JPG)
> <br>
> <br>
> <br>
> password설정(기억해두자)을 하고 next
>![mysql](/assets/images/mysql5.JPG)
> <br>
> <br>
> <br>
> next ~~
>![mysql](/assets/images/mysql6.JPG)
> <br>
> <br>
> <br>
> 뭐 저렇게 체크체크가 뜨는데 다 되면 finish 눌러주자.
>![mysql](/assets/images/mysql7.JPG)
> <br>
> <br>
> <br>
> next 눌러주자.
>![mysql](/assets/images/mysql8.JPG)
> <br>
> <br>
> <br>
> finish 눌러주자.
>![mysql](/assets/images/mysql9.JPG)
> <br>
> <br>
> <br>
> 시작버튼을 눌러보면 이렇게 설치가 된 것을 알 수 있다.
>![mysql](/assets/images/dd.jpg)
> <br>
> <br>
> <br>
>윈도우키 +R을 눌러서 services.msc를 적고 엔터
>![mysql](/assets/images/mysql10.JPG)
> <br>
> <br>
> <br>
> 밑으로 쭉 내리다가 MySQL80 실행상태인지 자동으로 되어 있는지 확인.
>![mysql](/assets/images/mysql11.JPG)
> <br>
> <br>
> <br>
> C:\Program Files\MySQL\MySQL Server 8.0\bin 주소를 복사한다.
>![mysql](/assets/images/sqlsql.JPG)
> <br>
> <br>
> <br>
> 윈도우키+R 입력 후 sysdm.cpl 입력 후 엔터
>![mysql](/assets/images/sqlsql2.JPG)
> <br>
> <br>
> <br>
> 고급 - 환경변수 클릭
>![mysql](/assets/images/system1.JPG)
> <br>
> <br>
> <br>
> Path 탭 클릭 후 편집 클릭
>![mysql](/assets/images/path.JPG)
> <br>
> <br>
> <br>
> 새로만들기 클릭 후 C:\Program Files\MySQL\MySQL Server 8.0\bin (mysql이 설치된 곳)<br>
>추가 후 확인
>![mysql](/assets/images/path2.JPG)
> <br>
> <br>
> <br>
> 윈도우키 + R 누른후 cmd 치고 엔터
>![mysql](/assets/images/mysql12.JPG)
> <br>
> <br>
> <br>
> mysql -u root -p 타이핑 후 엔터 <br>
> 아까 설치할때 설정했던 password 입력 후 엔터 <br>
> show databases; 입력후 엔터 <br>
> 밑에 있는것처럼 나오면 설치가 완료 된거다.
>![mysql](/assets/images/mysql13.JPG)
