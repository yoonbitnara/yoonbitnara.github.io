---
title: "Mysql Quiz"
tag : mysql문제 mysqlquiz mysql연습문제
---

![quiz](/assets/images/mysqlquiz1.JPG)<br>
<br>
<br>
<br>

# 풀이
```sql
create database cafemanage; # 데이터베이스 생성

use cafemanage; # 데이터베이스 사용

create table goodslist ( # 테이블 생성
goodsname char(20), # 상품명
cnt int, # 수량
unit_price int, # 단가
sale_price int # 금액
); 

select * from goodslist; # goodslist data 확인

# 테이블에 데이터 삽입
insert into goodslist (goodsname, cnt, unit_price, sale_price) 
values 
('초콜릿', 3, 1000, 3000),
('케이크', 1, 25000, 25000),
('샴페인', 1, 7000, 7000);

# 케이크 단가, 금액 3000으로 수정
update goodslist set unit_price = 30000, ssale_price = 30000 where goodsname = '케이크';

# 샴페인 데이터 삭제
delete from goodslist where goodsname = '샴페인';

# 타르트 데이터 생성
insert into goodslist (goodsname, cnt, unit_price, sale_price) 
values
('타르트', 5, 1200, 6000);
```