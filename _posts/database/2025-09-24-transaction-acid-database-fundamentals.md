---
title: "트랜잭션과 ACID"
date: 2025-09-24
categories: Database
tags: [Database, Transaction, ACID, MySQL, PostgreSQL, 데이터무결성]
author: pitbull terrier
---

# 트랜잭션과 ACID

데이터베이스를 다루다 보면 "트랜잭션"이라는 말을 자주 듣게 된다. 하지만 정작 트랜잭션이 뭔지, 왜 중요한지 제대로 알고 있는 개발자가 많지 않다. 오늘은 트랜잭션의 핵심인 ACID 원칙부터 실제 코드 예제까지, 데이터베이스의 가장 중요한 개념을 차근차근 알아보자.

## 트랜잭션이란 무엇인가

트랜잭션은 데이터베이스에서 하나의 논리적 작업 단위를 의미한다. 쉽게 말해서 "전부 성공하거나 전부 실패하는" 작업의 묶음이다.

예를 들어, 은행에서 계좌이체를 한다고 생각해보자. 내 계좌에서 10만원을 빼고, 상대방 계좌에 10만원을 넣는 작업이 있다. 이 두 작업은 하나의 트랜잭션으로 묶여야 한다. 내 계좌에서 돈을 뺐는데 상대방 계좌에 넣지 못했다면? 그럼 돈이 사라진다. 반대로 상대방 계좌에 돈을 넣었는데 내 계좌에서 빼지 못했다면? 그럼 돈이 마술처럼 생겨난다.

```sql
-- 트랜잭션 시작
START TRANSACTION;

-- 내 계좌에서 돈 빼기
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'my_account';

-- 상대방 계좌에 돈 넣기
UPDATE accounts SET balance = balance + 100000 WHERE account_id = 'other_account';

-- 모든 작업이 성공하면 커밋
COMMIT;
```

이렇게 하나의 트랜잭션으로 묶으면, 두 작업이 모두 성공하거나 모두 실패한다. 중간에 뭔가 잘못되면 모든 변경사항이 취소된다.

## ACID 원칙 - 트랜잭션의 4가지 핵심 특성

트랜잭션은 ACID라는 4가지 특성을 가져야 한다. 이게 바로 데이터베이스가 신뢰할 수 있는 이유다.

### 1. Atomicity (원자성) - 전부 아니면 전무

원자성은 트랜잭션의 모든 작업이 성공하거나, 모두 실패해야 한다는 의미다. 중간 상태는 없다.

```sql
-- 잘못된 예: 트랜잭션 없이 실행
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'my_account';
-- 여기서 서버가 다운되면? 돈은 빠졌는데 상대방에게는 안 들어갔다

-- 올바른 예: 트랜잭션으로 보호
START TRANSACTION;
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'my_account';
UPDATE accounts SET balance = balance + 100000 WHERE account_id = 'other_account';
COMMIT;
-- 이제 안전하다. 전부 성공하거나 전부 실패한다
```

실제로 이런 상황을 경험해본 적이 있을 것이다. 온라인 쇼핑몰에서 결제는 됐는데 주문이 안 들어갔다거나, 반대로 주문은 됐는데 결제가 안 된 경우 말이다. 이런 일이 생기는 이유가 바로 트랜잭션 처리가 제대로 안 되어서다.

### 2. Consistency (일관성) - 데이터의 규칙 준수

일관성은 트랜잭션 실행 전후로 데이터베이스가 항상 유효한 상태를 유지해야 한다는 의미다.

```sql
-- 예: 계좌 잔액은 음수가 될 수 없다는 규칙
CREATE TABLE accounts (
    account_id VARCHAR(50) PRIMARY KEY,
    balance INT CHECK (balance >= 0)  -- 잔액은 0 이상이어야 함
);

-- 트랜잭션 실행
START TRANSACTION;
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'my_account';
-- 만약 잔액이 50,000원인데 100,000원을 빼려고 하면?
-- CHECK 제약조건 때문에 트랜잭션이 실패한다
-- 이게 바로 일관성 보장이다
```

일관성은 데이터베이스의 제약조건, 트리거, 외래키 등으로 보장된다. 트랜잭션 중간에는 일시적으로 일관성이 깨질 수 있지만, 트랜잭션이 끝나면 반드시 유효한 상태로 돌아간다.

### 3. Isolation (격리성) - 동시성 제어

격리성은 여러 트랜잭션이 동시에 실행될 때 서로 간섭하지 않아야 한다는 의미다.

```sql
-- 트랜잭션 A
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 'my_account';  -- 100,000원 조회
-- 여기서 잠시 대기...

-- 트랜잭션 B (동시에 실행)
START TRANSACTION;
UPDATE accounts SET balance = balance - 50000 WHERE account_id = 'my_account';  -- 50,000원 출금
COMMIT;

-- 트랜잭션 A 계속
UPDATE accounts SET balance = balance - 30000 WHERE account_id = 'my_account';  -- 30,000원 출금
COMMIT;
```

격리성이 없다면? 트랜잭션 A는 처음에 100,000원을 봤는데, 실제로는 트랜잭션 B가 50,000원을 뺀 후의 상태에서 30,000원을 빼게 된다. 결과적으로 계좌 잔액은 20,000원이 되어야 하는데, 트랜잭션 A는 70,000원이 될 거라고 생각한다. 이런 상황을 "더티 리드"라고 한다.

### 4. Durability (지속성) - 영구 저장

지속성은 트랜잭션이 성공적으로 커밋되면 그 결과가 영구적으로 저장되어야 한다는 의미다.

```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'my_account';
UPDATE accounts SET balance = balance + 100000 WHERE account_id = 'other_account';
COMMIT;
-- 커밋이 성공하면, 서버가 다운되어도 이 변경사항은 사라지지 않는다
```

데이터베이스는 WAL(Write-Ahead Logging), 체크포인트, 리두 로그 등으로 지속성을 보장한다. 커밋된 데이터는 디스크에 물리적으로 저장되기 때문에 전원이 나가도 사라지지 않는다.

## 격리 수준 - 격리성의 정도

격리성은 완벽하게 보장하려면 성능이 떨어진다. 그래서 데이터베이스는 여러 격리 수준을 제공한다.

### 1. READ UNCOMMITTED (레벨 0)

가장 낮은 격리 수준이다. 다른 트랜잭션이 아직 커밋하지 않은 데이터도 읽을 수 있다.

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 'my_account';
-- 다른 트랜잭션이 아직 커밋하지 않은 변경사항도 보인다
-- 더티 리드 발생 가능
```

이 레벨에서는 더티 리드가 발생할 수 있어서 거의 사용하지 않는다.

### 2. READ COMMITTED (레벨 1)

다른 트랜잭션이 커밋한 데이터만 읽을 수 있다. 대부분의 데이터베이스가 기본값으로 사용한다.

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 'my_account';  -- 100,000원
-- 다른 트랜잭션이 50,000원을 출금하고 커밋
SELECT balance FROM accounts WHERE account_id = 'my_account';  -- 50,000원
-- 같은 트랜잭션 내에서도 다른 값이 나올 수 있다 (Non-repeatable read)
```

더티 리드는 방지하지만, 같은 트랜잭션 내에서 같은 쿼리를 두 번 실행했을 때 다른 결과가 나올 수 있다.

### 3. REPEATABLE READ (레벨 2)

같은 트랜잭션 내에서 같은 쿼리는 항상 같은 결과를 반환한다.

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 'my_account';  -- 100,000원
-- 다른 트랜잭션이 50,000원을 출금하고 커밋
SELECT balance FROM accounts WHERE account_id = 'my_account';  -- 여전히 100,000원
-- 같은 트랜잭션 내에서는 일관된 결과를 보장한다
```

MySQL의 InnoDB가 기본값으로 사용하는 격리 수준이다. 하지만 팬텀 리드는 여전히 발생할 수 있다.

### 4. SERIALIZABLE (레벨 3)

가장 높은 격리 수준이다. 트랜잭션들이 순차적으로 실행되는 것처럼 동작한다.

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT balance FROM accounts WHERE account_id = 'my_account';
-- 다른 트랜잭션의 모든 변경이 차단된다
-- 완벽한 격리이지만 성능이 가장 떨어진다
```

완벽한 격리를 보장하지만 성능상 오버헤드가 크다.

## 실제 개발에서 트랜잭션 다루기

### Java에서의 트랜잭션

```java
@Service
@Transactional
public class AccountService {
    
    @Autowired
    private AccountRepository accountRepository;
    
    public void transfer(String fromAccount, String toAccount, int amount) {
        // 이 메서드 전체가 하나의 트랜잭션으로 실행된다
        Account from = accountRepository.findById(fromAccount);
        Account to = accountRepository.findById(toAccount);
        
        if (from.getBalance() < amount) {
            throw new InsufficientFundsException("잔액이 부족합니다");
        }
        
        from.withdraw(amount);
        to.deposit(amount);
        
        accountRepository.save(from);
        accountRepository.save(to);
        
        // 예외가 발생하면 모든 변경사항이 롤백된다
    }
}
```

Spring의 `@Transactional` 어노테이션을 사용하면 자동으로 트랜잭션이 관리된다. 메서드가 정상적으로 끝나면 커밋되고, 예외가 발생하면 롤백된다.

### 트랜잭션 롤백 시나리오

```java
@Service
public class OrderService {
    
    @Transactional
    public void createOrder(OrderRequest request) {
        // 1. 주문 생성
        Order order = new Order(request);
        orderRepository.save(order);
        
        // 2. 재고 차감
        inventoryService.decreaseStock(request.getProductId(), request.getQuantity());
        
        // 3. 결제 처리
        paymentService.processPayment(request.getPaymentInfo());
        
        // 만약 결제 처리에서 예외가 발생하면?
        // 주문 생성과 재고 차감도 모두 롤백된다
    }
}
```

이렇게 하나의 트랜잭션으로 묶으면, 중간에 어떤 단계에서든 실패하면 모든 작업이 취소된다. 데이터의 일관성이 보장된다.

## 트랜잭션에서 주의해야 할 점들

### 1. 트랜잭션 범위는 최소화하자

```java
// 나쁜 예: 트랜잭션이 너무 길다
@Transactional
public void processLargeData() {
    List<Data> dataList = dataRepository.findAll(); // 100만 건 조회
    
    for (Data data : dataList) {
        // 복잡한 비즈니스 로직
        processData(data);
        
        // 외부 API 호출
        externalApiService.call(data);
        
        dataRepository.save(data);
    }
    // 이 트랜잭션은 너무 오래 지속된다
}

// 좋은 예: 배치 단위로 트랜잭션 분리
public void processLargeData() {
    List<Data> dataList = dataRepository.findAll();
    
    for (List<Data> batch : Lists.partition(dataList, 1000)) {
        processBatch(batch);
    }
}

@Transactional
public void processBatch(List<Data> batch) {
    for (Data data : batch) {
        processData(data);
        dataRepository.save(data);
    }
}
```

트랜잭션이 길수록 락을 오래 잡고 있어서 다른 트랜잭션들이 대기하게 된다. 성능에 악영향을 준다.

### 2. 읽기 전용 트랜잭션 활용

```java
@Transactional(readOnly = true)
public List<Account> getAccountsByUser(String userId) {
    // 읽기 전용 트랜잭션으로 성능 최적화
    return accountRepository.findByUserId(userId);
}
```

읽기 전용 트랜잭션은 락을 걸지 않아서 성능이 좋다. 조회만 하는 메서드에는 이렇게 설정하자.

### 3. 트랜잭션 전파 속성 이해하기

```java
@Service
public class OrderService {
    
    @Transactional
    public void createOrder(OrderRequest request) {
        orderRepository.save(new Order(request));
        
        // 이 메서드도 트랜잭션에 참여한다
        inventoryService.decreaseStock(request.getProductId(), request.getQuantity());
    }
}

@Service
public class InventoryService {
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void decreaseStock(String productId, int quantity) {
        // 새로운 트랜잭션을 시작한다
        // 부모 트랜잭션과 독립적으로 실행된다
        inventoryRepository.decreaseStock(productId, quantity);
    }
}
```

`REQUIRES_NEW`를 사용하면 새로운 트랜잭션을 시작한다. 부모 트랜잭션이 롤백되어도 이 작업은 커밋된다.

## 마무리

트랜잭션과 ACID는 데이터베이스의 핵심 개념이다. 이걸 제대로 이해하지 못하면 데이터 무결성 문제로 고생하게 된다.

실제로 개발하다 보면 "왜 이 데이터가 이렇게 되어 있지?" 하는 상황을 자주 만난다. 대부분 트랜잭션 처리를 제대로 하지 않아서 생기는 문제다.

트랜잭션은 성능과 일관성 사이의 균형을 맞추는 기술이다. 너무 보수적으로 하면 성능이 떨어지고, 너무 느슨하게 하면 데이터가 깨진다. 프로젝트의 요구사항에 맞는 적절한 격리 수준을 선택하는 것이 중요하다.
