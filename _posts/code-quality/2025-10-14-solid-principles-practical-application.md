---
title: "SOLID 원칙에 대하여"
excerpt: "객체지향 설계의 5가지 원칙, SOLID를 실무에서 어떻게 적용하는가"

categories:
  - Code-Quality
tags:
  - [SOLID, 객체지향, 설계원칙, 리팩토링, 클린코드]

toc: true
toc_sticky: true

date: 2025-10-14
last_modified_at: 2025-10-14
---

# SOLID 원칙에 대하여

처음 SOLID 원칙을 배울 때는 솔직히 무슨 말인지 이해가 안 갔다.

"단일 책임 원칙? 개방-폐쇄 원칙? 도대체 뭔 소리지?"

책에 나오는 예제들은 너무 이론적이었다. Animal 클래스가 있고, Dog와 Cat이 상속받고... 실감이 나지 않았다.

하지만 실무에서 코드를 작성하다 보니 이해가 되었다. "아, 이게 SOLID 원칙을 안 지켜서 생긴 문제구나."

실제 경험을 바탕으로 SOLID 원칙을 정리해보겠다.

## SOLID가 왜 필요한가?

### 처음 만난 레거시 코드

신입으로 회사에 입사하고 처음 맡은 업무가 기존 기능 수정이었다.

간단한 요구사항이었다. "회원가입 시 SMS 인증 추가해주세요."

쉽게 생각했다. 기존 코드 좀 고치면 되겠지?

코드를 열어보는 순간 당황스러웠다.

```java
public class UserService {
    
    public void registerUser(String email, String password, String name, 
                            String phone, String address) {
        // 1. 유효성 검증
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("이메일이 유효하지 않습니다");
        }
        
        if (password.length() < 8) {
            throw new IllegalArgumentException("비밀번호는 8자 이상이어야 합니다");
        }
        
        // 2. 비밀번호 암호화
        String salt = generateSalt();
        String hashedPassword = hashPassword(password, salt);
        
        // 3. 데이터베이스 저장
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/mydb", "user", "pass");
        PreparedStatement pstmt = conn.prepareStatement(
            "INSERT INTO users (email, password, salt, name, phone, address, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        pstmt.setString(1, email);
        pstmt.setString(2, hashedPassword);
        pstmt.setString(3, salt);
        pstmt.setString(4, name);
        pstmt.setString(5, phone);
        pstmt.setString(6, address);
        pstmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
        pstmt.executeUpdate();
        
        // 4. 환영 이메일 발송
        EmailSender emailSender = new EmailSender();
        emailSender.setHost("smtp.gmail.com");
        emailSender.setPort(587);
        emailSender.setUsername("noreply@example.com");
        emailSender.setPassword("password123");
        String emailContent = "<html><body><h1>환영합니다!</h1><p>" + name + "님의 가입을 환영합니다.</p></body></html>";
        emailSender.send(email, "회원가입 완료", emailContent);
        
        // 5. 포인트 지급
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/mydb", "user", "pass");
        pstmt = conn.prepareStatement("INSERT INTO points (user_email, amount, reason) VALUES (?, ?, ?)");
        pstmt.setString(1, email);
        pstmt.setInt(2, 1000);
        pstmt.setString(3, "회원가입 축하");
        pstmt.executeUpdate();
        
        // 6. 로그 기록
        Logger logger = Logger.getLogger("UserService");
        logger.info("새 회원 가입: " + email);
    }
}
```

이 코드의 문제가 뭘까?

SMS 인증을 어디에 추가해야 할지 모르겠었다. 코드를 수정하려니 무엇을 건드려야 할지, 무엇이 영향을 받을지 전혀 예측할 수 없었다.

이메일 발송 로직을 변경하려면? 비밀번호 암호화 방식을 바꾸려면? 데이터베이스를 MySQL에서 PostgreSQL로 바꾸려면?

전부 이 하나의 메서드를 고쳐야 했다. 그것도 조심조심, 다른 부분은 안 건드리면서.

이때 SOLID 원칙의 필요성을 느꼈다.

## S - Single Responsibility Principle (단일 책임 원칙)

### 한 클래스는 하나의 책임만

"클래스는 단 하나의 변경 이유만을 가져야 한다."

위의 `UserService`는 몇 가지 책임을 가지고 있을까?

1. 유효성 검증
2. 비밀번호 암호화
3. 데이터베이스 저장
4. 이메일 발송
5. 포인트 지급
6. 로깅

총 6가지다. 이메일 발송 로직이 바뀌어도, 데이터베이스 스키마가 바뀌어도, 포인트 정책이 바뀌어도 이 클래스를 수정해야 한다.

### 리팩토링 - 책임 분리하기

각 책임을 별도의 클래스로 분리하면 다음과 같다.

**1. 유효성 검증**

```java
public class UserValidator {
    
    public void validate(UserRegistrationRequest request) {
        validateEmail(request.getEmail());
        validatePassword(request.getPassword());
        validateName(request.getName());
        validatePhone(request.getPhone());
    }
    
    private void validateEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("이메일은 필수입니다");
        }
        
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("이메일 형식이 올바르지 않습니다");
        }
    }
    
    private void validatePassword(String password) {
        if (password == null || password.length() < 8) {
            throw new IllegalArgumentException("비밀번호는 8자 이상이어야 합니다");
        }
        
        if (!password.matches(".*[A-Z].*")) {
            throw new IllegalArgumentException("비밀번호에 대문자가 포함되어야 합니다");
        }
        
        if (!password.matches(".*[0-9].*")) {
            throw new IllegalArgumentException("비밀번호에 숫자가 포함되어야 합니다");
        }
    }
    
    private void validateName(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("이름은 필수입니다");
        }
    }
    
    private void validatePhone(String phone) {
        if (phone == null || phone.isBlank()) {
            throw new IllegalArgumentException("전화번호는 필수입니다");
        }
        
        if (!phone.matches("^01[0-9]-[0-9]{4}-[0-9]{4}$")) {
            throw new IllegalArgumentException("전화번호 형식이 올바르지 않습니다");
        }
    }
}
```

**2. 비밀번호 암호화**

```java
public class PasswordEncoder {
    
    private static final int SALT_LENGTH = 16;
    
    public EncodedPassword encode(String plainPassword) {
        String salt = generateSalt();
        String hashedPassword = hash(plainPassword, salt);
        return new EncodedPassword(hashedPassword, salt);
    }
    
    public boolean matches(String plainPassword, EncodedPassword encodedPassword) {
        String hashedAttempt = hash(plainPassword, encodedPassword.getSalt());
        return hashedAttempt.equals(encodedPassword.getHash());
    }
    
    private String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    private String hash(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes(StandardCharsets.UTF_8));
            byte[] hashedPassword = md.digest(password.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hashedPassword);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 알고리즘을 찾을 수 없습니다", e);
        }
    }
}
```

**3. 사용자 저장소**

```java
public class UserRepository {
    
    private final DataSource dataSource;
    
    public UserRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    public void save(User user) {
        String sql = "INSERT INTO users (email, password, salt, name, phone, address, created_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getEmail());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getSalt());
            pstmt.setString(4, user.getName());
            pstmt.setString(5, user.getPhone());
            pstmt.setString(6, user.getAddress());
            pstmt.setTimestamp(7, Timestamp.valueOf(user.getCreatedAt()));
            
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            throw new RuntimeException("사용자 저장 실패", e);
        }
    }
    
    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapToUser(rs);
            }
            
            return null;
            
        } catch (SQLException e) {
            throw new RuntimeException("사용자 조회 실패", e);
        }
    }
    
    private User mapToUser(ResultSet rs) throws SQLException {
        return User.builder()
                .email(rs.getString("email"))
                .password(rs.getString("password"))
                .salt(rs.getString("salt"))
                .name(rs.getString("name"))
                .phone(rs.getString("phone"))
                .address(rs.getString("address"))
                .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
                .build();
    }
}
```

**4. 이메일 발송**

```java
public class EmailService {
    
    private final JavaMailSender mailSender;
    
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }
    
    public void sendWelcomeEmail(String to, String userName) {
        String subject = "회원가입을 환영합니다";
        String content = buildWelcomeEmailContent(userName);
        
        sendEmail(to, subject, content);
    }
    
    private String buildWelcomeEmailContent(String userName) {
        return String.format(
            """
            <html>
            <body>
                <h1>환영합니다!</h1>
                <p>%s님의 가입을 진심으로 환영합니다.</p>
                <p>저희 서비스를 통해 즐거운 경험 하시기 바랍니다.</p>
            </body>
            </html>
            """, userName
        );
    }
    
    private void sendEmail(String to, String subject, String content) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(content, true);
            
            mailSender.send(message);
            
        } catch (MessagingException e) {
            throw new RuntimeException("이메일 발송 실패", e);
        }
    }
}
```

**5. 포인트 지급**

```java
public class PointService {
    
    private final PointRepository pointRepository;
    
    public PointService(PointRepository pointRepository) {
        this.pointRepository = pointRepository;
    }
    
    public void grantSignUpBonus(String email) {
        Point point = Point.builder()
                .userEmail(email)
                .amount(1000)
                .reason("회원가입 축하 포인트")
                .grantedAt(LocalDateTime.now())
                .build();
        
        pointRepository.save(point);
    }
}
```

**6. 개선된 UserService**

```java
public class UserService {
    
    private final UserValidator validator;
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final PointService pointService;
    
    public UserService(UserValidator validator,
                      PasswordEncoder passwordEncoder,
                      UserRepository userRepository,
                      EmailService emailService,
                      PointService pointService) {
        this.validator = validator;
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.pointService = pointService;
    }
    
    public void registerUser(UserRegistrationRequest request) {
        // 1. 유효성 검증
        validator.validate(request);
        
        // 2. 비밀번호 암호화
        EncodedPassword encodedPassword = passwordEncoder.encode(request.getPassword());
        
        // 3. 사용자 생성
        User user = User.builder()
                .email(request.getEmail())
                .password(encodedPassword.getHash())
                .salt(encodedPassword.getSalt())
                .name(request.getName())
                .phone(request.getPhone())
                .address(request.getAddress())
                .createdAt(LocalDateTime.now())
                .build();
        
        // 4. 저장
        userRepository.save(user);
        
        // 5. 환영 이메일 발송
        emailService.sendWelcomeEmail(user.getEmail(), user.getName());
        
        // 6. 포인트 지급
        pointService.grantSignUpBonus(user.getEmail());
    }
}
```

### 무엇이 좋아졌나?

이제 각 클래스는 명확한 하나의 책임만 가진다.

- 이메일 템플릿을 변경하고 싶다? `EmailService`만 수정하면 된다.
- 비밀번호 암호화 방식을 변경하고 싶다? `PasswordEncoder`만 수정하면 된다.
- 데이터베이스를 변경하고 싶다? `UserRepository`만 수정하면 된다.

각 클래스가 독립적이어서 테스트하기도 쉽다.

```java
@Test
void 유효한_이메일이면_검증_통과() {
    // Given
    UserValidator validator = new UserValidator();
    UserRegistrationRequest request = new UserRegistrationRequest(
        "test@example.com", "Password123", "홍길동", "010-1234-5678", "서울시"
    );
    
    // When & Then
    assertDoesNotThrow(() -> validator.validate(request));
}

@Test
void 비밀번호_암호화_후_검증_가능() {
    // Given
    PasswordEncoder encoder = new PasswordEncoder();
    String plainPassword = "Password123";
    
    // When
    EncodedPassword encoded = encoder.encode(plainPassword);
    
    // Then
    assertTrue(encoder.matches(plainPassword, encoded));
    assertFalse(encoder.matches("WrongPassword", encoded));
}
```

## O - Open-Closed Principle (개방-폐쇄 원칙)

### 확장에는 열려있고, 수정에는 닫혀있어야 한다

다음 요구사항이 들어왔다.

"결제 방식을 신용카드, 계좌이체, 카카오페이 3가지로 지원해주세요."

처음 코드는 이랬다.

```java
public class PaymentService {
    
    public void processPayment(String paymentMethod, int amount) {
        if (paymentMethod.equals("CREDIT_CARD")) {
            // 신용카드 결제 로직
            System.out.println("신용카드로 " + amount + "원 결제");
            
        } else if (paymentMethod.equals("BANK_TRANSFER")) {
            // 계좌이체 로직
            System.out.println("계좌이체로 " + amount + "원 결제");
            
        } else if (paymentMethod.equals("KAKAO_PAY")) {
            // 카카오페이 로직
            System.out.println("카카오페이로 " + amount + "원 결제");
            
        } else {
            throw new IllegalArgumentException("지원하지 않는 결제 방식입니다");
        }
    }
}
```

그런데 다음날 "네이버페이도 추가해주세요"라고 한다.

또 `else if`를 추가해야 한다. 그 다음엔 토스페이, 페이코...

계속 기존 코드를 수정해야 한다. 이건 OCP 위반이다.

### 리팩토링: 인터페이스로 확장 가능하게

```java
// 결제 수단 인터페이스
public interface PaymentMethod {
    void pay(int amount);
    String getName();
}

// 신용카드 결제
public class CreditCardPayment implements PaymentMethod {
    
    private final String cardNumber;
    private final String cvv;
    
    public CreditCardPayment(String cardNumber, String cvv) {
        this.cardNumber = cardNumber;
        this.cvv = cvv;
    }
    
    @Override
    public void pay(int amount) {
        // 신용카드 결제 API 호출
        System.out.println("신용카드 " + maskCardNumber(cardNumber) + "로 " + amount + "원 결제");
        
        // PG사 API 호출
        callPaymentGateway(cardNumber, cvv, amount);
    }
    
    @Override
    public String getName() {
        return "신용카드";
    }
    
    private String maskCardNumber(String cardNumber) {
        return cardNumber.substring(0, 4) + "-****-****-" + cardNumber.substring(12);
    }
    
    private void callPaymentGateway(String cardNumber, String cvv, int amount) {
        // 실제 PG사 API 호출 로직
    }
}

// 계좌이체 결제
public class BankTransferPayment implements PaymentMethod {
    
    private final String bankCode;
    private final String accountNumber;
    
    public BankTransferPayment(String bankCode, String accountNumber) {
        this.bankCode = bankCode;
        this.accountNumber = accountNumber;
    }
    
    @Override
    public void pay(int amount) {
        System.out.println("계좌이체로 " + amount + "원 결제");
        
        // 은행 API 호출
        callBankAPI(bankCode, accountNumber, amount);
    }
    
    @Override
    public String getName() {
        return "계좌이체";
    }
    
    private void callBankAPI(String bankCode, String accountNumber, int amount) {
        // 실제 은행 API 호출 로직
    }
}

// 카카오페이 결제
public class KakaoPayPayment implements PaymentMethod {
    
    private final String kakaoPayToken;
    
    public KakaoPayPayment(String kakaoPayToken) {
        this.kakaoPayToken = kakaoPayToken;
    }
    
    @Override
    public void pay(int amount) {
        System.out.println("카카오페이로 " + amount + "원 결제");
        
        // 카카오페이 API 호출
        callKakaoPayAPI(kakaoPayToken, amount);
    }
    
    @Override
    public String getName() {
        return "카카오페이";
    }
    
    private void callKakaoPayAPI(String token, int amount) {
        // 실제 카카오페이 API 호출 로직
    }
}

// 개선된 PaymentService
public class PaymentService {
    
    public void processPayment(PaymentMethod paymentMethod, int amount) {
        System.out.println(paymentMethod.getName() + " 결제를 시작합니다.");
        
        paymentMethod.pay(amount);
        
        System.out.println("결제가 완료되었습니다.");
    }
}
```

### 새로운 결제 수단 추가하기

이제 네이버페이를 추가하려면?

기존 코드는 전혀 수정하지 않고, 새로운 클래스만 추가하면 된다.

```java
public class NaverPayPayment implements PaymentMethod {
    
    private final String naverPayToken;
    
    public NaverPayPayment(String naverPayToken) {
        this.naverPayToken = naverPayToken;
    }
    
    @Override
    public void pay(int amount) {
        System.out.println("네이버페이로 " + amount + "원 결제");
        
        // 네이버페이 API 호출
        callNaverPayAPI(naverPayToken, amount);
    }
    
    @Override
    public String getName() {
        return "네이버페이";
    }
    
    private void callNaverPayAPI(String token, int amount) {
        // 실제 네이버페이 API 호출 로직
    }
}
```

사용하는 쪽 코드도 변경 없다.

```java
public class OrderController {
    
    private final PaymentService paymentService;
    
    public void checkout(Order order, String paymentType) {
        PaymentMethod paymentMethod = createPaymentMethod(paymentType);
        paymentService.processPayment(paymentMethod, order.getTotalAmount());
    }
    
    private PaymentMethod createPaymentMethod(String paymentType) {
        return switch (paymentType) {
            case "CREDIT_CARD" -> new CreditCardPayment("1234567812345678", "123");
            case "BANK_TRANSFER" -> new BankTransferPayment("004", "12345678");
            case "KAKAO_PAY" -> new KakaoPayPayment("kakao_token_123");
            case "NAVER_PAY" -> new NaverPayPayment("naver_token_456");
            default -> throw new IllegalArgumentException("지원하지 않는 결제 방식");
        };
    }
}
```

### 더 나아가기 - Factory 패턴

결제 수단 생성도 분리하면 더 깔끔하다.

```java
public class PaymentMethodFactory {
    
    private final Map<String, Supplier<PaymentMethod>> paymentMethods = new HashMap<>();
    
    public PaymentMethodFactory() {
        // 결제 수단 등록
        register("CREDIT_CARD", () -> new CreditCardPayment("1234567812345678", "123"));
        register("BANK_TRANSFER", () -> new BankTransferPayment("004", "12345678"));
        register("KAKAO_PAY", () -> new KakaoPayPayment("kakao_token_123"));
        register("NAVER_PAY", () -> new NaverPayPayment("naver_token_456"));
    }
    
    public void register(String type, Supplier<PaymentMethod> supplier) {
        paymentMethods.put(type, supplier);
    }
    
    public PaymentMethod create(String type) {
        Supplier<PaymentMethod> supplier = paymentMethods.get(type);
        
        if (supplier == null) {
            throw new IllegalArgumentException("지원하지 않는 결제 방식: " + type);
        }
        
        return supplier.get();
    }
}
```

이제 새로운 결제 수단을 추가해도 `PaymentMethodFactory`의 생성자에 한 줄만 추가하면 된다.

## L - Liskov Substitution Principle (리스코프 치환 원칙)

### 자식 클래스는 부모 클래스를 대체할 수 있어야 한다

"상속받은 클래스는 부모 클래스의 역할을 완벽히 수행할 수 있어야 한다."

이론은 간단한데 실무에서 어기기 쉽다.

### 잘못된 예 - 정사각형은 직사각형이다?

수학적으로는 맞다. 하지만 프로그래밍에서는?

```java
public class Rectangle {
    protected int width;
    protected int height;
    
    public void setWidth(int width) {
        this.width = width;
    }
    
    public void setHeight(int height) {
        this.height = height;
    }
    
    public int getArea() {
        return width * height;
    }
}

public class Square extends Rectangle {
    
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;  // 정사각형은 가로세로가 같아야 함
    }
    
    @Override
    public void setHeight(int height) {
        this.width = height;
        this.height = height;  // 정사각형은 가로세로가 같아야 함
    }
}
```

문제가 뭘까?

```java
public class GeometryTest {
    
    public void testRectangle() {
        Rectangle rect = new Rectangle();
        rect.setWidth(5);
        rect.setHeight(10);
        
        System.out.println("넓이: " + rect.getArea());  // 50
    }
    
    public void testSquare() {
        Rectangle rect = new Square();  // Rectangle로 받음
        rect.setWidth(5);
        rect.setHeight(10);  // Square이므로 width도 10으로 변경됨
        
        System.out.println("넓이: " + rect.getArea());  // 100 (예상: 50)
    }
}
```

`Rectangle`을 사용하는 코드에 `Square`를 넣으면 예상과 다른 결과가 나온다. LSP 위반이다.

### 올바른 설계

```java
public interface Shape {
    int getArea();
}

public class Rectangle implements Shape {
    private final int width;
    private final int height;
    
    public Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }
    
    @Override
    public int getArea() {
        return width * height;
    }
    
    public int getWidth() {
        return width;
    }
    
    public int getHeight() {
        return height;
    }
}

public class Square implements Shape {
    private final int side;
    
    public Square(int side) {
        this.side = side;
    }
    
    @Override
    public int getArea() {
        return side * side;
    }
    
    public int getSide() {
        return side;
    }
}
```

이제 `Square`는 `Rectangle`을 상속받지 않는다. 둘 다 `Shape` 인터페이스를 구현한다.

### 할인 정책

더 실무적인 예제를 살펴보겠다.

```java
// 할인 정책 인터페이스
public interface DiscountPolicy {
    int discount(int price);
}

// 정액 할인
public class FixedAmountDiscount implements DiscountPolicy {
    private final int discountAmount;
    
    public FixedAmountDiscount(int discountAmount) {
        this.discountAmount = discountAmount;
    }
    
    @Override
    public int discount(int price) {
        int discountedPrice = price - discountAmount;
        return Math.max(discountedPrice, 0);  // 음수 방지
    }
}

// 정률 할인
public class PercentageDiscount implements DiscountPolicy {
    private final int percentage;
    
    public PercentageDiscount(int percentage) {
        if (percentage < 0 || percentage > 100) {
            throw new IllegalArgumentException("할인율은 0~100 사이여야 합니다");
        }
        this.percentage = percentage;
    }
    
    @Override
    public int discount(int price) {
        return price * (100 - percentage) / 100;
    }
}

// 할인 없음
public class NoDiscount implements DiscountPolicy {
    
    @Override
    public int discount(int price) {
        return price;
    }
}
```

이제 어떤 할인 정책을 넣어도 동일하게 작동한다.

```java
public class Order {
    private final List<OrderItem> items;
    private final DiscountPolicy discountPolicy;
    
    public Order(List<OrderItem> items, DiscountPolicy discountPolicy) {
        this.items = items;
        this.discountPolicy = discountPolicy;
    }
    
    public int calculateTotalPrice() {
        int totalPrice = items.stream()
                .mapToInt(OrderItem::getPrice)
                .sum();
        
        return discountPolicy.discount(totalPrice);
    }
}

// 사용
Order order1 = new Order(items, new FixedAmountDiscount(5000));
Order order2 = new Order(items, new PercentageDiscount(10));
Order order3 = new Order(items, new NoDiscount());

// 모두 동일한 방식으로 작동
System.out.println(order1.calculateTotalPrice());
System.out.println(order2.calculateTotalPrice());
System.out.println(order3.calculateTotalPrice());
```

## I - Interface Segregation Principle (인터페이스 분리 원칙)

### 클라이언트는 사용하지 않는 메서드에 의존하지 않아야 한다

한 인터페이스에 너무 많은 메서드를 넣으면 문제가 생긴다.

### 잘못된 예 - 거대한 인터페이스

```java
public interface Worker {
    void work();
    void eat();
    void sleep();
    void getSalary();
    void attendMeeting();
    void writeReport();
}

// 정규직 직원
public class RegularEmployee implements Worker {
    @Override
    public void work() {
        System.out.println("업무 수행");
    }
    
    @Override
    public void eat() {
        System.out.println("점심 식사");
    }
    
    @Override
    public void sleep() {
        System.out.println("휴식");
    }
    
    @Override
    public void getSalary() {
        System.out.println("월급 수령");
    }
    
    @Override
    public void attendMeeting() {
        System.out.println("회의 참석");
    }
    
    @Override
    public void writeReport() {
        System.out.println("보고서 작성");
    }
}

// 로봇 직원 (문제 발생!)
public class RobotWorker implements Worker {
    @Override
    public void work() {
        System.out.println("업무 수행");
    }
    
    @Override
    public void eat() {
        // 로봇은 식사하지 않음
        throw new UnsupportedOperationException("로봇은 식사하지 않습니다");
    }
    
    @Override
    public void sleep() {
        // 로봇은 자지 않음
        throw new UnsupportedOperationException("로봇은 휴식하지 않습니다");
    }
    
    @Override
    public void getSalary() {
        // 로봇은 월급 안 받음
        throw new UnsupportedOperationException("로봇은 월급을 받지 않습니다");
    }
    
    @Override
    public void attendMeeting() {
        System.out.println("회의 참석");
    }
    
    @Override
    public void writeReport() {
        System.out.println("보고서 작성");
    }
}
```

`RobotWorker`는 `Worker` 인터페이스의 절반도 사용하지 않는다. 사용하지 않는 메서드를 구현하느라 예외를 던지고 있다.

### 리팩토링 - 인터페이스 분리

```java
// 일을 하는 인터페이스
public interface Workable {
    void work();
}

// 식사하는 인터페이스
public interface Eatable {
    void eat();
}

// 휴식하는 인터페이스
public interface Sleepable {
    void sleep();
}

// 급여를 받는 인터페이스
public interface Payable {
    void getSalary();
}

// 회의에 참석하는 인터페이스
public interface Meetable {
    void attendMeeting();
}

// 보고서를 작성하는 인터페이스
public interface Reportable {
    void writeReport();
}

// 정규직 직원 (필요한 인터페이스만 구현)
public class RegularEmployee implements Workable, Eatable, Sleepable, 
                                        Payable, Meetable, Reportable {
    @Override
    public void work() {
        System.out.println("업무 수행");
    }
    
    @Override
    public void eat() {
        System.out.println("점심 식사");
    }
    
    @Override
    public void sleep() {
        System.out.println("휴식");
    }
    
    @Override
    public void getSalary() {
        System.out.println("월급 수령");
    }
    
    @Override
    public void attendMeeting() {
        System.out.println("회의 참석");
    }
    
    @Override
    public void writeReport() {
        System.out.println("보고서 작성");
    }
}

// 로봇 직원 (필요한 인터페이스만 구현)
public class RobotWorker implements Workable, Meetable, Reportable {
    @Override
    public void work() {
        System.out.println("업무 수행");
    }
    
    @Override
    public void attendMeeting() {
        System.out.println("회의 참석");
    }
    
    @Override
    public void writeReport() {
        System.out.println("보고서 작성");
    }
}
```

이제 각 클래스는 자신이 필요한 인터페이스만 구현한다.

### 파일 저장소

자주 사용하는 파일 저장소 예제다.

```java
// 잘못된 설계
public interface FileStorage {
    void uploadFile(String filename, byte[] content);
    void downloadFile(String filename);
    void deleteFile(String filename);
    void shareFile(String filename, String email);
    void setPublicAccess(String filename, boolean isPublic);
    void encryptFile(String filename);
    void compressFile(String filename);
}
```

모든 파일 저장소가 이 기능을 다 제공하는 건 아니다.

```java
// 개선된 설계
public interface FileUploader {
    void upload(String filename, byte[] content);
}

public interface FileDownloader {
    byte[] download(String filename);
}

public interface FileDeleter {
    void delete(String filename);
}

public interface FileSharer {
    void share(String filename, String email);
}

public interface FileAccessController {
    void setPublicAccess(String filename, boolean isPublic);
}

public interface FileEncryptor {
    void encrypt(String filename);
}

public interface FileCompressor {
    void compress(String filename);
}

// 로컬 파일 저장소 (기본 기능만)
public class LocalFileStorage implements FileUploader, FileDownloader, FileDeleter {
    @Override
    public void upload(String filename, byte[] content) {
        // 로컬 파일 시스템에 저장
    }
    
    @Override
    public byte[] download(String filename) {
        // 로컬 파일 시스템에서 읽기
        return new byte[0];
    }
    
    @Override
    public void delete(String filename) {
        // 로컬 파일 삭제
    }
}

// 클라우드 파일 저장소 (모든 기능)
public class CloudFileStorage implements FileUploader, FileDownloader, FileDeleter,
                                         FileSharer, FileAccessController, 
                                         FileEncryptor, FileCompressor {
    @Override
    public void upload(String filename, byte[] content) {
        // 클라우드에 업로드
    }
    
    @Override
    public byte[] download(String filename) {
        // 클라우드에서 다운로드
        return new byte[0];
    }
    
    @Override
    public void delete(String filename) {
        // 클라우드에서 삭제
    }
    
    @Override
    public void share(String filename, String email) {
        // 파일 공유
    }
    
    @Override
    public void setPublicAccess(String filename, boolean isPublic) {
        // 공개 설정
    }
    
    @Override
    public void encrypt(String filename) {
        // 파일 암호화
    }
    
    @Override
    public void compress(String filename) {
        // 파일 압축
    }
}
```

## D - Dependency Inversion Principle (의존성 역전 원칙)

### 고수준 모듈은 저수준 모듈에 의존하면 안 된다

"구체적인 것이 아닌 추상적인 것에 의존해라."

### 잘못된 예 - 구체 클래스에 의존

```java
public class UserService {
    
    private MySQLUserRepository repository;  // 구체 클래스에 직접 의존
    
    public UserService() {
        this.repository = new MySQLUserRepository();  // 강한 결합
    }
    
    public User findUser(String email) {
        return repository.findByEmail(email);
    }
}

public class MySQLUserRepository {
    public User findByEmail(String email) {
        // MySQL 데이터베이스에서 조회
        return null;
    }
}
```

문제는?

1. MySQL에서 PostgreSQL로 변경하려면 `UserService`를 수정해야 함
2. 테스트할 때 실제 MySQL이 필요함
3. 다른 저장소 구현체를 사용할 수 없음

### 리팩토링 - 추상화에 의존

```java
// 추상화된 인터페이스
public interface UserRepository {
    User findByEmail(String email);
    void save(User user);
    void delete(String email);
}

// 고수준 모듈 (비즈니스 로직)
public class UserService {
    
    private final UserRepository repository;  // 인터페이스에 의존
    
    public UserService(UserRepository repository) {  // 의존성 주입
        this.repository = repository;
    }
    
    public User findUser(String email) {
        return repository.findByEmail(email);
    }
    
    public void registerUser(User user) {
        // 비즈니스 로직
        validateUser(user);
        repository.save(user);
    }
    
    private void validateUser(User user) {
        // 검증 로직
    }
}

// 저수준 모듈 구현체 1
public class MySQLUserRepository implements UserRepository {
    
    private final DataSource dataSource;
    
    public MySQLUserRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    @Override
    public User findByEmail(String email) {
        // MySQL 조회 로직
        return null;
    }
    
    @Override
    public void save(User user) {
        // MySQL 저장 로직
    }
    
    @Override
    public void delete(String email) {
        // MySQL 삭제 로직
    }
}

// 저수준 모듈 구현체 2
public class PostgreSQLUserRepository implements UserRepository {
    
    private final DataSource dataSource;
    
    public PostgreSQLUserRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    @Override
    public User findByEmail(String email) {
        // PostgreSQL 조회 로직
        return null;
    }
    
    @Override
    public void save(User user) {
        // PostgreSQL 저장 로직
    }
    
    @Override
    public void delete(String email) {
        // PostgreSQL 삭제 로직
    }
}

// 저수준 모듈 구현체 3 (테스트용)
public class InMemoryUserRepository implements UserRepository {
    
    private final Map<String, User> users = new HashMap<>();
    
    @Override
    public User findByEmail(String email) {
        return users.get(email);
    }
    
    @Override
    public void save(User user) {
        users.put(user.getEmail(), user);
    }
    
    @Override
    public void delete(String email) {
        users.remove(email);
    }
}
```

### 무엇이 좋아졌나?

이제 `UserService`는 구체적인 저장소 구현체를 몰라도 된다.

```java
// 프로덕션: MySQL 사용
DataSource mysqlDataSource = createMySQLDataSource();
UserRepository repository = new MySQLUserRepository(mysqlDataSource);
UserService userService = new UserService(repository);

// 다른 환경: PostgreSQL 사용
DataSource postgresDataSource = createPostgreSQLDataSource();
UserRepository repository = new PostgreSQLUserRepository(postgresDataSource);
UserService userService = new UserService(repository);

// 테스트: 인메모리 사용
UserRepository repository = new InMemoryUserRepository();
UserService userService = new UserService(repository);
```

테스트도 쉬워진다.

```java
@Test
void 사용자_등록_테스트() {
    // Given
    UserRepository repository = new InMemoryUserRepository();
    UserService userService = new UserService(repository);
    
    User user = new User("test@example.com", "password", "홍길동");
    
    // When
    userService.registerUser(user);
    
    // Then
    User savedUser = userService.findUser("test@example.com");
    assertNotNull(savedUser);
    assertEquals("홍길동", savedUser.getName());
}
```

### 알림 발송

자주 쓰는 패턴이다.

```java
// 알림 발송 인터페이스
public interface NotificationSender {
    void send(String recipient, String message);
}

// 이메일 발송
public class EmailNotificationSender implements NotificationSender {
    
    private final JavaMailSender mailSender;
    
    public EmailNotificationSender(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }
    
    @Override
    public void send(String recipient, String message) {
        // 이메일 발송 로직
        System.out.println("이메일 발송: " + recipient + " - " + message);
    }
}

// SMS 발송
public class SmsNotificationSender implements NotificationSender {
    
    private final SmsClient smsClient;
    
    public SmsNotificationSender(SmsClient smsClient) {
        this.smsClient = smsClient;
    }
    
    @Override
    public void send(String recipient, String message) {
        // SMS 발송 로직
        System.out.println("SMS 발송: " + recipient + " - " + message);
    }
}

// 푸시 알림 발송
public class PushNotificationSender implements NotificationSender {
    
    private final FcmClient fcmClient;
    
    public PushNotificationSender(FcmClient fcmClient) {
        this.fcmClient = fcmClient;
    }
    
    @Override
    public void send(String recipient, String message) {
        // 푸시 알림 발송 로직
        System.out.println("푸시 알림 발송: " + recipient + " - " + message);
    }
}

// 알림 서비스
public class NotificationService {
    
    private final List<NotificationSender> senders;
    
    public NotificationService(List<NotificationSender> senders) {
        this.senders = senders;
    }
    
    public void notifyUser(String recipient, String message) {
        for (NotificationSender sender : senders) {
            try {
                sender.send(recipient, message);
            } catch (Exception e) {
                // 로깅 후 계속 진행
                System.err.println("알림 발송 실패: " + e.getMessage());
            }
        }
    }
}

// 사용
List<NotificationSender> senders = Arrays.asList(
    new EmailNotificationSender(mailSender),
    new SmsNotificationSender(smsClient),
    new PushNotificationSender(fcmClient)
);

NotificationService notificationService = new NotificationService(senders);
notificationService.notifyUser("user@example.com", "주문이 완료되었습니다");
```

이제 새로운 알림 수단을 추가해도 `NotificationService`는 수정할 필요가 없다.

```java
// 카카오톡 알림 추가
public class KakaoTalkNotificationSender implements NotificationSender {
    
    private final KakaoTalkClient kakaoClient;
    
    public KakaoTalkNotificationSender(KakaoTalkClient kakaoClient) {
        this.kakaoClient = kakaoClient;
    }
    
    @Override
    public void send(String recipient, String message) {
        // 카카오톡 알림 발송 로직
        System.out.println("카카오톡 발송: " + recipient + " - " + message);
    }
}

// 사용 (NotificationService 코드 수정 없음)
List<NotificationSender> senders = Arrays.asList(
    new EmailNotificationSender(mailSender),
    new SmsNotificationSender(smsClient),
    new PushNotificationSender(fcmClient),
    new KakaoTalkNotificationSender(kakaoClient)  // 추가
);
```

## SOLID 원칙의 실전 적용

### 레거시 코드 개선하기

실무에서는 완벽한 새 프로젝트보다 레거시 코드를 개선하는 경우가 더 많다.

SOLID 원칙을 한 번에 다 적용하려고 하면 힘들다. 단계적으로 개선해야 한다.

**1단계: SRP부터 시작**

가장 문제가 되는 큰 클래스를 찾아서 책임별로 분리한다.

**2단계: DIP 적용**

구체 클래스에 의존하는 부분을 찾아서 인터페이스로 추상화한다.

**3단계: OCP 고려**

새 기능을 추가할 때 기존 코드를 수정하는지 확인한다. 수정한다면 인터페이스를 도입한다.

**4단계: LSP와 ISP**

상속 구조를 검토하고, 너무 큰 인터페이스는 분리한다.

### 주문 시스템 리팩토링

처음 코드

```java
public class OrderService {
    
    public void processOrder(Order order) {
        // 재고 확인
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/db", "user", "pass");
        PreparedStatement pstmt = conn.prepareStatement("SELECT quantity FROM inventory WHERE product_id = ?");
        pstmt.setLong(1, order.getProductId());
        ResultSet rs = pstmt.executeQuery();
        int stock = rs.getInt("quantity");
        
        if (stock < order.getQuantity()) {
            throw new IllegalStateException("재고 부족");
        }
        
        // 결제 처리
        if (order.getPaymentMethod().equals("CARD")) {
            // 신용카드 결제
        } else if (order.getPaymentMethod().equals("BANK")) {
            // 계좌이체
        }
        
        // 재고 차감
        pstmt = conn.prepareStatement("UPDATE inventory SET quantity = quantity - ? WHERE product_id = ?");
        pstmt.setInt(1, order.getQuantity());
        pstmt.setLong(2, order.getProductId());
        pstmt.executeUpdate();
        
        // 주문 저장
        pstmt = conn.prepareStatement("INSERT INTO orders (product_id, quantity, status) VALUES (?, ?, ?)");
        pstmt.setLong(1, order.getProductId());
        pstmt.setInt(2, order.getQuantity());
        pstmt.setString(3, "COMPLETED");
        pstmt.executeUpdate();
        
        // 이메일 발송
        EmailSender sender = new EmailSender();
        sender.send(order.getUserEmail(), "주문이 완료되었습니다");
    }
}
```

SOLID 원칙 적용 후

```java
// 재고 관리 (SRP)
public interface InventoryRepository {
    int getStock(Long productId);
    void decreaseStock(Long productId, int quantity);
}

public class InventoryService {
    private final InventoryRepository inventoryRepository;
    
    public InventoryService(InventoryRepository inventoryRepository) {
        this.inventoryRepository = inventoryRepository;
    }
    
    public void checkStock(Long productId, int requiredQuantity) {
        int currentStock = inventoryRepository.getStock(productId);
        
        if (currentStock < requiredQuantity) {
            throw new InsufficientStockException(
                "재고 부족: 필요 수량 " + requiredQuantity + ", 현재 재고 " + currentStock
            );
        }
    }
    
    public void decreaseStock(Long productId, int quantity) {
        inventoryRepository.decreaseStock(productId, quantity);
    }
}

// 결제 처리 (OCP, DIP)
public interface PaymentProcessor {
    void process(Payment payment);
}

public class PaymentService {
    private final Map<String, PaymentProcessor> processors;
    
    public PaymentService(Map<String, PaymentProcessor> processors) {
        this.processors = processors;
    }
    
    public void processPayment(Payment payment) {
        PaymentProcessor processor = processors.get(payment.getMethod());
        
        if (processor == null) {
            throw new IllegalArgumentException("지원하지 않는 결제 수단: " + payment.getMethod());
        }
        
        processor.process(payment);
    }
}

// 주문 저장 (SRP, DIP)
public interface OrderRepository {
    void save(Order order);
    Order findById(Long orderId);
}

// 알림 발송 (DIP)
public interface NotificationSender {
    void send(String recipient, String message);
}

// 주문 서비스 (조합)
public class OrderService {
    private final InventoryService inventoryService;
    private final PaymentService paymentService;
    private final OrderRepository orderRepository;
    private final NotificationSender notificationSender;
    
    public OrderService(InventoryService inventoryService,
                       PaymentService paymentService,
                       OrderRepository orderRepository,
                       NotificationSender notificationSender) {
        this.inventoryService = inventoryService;
        this.paymentService = paymentService;
        this.orderRepository = orderRepository;
        this.notificationSender = notificationSender;
    }
    
    public void processOrder(Order order) {
        // 1. 재고 확인
        inventoryService.checkStock(order.getProductId(), order.getQuantity());
        
        // 2. 결제 처리
        Payment payment = Payment.of(order.getPaymentMethod(), order.getTotalAmount());
        paymentService.processPayment(payment);
        
        // 3. 재고 차감
        inventoryService.decreaseStock(order.getProductId(), order.getQuantity());
        
        // 4. 주문 저장
        order.complete();
        orderRepository.save(order);
        
        // 5. 알림 발송
        notificationSender.send(
            order.getUserEmail(),
            "주문이 완료되었습니다. 주문번호: " + order.getId()
        );
    }
}
```

### 무엇이 좋아졌나?

1. **SRP**: 각 클래스가 하나의 책임만 가짐
2. **OCP**: 새 결제 수단 추가 시 기존 코드 수정 불필요
3. **LSP**: 모든 구현체가 인터페이스 계약을 지킴
4. **ISP**: 각 인터페이스가 명확한 하나의 역할만 정의
5. **DIP**: 고수준 모듈이 저수준 구현에 의존하지 않음

테스트도 훨씬 쉬워진다.

```java
@Test
void 주문_처리_성공() {
    // Given
    InventoryRepository inventoryRepository = mock(InventoryRepository.class);
    when(inventoryRepository.getStock(1L)).thenReturn(10);
    
    PaymentProcessor paymentProcessor = mock(PaymentProcessor.class);
    Map<String, PaymentProcessor> processors = Map.of("CARD", paymentProcessor);
    
    OrderRepository orderRepository = mock(OrderRepository.class);
    NotificationSender notificationSender = mock(NotificationSender.class);
    
    InventoryService inventoryService = new InventoryService(inventoryRepository);
    PaymentService paymentService = new PaymentService(processors);
    OrderService orderService = new OrderService(
        inventoryService, paymentService, orderRepository, notificationSender
    );
    
    Order order = Order.builder()
        .productId(1L)
        .quantity(5)
        .paymentMethod("CARD")
        .totalAmount(50000)
        .userEmail("user@example.com")
        .build();
    
    // When
    orderService.processOrder(order);
    
    // Then
    verify(inventoryRepository).decreaseStock(1L, 5);
    verify(orderRepository).save(order);
    verify(notificationSender).send(eq("user@example.com"), anyString());
}
```

## SOLID는 은탄환이 아니다

### 과도한 추상화의 함정

SOLID 원칙을 맹목적으로 따르다 보면 오히려 코드가 복잡해질 수 있다.

간단한 기능에 굳이 인터페이스를 만들 필요는 없다.

```java
// 과도한 추상화
public interface StringReverser {
    String reverse(String input);
}

public class StringReverserImpl implements StringReverser {
    @Override
    public String reverse(String input) {
        return new StringBuilder(input).reverse().toString();
    }
}

// 이게 나을 수도
public class StringUtils {
    public static String reverse(String input) {
        return new StringBuilder(input).reverse().toString();
    }
}
```

### 언제 추상화할 것인가?

다음 조건 중 하나라도 해당하면 추상화를 고려한다.

1. **여러 구현체가 필요한 경우**
   - 결제 수단, 알림 발송, 파일 저장소 등

2. **테스트를 위해 mock이 필요한 경우**
   - 외부 API 호출, 데이터베이스 접근 등

3. **구현이 자주 바뀌는 경우**
   - 비즈니스 규칙, 정책 등

4. **런타임에 구현체를 선택해야 하는 경우**
   - 사용자 설정에 따른 동작 변경 등

### 실용적인 접근

처음부터 완벽한 설계를 할 필요는 없다.

1. **일단 작동하는 코드를 작성**
2. **문제가 보이면 리팩토링**
3. **새 요구사항이 들어오면 확장성 고려**
4. **테스트하기 어려우면 의존성 분리**

SOLID 원칙은 도구다. 목적이 아니다.

"이 코드가 유지보수하기 쉬운가?"
"새 기능을 추가하기 쉬운가?"
"테스트하기 쉬운가?"

이 질문에 "아니오"라고 답한다면, 그때 SOLID 원칙을 적용하면 된다.

## 마무리

SOLID 원칙을 처음 배웠을 때는 이론적이고 추상적으로 느껴졌다.

하지만 실무에서 레거시 코드를 다루다 보면 자연스럽게 이해가 된다.

"왜 이 코드는 수정하기 어렵지?"
"왜 새 기능을 추가할 때마다 기존 코드를 고쳐야 하지?"
"왜 테스트 코드 작성이 이렇게 힘들지?"

이런 문제들이 SOLID 원칙을 지키지 않아서 생기는 것들이다.

**S - Single Responsibility**: 한 클래스는 한 가지 이유로만 변경되어야 한다
**O - Open-Closed**: 확장에는 열려있고, 수정에는 닫혀있어야 한다
**L - Liskov Substitution**: 자식 클래스는 부모 클래스를 대체할 수 있어야 한다
**I - Interface Segregation**: 사용하지 않는 인터페이스에 의존하지 말아야 한다
**D - Dependency Inversion**: 구체가 아닌 추상에 의존해야 한다

이 5가지 원칙이 완벽하게 지켜진 코드는 드물다. 실무에서는 트레이드오프가 있다.

중요한 건 "이 원칙을 왜 지켜야 하는지" 이해하고, "언제 지켜야 하는지" 판단하는 것이다.

처음부터 완벽한 설계를 하려고 할 필요는 없다. 일단 작동하는 코드를 만들고, 문제가 보이면 리팩토링하면 된다.

그 과정에서 SOLID 원칙을 적용하면 된다. 그게 가장 실용적인 접근이다.

