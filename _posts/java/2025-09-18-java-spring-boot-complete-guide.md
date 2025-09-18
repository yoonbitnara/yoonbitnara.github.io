---
title: "현대적 웹 개발의 모든 것"
date: 2025-09-18
categories: Java
tags: [java, spring-boot, web-development, rest-api, database, jpa]
author: pitbull terrier
---

# 현대적 웹 개발의 모든 것

자바를 처음 배웠을 때는 그냥 "Hello World" 출력하는 게 전부였다. 하지만 스프링 부트를 만나고 나서야 자바의 진짜 매력을 알게 됐다. 이제는 웹 애플리케이션을 몇 시간 만에 뚝딱 만들 수 있다.

## 자바 기초부터 다시 보기

자바를 제대로 쓰려면 기본기를 탄탄히 해야 한다. 특히 객체지향 프로그래밍과 컬렉션 프레임워크는 필수다.

### 클래스와 객체

자바의 핵심은 클래스다. 현실 세계의 개념을 코드로 표현할 수 있다.

```java
public class User {
    private String name;
    private String email;
    private int age;
    
    // 생성자
    public User(String name, String email, int age) {
        this.name = name;
        this.email = email;
        this.age = age;
    }
    
    // Getter와 Setter
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    // 비즈니스 로직
    public boolean isAdult() {
        return age >= 18;
    }
    
    @Override
    public String toString() {
        return "User{name='" + name + "', email='" + email + "', age=" + age + "}";
    }
}
```

### 컬렉션 프레임워크

데이터를 효율적으로 관리하려면 컬렉션을 잘 써야 한다.

```java
import java.util.*;

public class CollectionExample {
    public static void main(String[] args) {
        // List - 순서가 있는 컬렉션
        List<String> names = new ArrayList<>();
        names.add("김철수");
        names.add("이영희");
        names.add("박민수");
        
        // Set - 중복을 허용하지 않는 컬렉션
        Set<Integer> numbers = new HashSet<>();
        numbers.add(1);
        numbers.add(2);
        numbers.add(2); // 중복이므로 추가되지 않음
        
        // Map - 키-값 쌍을 저장하는 컬렉션
        Map<String, Integer> scores = new HashMap<>();
        scores.put("김철수", 95);
        scores.put("이영희", 87);
        scores.put("박민수", 92);
        
        // 람다 표현식과 스트림 API
        names.stream()
            .filter(name -> name.startsWith("김"))
            .forEach(System.out::println);
    }
}
```

### 예외 처리

자바에서 예외 처리는 필수다. 프로그램의 안정성을 위해 반드시 해야 한다.

```java
public class ExceptionExample {
    public static void main(String[] args) {
        try {
            int result = divide(10, 0);
            System.out.println("결과: " + result);
        } catch (ArithmeticException e) {
            System.out.println("0으로 나눌 수 없습니다: " + e.getMessage());
        } catch (Exception e) {
            System.out.println("예상치 못한 오류: " + e.getMessage());
        } finally {
            System.out.println("예외 처리 완료");
        }
    }
    
    public static int divide(int a, int b) throws ArithmeticException {
        if (b == 0) {
            throw new ArithmeticException("0으로 나눌 수 없습니다");
        }
        return a / b;
    }
}
```

## 스프링 부트 시작하기

스프링 부트는 자바 웹 개발을 쉽게 만들어준다. 설정이 복잡했던 스프링을 간단하게 사용할 수 있다.

### 프로젝트 생성

Spring Initializr를 사용해서 프로젝트를 생성하자.

**의존성 선택:**
- Spring Web
- Spring Data JPA
- H2 Database
- Spring Boot DevTools
- Validation

### 기본 구조

```
src/
├── main/
│   ├── java/
│   │   └── com/
│   │       └── example/
│   │           └── demo/
│   │               ├── DemoApplication.java
│   │               ├── controller/
│   │               ├── service/
│   │               ├── repository/
│   │               └── entity/
│   └── resources/
│       ├── application.properties
│       └── static/
└── test/
```

### 메인 애플리케이션 클래스

```java
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

## REST API 만들기

REST API는 현대 웹 개발의 핵심이다. 스프링 부트로 쉽게 만들 수 있다.

### 컨트롤러 작성

```java
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    // 모든 사용자 조회
    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
    
    // 특정 사용자 조회
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        User user = userService.getUserById(id);
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    // 새 사용자 생성
    @PostMapping
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        User createdUser = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }
    
    // 사용자 정보 수정
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @Valid @RequestBody User user) {
        User updatedUser = userService.updateUser(id, user);
        if (updatedUser != null) {
            return ResponseEntity.ok(updatedUser);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    // 사용자 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        boolean deleted = userService.deleteUser(id);
        if (deleted) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
```

### 서비스 레이어

```java
@Service
@Transactional
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    public User getUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }
    
    public User createUser(User user) {
        // 이메일 중복 체크
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("이미 존재하는 이메일입니다");
        }
        
        return userRepository.save(user);
    }
    
    public User updateUser(Long id, User userDetails) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
        
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        user.setAge(userDetails.getAge());
        
        return userRepository.save(user);
    }
    
    public boolean deleteUser(Long id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
```

## 데이터베이스 연동

JPA를 사용해서 데이터베이스를 쉽게 다룰 수 있다.

### 엔티티 클래스

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(nullable = false, unique = true, length = 255)
    private String email;
    
    @Column(nullable = false)
    private int age;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // 기본 생성자
    public User() {}
    
    // 생성자
    public User(String name, String email, int age) {
        this.name = name;
        this.email = email;
        this.age = age;
    }
    
    // Getter와 Setter
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public int getAge() {
        return age;
    }
    
    public void setAge(int age) {
        this.age = age;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
```

### 리포지토리 인터페이스

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // 이메일로 사용자 찾기
    Optional<User> findByEmail(String email);
    
    // 이름으로 사용자 찾기
    List<User> findByName(String name);
    
    // 나이 범위로 사용자 찾기
    List<User> findByAgeBetween(int minAge, int maxAge);
    
    // 이름으로 검색 (부분 일치)
    List<User> findByNameContaining(String name);
    
    // 커스텀 쿼리
    @Query("SELECT u FROM User u WHERE u.age > :age ORDER BY u.createdAt DESC")
    List<User> findUsersOlderThan(@Param("age") int age);
    
    // 네이티브 쿼리
    @Query(value = "SELECT * FROM users WHERE age > ?1", nativeQuery = true)
    List<User> findUsersOlderThanNative(int age);
}
```

### 데이터베이스 설정

```properties
# application.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# H2 콘솔 활성화
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

## 고급 기능들

### 예외 처리

전역 예외 처리를 통해 일관된 에러 응답을 제공하자.

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(RuntimeException e) {
        ErrorResponse error = new ErrorResponse("RUNTIME_ERROR", e.getMessage());
        return ResponseEntity.badRequest().body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .collect(Collectors.joining(", "));
        
        ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", message);
        return ResponseEntity.badRequest().body(error);
    }
}

// 에러 응답 클래스
public class ErrorResponse {
    private String code;
    private String message;
    private LocalDateTime timestamp;
    
    public ErrorResponse(String code, String message) {
        this.code = code;
        this.message = message;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getter와 Setter
    public String getCode() {
        return code;
    }
    
    public void setCode(String code) {
        this.code = code;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
```

### 로깅

애플리케이션의 상태를 모니터링하기 위해 로깅을 활용하자.

```java
@RestController
@Slf4j
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/api/users")
    public ResponseEntity<List<User>> getAllUsers() {
        log.info("모든 사용자 조회 요청");
        
        try {
            List<User> users = userService.getAllUsers();
            log.info("사용자 조회 성공: {}명", users.size());
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            log.error("사용자 조회 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PostMapping("/api/users")
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        log.info("새 사용자 생성 요청: {}", user.getEmail());
        
        try {
            User createdUser = userService.createUser(user);
            log.info("사용자 생성 성공: ID={}", createdUser.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
        } catch (Exception e) {
            log.error("사용자 생성 실패: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }
}
```

### 캐싱

성능 향상을 위해 캐싱을 활용하자.

```java
@Service
@Slf4j
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Cacheable(value = "users", key = "#id")
    public User getUserById(Long id) {
        log.info("데이터베이스에서 사용자 조회: ID={}", id);
        return userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public User updateUser(Long id, User userDetails) {
        log.info("사용자 정보 수정: ID={}", id);
        
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
        
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        user.setAge(userDetails.getAge());
        
        return userRepository.save(user);
    }
    
    @CacheEvict(value = "users", allEntries = true)
    public void clearCache() {
        log.info("사용자 캐시 초기화");
    }
}
```

## 테스트 작성

테스트는 코드의 품질을 보장하는 핵심이다.

### 단위 테스트

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void 사용자_생성_성공() {
        // Given
        User user = new User("김철수", "kim@example.com", 25);
        User savedUser = new User("김철수", "kim@example.com", 25);
        savedUser.setId(1L);
        
        when(userRepository.findByEmail("kim@example.com")).thenReturn(Optional.empty());
        when(userRepository.save(user)).thenReturn(savedUser);
        
        // When
        User result = userService.createUser(user);
        
        // Then
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getName()).isEqualTo("김철수");
        verify(userRepository).save(user);
    }
    
    @Test
    void 중복_이메일로_사용자_생성_실패() {
        // Given
        User user = new User("김철수", "kim@example.com", 25);
        User existingUser = new User("이영희", "kim@example.com", 30);
        
        when(userRepository.findByEmail("kim@example.com")).thenReturn(Optional.of(existingUser));
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(user))
            .isInstanceOf(RuntimeException.class)
            .hasMessage("이미 존재하는 이메일입니다");
    }
}
```

### 통합 테스트

```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class UserControllerIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @AfterEach
    void tearDown() {
        userRepository.deleteAll();
    }
    
    @Test
    void 사용자_생성_및_조회_통합_테스트() {
        // Given
        User user = new User("김철수", "kim@example.com", 25);
        
        // When - 사용자 생성
        ResponseEntity<User> createResponse = restTemplate.postForEntity(
            "/api/users", user, User.class);
        
        // Then
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(createResponse.getBody().getName()).isEqualTo("김철수");
        
        // When - 사용자 조회
        ResponseEntity<User> getResponse = restTemplate.getForEntity(
            "/api/users/" + createResponse.getBody().getId(), User.class);
        
        // Then
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody().getName()).isEqualTo("김철수");
    }
}
```

## 배포와 운영

### 프로파일 설정

환경별로 다른 설정을 사용하자.

```properties
# application-dev.properties (개발 환경)
spring.datasource.url=jdbc:h2:mem:testdb
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true

# application-prod.properties (운영 환경)
spring.datasource.url=jdbc:mysql://localhost:3306/proddb
spring.datasource.username=produser
spring.datasource.password=prodpass
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
```

### Docker 컨테이너화

```dockerfile
# Dockerfile
FROM openjdk:11-jre-slim

WORKDIR /app

COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 헬스 체크

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public Health health() {
        try {
            long count = userRepository.count();
            return Health.up()
                .withDetail("database", "Available")
                .withDetail("userCount", count)
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("database", "Unavailable")
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

## 결론

자바와 스프링 부트는 현대 웹 개발의 핵심이다. 기본기를 탄탄히 하고, 실전 프로젝트를 통해 경험을 쌓아야 한다.

특히 REST API 설계, 데이터베이스 연동, 테스트 작성은 필수다. 이 모든 것을 마스터하면 어떤 웹 애플리케이션이든 만들 수 있다.
