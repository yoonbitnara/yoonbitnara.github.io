---
layout: single
title: "코드 커버리지와 품질 관리"
categories: Code-Quality
tags: [코드품질, 테스트, 커버리지, 품질관리, 개발철학]
date: 2025-09-30
---

# 코드 커버리지와 품질 관리

개발하다 보면 항상 고민되는 게 있다. "이 코드가 제대로 작동할까?"

처음에는 그냥 실행해보고 에러가 없으면 되는 줄 알았다. 하지만 프로젝트가 커질수록, 팀이 커질수록 그런 방식으로는 한계가 명확해졌다. 

"이 부분은 테스트해봤는데, 저 부분은 어떨까?" 이런 불안감이 계속 생긴다. 그럴 때 코드 커버리지라는 개념을 알게 되었다.

하지만 커버리지 100%가 정말 좋은 걸까? 숫자만 보고 판단하는 게 맞을까?

## 코드 커버리지란?

### 기본 개념

코드 커버리지는 테스트가 실제 코드의 얼마나 많은 부분을 실행했는지를 측정하는 지표다.

```java
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
    
    public int divide(int a, int b) {
        if (b == 0) {
            throw new IllegalArgumentException("0으로 나눌 수 없습니다");
        }
        return a / b;
    }
}
```

이 코드에서 add 메서드만 테스트했다면 커버리지는 50%가 된다. divide 메서드의 예외 처리 부분까지 테스트해야 100%가 된다.

### 커버리지 종류

#### 1. 라인 커버리지 (Line Coverage)
실행된 코드 라인의 비율을 측정한다.

```java
public void processUser(String name, int age) {
    if (name == null) {           // 라인 1
        throw new IllegalArgumentException(); // 라인 2
    }
    
    if (age < 0) {                // 라인 3
        throw new IllegalArgumentException(); // 라인 4
    }
    
    // 실제 처리 로직              // 라인 5
    System.out.println(name + " : " + age);
}
```

name이 null인 경우만 테스트하면 라인 1, 2, 5가 실행되어 60% 커버리지가 된다.

#### 2. 브랜치 커버리지 (Branch Coverage)
분기문을 얼마나 테스트했는지 측정한다.

```java
public String getGrade(int score) {
    if (score >= 90) {
        return "A";
    } else if (score >= 80) {
        return "B";
    } else if (score >= 70) {
        return "C";
    } else {
        return "F";
    }
}
```

각 조건문의 true/false 케이스를 모두 테스트해야 한다.

#### 3. 조건 커버리지 (Condition Coverage)
각 조건의 true/false를 테스트한다.

```java
public boolean canVote(int age, boolean isCitizen) {
    return age >= 18 && isCitizen;
}
```

age >= 18과 isCitizen 각각의 true/false 케이스를 테스트해야 한다.

## 커버리지 도구들

### Java - JaCoCo

널리 사용되는 Java 커버리지 도구다.

```xml
<!-- Maven 설정 -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.7</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### JavaScript - Istanbul (nyc)

```json
{
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "jest": "^27.0.0",
    "@types/jest": "^27.0.0"
  }
}
```

### Python - coverage.py

```bash
pip install coverage
coverage run -m pytest
coverage report
coverage html  # HTML 리포트 생성
```

## 커버리지의 함정

### 100% 커버리지의 착각

커버리지 100%가 항상 좋은 건 아니다. 잘못된 테스트로 인해 오히려 나쁠 수 있다.

```java
public String processData(String input) {
    // 복잡한 비즈니스 로직
    if (input == null) {
        return "default";
    }
    
    // 실제 중요한 로직
    String result = complexBusinessLogic(input);
    
    return result;
}

// 잘못된 테스트 - 커버리지만 채우려고 작성
@Test
public void testProcessData() {
    String result = processData("test");
    assertNotNull(result);  // 의미 없는 테스트
}
```

이 테스트는 커버리지는 높지만 실제로 코드가 제대로 작동하는지 검증하지 못한다.

### 의미 있는 테스트 작성하기

```java
// 올바른 테스트
@Test
public void testProcessData_ValidInput() {
    String result = processData("valid_input");
    assertEquals("expected_result", result);
}

@Test
public void testProcessData_NullInput() {
    String result = processData(null);
    assertEquals("default", result);
}

@Test
public void testProcessData_EdgeCase() {
    String result = processData("");
    assertEquals("empty_result", result);
}
```

## 품질 관리의 철학

### 테스트는 왜 필요한가?

테스트는 단순히 버그를 찾기 위한 게 아니다. 더 중요한 건 코드의 의도를 명확히 하는 것이다.

```java
// 테스트가 없는 코드
public class UserService {
    public User createUser(String email, String password) {
        // 복잡한 로직
        User user = new User();
        user.setEmail(email);
        user.setPassword(hashPassword(password));
        user.setCreatedAt(LocalDateTime.now());
        return userRepository.save(user);
    }
}

// 테스트가 있는 코드
@Test
public void testCreateUser_ValidInput() {
    // Given
    String email = "test@example.com";
    String password = "password123";
    
    // When
    User result = userService.createUser(email, password);
    
    // Then
    assertEquals(email, result.getEmail());
    assertNotNull(result.getPassword());
    assertTrue(result.getPassword().startsWith("$2a$")); // 해시 확인
    assertNotNull(result.getCreatedAt());
}
```

테스트를 보면 이 메서드가 무엇을 하는지, 어떤 결과를 기대하는지 명확해진다.

### 품질 지표의 균형

커버리지만으로는 품질을 판단할 수 없다. 여러 지표를 종합적으로 봐야 한다.

#### 1. 커버리지 (Coverage)
- 라인 커버리지: 80% 이상
- 브랜치 커버리지: 70% 이상

#### 2. 복잡도 (Complexity)
- 순환 복잡도가 높은 메서드는 더 많은 테스트가 필요

```java
// 복잡도가 높은 메서드
public String processOrder(Order order) {
    if (order == null) return "INVALID";
    if (!order.isValid()) return "INVALID";
    if (order.getStatus() == OrderStatus.CANCELLED) return "CANCELLED";
    if (order.getPaymentStatus() != PaymentStatus.PAID) return "UNPAID";
    if (order.getItems().isEmpty()) return "EMPTY";
    
    // 실제 처리 로직
    return "PROCESSED";
}
```

#### 3. 결합도 (Coupling)
- 의존성이 많은 클래스는 테스트하기 어렵다

```java
// 결합도가 높은 코드
public class OrderService {
    private UserService userService;
    private PaymentService paymentService;
    private InventoryService inventoryService;
    private NotificationService notificationService;
    private EmailService emailService;
    // ... 더 많은 의존성
}
```

#### 4. 응집도 (Cohesion)
- 하나의 책임만 가진 클래스가 테스트하기 쉽다

```java
// 응집도가 높은 코드
public class PasswordValidator {
    public boolean isValid(String password) {
        return hasMinLength(password) && 
               hasUpperCase(password) && 
               hasNumber(password);
    }
}
```

## 실무에서의 품질 관리

### 점진적 개선

한 번에 모든 것을 완벽하게 하려고 하면 실패한다. 점진적으로 개선해나가야 한다.

#### 1단계: 핵심 로직부터 테스트
```java
// 가장 중요한 비즈니스 로직부터
public class PaymentService {
    public PaymentResult processPayment(PaymentRequest request) {
        // 핵심 로직
        if (request.getAmount() <= 0) {
            return PaymentResult.failure("Invalid amount");
        }
        
        // 결제 처리
        return processPaymentWithGateway(request);
    }
}
```

#### 2단계: 경계값 테스트
```java
@Test
public void testProcessPayment_EdgeCases() {
    // 0원 결제
    PaymentResult result1 = paymentService.processPayment(
        new PaymentRequest(0));
    assertFalse(result1.isSuccess());
    
    // 음수 금액
    PaymentResult result2 = paymentService.processPayment(
        new PaymentRequest(-100));
    assertFalse(result2.isSuccess());
    
    // 매우 큰 금액
    PaymentResult result3 = paymentService.processPayment(
        new PaymentRequest(Integer.MAX_VALUE));
    // 예상 결과에 따라 검증
}
```

#### 3단계: 통합 테스트
```java
@SpringBootTest
public class PaymentIntegrationTest {
    @Autowired
    private PaymentService paymentService;
    
    @Test
    @Transactional
    public void testCompletePaymentFlow() {
        // 실제 데이터베이스와 함께 테스트
        PaymentRequest request = createValidPaymentRequest();
        PaymentResult result = paymentService.processPayment(request);
        
        assertTrue(result.isSuccess());
        // 데이터베이스 상태도 확인
    }
}
```

### 팀 차원의 품질 관리

#### 코드 리뷰에서 확인할 것들

코드 리뷰할 때는 단순히 문법이나 스타일만 보는 게 아니다. 테스트가 제대로 있는지, 의미 있는 테스트인지 확인해야 한다. 커버리지가 적절한지도 보고, 복잡도가 높은 부분은 더 많은 테스트가 필요하다는 걸 알려줘야 한다.

#### CI/CD 파이프라인에서 자동화
```yaml
# GitHub Actions 예시
name: Test and Coverage
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests with coverage
        run: |
          mvn test jacoco:report
      - name: Check coverage threshold
        run: |
          # 커버리지 임계값 확인
          mvn jacoco:check
```

## 품질 관리의 현실

### 이상과 현실의 균형

이론적으로는 모든 코드를 완벽하게 테스트해야 한다. 하지만 현실은 다르다.

#### 시간과 비용 고려
- 모든 코드를 100% 테스트하는 데 드는 시간
- 유지보수 비용
- 비즈니스 가치와의 균형

#### 우선순위 설정
1. **핵심 비즈니스 로직**: 높은 우선순위
2. **외부 API 연동**: 높은 우선순위  
3. **유틸리티 함수**: 중간 우선순위
4. **단순한 getter/setter**: 낮은 우선순위

### 레거시 코드와의 공존

기존 코드에 테스트가 없다고 해서 모든 것을 다시 작성할 수는 없다.

```java
// 레거시 코드
public class LegacyService {
    public String processLegacyData(String data) {
        // 복잡하고 테스트하기 어려운 코드
        // 하지만 현재 잘 작동하고 있음
        return processedData;
    }
}

// 점진적 개선 방법
public class LegacyServiceWrapper {
    private LegacyService legacyService;
    
    public String processData(String data) {
        // 입력 검증 추가
        if (data == null || data.trim().isEmpty()) {
            throw new IllegalArgumentException("Data cannot be empty");
        }
        
        // 기존 로직 실행
        String result = legacyService.processLegacyData(data);
        
        // 결과 검증 추가
        if (result == null) {
            throw new RuntimeException("Processing failed");
        }
        
        return result;
    }
}
```

## 마무리

코드 커버리지는 품질 관리의 도구일 뿐이다. 목적이 되어서는 안 된다.

진짜 중요한 건 의미 있는 테스트를 작성하는 것이다. 테스트가 코드의 의도를 명확히 하고, 변경 시 안전장치 역할을 해야 한다.

커버리지 100%를 달성하는 것보다, 핵심 로직을 확실하게 테스트하고, 팀이 함께 품질을 개선해나가는 문화를 만드는 게 더 중요하다.

숫자에 매몰되지 말고, 실제로 코드가 더 안전하고 유지보수하기 쉬워지는지에 집중해야 한다.
