---
layout: single
title: "데이터베이스 인덱스, 이제 제대로 써보자"
categories: Database
tags: [데이터베이스, 인덱스, 성능튜닝, MySQL, PostgreSQL, SQL최적화]
date: 2025-09-30
---

# 데이터베이스 인덱스, 이제 제대로 써보자

개발하다 보면 항상 마주치는 문제가 있다. "왜 이 쿼리가 이렇게 느리지?"

처음에는 그냥 기다렸다. 3초면 충분하지 않나? 하지만 사용자가 늘어날수록 3초가 10초가 되고, 결국 타임아웃이 뜬다. 그때서야 인덱스의 존재를 기억한다.

"아, 인덱스 만들어야겠다"고 생각하고 무작정 인덱스를 때려박는다. 그런데 뭔가 더 느려진 것 같다. 이상하다. 분명히 인덱스를 만들었는데 왜 느려졌을까?

오늘은 이런 고민들을 해결해보자.

## 인덱스가 뭔데?

### 기본 개념

인덱스는 데이터를 빠르게 찾기 위한 별도의 자료구조다.

```sql
-- 인덱스 없을 때: 전체 테이블 스캔
SELECT * FROM users WHERE email = 'user@example.com';
-- 100만 개 행을 모두 확인해야 함

-- 인덱스 있을 때: 인덱스 스캔
CREATE INDEX idx_users_email ON users(email);
SELECT * FROM users WHERE email = 'user@example.com';
-- 인덱스를 통해 해당 행을 빠르게 찾음
```

100만 개를 다 뒤지느냐, 인덱스로 바로 찾느냐의 차이다.

### 인덱스 종류

#### 1. 단일 컬럼 인덱스
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_date ON orders(order_date);
```

#### 2. 복합 인덱스
```sql
CREATE INDEX idx_users_name_age ON users(last_name, age);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
```

#### 3. 유니크 인덱스
```sql
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);
```

#### 4. 부분 인덱스 (PostgreSQL만)
```sql
CREATE INDEX idx_orders_active ON orders(customer_id) WHERE status = 'active';
```

## 인덱스 설계 전략

### 1. 카디널리티 고려

고유값이 많은 컬럼에 인덱스를 만들어야 효과적이다.

```sql
-- 좋은 예: 고유값이 많음
CREATE INDEX idx_users_email ON users(email);        -- 100만 개 고유값
CREATE INDEX idx_users_phone ON users(phone);        -- 100만 개 고유값

-- 나쁜 예: 고유값이 적음
CREATE INDEX idx_users_gender ON users(gender);      -- 2개 값 (M, F)
CREATE INDEX idx_users_status ON users(status);      -- 3개 값 (active, inactive, pending)
```

성별 인덱스를 만들면 100만 명 중 50만 명씩 나뉘어서 의미가 없다. 하지만 이메일은 거의 1:1 매칭이라 효과적이다.

### 2. 복합 인덱스의 컬럼 순서

복합 인덱스는 순서가 중요하다. 자주 사용되는 컬럼을 앞에 배치해야 한다.

```sql
-- 실제 쿼리 패턴
SELECT * FROM orders WHERE customer_id = 123 AND order_date >= '2025-01-01';
SELECT * FROM orders WHERE customer_id = 123 AND status = 'completed';

-- 잘못된 순서
CREATE INDEX idx_orders_date_customer ON orders(order_date, customer_id, status);

-- 올바른 순서
CREATE INDEX idx_orders_customer_date_status ON orders(customer_id, order_date, status);
```

복합 인덱스는 첫 번째 컬럼부터 순서대로 사용한다. customer_id가 없으면 order_date로는 검색이 불가능하다.

### 3. 선택성 계산

선택성 = 고유값 개수 / 전체 행 수 (1에 가까울수록 좋음)

```sql
-- 어떤 컬럼이 인덱스로 좋은지 확인
SELECT 
    COUNT(DISTINCT email) / COUNT(*) as email_selectivity,
    COUNT(DISTINCT gender) / COUNT(*) as gender_selectivity
FROM users;

-- 결과:
-- email_selectivity: 0.999 (99.9% - 매우 좋음)
-- gender_selectivity: 0.0005 (0.05% - 매우 나쁨)
```

0.999면 거의 모든 값이 다르다는 뜻이고, 0.0005면 1000명 중 5명만 다르다는 뜻이다. 당연히 0.999가 인덱스로 효과적이다.

## 성능 튜닝 실무 가이드

### 1. 쿼리 실행 계획 분석

느린 쿼리가 있으면 EXPLAIN부터 실행해보자.

```sql
-- MySQL
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- PostgreSQL (더 자세한 정보)
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE email = 'user@example.com';
```

결과 해석:
```sql
-- 좋은 결과 (인덱스 사용)
-- Index Scan using idx_users_email (cost=0.43..8.45 rows=1)
--   Index Cond: (email = 'user@example.com'::text)

-- 나쁜 결과 (전체 테이블 스캔)
-- Seq Scan on users (cost=0.00..18334.00 rows=1)
--   Filter: (email = 'user@example.com'::text)
```

cost가 8.45 vs 18334. 2000배 차이다.

### 2. 슬로우 쿼리 로그 분석

**MySQL 슬로우 쿼리 설정**
```sql
-- 슬로우 쿼리 로그 활성화
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;  -- 1초 이상 걸리는 쿼리 로그

-- 슬로우 쿼리 로그 확인
SHOW VARIABLES LIKE 'slow_query_log%';
```

**PostgreSQL 슬로우 쿼리 설정**
```sql
-- postgresql.conf 설정
log_min_duration_statement = 1000  -- 1초 이상 걸리는 쿼리 로그
log_statement = 'all'              -- 모든 쿼리 로그
```

### 3. 인덱스 사용 패턴 분석

**인덱스 사용률 확인**
```sql
-- MySQL: 인덱스 사용 통계
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    NULLABLE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'your_database'
ORDER BY TABLE_NAME, INDEX_NAME;

-- PostgreSQL: 인덱스 사용 통계
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes;
```

## 실무 인덱싱 패턴

### 1. 웹 애플리케이션 인덱싱

**사용자 테이블 최적화**
```sql
-- 사용자 로그인 최적화
CREATE INDEX idx_users_email_password ON users(email, password_hash);

-- 사용자 검색 최적화
CREATE INDEX idx_users_name_active ON users(last_name, first_name) WHERE status = 'active';

-- 사용자 생성일 기준 정렬 최적화
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

**주문 테이블 최적화**
```sql
-- 고객별 주문 조회 최적화
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date DESC);

-- 주문 상태별 조회 최적화
CREATE INDEX idx_orders_status_date ON orders(status, order_date DESC);

-- 주문 금액 범위 조회 최적화
CREATE INDEX idx_orders_amount ON orders(total_amount);
```

### 2. 분석 쿼리 최적화

**집계 쿼리 최적화**
```sql
-- 월별 매출 집계 최적화
CREATE INDEX idx_orders_date_amount ON orders(order_date, total_amount);

-- 지역별 사용자 수 집계 최적화
CREATE INDEX idx_users_region_created ON users(region, created_at);
```

### 3. 복잡한 조인 쿼리 최적화

**조인 컬럼 인덱싱**
```sql
-- 외래키 인덱스 (자동 생성되지 않는 경우)
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- 조인 최적화 쿼리
SELECT o.order_id, o.order_date, c.customer_name, p.product_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_date >= '2025-01-01';
```

## 인덱스 관리와 모니터링

### 1. 인덱스 크기 모니터링

```sql
-- MySQL: 테이블별 인덱스 크기 확인
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(STAT_VALUE * @@innodb_page_size / 1024 / 1024, 2) AS 'Index Size (MB)'
FROM information_schema.INNODB_SYS_TABLESTATS
WHERE TABLE_NAME = 'users';

-- PostgreSQL: 인덱스 크기 확인
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

### 2. 사용하지 않는 인덱스 찾기

```sql
-- PostgreSQL: 사용하지 않는 인덱스 찾기
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_tup_read = 0 AND idx_tup_fetch = 0;
```

### 3. 인덱스 재구성과 유지보수

```sql
-- MySQL: 인덱스 재구성
ALTER TABLE users REBUILD INDEX idx_users_email;

-- PostgreSQL: 인덱스 재구성
REINDEX INDEX idx_users_email;

-- 인덱스 통계 업데이트
ANALYZE TABLE users;  -- MySQL
ANALYZE users;        -- PostgreSQL
```

## 실무에서 체크해야 할 것들

### 쿼리 최적화할 때

WHERE 절에 사용되는 컬럼에 인덱스가 있는지 확인하자. JOIN 컬럼에도 인덱스가 필요하다. ORDER BY나 GROUP BY에 사용되는 컬럼도 마찬가지다.

복합 인덱스를 만들 때는 실제 쿼리 패턴과 순서가 일치하는지 확인해야 한다. 그리고 불필요한 SELECT * 사용은 피하는 게 좋다.

### 인덱스 설계할 때

고유값이 많은 컬럼부터 선택하자. 자주 사용되는 쿼리 패턴을 먼저 분석해야 한다. 인덱스 크기도 고려해야 하고, 데이터 수정 시마다 업데이트되는 비용도 생각해봐야 한다.

사용하지 않는 인덱스는 정기적으로 제거하자. 용량만 차지한다.

### 모니터링

슬로우 쿼리 로그를 정기적으로 확인하자. 인덱스 사용률도 모니터링해야 한다. 데이터베이스 성능 지표들을 추적하고, 인덱스 크기 증가도 주시해야 한다.

## 실무 팁과 주의사항

### 1. 인덱스 생성 시 주의사항

**너무 많은 인덱스는 성능 저하의 원인**
```sql
-- 나쁜 예: 불필요한 인덱스들
CREATE INDEX idx_users_gender ON users(gender);           -- 카디널리티 낮음
CREATE INDEX idx_users_created_at ON users(created_at);   -- 사용되지 않음
CREATE INDEX idx_users_updated_at ON users(updated_at);   -- 사용되지 않음

-- 좋은 예: 필요한 인덱스만
CREATE INDEX idx_users_email ON users(email);             -- 로그인에 사용
CREATE INDEX idx_users_name_active ON users(last_name) WHERE status = 'active';  -- 검색에 사용
```

### 2. 인덱스 생성 시점 고려

**대용량 테이블에서의 인덱스 생성**
```sql
-- 온라인 인덱스 생성 (MySQL 5.7+)
ALTER TABLE large_table ADD INDEX idx_column (column_name), ALGORITHM=INPLACE, LOCK=NONE;

-- PostgreSQL: 인덱스 생성 중 락 최소화
CREATE INDEX CONCURRENTLY idx_column ON large_table(column_name);
```

### 3. 인덱스와 파티셔닝

**파티션된 테이블의 인덱스 설계**
```sql
-- 날짜별 파티션 테이블의 인덱스
CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    customer_id INT,
    -- ... 다른 컬럼들
) PARTITION BY RANGE (YEAR(order_date));

-- 파티션별 인덱스 생성
ALTER TABLE orders ADD INDEX idx_orders_customer (customer_id);
```

## 결론

인덱스는 만능이 아니다. 하지만 올바르게 사용하면 강력하다.

실제로 어떤 쿼리가 자주 실행되는지 파악하는 게 먼저다. 그 다음에 고유값이 많은 컬럼에 인덱스를 만들고, 복합 인덱스는 자주 사용되는 컬럼을 앞에 배치하자.

정기적으로 모니터링해서 사용하지 않는 인덱스는 제거해야 한다. 느린 쿼리가 있으면 EXPLAIN부터 돌려보는 게 기본이다.

처음에는 복잡해 보일 수 있다. 하지만 몇 번 해보면 패턴이 보인다. 한 번 제대로 만들어두면 성능이 확실히 개선된다.

마지막으로 인덱스를 너무 많이 만들지 마라. 인덱스도 저장공간을 차지하고, 데이터 수정할 때마다 업데이트해야 한다. 
