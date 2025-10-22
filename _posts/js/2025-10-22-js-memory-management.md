---
title: "JavaScript 메모리 관리와 가비지 컬렉션"
tags: javascript memory garbage-collection performance debugging
date: "2025.10.22"
categories:
    - Js
---

## SPA 만들었는데 계속 느려진다

React로 대시보드 만들었다. 처음엔 잘 돌아갔다.

근데 10분 정도 쓰다 보면 점점 느려진다. 탭 전환할 때마다 버벅인다.

새로고침하면? 다시 빨라진다. 또 10분 쓰면 느려진다.

Chrome DevTools Performance 탭을 열었다. 메모리 사용량이 계속 올라간다. 내려오질 않는다.

**메모리 누수**였다.

<br>

## 메모리 누수가 뭔데?

JavaScript는 자동으로 메모리를 관리한다. 필요 없어진 객체는 알아서 제거해준다.

근데 왜 메모리 누수가 생기는가?

**가비지 컬렉터가 "이거 아직 필요한가?"라고 착각하기 때문이다.**

```javascript
let bigData = new Array(1000000).fill('data');

function processData() {
    // bigData 사용
    console.log(bigData.length);
}

// processData는 끝났는데 bigData는 계속 메모리에 남아있다
// 왜? 전역 변수니까 가비지 컬렉터가 못 지운다
```

전역 변수로 선언하면 페이지 닫을 때까지 메모리에 있다. 계속 쌓인다.

<br>

## 실제 메모리 누수 예시

### 1. 이벤트 리스너를 안 지운다

제일 흔한 케이스다.

```javascript
function setupButton() {
    const button = document.getElementById('myButton');
    
    button.addEventListener('click', function() {
        // 엄청 큰 데이터 처리
        const bigData = new Array(1000000).fill('data');
        console.log(bigData.length);
    });
}

// 컴포넌트 제거해도 이벤트 리스너는 남아있다
// button이 DOM에서 제거되어도 리스너는 메모리에 있다
```

**React에서 흔한 실수**

```javascript
function MyComponent() {
    useEffect(() => {
        const handleScroll = () => {
            console.log('scrolling...');
        };
        
        window.addEventListener('scroll', handleScroll);
        
        // 이거 빼먹으면 메모리 누수
        // return () => {
        //     window.removeEventListener('scroll', handleScroll);
        // };
    }, []);
}
```

컴포넌트 언마운트돼도 scroll 이벤트 리스너는 살아있다. 컴포넌트 10번 마운트하면 리스너 10개 생긴다.

**해결법**

```javascript
useEffect(() => {
    const handleScroll = () => {
        console.log('scrolling...');
    };
    
    window.addEventListener('scroll', handleScroll);
    
    return () => {
        window.removeEventListener('scroll', handleScroll);
    };
}, []);
```

cleanup 함수로 이벤트 리스너 제거한다.

<br>

### 2. setInterval을 안 지운다

타이머도 마찬가지다.

```javascript
function startTimer() {
    setInterval(() => {
        console.log('tick');
    }, 1000);
}

// 이거 한 번 호출하면 영원히 돌아간다
// 페이지 닫을 때까지
```

**React에서**

```javascript
function Timer() {
    const [count, setCount] = useState(0);
    
    useEffect(() => {
        const timer = setInterval(() => {
            setCount(c => c + 1);
        }, 1000);
        
        // 이거 없으면 메모리 누수
        return () => clearInterval(timer);
    }, []);
    
    return <div>{count}</div>;
}
```

컴포넌트 언마운트돼도 setInterval은 계속 돌아간다. clearInterval 필수다.

<br>

### 3. 클로저가 큰 객체를 참조한다

클로저는 외부 변수를 기억한다. 큰 객체를 참조하면 메모리에 계속 남는다.

```javascript
function createHandler() {
    const bigData = new Array(1000000).fill('data');
    
    return function() {
        // bigData의 길이만 쓰는데
        console.log(bigData.length);
        // bigData 전체가 메모리에 남아있다
    };
}

const handler = createHandler();
// handler가 살아있는 한 bigData도 메모리에 있다
```

**해결법**

```javascript
function createHandler() {
    const bigData = new Array(1000000).fill('data');
    const length = bigData.length; // 필요한 것만 저장
    
    return function() {
        console.log(length); // 이제 bigData는 가비지 컬렉션 가능
    };
}
```

필요한 값만 따로 저장하면 원본 객체는 메모리에서 제거된다.

<br>

### 4. DOM 참조를 계속 들고 있다

```javascript
const elements = [];

function addElement() {
    const div = document.createElement('div');
    document.body.appendChild(div);
    
    elements.push(div); // 여기서 참조 저장
}

function removeElement() {
    const div = elements.pop();
    document.body.removeChild(div);
    
    // div는 DOM에서 제거됐지만
    // elements 배열이 참조를 들고 있어서 메모리에 남는다
}
```

DOM에서 제거해도 JavaScript가 참조를 들고 있으면 메모리에 남는다.

**해결법**

```javascript
function removeElement() {
    const div = elements.pop();
    document.body.removeChild(div);
    
    // 참조도 제거
    div = null;
}
```

<br>

## 가비지 컬렉션이 어떻게 동작하나?

JavaScript는 **Mark-and-Sweep** 알고리즘을 쓴다.

### 1. Mark (표시)

루트(전역 객체, 현재 실행 중인 함수)에서 시작해서 닿을 수 있는 객체를 전부 표시한다.

```javascript
let obj1 = { name: 'A' };
let obj2 = { name: 'B' };

obj1.ref = obj2; // obj1 → obj2

obj1 = null; // obj1 참조 제거

// obj1은 더 이상 루트에서 닿을 수 없다 → 표시 안 됨
// obj2는? obj1에서만 참조했으니 obj2도 표시 안 됨
```

### 2. Sweep (청소)

표시 안 된 객체를 전부 메모리에서 제거한다.

간단하다. **닿을 수 없으면 지운다.**

<br>

## Chrome DevTools로 메모리 분석

실제로 메모리 누수를 찾으려면 DevTools를 써야 한다.

### 1. Memory 탭 열기

Chrome DevTools → Memory 탭 → Heap snapshot

### 2. 스냅샷 찍기

1. 페이지 로드 직후 스냅샷 찍기
2. 기능 사용 (버튼 클릭, 페이지 이동 등)
3. 다시 스냅샷 찍기
4. 비교

### 3. Detached DOM 찾기

"Detached" 검색하면 DOM에서 제거됐지만 메모리에 남아있는 요소들이 나온다.

```javascript
// 나쁜 예
let detachedDiv;

function createDiv() {
    const div = document.createElement('div');
    document.body.appendChild(div);
    detachedDiv = div; // 참조 저장
}

function removeDiv() {
    document.body.removeChild(detachedDiv);
    // detachedDiv가 아직 참조 들고 있음 → Detached DOM
}
```

<br>

## 실전 팁

### 1. 전역 변수 최소화

```javascript
// 나쁜 예
var cache = {}; // 전역

function getData(id) {
    if (!cache[id]) {
        cache[id] = fetchData(id);
    }
    return cache[id];
}

// 좋은 예
function createCache() {
    const cache = {}; // 클로저로 캡슐화
    
    return {
        get(id) {
            if (!cache[id]) {
                cache[id] = fetchData(id);
            }
            return cache[id];
        },
        clear() {
            cache = {}; // 메모리 해제 가능
        }
    };
}
```

### 2. WeakMap 사용

일반 Map은 키를 강하게 참조한다. 키가 제거돼도 Map이 들고 있으면 메모리에 남는다.

WeakMap은 약하게 참조한다. 키가 제거되면 Map에서도 자동으로 제거된다.

```javascript
// 나쁜 예
const userMetadata = new Map();

function addUser(user) {
    userMetadata.set(user, { loginCount: 0 });
}

// user 객체가 제거돼도 Map에 남아있다

// 좋은 예
const userMetadata = new WeakMap();

function addUser(user) {
    userMetadata.set(user, { loginCount: 0 });
}

// user 객체가 제거되면 WeakMap에서도 자동 제거
```

### 3. 큰 배열은 null로 초기화

```javascript
function processLargeData() {
    let bigArray = new Array(1000000).fill('data');
    
    // 처리
    doSomething(bigArray);
    
    // 다 쓰면 명시적으로 제거
    bigArray = null;
}
```

가비지 컬렉터를 기다리지 말고 직접 null 할당하면 빨리 메모리 해제된다.

### 4. 디바운스/쓰로틀 cleanup

```javascript
function useDebounce(callback, delay) {
    const timeoutRef = useRef();
    
    useEffect(() => {
        return () => {
            // cleanup에서 타이머 제거
            if (timeoutRef.current) {
                clearTimeout(timeoutRef.current);
            }
        };
    }, []);
    
    return (...args) => {
        if (timeoutRef.current) {
            clearTimeout(timeoutRef.current);
        }
        timeoutRef.current = setTimeout(() => {
            callback(...args);
        }, delay);
    };
}
```

<br>

## React 무한 스크롤

처음에 만든 코드

```javascript
function InfiniteScroll() {
    const [items, setItems] = useState([]);
    
    useEffect(() => {
        const handleScroll = () => {
            if (window.scrollY + window.innerHeight >= document.body.scrollHeight) {
                // 데이터 추가
                setItems(prev => [...prev, ...fetchMoreItems()]);
            }
        };
        
        window.addEventListener('scroll', handleScroll);
        // cleanup 없음!
    }, []);
    
    return <div>{items.map(item => <Item key={item.id} data={item} />)}</div>;
}
```

문제는
1. scroll 이벤트 리스너 제거 안 함
2. 컴포넌트 재마운트하면 리스너 중복 생성
3. 메모리 누수

**수정한 코드**

```javascript
function InfiniteScroll() {
    const [items, setItems] = useState([]);
    const observerRef = useRef();
    
    useEffect(() => {
        const observer = new IntersectionObserver((entries) => {
            if (entries[0].isIntersecting) {
                setItems(prev => [...prev, ...fetchMoreItems()]);
            }
        });
        
        if (observerRef.current) {
            observer.observe(observerRef.current);
        }
        
        // cleanup
        return () => {
            if (observerRef.current) {
                observer.unobserve(observerRef.current);
            }
        };
    }, []);
    
    return (
        <div>
            {items.map(item => <Item key={item.id} data={item} />)}
            <div ref={observerRef} />
        </div>
    );
}
```

개선점
1. IntersectionObserver 사용 (scroll 이벤트보다 효율적)
2. cleanup 함수로 observer 제거
3. 메모리 누수 없음

<br>

## 정리

JavaScript는 자동으로 메모리 관리를 해준다. 근데 완벽하지 않다.

개발자가 실수하면 메모리 누수가 생긴다. 특히 SPA에서 치명적이다.

**핵심은 3가지다**

1. **이벤트 리스너, 타이머는 반드시 제거한다**
2. **전역 변수, 클로저 조심한다**
3. **Chrome DevTools로 주기적으로 체크한다**

메모리 누수는 눈에 안 보인다. 근데 사용자는 느낀다. "왜 이거 점점 느려져?"

코드 작성할 때 cleanup 함수 습관화하면 대부분 예방된다.

