---
title: "리팩토링 패턴에 대하여"
tags: 리팩토링, 패턴, 코드품질, CleanCode, JavaScript
date: "2025.09.19"
categories: 
    - Code-Quality
---

# 리팩토링 패턴에 대하여

개발을 하다 보면 "이 코드가 왜 이렇게 복잡하지?"라는 생각이 들 때가 있다. 처음에는 간단했던 코드가 기능을 추가하고 수정하다 보니 점점 복잡해진다. 

그럴 때 필요한 것이 리팩토링이다. 하지만 리팩토링을 어떻게 해야 할지 모르겠다는 사람들이 많다. "어디서부터 시작해야 하지?", "이 코드를 어떻게 개선하지?"라는 고민을 한다.

마틴 파울러의 "리팩토링" 책에는 24가지 리팩토링 기법이 정리되어 있다. 하지만 이론만으로는 부족하다. 실제로 어떻게 적용하는지, 언제 사용하는지 알아야 한다.

오늘은 실무에서 자주 사용하는 리팩토링 패턴들을 구체적인 예시와 함께 알아보자.

## Extract Method (메서드 추출)

가장 기본적이면서도 가장 중요한 리팩토링 기법이다. 긴 메서드를 작은 단위로 나누는 것이다.

### 언제 사용하는가

메서드가 너무 길 때, 하나의 메서드에서 여러 가지 일을 할 때 사용한다. 일반적으로 20줄을 넘어가면 메서드를 분리하는 것을 고려해보자.

### Before - 나쁜 예시

```javascript
function printOwing(invoice) {
    let outstanding = 0;
    
    // 미해결 채무 계산
    for (const o of invoice.orders) {
        outstanding += o.amount;
    }
    
    // 만료일 계산
    const today = new Date();
    invoice.dueDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);
    
    // 세부사항 출력
    console.log("***********************");
    console.log("*** 고객 외상 ***");
    console.log("***********************");
    console.log(`고객명: ${invoice.customer}`);
    console.log(`채무액: ${outstanding}`);
    console.log(`만료일: ${invoice.dueDate.toLocaleDateString()}`);
}
```

### After - 개선된 예시

```javascript
function printOwing(invoice) {
    const outstanding = calculateOutstanding(invoice);
    recordDueDate(invoice);
    printDetails(invoice, outstanding);
}

function calculateOutstanding(invoice) {
    let outstanding = 0;
    for (const o of invoice.orders) {
        outstanding += o.amount;
    }
    return outstanding;
}

function recordDueDate(invoice) {
    const today = new Date();
    invoice.dueDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);
}

function printDetails(invoice, outstanding) {
    console.log("***********************");
    console.log("*** 고객 외상 ***");
    console.log("***********************");
    console.log(`고객명: ${invoice.customer}`);
    console.log(`채무액: ${outstanding}`);
    console.log(`만료일: ${invoice.dueDate.toLocaleDateString()}`);
}
```

### 효과

각 메서드가 하나의 책임만 가진다. 테스트하기 쉬워지고, 재사용 가능한 메서드들이 생긴다. 코드의 의도가 명확해진다.

## Extract Variable (변수 추출)

복잡한 표현식을 의미 있는 변수로 추출하는 기법이다.

### 언제 사용하는가

복잡한 계산식이나 조건문이 있을 때, 같은 표현식이 여러 번 반복될 때 사용한다.

### Before - 나쁜 예시

```javascript
function price(order) {
    return order.quantity * order.itemPrice - 
           Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 + 
           Math.min(order.quantity * order.itemPrice * 0.1, 100);
}
```

### After - 개선된 예시

```javascript
function price(order) {
    const basePrice = order.quantity * order.itemPrice;
    const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
    const shipping = Math.min(basePrice * 0.1, 100);
    
    return basePrice - quantityDiscount + shipping;
}
```

### 효과

코드의 의도가 명확해진다. 디버깅하기 쉬워지고, 변수명을 통해 비즈니스 로직을 이해할 수 있다.

## Inline Method (메서드 인라인)

메서드의 본문이 메서드 이름만큼 명확할 때 사용하는 기법이다.

### 언제 사용하는가

메서드가 너무 간단해서 오히려 복잡하게 만들 때, 메서드가 한 곳에서만 사용될 때 사용한다.

### Before - 나쁜 예시

```javascript
function getRating(driver) {
    return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver) {
    return driver.numberOfLateDeliveries > 5;
}
```

### After - 개선된 예시

```javascript
function getRating(driver) {
    return driver.numberOfLateDeliveries > 5 ? 2 : 1;
}
```

### 효과

불필요한 메서드가 제거되어 코드가 단순해진다. 과도한 추상화를 피할 수 있다.

## Move Method (메서드 이동)

메서드가 자신이 속한 클래스보다 다른 클래스에서 더 많이 사용될 때 사용하는 기법이다.

### 언제 사용하는가

메서드가 다른 클래스의 데이터를 더 많이 사용할 때, 메서드가 현재 클래스와 관련이 없어 보일 때 사용한다.

### Before - 나쁜 예시

```javascript
class Account {
    constructor(type, daysOverdrawn) {
        this.type = type;
        this.daysOverdrawn = daysOverdrawn;
    }
    
    bankCharge() {
        let result = 4.5;
        if (this.daysOverdrawn > 0) {
            result += this.overdraftCharge();
        }
        return result;
    }
    
    overdraftCharge() {
        if (this.type.isPremium) {
            const baseCharge = 10;
            if (this.daysOverdrawn <= 7) {
                return baseCharge;
            } else {
                return baseCharge + (this.daysOverdrawn - 7) * 0.85;
            }
        } else {
            return this.daysOverdrawn * 1.75;
        }
    }
}
```

### After - 개선된 예시

```javascript
class Account {
    constructor(type, daysOverdrawn) {
        this.type = type;
        this.daysOverdrawn = daysOverdrawn;
    }
    
    bankCharge() {
        let result = 4.5;
        if (this.daysOverdrawn > 0) {
            result += this.type.overdraftCharge(this.daysOverdrawn);
        }
        return result;
    }
}

class AccountType {
    constructor(isPremium) {
        this.isPremium = isPremium;
    }
    
    overdraftCharge(daysOverdrawn) {
        if (this.isPremium) {
            const baseCharge = 10;
            if (daysOverdrawn <= 7) {
                return baseCharge;
            } else {
                return baseCharge + (daysOverdrawn - 7) * 0.85;
            }
        } else {
            return daysOverdrawn * 1.75;
        }
    }
}
```

### 효과

메서드가 적절한 클래스에 위치하게 된다. 응집도가 높아지고 결합도가 낮아진다.

## Replace Conditional with Polymorphism (조건문을 다형성으로 대체)

복잡한 조건문을 다형성을 이용해 제거하는 기법이다.

### 언제 사용하는가

같은 조건문이 여러 곳에서 반복될 때, 새로운 타입이 추가될 때마다 조건문을 수정해야 할 때 사용한다.

### Before - 나쁜 예시

```javascript
function getSpeed(animal) {
    switch (animal.type) {
        case 'EUROPEAN':
            return getBaseSpeed();
        case 'AFRICAN':
            return getBaseSpeed() - getLoadFactor() * animal.numberOfCoconuts;
        case 'NORWEGIAN_BLUE':
            return animal.isNailed ? 0 : getBaseSpeed();
        default:
            return 0;
    }
}

function getBaseSpeed() {
    return 10;
}

function getLoadFactor() {
    return 0.1;
}
```

### After - 개선된 예시

```javascript
class Bird {
    getSpeed() {
        return 0;
    }
}

class EuropeanSwallow extends Bird {
    getSpeed() {
        return this.getBaseSpeed();
    }
    
    getBaseSpeed() {
        return 10;
    }
}

class AfricanSwallow extends Bird {
    constructor(numberOfCoconuts) {
        super();
        this.numberOfCoconuts = numberOfCoconuts;
    }
    
    getSpeed() {
        return this.getBaseSpeed() - this.getLoadFactor() * this.numberOfCoconuts;
    }
    
    getBaseSpeed() {
        return 10;
    }
    
    getLoadFactor() {
        return 0.1;
    }
}

class NorwegianBlueParrot extends Bird {
    constructor(isNailed) {
        super();
        this.isNailed = isNailed;
    }
    
    getSpeed() {
        return this.isNailed ? 0 : this.getBaseSpeed();
    }
    
    getBaseSpeed() {
        return 10;
    }
}
```

### 효과

새로운 타입 추가가 쉬워진다. 각 클래스가 자신의 행동을 책임진다. 조건문이 사라져서 코드가 깔끔해진다.

## Replace Magic Numbers with Named Constants (매직 넘버를 상수로 대체)

숫자 리터럴을 의미 있는 상수로 대체하는 기법이다.

### 언제 사용하는가

숫자의 의미가 명확하지 않을 때, 같은 숫자가 여러 곳에서 사용될 때 사용한다.

### Before - 나쁜 예시

```javascript
function potentialEnergy(mass, height) {
    return mass * 9.81 * height;
}

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
```

### After - 개선된 예시

```javascript
const GRAVITATIONAL_CONSTANT = 9.81;

const SHIPPING_RATES = {
    LIGHT_WEIGHT_LIMIT: 1,
    MEDIUM_WEIGHT_LIMIT: 5,
    HEAVY_WEIGHT_LIMIT: 10,
    LIGHT_WEIGHT_FEE: 2500,
    MEDIUM_WEIGHT_FEE: 3500,
    HEAVY_WEIGHT_FEE: 5000,
    PER_KG_FEE: 800
};

function potentialEnergy(mass, height) {
    return mass * GRAVITATIONAL_CONSTANT * height;
}

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

### 효과

코드의 의도가 명확해진다. 값 변경이 쉬워진다. 실수로 잘못된 값을 사용할 확률이 줄어든다.

## Extract Class (클래스 추출)

하나의 클래스가 너무 많은 책임을 가질 때 사용하는 기법이다.

### 언제 사용하는가

클래스가 두 가지 이상의 이유로 변경될 때, 클래스가 너무 클 때 사용한다.

### Before - 나쁜 예시

```javascript
class Person {
    constructor(name, officeAreaCode, officeNumber) {
        this.name = name;
        this.officeAreaCode = officeAreaCode;
        this.officeNumber = officeNumber;
    }
    
    getName() {
        return this.name;
    }
    
    getTelephoneNumber() {
        return `(${this.officeAreaCode}) ${this.officeNumber}`;
    }
    
    getOfficeAreaCode() {
        return this.officeAreaCode;
    }
    
    setOfficeAreaCode(arg) {
        this.officeAreaCode = arg;
    }
    
    getOfficeNumber() {
        return this.officeNumber;
    }
    
    setOfficeNumber(arg) {
        this.officeNumber = arg;
    }
}
```

### After - 개선된 예시

```javascript
class Person {
    constructor(name, officeAreaCode, officeNumber) {
        this.name = name;
        this.officeTelephone = new TelephoneNumber(officeAreaCode, officeNumber);
    }
    
    getName() {
        return this.name;
    }
    
    getTelephoneNumber() {
        return this.officeTelephone.getTelephoneNumber();
    }
    
    getOfficeAreaCode() {
        return this.officeTelephone.getAreaCode();
    }
    
    setOfficeAreaCode(arg) {
        this.officeTelephone.setAreaCode(arg);
    }
    
    getOfficeNumber() {
        return this.officeTelephone.getNumber();
    }
    
    setOfficeNumber(arg) {
        this.officeTelephone.setNumber(arg);
    }
}

class TelephoneNumber {
    constructor(areaCode, number) {
        this.areaCode = areaCode;
        this.number = number;
    }
    
    getAreaCode() {
        return this.areaCode;
    }
    
    setAreaCode(arg) {
        this.areaCode = arg;
    }
    
    getNumber() {
        return this.number;
    }
    
    setNumber(arg) {
        this.number = arg;
    }
    
    getTelephoneNumber() {
        return `(${this.areaCode}) ${this.number}`;
    }
}
```

### 효과

각 클래스가 단일 책임을 가진다. 테스트하기 쉬워진다. 재사용성이 높아진다.

## Introduce Parameter Object (매개변수 객체 도입)

여러 개의 매개변수를 하나의 객체로 묶는 기법이다.

### 언제 사용하는가

매개변수가 3개 이상일 때, 관련된 매개변수들이 함께 사용될 때 사용한다.

### Before - 나쁜 예시

```javascript
function amountInvoiced(startDate, endDate) {
    // ...
}

function amountReceived(startDate, endDate) {
    // ...
}

function amountOverdue(startDate, endDate) {
    // ...
}
```

### After - 개선된 예시

```javascript
class DateRange {
    constructor(startDate, endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    getStartDate() {
        return this.startDate;
    }
    
    getEndDate() {
        return this.endDate;
    }
}

function amountInvoiced(dateRange) {
    // ...
}

function amountReceived(dateRange) {
    // ...
}

function amountOverdue(dateRange) {
    // ...
}
```

### 효과

매개변수 개수가 줄어든다. 관련된 데이터가 하나의 객체로 묶인다. 코드의 가독성이 향상된다.

## Replace Array with Object (배열을 객체로 교체)

배열의 각 요소가 서로 다른 의미를 가질 때 사용하는 기법이다.

### 언제 사용하는가

배열의 인덱스가 특별한 의미를 가질 때, 배열의 요소가 서로 다른 타입일 때 사용한다.

### Before - 나쁜 예시

```javascript
function getPerformanceData(performance) {
    const playID = performance[0];
    const audience = performance[1];
    const play = getPlay(playID);
    
    let thisAmount = 0;
    switch (play.type) {
        case 'tragedy':
            thisAmount = 40000;
            if (audience > 30) {
                thisAmount += 1000 * (audience - 30);
            }
            break;
        case 'comedy':
            thisAmount = 30000;
            if (audience > 20) {
                thisAmount += 10000 + 500 * (audience - 20);
            }
            thisAmount += 300 * audience;
            break;
        default:
            throw new Error(`알 수 없는 장르: ${play.type}`);
    }
    
    return thisAmount;
}
```

### After - 개선된 예시

```javascript
class Performance {
    constructor(playID, audience) {
        this.playID = playID;
        this.audience = audience;
    }
    
    getPlayID() {
        return this.playID;
    }
    
    getAudience() {
        return this.audience;
    }
}

function getPerformanceData(performance) {
    const play = getPlay(performance.getPlayID());
    const audience = performance.getAudience();
    
    let thisAmount = 0;
    switch (play.type) {
        case 'tragedy':
            thisAmount = 40000;
            if (audience > 30) {
                thisAmount += 1000 * (audience - 30);
            }
            break;
        case 'comedy':
            thisAmount = 30000;
            if (audience > 20) {
                thisAmount += 10000 + 500 * (audience - 20);
            }
            thisAmount += 300 * audience;
            break;
        default:
            throw new Error(`알 수 없는 장르: ${play.type}`);
    }
    
    return thisAmount;
}
```

### 효과

코드의 의도가 명확해진다. 인덱스 실수를 방지할 수 있다. 타입 안정성이 향상된다.

## 실무에서 리팩토링 패턴 적용하기

### 단계별 접근법

리팩토링을 할 때는 한 번에 모든 것을 바꾸려 하지 말고 단계별로 접근해야 한다.

**1단계: 테스트 작성**
리팩토링을 시작하기 전에 반드시 테스트를 작성한다. 기존 기능이 정상 동작하는지 확인할 수 있는 테스트가 있어야 한다.

**2단계: 작은 단위로 리팩토링**
한 번에 하나의 리팩토링 기법만 적용한다. 여러 기법을 동시에 적용하면 오히려 문제가 생길 수 있다.

**3단계: 테스트 실행**
각 단계마다 테스트를 실행해서 기능이 정상 동작하는지 확인한다.

**4단계: 커밋**
리팩토링이 성공적으로 완료되면 커밋한다. 문제가 생겼을 때 이전 상태로 돌아갈 수 있다.

### 리팩토링 우선순위

모든 코드를 한 번에 리팩토링할 수는 없다. 우선순위를 정해서 중요한 부분부터 시작해야 한다.

**높은 우선순위**
- 자주 변경되는 코드
- 버그가 자주 발생하는 코드
- 성능이 중요한 코드
- 여러 곳에서 사용되는 코드

**낮은 우선순위**
- 거의 변경되지 않는 코드
- 곧 제거될 예정인 코드
- 단순한 코드

### 리팩토링 저항 극복하기

리팩토링을 하려고 하면 "지금은 바쁘니까 나중에 하자"는 반응을 받기 쉽다. 이런 저항을 극복하는 방법이 있다.

**점진적 개선**
큰 리팩토링을 한 번에 하려 하지 말고, 작은 개선을 지속적으로 한다. 버그를 수정할 때마다 조금씩 개선한다.

**측정 가능한 개선**
리팩토링의 효과를 측정할 수 있게 한다. 성능 개선, 버그 감소, 개발 속도 향상 등을 수치로 보여준다.

**팀 문화 구축**
리팩토링이 선택이 아닌 필수라는 문화를 만든다. 코드 리뷰에서 리팩토링을 권장하고, 리팩토링 시간을 정기적으로 확보한다.

## 마무리

리팩토링 패턴을 익히는 것은 중요하다. 하지만 더 중요한 것은 언제 어떤 패턴을 사용할지 판단하는 능력이다.

처음에는 모든 코드를 리팩토링하려고 할 수도 있다. 하지만 모든 코드가 완벽할 필요는 없다. 중요한 것은 코드가 이해하기 쉽고, 수정하기 쉽고, 확장하기 쉽다는 것이다.

리팩토링은 한 번에 끝나는 것이 아니다. 지속적으로 해야 하는 작업이다. 작은 개선을 꾸준히 하다 보면, 어느새 훨씬 나은 코드베이스를 갖게 될 것이라고 생각한다.
