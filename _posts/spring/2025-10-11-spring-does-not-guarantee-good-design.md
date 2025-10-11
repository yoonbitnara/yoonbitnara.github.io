---
title: "Spring을 쓴다고 좋은 설계가 되는 건 아니다"
date: 2025-10-11
categories: Spring
tags: [Spring, 설계, 아키텍처, 코드품질, 실무경험, 개발철학]
author: pitbull terrier
---

# Spring을 쓴다고 좋은 설계가 되는 건 아니다

예전에 이런 생각을 했다.

"Spring 쓰면 자동으로 좋은 코드가 되는 거 아닌가?"

프레임워크가 알아서 다 해주니까 그냥 따라만 하면 될 줄 알았다.

하지만 현실은 달랐다.

## 첫 프로젝트의 충격

처음 회사에 들어가서 기존 프로젝트 코드를 봤을 때의 충격을 아직도 기억한다.

Spring을 쓰고 있었다.

@Controller, @Service, @Repository도 다 있었다.

하지만 코드는 엉망이었다.

Controller에 SQL 쿼리가 직접 들어가 있었다.

Service는 그냥 Controller에서 호출하는 메서드의 집합이었다.

비즈니스 로직은 곳곳에 흩어져 있었다.

"이게 Spring을 쓰는 거라고?"

그때 깨달았다.

**Spring을 쓴다고 좋은 설계가 되는 건 아니구나.**

## Controller에 모든 걸 넣는 사람들

가장 흔한 실수다.

```java
@RestController
public class UserController {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @PostMapping("/users")
    public ResponseEntity<?> createUser(@RequestBody UserRequest request) {
        // 여기서 비즈니스 로직을 다 처리
        if (request.getEmail() == null || request.getEmail().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        // 여기서 DB 조회
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        int count = jdbcTemplate.queryForObject(sql, Integer.class, request.getEmail());
        
        if (count > 0) {
            return ResponseEntity.badRequest().body("이미 존재하는 이메일");
        }
        
        // 여기서 비즈니스 로직
        String password = hashPassword(request.getPassword());
        
        // 여기서 DB 저장
        String insertSql = "INSERT INTO users (email, password) VALUES (?, ?)";
        jdbcTemplate.update(insertSql, request.getEmail(), password);
        
        return ResponseEntity.ok().build();
    }
    
    private String hashPassword(String password) {
        // 비밀번호 해싱 로직
        return password; // 실제로는 해싱해야 함
    }
}
```

이게 뭐가 문제냐고?

Controller가 너무 많은 걸 알고 있다.

DB 쿼리도 알고, 비즈니스 로직도 알고, 유효성 검증도 한다.

나중에 이메일 중복 체크 로직을 다른 곳에서도 써야 하면?

다시 짜야 한다.

비밀번호 해싱 방식을 바꾸려면?

Controller를 수정해야 한다.

테스트하려면?

DB까지 다 띄워야 한다.

## Service가 그냥 Controller의 메서드인 경우

이것도 자주 본다.

```java
@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public void createUser(String email, String password) {
        User user = new User();
        user.setEmail(email);
        user.setPassword(password);
        userRepository.save(user);
    }
    
    public User getUser(Long id) {
        return userRepository.findById(id).orElse(null);
    }
}
```

이게 Service라고?

그냥 Repository 호출만 하고 있다.

비즈니스 로직이 어디 있나?

이메일 중복 체크는?

비밀번호 해싱은?

유효성 검증은?

다 Controller에 있다.

그럼 Service는 왜 만든 거지?

"Spring은 Service를 만들어야 한다고 했으니까"

이게 문제다.

## 비즈니스 로직이 곳곳에 흩어진 경우

더 심각한 경우도 있다.

같은 비즈니스 로직이 여러 곳에 중복되어 있는 경우.

```java
// UserController.java
if (user.getAge() < 19) {
    throw new IllegalArgumentException("미성년자는 가입할 수 없습니다");
}

// OrderController.java  
if (user.getAge() < 19) {
    throw new IllegalArgumentException("미성년자는 구매할 수 없습니다");
}

// PaymentController.java
if (user.getAge() < 19) {
    throw new IllegalArgumentException("미성년자는 결제할 수 없습니다");
}
```

나중에 미성년자 기준이 19세에서 18세로 바뀌면?

세 군데를 다 수정해야 한다.

하나라도 놓치면?

## 그럼 어떻게 해야 하나?

### 계층을 제대로 나누기

**Controller의 역할**
- HTTP 요청과 응답만 처리
- 요청 데이터를 DTO로 변환
- Service 호출
- 응답 데이터를 HTTP로 변환

**Service의 역할**
- 비즈니스 로직 처리
- 트랜잭션 관리
- 도메인 객체 조합
- Repository 조율

**Repository의 역할**
- 데이터 접근만 담당
- CRUD 연산
- 쿼리 최적화

### 개선된 코드

```java
@RestController
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    @PostMapping("/users")
    public ResponseEntity<?> createUser(@RequestBody UserRequest request) {
        try {
            User user = userService.createUser(request);
            return ResponseEntity.ok(UserResponse.from(user));
        } catch (DuplicateEmailException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}

@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public UserService(UserRepository userRepository, 
                      PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
    
    @Transactional
    public User createUser(UserRequest request) {
        // 비즈니스 로직: 이메일 중복 체크
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("이미 존재하는 이메일입니다");
        }
        
        // 비즈니스 로직: User 생성
        User user = User.create(
            request.getEmail(),
            passwordEncoder.encode(request.getPassword())
        );
        
        return userRepository.save(user);
    }
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    boolean existsByEmail(String email);
}
```

이게 뭐가 다른가?

**Controller는**
- HTTP만 신경쓴다
- Service만 호출한다
- 비즈니스 로직을 모른다

**Service는**
- 비즈니스 로직을 처리한다
- 이메일 중복 체크를 한다
- 비밀번호 해싱을 한다

**Repository는**
- 데이터 접근만 한다
- SQL을 캡슐화한다

## 실제로 깨달은 것들

### Spring은 도구일 뿐이다

Spring은 좋은 설계를 강제하지 않는다.

그냥 편리한 기능들을 제공할 뿐이다.

@Service 어노테이션을 붙인다고 좋은 Service가 되는 게 아니다.

@Transactional을 붙인다고 트랜잭션을 제대로 관리하는 게 아니다.

개발자가 제대로 이해하고 써야 한다.

### 계층 분리의 진짜 이유

처음에는 "왜 이렇게 복잡하게 나누지?"라고 생각했다.

Controller, Service, Repository로 나누는 게 귀찮았다.

그냥 Controller에서 다 처리하면 편할 것 같았다.

하지만 프로젝트가 커질수록 깨달았다.

계층을 나누는 이유는
- 각 계층의 역할이 명확해진다
- 테스트하기 쉬워진다
- 수정할 때 영향 범위가 줄어든다
- 재사용하기 쉬워진다

### 프레임워크에 종속되지 않기

Spring을 쓰면 Spring에 종속되기 쉽다.

모든 클래스에 @Autowired를 붙이고, 모든 곳에서 Spring 기능을 쓴다.

하지만 비즈니스 로직은 Spring과 무관해야 한다.

```java
// Spring에 종속된 코드
@Service
public class OrderService {
    
    @Autowired
    private ApplicationContext context;
    
    public void processOrder(Order order) {
        PaymentProcessor processor = context.getBean(PaymentProcessor.class);
        processor.process(order);
    }
}

// Spring과 무관한 비즈니스 로직
public class OrderService {
    
    private final PaymentProcessor paymentProcessor;
    
    public OrderService(PaymentProcessor paymentProcessor) {
        this.paymentProcessor = paymentProcessor;
    }
    
    public void processOrder(Order order) {
        if (!order.isValid()) {
            throw new InvalidOrderException();
        }
        
        paymentProcessor.process(order);
    }
}
```

차이가 보이는가?

두 번째 코드는 Spring이 없어도 테스트할 수 있다.

비즈니스 로직이 프레임워크와 분리되어 있다.

## 현실적인 조언

### 프레임워크 기능을 다 쓸 필요 없다

Spring은 정말 많은 기능을 제공한다.

하지만 다 쓸 필요 없다.

프로젝트에 필요한 것만 쓰면 된다.

"Spring에 이런 기능이 있으니까 써야지"가 아니라 "이 문제를 해결하려면 Spring의 이 기능이 필요하네"가 되어야 한다.

### 간결함이 중요하다

복잡한 설계가 좋은 설계가 아니다.

간결하고 이해하기 쉬운 설계가 좋은 설계다.

"이 코드를 6개월 후에 다시 봤을 때 이해할 수 있나?"

"새로운 팀원이 이 코드를 보고 이해할 수 있나?"

이게 기준이다.

### 비즈니스 로직을 중심에 두기

프레임워크는 도구다.

비즈니스 로직이 중심이어야 한다.

"이 코드가 어떤 비즈니스 문제를 해결하는가?"

"이 설계가 비즈니스 요구사항을 명확히 표현하는가?"

이게 중요하다.

## 실수에서 배운 것들

### Controller에 비즈니스 로직 넣었던 실수

초보 때 Controller에 비즈니스 로직을 다 넣었다.

나중에 같은 로직을 다른 곳에서 써야 할 때 문제가 생겼다.

중복 코드가 늘어나고, 수정할 때마다 여러 곳을 고쳐야 했다.

지금 생각하면 너무 당연한 건데, 그때는 몰랐다.

**Controller는 HTTP만 처리해야 한다.**

### Service를 Repository 래퍼로 만든 실수

Service가 그냥 Repository 메서드를 호출만 하게 만들었다.

비즈니스 로직은 Controller에 있었다.

Service의 존재 이유가 없었다.

이건 정말 의미 없는 코드였다.

**Service에 비즈니스 로직을 넣어야 한다.**

### @Transactional을 아무 데나 붙인 실수

"트랜잭션이 필요하니까 일단 붙이자"

모든 Service 메서드에 @Transactional을 붙였다.

성능이 떨어지고, 불필요한 락이 걸렸다.

디버깅하면서 알게 된 사실이다.

**필요한 곳에만 써야 한다.**

### 모든 걸 Bean으로 만든 실수

"Spring은 Bean으로 관리해야 하니까"

모든 클래스를 @Component로 만들었다.

간단한 DTO도, Util 클래스도 전부 Bean이었다.

나중에 의존성이 복잡해져서 순환 참조가 발생했다.

에러 로그를 보고 나서야 이해했다.

**꼭 필요한 것만 Bean으로 만들어야 한다.**

## 좋은 설계란 무엇인가

### 명확한 역할 분리

각 계층이 자기 역할만 한다.

Controller는 HTTP만, Service는 비즈니스 로직만, Repository는 데이터 접근만.

역할이 명확하면 코드를 이해하기 쉽다.

### 테스트하기 쉬운 코드

좋은 설계의 증거는 테스트하기 쉬운 것이다.

Controller 테스트할 때 DB가 필요하면 잘못된 것이다.

Service 테스트할 때 HTTP 서버가 필요하면 잘못된 것이다.

각 계층을 독립적으로 테스트할 수 있어야 한다.

### 변경에 유연한 구조

요구사항은 항상 바뀐다.

좋은 설계는 변경을 쉽게 만든다.

"이메일 중복 체크 로직을 바꿔야 해"

→ Service 메서드 하나만 수정

"DB를 MySQL에서 PostgreSQL로 바꿔야 해"

→ Repository만 수정

"REST API를 GraphQL로 바꿔야 해"

→ Controller만 수정

각 계층이 독립적이면 변경이 쉽다.

## 현실적인 접근

### 완벽한 설계는 없다

처음부터 완벽한 설계를 하려고 하지 마라.

과도한 설계는 오히려 복잡성만 증가시킨다.

**간단하게 시작하고, 필요할 때 개선하는 것이 현실적이다.**

### 팀원과의 합의가 중요하다

아무리 좋은 설계라도 팀원들이 이해하지 못하면 소용없다.

"이 설계 패턴이 최고야!"보다는 "우리 팀이 이해하고 유지보수할 수 있는 설계가 뭘까?"를 고민해야 한다.

### 점진적 개선이 답이다

레거시 코드를 한 번에 다 바꿀 수 없다.

조금씩, 하나씩 개선해야 한다.

"이번 기능부터는 제대로 된 구조로 만들자"

"다음 리팩토링 때는 이 부분을 개선하자"

이렇게 점진적으로 나아가는 것이 현실적이다.

## 마지막

Spring을 쓴다고 좋은 설계가 되는 건 아니다.

프레임워크는 도구일 뿐이다.

**좋은 설계는 개발자가 만드는 것이다.**

각 계층의 역할을 명확히 하고, 비즈니스 로직을 중심에 두고, 테스트하기 쉽게 만들고, 변경에 유연하게 만들어야 한다.

그리고 완벽을 추구하지 말고, 팀원과 함께 점진적으로 개선해야 한다.

Spring은 이런 좋은 설계를 돕는 도구다.

하지만 도구를 쓴다고 자동으로 좋은 결과가 나오는 건 아니다.

**도구를 어떻게 쓰느냐가 중요하다.**

