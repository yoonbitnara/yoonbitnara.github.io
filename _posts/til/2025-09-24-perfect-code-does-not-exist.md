---
title: "완벽한 코드는 존재하는가"
date: 2025-09-24
categories: Til
tags: [TIL, 코드품질, 개발철학, 실무경험]
author: pitbull terrier
---

# 완벽한 코드는 존재하는가

개발을 시작한 지 얼마 되지 않았을 때, 나는 완벽한 코드를 작성하려고 했다. 변수명도 의미있게, 함수도 작게 나누고, 주석도 꼼꼼히 달고. 그런데 시간이 지나면서 깨달았다. 완벽한 코드는 없다는 걸.

## 완벽한 코드에 대한 착각

처음에는 이런 생각을 했다. "좋은 개발자가 되려면 완벽한 코드를 써야 해." 그래서 변수명 하나하나 신경쓰고, 함수 길이도 체크하고, 디자인 패턴도 무조건 적용하려고 했다.

```javascript
// 내가 처음에 생각했던 '완벽한' 코드
class UserAccountManagementService {
    constructor(userRepository, emailNotificationService, auditLogger) {
        this.userRepository = userRepository;
        this.emailNotificationService = emailNotificationService;
        this.auditLogger = auditLogger;
    }
    
    /**
     * 사용자 계정을 생성하고 관련된 모든 작업을 수행합니다.
     * @param {UserRegistrationRequest} registrationRequest - 사용자 등록 요청 객체
     * @returns {Promise<UserRegistrationResult>} 등록 결과
     */
    async createUserAccount(registrationRequest) {
        try {
            // 입력값 검증
            this.validateRegistrationRequest(registrationRequest);
            
            // 중복 이메일 확인
            const existingUser = await this.userRepository.findByEmail(registrationRequest.email);
            if (existingUser) {
                throw new DuplicateEmailException('이미 존재하는 이메일입니다.');
            }
            
            // 사용자 생성
            const newUser = await this.userRepository.create(registrationRequest);
            
            // 이메일 인증 발송
            await this.emailNotificationService.sendVerificationEmail(newUser);
            
            // 감사 로그 기록
            await this.auditLogger.logUserRegistration(newUser);
            
            return new UserRegistrationResult(true, newUser);
        } catch (error) {
            await this.auditLogger.logError('User registration failed', error);
            throw error;
        }
    }
}
```

이런 코드를 보면 "와, 정말 잘 짰다" 싶었다. 클래스명도 명확하고, 의존성 주입도 하고, 에러 처리도 완벽하고. 하지만 실제로는 이게 완벽한 코드가 아니었다.

## 완벽하지 않은 현실

첫 번째 문제는 시간이었다. 이런 코드를 짜려면 엄청난 시간이 걸린다. 간단한 기능 하나 구현하는데 하루종일 걸렸다. 그리고 더 큰 문제는 이렇게 짠 코드가 실제로는 잘 안 돌아간다는 거였다.

```javascript
// 실제로는 이렇게 간단하게 짜는 게 나았다
async function signup(email, password) {
    const user = await db.users.create({ email, password });
    await sendEmail(email);
    return user;
}
```

두 번째 문제는 과도한 추상화였다. 작은 프로젝트에서도 무조건 디자인 패턴을 적용하려고 했다. 결국 코드가 복잡해지기만 했다. 다른 개발자가 봤을 때도 이해하기 어려웠다.

세 번째 문제는 완벽주의였다. 조금만 문제가 있어도 처음부터 다시 짰다. 그런데 결국은 마감일이 다가오고, 급하게 그냥 돌아가게만 만들었다.

## 완벽한 코드의 기준이 바뀌었다

시간이 지나면서 완벽한 코드의 기준이 바뀌었다. 이제는 이런 것들을 중요하게 생각한다.

### 1. 읽기 쉬운가?

```javascript
// 좋은 코드
function calculateTotalPrice(items) {
    let total = 0;
    for (const item of items) {
        total += item.price * item.quantity;
    }
    return total;
}

// 나쁜 코드
function calc(items) {
    return items.reduce((a, b) => a + (b.p * b.q), 0);
}
```

첫 번째 코드는 누가 봐도 이해할 수 있다. 두 번째 코드는 나만 알 수 있다.

### 2. 변경하기 쉬운가?

```javascript
// 좋은 코드 - 새로운 할인 규칙 추가하기 쉬움
function calculateDiscount(customer, items) {
    if (customer.isVip) {
        return calculateVipDiscount(items);
    }
    if (customer.isStudent) {
        return calculateStudentDiscount(items);
    }
    return 0;
}

// 나쁜 코드 - 새로운 규칙 추가하기 어려움
function calculateDiscount(customer, items) {
    let discount = 0;
    if (customer.isVip && items.length > 5) {
        discount = Math.min(items.reduce((sum, item) => sum + item.price, 0) * 0.2, 50000);
    } else if (customer.isStudent && customer.age < 25) {
        discount = Math.min(items.reduce((sum, item) => sum + item.price, 0) * 0.1, 30000);
    }
    return discount;
}
```

첫 번째 코드는 새로운 할인 규칙을 추가하기 쉽다. 두 번째 코드는 복잡한 조건문 때문에 수정하기 어렵다.

### 3. 테스트하기 쉬운가?

```javascript
// 좋은 코드 - 테스트하기 쉬움
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// 나쁜 코드 - 테스트하기 어려움
function validateUserInput(userInput) {
    if (userInput.email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(userInput.email)) {
            alert('이메일 형식이 올바르지 않습니다.');
            return false;
        }
    }
    // 다른 검증들...
    return true;
}
```

첫 번째 함수는 단순하고 테스트하기 쉽다. 두 번째 함수는 여러 기능이 섞여있어서 테스트하기 어렵다.

## 완벽한 코드는 없다

결론적으로 완벽한 코드는 없다. 하지만 더 나은 코드는 있다.

### 완벽하지 않아도 되는 이유들

**1. 요구사항은 변한다**
오늘 완벽하다고 생각한 코드가 내일은 완벽하지 않을 수 있다. 비즈니스 요구사항이 바뀌면 코드도 바뀌어야 한다.

**2. 완벽은 비용이 너무 크다**
완벽한 코드를 짜려면 엄청난 시간과 노력이 필요하다. 하지만 그 시간을 다른 중요한 일에 쓸 수도 있다.

**3. 완벽은 주관적이다**
내가 완벽하다고 생각하는 코드를 다른 사람은 복잡하다고 생각할 수 있다. 팀의 코딩 스타일과 경험 수준에 따라 다르다.

**4. 완벽보다는 충분함이 중요하다**
코드가 요구사항을 만족하고, 읽기 쉽고, 수정하기 쉽다면 충분하다.

## 실무에서 배운 것들

### 코드 리뷰에서 배운 것

코드 리뷰를 하다 보면 이런 생각이 들었다. "이 코드가 정말 완벽한가?" 하지만 결국은 "이 코드가 문제없이 돌아가고, 다른 사람이 이해할 수 있나?"가 더 중요했다.

```javascript
// 리뷰어가 좋아했던 코드
function formatDate(date) {
    return date.toLocaleDateString('ko-KR');
}

// 리뷰어가 싫어했던 코드
function formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}년 ${month}월 ${day}일`;
}
```

첫 번째 코드가 더 간단하고 명확했다. 두 번째 코드는 너무 복잡했다.

### 레거시 코드에서 배운 것

기존 코드를 유지보수하다 보면 이런 생각이 들었다. "이 코드가 왜 이렇게 되어 있지?" 하지만 시간이 지나면서 이해했다. 그때는 그게 최선이었을 수도 있다.

완벽한 코드를 짜려고 하지 말고, 지금 상황에서 최선의 선택을 하는 게 중요하다.

### 팀에서 배운 것

팀 프로젝트를 하다 보면 다른 사람의 코드 스타일과 맞춰야 한다. 내가 완벽하다고 생각하는 코드가 팀의 스타일과 안 맞으면 문제가 된다.

완벽한 코드보다는 팀과 조화를 이루는 코드가 더 중요하다.

## 결론: 충분히 좋은 코드

완벽한 코드는 없다. 하지만 충분히 좋은 코드는 있다.

충분히 좋은 코드의 기준
- 요구사항을 만족한다
- 읽기 쉽다
- 수정하기 쉽다
- 테스트할 수 있다
- 팀의 스타일과 맞다

이 기준들을 만족한다면 그 코드는 충분히 좋은 코드다. 완벽을 추구하기보다는 지속적으로 개선해나가는 게 더 중요하다.

코드는 사람이 쓰는 것이다. 사람이 이해할 수 있고, 수정할 수 있고, 확장할 수 있는 코드가 진짜 좋은 코드다.

완벽한 코드를 짜려고 하지 말자. 대신 내일의 나가 이해할 수 있는 코드를 짜자. 6개월 후의 내가 봐도 문제없는 코드를 짜자.
