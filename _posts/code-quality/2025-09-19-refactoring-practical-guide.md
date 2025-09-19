---
title: "리팩토링에 관하여"
tags: 리팩토링, 코드품질, CleanCode, Java, JavaScript
date: "2025.09.19"
categories: 
    - Code-Quality
---

# 리팩토링에 관하여

개발하다 보면 "일단 돌아가게 만들자"라는 생각으로 코드를 작성할 때가 있다. 기능 구현에 급급해서 변수명은 대충 짓고, 함수는 길게 만들고, 중복 코드는 그대로 두고... 

그런데 몇 달 뒤에 그 코드를 다시 보면 "이게 뭐지?"라는 생각이 든다. 나도 그런 코드를 많이 작성했고, 지금도 가끔 그런 실수를 한다.

리팩토링은 그런 코드를 깔끔하게 정리하는 작업이다. 기능은 그대로 두고 코드만 개선하는 것이다. 오늘은 실제로 리팩토링을 어떻게 하는지, 어떤 효과가 있는지 알아보자.

## 왜 리팩토링이 필요한가?

### 유지보수의 어려움

예전에 작성한 코드를 보자.

```java
// 리팩토링 전 - 나쁜 예시
public void processOrder(String orderId, String userId, String productId, int quantity, double price, String address, String phone, String email) {
    // 주문 처리 로직
    Order order = new Order();
    order.setOrderId(orderId);
    order.setUserId(userId);
    order.setProductId(productId);
    order.setQuantity(quantity);
    order.setPrice(price);
    order.setAddress(address);
    order.setPhone(phone);
    order.setEmail(email);
    
    // 데이터베이스 저장
    orderRepository.save(order);
    
    // 재고 차감
    Product product = productRepository.findById(productId);
    product.setStock(product.getStock() - quantity);
    productRepository.save(product);
    
    // 이메일 발송
    String subject = "주문이 완료되었습니다";
    String body = "주문번호: " + orderId + ", 상품: " + productId + ", 수량: " + quantity + ", 가격: " + price;
    emailService.sendEmail(email, subject, body);
    
    // SMS 발송
    String smsBody = "주문이 완료되었습니다. 주문번호: " + orderId;
    smsService.sendSms(phone, smsBody);
    
    // 로그 기록
    log.info("주문 처리 완료: " + orderId + ", 사용자: " + userId + ", 상품: " + productId);
}
```

이 코드의 문제점들
1. **함수가 너무 길다**: 하나의 함수에서 너무 많은 일을 한다
2. **파라미터가 너무 많다**: 8개의 파라미터는 관리하기 어렵다
3. **책임이 분산되지 않았다**: 주문 생성, 재고 관리, 알림 발송이 모두 섞여있다
4. **하드코딩된 문자열**: 이메일 제목, 내용이 코드에 직접 들어가있다
5. **에러 처리가 없다**: 중간에 실패하면 어떻게 될까?

### 리팩토링 후

```java
// 리팩토링 후 - 좋은 예시
public class OrderService {
    
    public void processOrder(OrderRequest request) {
        try {
            Order order = createOrder(request);
            updateInventory(request);
            sendNotifications(order);
            logOrderCompletion(order);
        } catch (Exception e) {
            log.error("주문 처리 중 오류 발생", e);
            throw new OrderProcessingException("주문 처리에 실패했습니다", e);
        }
    }
    
    private Order createOrder(OrderRequest request) {
        Order order = Order.builder()
            .orderId(generateOrderId())
            .userId(request.getUserId())
            .productId(request.getProductId())
            .quantity(request.getQuantity())
            .price(request.getPrice())
            .address(request.getAddress())
            .phone(request.getPhone())
            .email(request.getEmail())
            .build();
            
        return orderRepository.save(order);
    }
    
    private void updateInventory(OrderRequest request) {
        Product product = productRepository.findById(request.getProductId());
        if (product.getStock() < request.getQuantity()) {
            throw new InsufficientStockException("재고가 부족합니다");
        }
        product.decreaseStock(request.getQuantity());
        productRepository.save(product);
    }
    
    private void sendNotifications(Order order) {
        notificationService.sendOrderConfirmation(order);
    }
    
    private void logOrderCompletion(Order order) {
        log.info("주문 처리 완료 - 주문번호: {}, 사용자: {}, 상품: {}", 
                order.getOrderId(), order.getUserId(), order.getProductId());
    }
}
```

## 리팩토링 기법들

### 1. Extract Method (메서드 추출)

가장 기본적인 리팩토링 기법이다. 긴 메서드를 작은 단위로 나누는 것이다.

```javascript
// 리팩토링 전
function calculateTotalPrice(items) {
    let total = 0;
    for (let item of items) {
        if (item.discount > 0) {
            total += item.price * (1 - item.discount / 100);
        } else {
            total += item.price;
        }
    }
    
    if (total > 100000) {
        total = total * 0.95; // 5% 할인
    }
    
    if (total > 200000) {
        total = total * 0.9; // 10% 할인
    }
    
    return total;
}

// 리팩토링 후
function calculateTotalPrice(items) {
    const subtotal = calculateSubtotal(items);
    return applyBulkDiscount(subtotal);
}

function calculateSubtotal(items) {
    return items.reduce((total, item) => {
        return total + calculateItemPrice(item);
    }, 0);
}

function calculateItemPrice(item) {
    if (item.discount > 0) {
        return item.price * (1 - item.discount / 100);
    }
    return item.price;
}

function applyBulkDiscount(total) {
    if (total > 200000) return total * 0.9;
    if (total > 100000) return total * 0.95;
    return total;
}
```

**효과:**
- 각 함수가 하나의 책임만 가진다
- 테스트하기 쉬워진다
- 재사용 가능한 함수들이 생긴다

### 2. Replace Conditional with Polymorphism (조건문을 다형성으로 대체)

if-else나 switch문이 많을 때 사용한다.

```java
// 리팩토링 전
public class PaymentProcessor {
    
    public void processPayment(String paymentType, double amount) {
        if ("CREDIT_CARD".equals(paymentType)) {
            // 신용카드 처리 로직
            validateCreditCard();
            chargeCreditCard(amount);
            sendReceipt("credit_card", amount);
        } else if ("BANK_TRANSFER".equals(paymentType)) {
            // 계좌이체 처리 로직
            validateBankAccount();
            transferMoney(amount);
            sendReceipt("bank_transfer", amount);
        } else if ("PAYPAL".equals(paymentType)) {
            // 페이팔 처리 로직
            validatePayPal();
            chargePayPal(amount);
            sendReceipt("paypal", amount);
        }
    }
    
    private void validateCreditCard() { /* 신용카드 검증 */ }
    private void chargeCreditCard(double amount) { /* 신용카드 결제 */ }
    private void validateBankAccount() { /* 계좌 검증 */ }
    private void transferMoney(double amount) { /* 계좌이체 */ }
    private void validatePayPal() { /* 페이팔 검증 */ }
    private void chargePayPal(double amount) { /* 페이팔 결제 */ }
}

// 리팩토링 후
public abstract class PaymentMethod {
    public abstract void processPayment(double amount);
    protected abstract void validate();
    protected abstract void charge(double amount);
    protected abstract String getReceiptType();
}

public class CreditCardPayment extends PaymentMethod {
    @Override
    public void processPayment(double amount) {
        validate();
        charge(amount);
        sendReceipt(getReceiptType(), amount);
    }
    
    @Override
    protected void validate() { /* 신용카드 검증 */ }
    
    @Override
    protected void charge(double amount) { /* 신용카드 결제 */ }
    
    @Override
    protected String getReceiptType() { return "credit_card"; }
}

public class BankTransferPayment extends PaymentMethod {
    @Override
    public void processPayment(double amount) {
        validate();
        charge(amount);
        sendReceipt(getReceiptType(), amount);
    }
    
    @Override
    protected void validate() { /* 계좌 검증 */ }
    
    @Override
    protected void charge(double amount) { /* 계좌이체 */ }
    
    @Override
    protected String getReceiptType() { return "bank_transfer"; }
}

public class PaymentProcessor {
    public void processPayment(PaymentMethod paymentMethod, double amount) {
        paymentMethod.processPayment(amount);
    }
}
```

**효과:**
- 새로운 결제 방식 추가가 쉬워진다
- 각 결제 방식의 로직이 캡슐화된다
- 조건문이 사라져서 코드가 깔끔해진다

### 3. Replace Magic Numbers with Named Constants (매직 넘버를 상수로 대체)

```javascript
// 리팩토링 전
function calculateShippingFee(weight) {
    if (weight <= 1) {
        return 2500;
    } else if (weight <= 5) {
        return 3500;
    } else if (weight <= 10) {
        return 5000;
    } else {
        return weight * 800;
    }
}

// 리팩토링 후
const SHIPPING_RATES = {
    LIGHT_WEIGHT_LIMIT: 1,
    MEDIUM_WEIGHT_LIMIT: 5,
    HEAVY_WEIGHT_LIMIT: 10,
    LIGHT_WEIGHT_FEE: 2500,
    MEDIUM_WEIGHT_FEE: 3500,
    HEAVY_WEIGHT_FEE: 5000,
    PER_KG_FEE: 800
};

function calculateShippingFee(weight) {
    if (weight <= SHIPPING_RATES.LIGHT_WEIGHT_LIMIT) {
        return SHIPPING_RATES.LIGHT_WEIGHT_FEE;
    } else if (weight <= SHIPPING_RATES.MEDIUM_WEIGHT_LIMIT) {
        return SHIPPING_RATES.MEDIUM_WEIGHT_FEE;
    } else if (weight <= SHIPPING_RATES.HEAVY_WEIGHT_LIMIT) {
        return SHIPPING_RATES.HEAVY_WEIGHT_FEE;
    } else {
        return weight * SHIPPING_RATES.PER_KG_FEE;
    }
}
```

**효과:**
- 코드의 의도가 명확해진다
- 값 변경이 쉬워진다
- 실수로 잘못된 값을 사용할 확률이 줄어든다

### 4. Extract Class (클래스 추출)

하나의 클래스가 너무 많은 책임을 가질 때 사용한다.

```java
// 리팩토링 전 - UserService가 너무 많은 일을 함
public class UserService {
    
    public User createUser(UserRequest request) {
        // 사용자 생성
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(encryptPassword(request.getPassword()));
        user.setName(request.getName());
        userRepository.save(user);
        
        // 환영 이메일 발송
        String subject = "환영합니다!";
        String body = "안녕하세요 " + request.getName() + "님, 가입을 환영합니다!";
        emailService.sendEmail(request.getEmail(), subject, body);
        
        // 사용자 통계 업데이트
        userStatistics.incrementTotalUsers();
        userStatistics.incrementTodaySignups();
        
        // 로그인 이력 기록
        loginHistory.recordSignup(request.getEmail(), new Date());
        
        return user;
    }
    
    public boolean validateEmail(String email) {
        return email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }
    
    public String encryptPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }
    
    // ... 다른 메서드들
}

// 리팩토링 후 - 책임을 분리
public class UserService {
    private final UserRepository userRepository;
    private final UserNotificationService notificationService;
    private final UserStatisticsService statisticsService;
    private final UserValidationService validationService;
    
    public User createUser(UserRequest request) {
        validationService.validateUserRequest(request);
        
        User user = buildUser(request);
        userRepository.save(user);
        
        notificationService.sendWelcomeEmail(user);
        statisticsService.recordUserSignup();
        
        return user;
    }
    
    private User buildUser(UserRequest request) {
        return User.builder()
            .email(request.getEmail())
            .password(validationService.encryptPassword(request.getPassword()))
            .name(request.getName())
            .build();
    }
}

public class UserValidationService {
    public void validateUserRequest(UserRequest request) {
        if (!isValidEmail(request.getEmail())) {
            throw new InvalidEmailException("이메일 형식이 올바르지 않습니다");
        }
        if (!isValidPassword(request.getPassword())) {
            throw new InvalidPasswordException("비밀번호는 8자 이상이어야 합니다");
        }
    }
    
    public boolean isValidEmail(String email) {
        return email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }
    
    public boolean isValidPassword(String password) {
        return password.length() >= 8;
    }
    
    public String encryptPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }
}

public class UserNotificationService {
    public void sendWelcomeEmail(User user) {
        String subject = "환영합니다!";
        String body = buildWelcomeEmailBody(user.getName());
        emailService.sendEmail(user.getEmail(), subject, body);
    }
    
    private String buildWelcomeEmailBody(String userName) {
        return String.format("안녕하세요 %s님, 가입을 환영합니다!", userName);
    }
}
```

**효과:**
- 각 클래스가 단일 책임을 가진다
- 테스트하기 쉬워진다
- 재사용성이 높아진다

## 주문 상태 관리 시스템

```java
// 리팩토링 전 - 상태 관리가 복잡함
public class Order {
    private String status;
    
    public void updateStatus(String newStatus) {
        if ("PENDING".equals(status)) {
            if ("CONFIRMED".equals(newStatus) || "CANCELLED".equals(newStatus)) {
                this.status = newStatus;
            } else {
                throw new IllegalStateException("PENDING에서 " + newStatus + "로 변경할 수 없습니다");
            }
        } else if ("CONFIRMED".equals(status)) {
            if ("SHIPPED".equals(newStatus) || "CANCELLED".equals(newStatus)) {
                this.status = newStatus;
            } else {
                throw new IllegalStateException("CONFIRMED에서 " + newStatus + "로 변경할 수 없습니다");
            }
        } else if ("SHIPPED".equals(status)) {
            if ("DELIVERED".equals(newStatus)) {
                this.status = newStatus;
            } else {
                throw new IllegalStateException("SHIPPED에서 " + newStatus + "로 변경할 수 없습니다");
            }
        }
        // ... 더 많은 상태들
    }
}

// 리팩토링 후 - State 패턴 적용
public abstract class OrderState {
    public abstract void confirm(Order order);
    public abstract void ship(Order order);
    public abstract void deliver(Order order);
    public abstract void cancel(Order order);
    public abstract String getStatus();
}

public class PendingOrderState extends OrderState {
    @Override
    public void confirm(Order order) {
        order.setState(new ConfirmedOrderState());
    }
    
    @Override
    public void cancel(Order order) {
        order.setState(new CancelledOrderState());
    }
    
    @Override
    public void ship(Order order) {
        throw new IllegalStateException("확인되지 않은 주문은 배송할 수 없습니다");
    }
    
    @Override
    public void deliver(Order order) {
        throw new IllegalStateException("배송되지 않은 주문은 배송완료할 수 없습니다");
    }
    
    @Override
    public String getStatus() {
        return "PENDING";
    }
}

public class ConfirmedOrderState extends OrderState {
    @Override
    public void ship(Order order) {
        order.setState(new ShippedOrderState());
    }
    
    @Override
    public void cancel(Order order) {
        order.setState(new CancelledOrderState());
    }
    
    @Override
    public void confirm(Order order) {
        throw new IllegalStateException("이미 확인된 주문입니다");
    }
    
    @Override
    public void deliver(Order order) {
        throw new IllegalStateException("배송되지 않은 주문은 배송완료할 수 없습니다");
    }
    
    @Override
    public String getStatus() {
        return "CONFIRMED";
    }
}

public class Order {
    private OrderState state;
    
    public Order() {
        this.state = new PendingOrderState();
    }
    
    public void confirm() {
        state.confirm(this);
    }
    
    public void ship() {
        state.ship(this);
    }
    
    public void deliver() {
        state.deliver(this);
    }
    
    public void cancel() {
        state.cancel(this);
    }
    
    public String getStatus() {
        return state.getStatus();
    }
    
    protected void setState(OrderState newState) {
        this.state = newState;
    }
}
```

**효과:**
- 상태 전환 로직이 명확해진다
- 새로운 상태 추가가 쉬워진다
- 각 상태별 동작이 캡슐화된다

## JavaScript 배열 처리 최적화

```javascript
// 리팩토링 전 - 중첩된 반복문과 복잡한 로직
function findExpensiveProducts(products, categories, minPrice) {
    let result = [];
    
    for (let i = 0; i < products.length; i++) {
        let product = products[i];
        let isExpensive = false;
        
        if (product.price >= minPrice) {
            for (let j = 0; j < categories.length; j++) {
                let category = categories[j];
                if (product.categoryId === category.id && category.isActive) {
                    isExpensive = true;
                    break;
                }
            }
        }
        
        if (isExpensive) {
            result.push({
                id: product.id,
                name: product.name,
                price: product.price,
                category: getCategoryName(product.categoryId, categories)
            });
        }
    }
    
    return result;
}

function getCategoryName(categoryId, categories) {
    for (let i = 0; i < categories.length; i++) {
        if (categories[i].id === categoryId) {
            return categories[i].name;
        }
    }
    return "Unknown";
}

// 리팩토링 후 - 함수형 프로그래밍 스타일
function findExpensiveProducts(products, categories, minPrice) {
    const activeCategories = getActiveCategories(categories);
    const categoryMap = buildCategoryMap(activeCategories);
    
    return products
        .filter(product => isExpensiveProduct(product, minPrice, categoryMap))
        .map(product => buildProductSummary(product, categoryMap));
}

function getActiveCategories(categories) {
    return categories.filter(category => category.isActive);
}

function buildCategoryMap(categories) {
    return categories.reduce((map, category) => {
        map[category.id] = category.name;
        return map;
    }, {});
}

function isExpensiveProduct(product, minPrice, categoryMap) {
    return product.price >= minPrice && categoryMap[product.categoryId];
}

function buildProductSummary(product, categoryMap) {
    return {
        id: product.id,
        name: product.name,
        price: product.price,
        category: categoryMap[product.categoryId] || "Unknown"
    };
}
```

**효과:**
- 코드가 더 읽기 쉬워진다
- 각 함수가 하나의 역할만 한다
- 테스트하기 쉬워진다
- 성능이 개선된다 (중첩 반복문 제거)

## 리팩토링 시 주의사항

### 1. 테스트 먼저 작성하기

리팩토링 전에 반드시 테스트를 작성해야 한다.

```java
@Test
public void testOrderProcessing() {
    // Given
    OrderRequest request = OrderRequest.builder()
        .userId("user123")
        .productId("product456")
        .quantity(2)
        .price(10000.0)
        .build();
    
    // When
    orderService.processOrder(request);
    
    // Then
    Order savedOrder = orderRepository.findByUserId("user123");
    assertThat(savedOrder).isNotNull();
    assertThat(savedOrder.getQuantity()).isEqualTo(2);
    assertThat(savedOrder.getPrice()).isEqualTo(10000.0);
}
```

### 2. 작은 단위로 나누어 진행

한 번에 너무 많은 것을 바꾸지 말고, 작은 단위로 나누어서 진행한다.

```
1단계: 변수명 개선
2단계: 메서드 추출
3단계: 클래스 분리
4단계: 패턴 적용
```

### 3. 기능 동작 확인

리팩토링 후에는 반드시 기능이 정상 동작하는지 확인한다.

```java
// 리팩토링 전후 동작 비교 테스트
@Test
public void testRefactoringResult() {
    // 리팩토링 전 코드 결과
    String oldResult = oldCode.process();
    
    // 리팩토링 후 코드 결과
    String newResult = newCode.process();
    
    // 결과가 동일한지 확인
    assertThat(newResult).isEqualTo(oldResult);
}
```

## 리팩토링의 효과

### 1. 코드 가독성 향상

```java
// 리팩토링 전
if (user.getAge() >= 18 && user.getAge() <= 65 && user.getSalary() >= 30000000 && user.getCreditScore() >= 700) {
    // 승인 로직
}

// 리팩토링 후
if (isEligibleForLoan(user)) {
    // 승인 로직
}

private boolean isEligibleForLoan(User user) {
    return isWorkingAge(user.getAge()) 
        && hasMinimumSalary(user.getSalary())
        && hasGoodCreditScore(user.getCreditScore());
}
```

### 2. 유지보수성 개선

```java
// 리팩토링 전 - 하드코딩된 값들
if (status.equals("ACTIVE") && type.equals("PREMIUM")) {
    discount = price * 0.15;
}

// 리팩토링 후 - 상수 사용
if (isActivePremiumUser(status, type)) {
    discount = calculatePremiumDiscount(price);
}

private static final double PREMIUM_DISCOUNT_RATE = 0.15;

private boolean isActivePremiumUser(String status, String type) {
    return USER_STATUS.ACTIVE.equals(status) && USER_TYPE.PREMIUM.equals(type);
}
```

### 3. 재사용성 향상

```javascript
// 리팩토링 전 - 중복된 코드
function validateUserInput(userData) {
    if (!userData.name || userData.name.trim() === '') {
        throw new Error('이름은 필수입니다');
    }
    if (!userData.email || userData.email.trim() === '') {
        throw new Error('이메일은 필수입니다');
    }
    if (!userData.phone || userData.phone.trim() === '') {
        throw new Error('전화번호는 필수입니다');
    }
}

function validateProductInput(productData) {
    if (!productData.name || productData.name.trim() === '') {
        throw new Error('상품명은 필수입니다');
    }
    if (!productData.price || productData.price <= 0) {
        throw new Error('가격은 0보다 커야 합니다');
    }
}

// 리팩토링 후 - 재사용 가능한 함수
function validateRequiredField(value, fieldName) {
    if (!value || value.trim() === '') {
        throw new Error(`${fieldName}은(는) 필수입니다`);
    }
}

function validatePositiveNumber(value, fieldName) {
    if (!value || value <= 0) {
        throw new Error(`${fieldName}은(는) 0보다 커야 합니다`);
    }
}

function validateUserInput(userData) {
    validateRequiredField(userData.name, '이름');
    validateRequiredField(userData.email, '이메일');
    validateRequiredField(userData.phone, '전화번호');
}

function validateProductInput(productData) {
    validateRequiredField(productData.name, '상품명');
    validatePositiveNumber(productData.price, '가격');
}
```

## 마무리

리팩토링은 하루아침에 되는 일이 아니다. 지속적으로 해야 하는 작업이다. 처음에는 시간이 오래 걸리고 어려울 수 있지만, 점점 익숙해지면 코드 품질이 눈에 띄게 향상되는 걸 느낄 수 있다.

가장 중요한 건 **기능은 그대로 두고 코드만 개선한다**는 것이다. 리팩토링 후에도 동일한 결과가 나와야 한다.

작은 것부터 시작해보자. 변수명을 더 명확하게 바꾸고, 긴 함수를 작게 나누고, 중복 코드를 제거하는 것부터 시작하면 된다. 
