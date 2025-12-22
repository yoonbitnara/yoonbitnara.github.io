---
title: "코드를 안 짜는 게 최고의 코드다"
date: 2025-12-22
categories: Code-Quality
tags: [코드품질, 리팩토링, 개발철학, 간결함, 코드제거]
author: pitbull terrier
---

# 코드를 안 짜는 게 최고의 코드다

코드를 리뷰하다 보면 이런 생각이 들 때가 있다.

"이 코드가 없으면 안 될까?"

200줄짜리 함수를 보는데, 실제로 필요한 건 50줄도 안 된다. 나머지는 예외 처리와 로깅, 중복된 검증 로직들이다.

그리고 깨달았다.

**가장 좋은 코드는 존재하지 않는 코드다.**

## 코드를 추가하는 것보다 지우는 게 어렵다

처음 개발을 시작했을 때는 코드를 많이 짜는 게 실력이라고 생각했다. 복잡한 로직을 구현하고, 다양한 예외 케이스를 처리하고, 상세한 로깅을 추가하는 것. 그게 좋은 개발자라고 생각했다.

하지만 시간이 지나면서 생각이 바뀌었다.

코드를 추가하는 건 쉽다. 기능이 필요하면 추가하면 된다. 하지만 코드를 지우는 건 어렵다. 이 코드가 정말 필요 없는지, 다른 곳에서 쓰이지 않는지, 삭제해도 문제없는지 확인해야 한다.

그래서 대부분의 개발자는 코드를 추가하기만 한다. 지우지 않는다.

결과는 뻔하다. 코드베이스가 계속 커진다. 1년 전에는 1만 줄이었는데 지금은 3만 줄이다. 기능은 비슷한데 코드만 늘어났다.

```
코드 라인 수 변화
1년 전: ████████████░░░░░░░░ 10,000줄
지금:   ████████████████████ 30,000줄
```

## 불필요한 코드가 만드는 부채

불필요한 코드는 기술 부채다. 보이지 않는 부채다.

```
기술 부채의 구성
┌─────────────────────────────────┐
│  불필요한 코드 (30%)            │
│  중복 코드 (25%)                │
│  복잡한 로직 (20%)              │
│  테스트 부족 (15%)              │
│  문서 부족 (10%)                │
└─────────────────────────────────┘
```

### 이해 비용

코드를 읽는 시간이 늘어난다. 200줄짜리 함수를 읽어야 하는데, 실제로 필요한 건 50줄뿐이다. 나머지 150줄을 읽으면서 "이건 왜 있지?"라고 생각하는 시간이 낭비다.

새로운 팀원이 온다면? 200줄을 다 읽고 이해해야 한다. 하지만 실제로는 50줄만 알면 된다.

### 유지보수 비용

코드가 많을수록 버그가 생길 가능성이 높다. 200줄짜리 함수에서 버그를 찾는 것과 50줄짜리 함수에서 버그를 찾는 것. 어느 게 더 쉬운가?

수정할 때도 마찬가지다. 200줄 중에서 어디를 수정해야 하는지 찾아야 한다. 50줄이면 한눈에 보인다.

### 테스트 비용

코드가 많을수록 테스트해야 할 케이스가 늘어난다. 200줄짜리 함수를 테스트하는 것과 50줄짜리 함수를 테스트하는 것. 테스트 코드도 그만큼 늘어난다.

## 예시: 인증 로직 리팩토링

인터넷에서 흔히 볼 수 있는 인증 로직 예시를 보면 이런 패턴이 많다. 기존 코드는 200줄 정도다.

```java
public class AuthenticationService {
    
    public AuthResult authenticate(String email, String password) {
        // 로깅 시작
        logger.info("Authentication started for email: " + email);
        
        // 입력 검증
        if (email == null || email.isEmpty()) {
            logger.warn("Email is null or empty");
            return AuthResult.failure("Email is required");
        }
        
        if (password == null || password.isEmpty()) {
            logger.warn("Password is null or empty");
            return AuthResult.failure("Password is required");
        }
        
        // 이메일 형식 검증
        if (!email.contains("@")) {
            logger.warn("Invalid email format: " + email);
            return AuthResult.failure("Invalid email format");
        }
        
        // 비밀번호 길이 검증
        if (password.length() < 8) {
            logger.warn("Password too short");
            return AuthResult.failure("Password must be at least 8 characters");
        }
        
        // 사용자 조회
        User user = userRepository.findByEmail(email);
        if (user == null) {
            logger.warn("User not found: " + email);
            return AuthResult.failure("Invalid credentials");
        }
        
        // 비밀번호 검증
        if (!passwordEncoder.matches(password, user.getPassword())) {
            logger.warn("Password mismatch for user: " + email);
            return AuthResult.failure("Invalid credentials");
        }
        
        // 계정 활성화 확인
        if (!user.isActive()) {
            logger.warn("Inactive account: " + email);
            return AuthResult.failure("Account is not active");
        }
        
        // 로그인 성공 로깅
        logger.info("Authentication successful for email: " + email);
        
        // 세션 생성
        String sessionId = sessionManager.createSession(user.getId());
        
        return AuthResult.success(sessionId);
    }
}
```

코드를 보면 대부분이 검증과 로깅이다. 실제 비즈니스 로직은 사용자 조회, 비밀번호 검증, 세션 생성뿐이다.

이런 코드를 리팩토링하면 이렇게 줄일 수 있다.

```java
public class AuthenticationService {
    
    public AuthResult authenticate(String email, String password) {
        User user = userRepository.findByEmail(email);
        
        if (user == null || !passwordEncoder.matches(password, user.getPassword())) {
            return AuthResult.failure("Invalid credentials");
        }
        
        if (!user.isActive()) {
            return AuthResult.failure("Account is not active");
        }
        
        String sessionId = sessionManager.createSession(user.getId());
        return AuthResult.success(sessionId);
    }
}
```

200줄에서 15줄로 줄었다.

```
리팩토링 결과
Before: ████████████████████████████████████████ 200줄
After:  ███ 15줄

감소율: 92.5%
```

입력 검증은 어디 갔나? 컨트롤러 레이어로 옮겼다. `@Valid` 어노테이션으로 처리한다. 이메일 형식 검증도 `@Email` 어노테이션으로 처리한다.

로깅은? AOP로 처리한다. `@Loggable` 어노테이션을 붙이면 자동으로 로깅된다.

결과는 같다. 기능은 동일하게 동작한다. 하지만 코드는 85% 줄었다.

## 코드를 지우는 방법

코드를 지우는 건 어렵다. 하지만 방법이 있다.

```
코드 제거 프로세스
1. 사용 여부 확인 ──┐
2. 중복 제거      ──┤
3. 추상화 레벨 올리기 ──┼──> 코드 제거
4. 프레임워크 활용 ──┘
```

### 1. 사용 여부 확인

이 코드가 정말 사용되는지 확인한다. IDE의 "Find Usages" 기능을 쓰면 된다. 사용되지 않는 코드는 삭제해도 된다.

하지만 조심해야 한다. 리플렉션으로 호출되는 코드는 IDE가 찾지 못할 수 있다. 테스트를 돌려보고 확인한다.

### 2. 중복 제거

같은 로직이 여러 곳에 있으면 하나로 합친다. 함수로 추출하거나 공통 모듈로 분리한다.

예를 들어, 입력 검증 로직이 여러 서비스에 중복되어 있다면 `@Valid` 어노테이션으로 통일한다.

### 3. 추상화 레벨 올리기

구체적인 코드를 추상화하면 코드가 줄어든다.

예를 들어, 여러 서비스에서 비슷한 CRUD 로직이 반복된다면 `GenericService`를 만든다. 각 서비스는 `GenericService`를 상속받아서 필요한 부분만 오버라이드한다.

### 4. 프레임워크 기능 활용

직접 구현하는 대신 프레임워크 기능을 쓴다.

예를 들어, 로깅을 직접 구현하는 대신 AOP를 쓴다. 입력 검증을 직접 구현하는 대신 `@Valid` 어노테이션을 쓴다.

프레임워크가 제공하는 기능을 쓰면 코드가 줄어든다.

## 코드를 지우는 게 최고의 리팩토링인 이유

리팩토링이라고 하면 보통 코드를 개선하는 걸 생각한다. 변수명을 바꾸고, 함수를 분리하고, 클래스를 재구성하는 것.

하지만 가장 좋은 리팩토링은 코드를 지우는 것이다.

### 버그가 생길 수 없다

코드가 없으면 버그가 생길 수 없다. 200줄짜리 함수에서 버그가 생길 가능성과 15줄짜리 함수에서 버그가 생길 가능성. 어느 게 더 낮은가?

```
버그 발생 가능성
200줄 함수: ████████████████████ 20%
15줄 함수:  ██ 2%
```

### 이해하기 쉽다

코드가 적을수록 이해하기 쉽다. 15줄짜리 함수는 한눈에 보인다. 200줄짜리 함수는 스크롤을 내려가면서 읽어야 한다.

### 수정하기 쉽다

코드가 적을수록 수정하기 쉽다. 15줄 중에서 어디를 수정해야 하는지 찾는 것과 200줄 중에서 찾는 것. 어느 게 더 쉬운가?

### 테스트하기 쉽다

코드가 적을수록 테스트하기 쉽다. 15줄짜리 함수를 테스트하는 것과 200줄짜리 함수를 테스트하는 것. 테스트 케이스도 줄어든다.

## 코드를 지우는 것의 한계

코드를 지우는 것도 한계가 있다. 무작정 지우면 안 된다.

### 비즈니스 로직은 지우면 안 된다

비즈니스 로직은 지우면 안 된다. 이건 코드가 아니라 요구사항이다. 비즈니스 로직을 지우면 기능이 사라진다.

### 보안 관련 코드는 신중해야 한다

보안 관련 코드는 신중해야 한다. 입력 검증, 인증, 권한 체크 같은 건 지우면 안 된다. 하지만 중복된 검증은 제거할 수 있다.

### 로깅은 필요하다

로깅은 필요하다. 하지만 모든 곳에 로깅을 넣을 필요는 없다. 중요한 부분만 로깅한다. AOP로 처리하면 코드에서 로깅 로직을 제거할 수 있다.

## 실무에서의 적용

이론은 알겠는데, 실무에서는 어떻게 시작해야 할까? 큰 리팩토링부터 시작하면 부담스럽다. 작은 것부터 하나씩 제거해나가면 된다.

### 주석 처리된 코드 삭제

주석 처리된 코드는 삭제한다. Git이 있으니까 나중에 필요하면 찾을 수 있다. 주석 처리된 코드는 노이즈다.

### 사용하지 않는 import 삭제

사용하지 않는 import는 삭제한다. IDE가 자동으로 찾아준다. 한 번에 정리할 수 있다.

### 중복 코드 제거

같은 로직이 여러 곳에 있으면 하나로 합친다. 함수로 추출하거나 공통 모듈로 분리한다.

### 불필요한 추상화 제거

과도한 추상화는 오히려 복잡도를 높인다. 간단한 로직에 인터페이스를 만들 필요는 없다. 필요할 때 추가하면 된다.

## 마무리

코드를 짜는 것보다 지우는 게 어렵다. 하지만 지우는 게 더 중요하다.

코드가 적을수록 이해하기 쉽고, 수정하기 쉽고, 테스트하기 쉽다. 버그도 적다.

가장 좋은 코드는 존재하지 않는 코드다.

다음에 코드를 추가하기 전에 한 번 생각해보자. 이 코드가 정말 필요한가? 다른 방법은 없나? 프레임워크 기능을 쓸 수 없나?

그리고 코드를 리뷰할 때도 한 번 생각해보자. 이 코드가 없으면 안 될까? 지울 수 없을까?

코드를 지우는 것. 이것이 최고의 리팩토링이다.

## 참고자료

- Jeff Atwood, "The Best Code is No Code" (Coding Horror)
- Martin Fowler, "Refactoring: Improving the Design of Existing Code"
- Robert C. Martin, "Clean Code: A Handbook of Agile Software Craftsmanship"
- Andrew Hunt, David Thomas, "The Pragmatic Programmer: Your Journey to Mastery"
