---
title: "JavaScript 비동기 처리에 대하여"
tags: javascript async promise async-await event-loop callback
date: "2025.10.23"
categories:
    - Js
---

## 콜백 지옥부터 시작한다

API 호출을 연속으로 해야 하는 상황이다.

유저 정보 가져오고, 그 유저의 주문 목록 가져오고, 각 주문의 상세 정보 가져오기.

콜백으로 작성하면 이렇게 된다.

```javascript
getUserInfo(userId, function(user) {
    getOrders(user.id, function(orders) {
        getOrderDetails(orders[0].id, function(details) {
            console.log(details);
        });
    });
});
```

코드가 오른쪽으로 계속 들어간다.

**콜백 지옥**이다.

<br>

## 왜 비동기가 필요한가?

JavaScript는 싱글 스레드다. 한 번에 하나만 실행된다.

만약 동기적으로만 동작한다면?

```javascript
const data = fetchDataFromServer(); // 3초 걸림
console.log(data);
console.log('다음 작업');
```

서버에서 데이터 받는 3초 동안 브라우저가 멈춘다. 아무것도 못 한다. 클릭도 안 된다.

**그래서 비동기가 필요하다.**

```javascript
fetchDataFromServer(function(data) {
    console.log(data);
});
console.log('다음 작업'); // 이게 먼저 실행됨
```

데이터 받는 동안 다른 작업을 한다. 브라우저는 안 멈춘다. 사용자는 스크롤도 하고 클릭도 한다.

<br>

## 이벤트 루프가 어떻게 동작하나?

비동기를 이해하려면 이벤트 루프를 알아야 한다.

JavaScript 엔진은 세 가지로 구성된다.

### 1. Call Stack (호출 스택)

현재 실행 중인 함수가 쌓이는 곳이다.

```javascript
function first() {
    second();
    console.log('첫 번째');
}

function second() {
    console.log('두 번째');
}

first();
```

실행 순서
1. `first()` 스택에 들어감
2. `second()` 스택에 들어감
3. `console.log('두 번째')` 실행 → second() 스택에서 빠짐
4. `console.log('첫 번째')` 실행 → first() 스택에서 빠짐

출력
```
두 번째
첫 번째
```

간단하다. **LIFO (Last In First Out)**다.

### 2. Web APIs

브라우저가 제공하는 API다. `setTimeout`, `fetch`, `addEventListener` 같은 것들.

```javascript
console.log('1');

setTimeout(function() {
    console.log('2');
}, 0);

console.log('3');
```

실행하면?

```
1
3
2
```

왜 2가 마지막에 나올까? setTimeout이 0초인데?

**setTimeout은 Web API다. Call Stack에서 바로 실행 안 된다.**

### 3. Callback Queue (콜백 큐)

Web API가 끝나면 콜백을 여기에 넣는다.

이벤트 루프가 Call Stack이 비면 Callback Queue에서 꺼내서 실행한다.

```javascript
console.log('1'); // Call Stack에서 실행

setTimeout(function() {
    console.log('2'); // Web API → Callback Queue → Call Stack
}, 0);

console.log('3'); // Call Stack에서 실행
```

흐름
1. `console.log('1')` 실행 → 출력 "1"
2. `setTimeout` → Web API로 이동 (0초 대기)
3. `console.log('3')` 실행 → 출력 "3"
4. Call Stack 비었음 → 이벤트 루프가 Callback Queue 확인
5. `console.log('2')` 실행 → 출력 "2"

**setTimeout(fn, 0)은 "0초 후 실행"이 아니라 "Call Stack 비면 실행"이다.**

<br>

## 콜백의 문제점

초반에 본 코드다.

```javascript
getUserInfo(userId, function(user) {
    getOrders(user.id, function(orders) {
        getOrderDetails(orders[0].id, function(details) {
            console.log(details);
        });
    });
});
```

문제가 뭘까?

### 1. 가독성이 최악이다

코드가 오른쪽으로 계속 들어간다. 흐름을 따라가기 힘들다.

### 2. 에러 처리가 어렵다

```javascript
getUserInfo(userId, function(err, user) {
    if (err) {
        console.error(err);
        return;
    }
    
    getOrders(user.id, function(err, orders) {
        if (err) {
            console.error(err);
            return;
        }
        
        getOrderDetails(orders[0].id, function(err, details) {
            if (err) {
                console.error(err);
                return;
            }
            
            console.log(details);
        });
    });
});
```

에러 처리 코드가 반복된다. 지옥이 더 깊어진다.

### 3. 제어 흐름이 복잡하다

"첫 번째 API 실패하면 두 번째는 실행 안 하고, 세 번째만 실행하고 싶다"

콜백으로는 거의 불가능하다. 코드가 스파게티가 된다.

**그래서 Promise가 나왔다.**

<br>

## Promise의 등장

Promise는 "미래의 값"을 나타낸다.

지금은 없지만, 나중에 생길 값이다.

```javascript
const promise = getUserInfo(userId);

promise.then(function(user) {
    console.log(user);
});
```

훨씬 깔끔하다. 콜백 안에 콜백 없이 체이닝할 수 있다.

### Promise의 세 가지 상태

1. **Pending (대기)**: 아직 결과 안 나옴
2. **Fulfilled (이행)**: 성공적으로 완료됨
3. **Rejected (거부)**: 실패함

```javascript
const promise = new Promise(function(resolve, reject) {
    const success = true;
    
    if (success) {
        resolve('성공!');
    } else {
        reject('실패!');
    }
});

promise
    .then(function(result) {
        console.log(result); // "성공!"
    })
    .catch(function(error) {
        console.error(error); // "실패!"
    });
```

`resolve`를 호출하면 Fulfilled, `reject`를 호출하면 Rejected.

### Promise 체이닝

아까 콜백 지옥을 Promise로 바꾸면?

```javascript
getUserInfo(userId)
    .then(function(user) {
        return getOrders(user.id);
    })
    .then(function(orders) {
        return getOrderDetails(orders[0].id);
    })
    .then(function(details) {
        console.log(details);
    })
    .catch(function(error) {
        console.error(error); // 어디서 에러나도 여기서 잡힘
    });
```

오른쪽으로 들어가지 않는다. 위에서 아래로 읽힌다.

에러 처리도 한 곳에서 한다.

**훨씬 낫다.**

<br>

## Promise.all과 Promise.race

여러 개의 Promise를 다뤄야 할 때가 있다.

### Promise.all

"모든 Promise가 완료될 때까지 기다린다"

```javascript
const promise1 = fetch('/api/users');
const promise2 = fetch('/api/products');
const promise3 = fetch('/api/orders');

Promise.all([promise1, promise2, promise3])
    .then(function([users, products, orders]) {
        console.log(users, products, orders);
        // 세 개 다 완료되면 실행됨
    })
    .catch(function(error) {
        // 하나라도 실패하면 여기로 옴
        console.error(error);
    });
```

**하나라도 실패하면 전체가 실패한다.** 주의해야 한다.

### Promise.race

"제일 빨리 완료되는 Promise 하나만 기다린다"

```javascript
const timeout = new Promise((resolve, reject) => {
    setTimeout(() => reject('Timeout!'), 5000);
});

const fetchData = fetch('/api/data');

Promise.race([timeout, fetchData])
    .then(function(result) {
        console.log(result); // fetchData가 5초 안에 완료되면 이게 실행됨
    })
    .catch(function(error) {
        console.error(error); // 5초 지나면 "Timeout!" 에러
    });
```

타임아웃 구현할 때 유용하다.

### Promise.allSettled

"모든 Promise가 완료될 때까지 기다리되, 실패해도 상관없다"

```javascript
const promises = [
    fetch('/api/users'),
    fetch('/api/invalid'), // 이게 실패해도
    fetch('/api/products')
];

Promise.allSettled(promises)
    .then(function(results) {
        results.forEach(function(result) {
            if (result.status === 'fulfilled') {
                console.log('성공:', result.value);
            } else {
                console.log('실패:', result.reason);
            }
        });
    });
```

`Promise.all`과 달리 하나 실패해도 멈추지 않는다.

<br>

## async/await의 등장

Promise도 좋은데, 체이닝이 길어지면 또 복잡하다.

```javascript
getUserInfo(userId)
    .then(function(user) {
        return getOrders(user.id);
    })
    .then(function(orders) {
        return getOrderDetails(orders[0].id);
    })
    .then(function(details) {
        return processDetails(details);
    })
    .then(function(processed) {
        return saveToDatabase(processed);
    })
    .then(function(saved) {
        console.log(saved);
    })
    .catch(function(error) {
        console.error(error);
    });
```

여전히 길다.

**async/await가 해결책이다.**

```javascript
async function processUser(userId) {
    try {
        const user = await getUserInfo(userId);
        const orders = await getOrders(user.id);
        const details = await getOrderDetails(orders[0].id);
        const processed = await processDetails(details);
        const saved = await saveToDatabase(processed);
        
        console.log(saved);
    } catch (error) {
        console.error(error);
    }
}
```

동기 코드처럼 보인다. 읽기 쉽다.

`await`는 Promise가 완료될 때까지 기다린다. 그 동안 다른 코드가 실행된다.

**async/await는 Promise의 문법적 설탕이다.** 내부적으로는 Promise다.

<br>

## 순차 실행과 병렬 실행

순차 실행은 느리다.

```javascript
async function getDataSlow() {
    const user = await fetch('/api/user'); // 1초
    const products = await fetch('/api/products'); // 1초
    const orders = await fetch('/api/orders'); // 1초
    
    // 총 3초 걸림
    return { user, products, orders };
}
```

각 요청이 끝날 때까지 기다린다. 다음 요청이 시작된다.

병렬 실행은 빠르다.

```javascript
async function getDataFast() {
    const userPromise = fetch('/api/user');
    const productsPromise = fetch('/api/products');
    const ordersPromise = fetch('/api/orders');
    
    const [user, products, orders] = await Promise.all([
        userPromise,
        productsPromise,
        ordersPromise
    ]);
    
    // 총 1초 걸림 (가장 느린 요청 기준)
    return { user, products, orders };
}
```

세 요청을 동시에 시작한다. 모두 끝날 때까지 기다린다.

**3배 빠르다.**

<br>

## 에러 처리는 try-catch

async/await에서 에러는 try-catch로 잡는다.

```javascript
async function fetchUser(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const user = await response.json();
        return user;
    } catch (error) {
        console.error('사용자 정보 가져오기 실패:', error);
        throw error; // 상위로 전달
    }
}
```

개별적으로 처리할 수도 있다.

```javascript
async function processData() {
    let user;
    
    try {
        user = await fetchUser(userId);
    } catch (error) {
        console.error('유저 정보 실패:', error);
        return; // 여기서 중단
    }
    
    try {
        const orders = await fetchOrders(user.id);
        console.log(orders);
    } catch (error) {
        console.error('주문 정보 실패:', error);
        // 계속 진행 가능
    }
}
```

<br>

## forEach는 async를 기다리지 않는다

```javascript
async function processUsers(userIds) {
    userIds.forEach(async function(id) {
        const user = await fetchUser(id);
        console.log(user);
    });
    
    console.log('완료!'); // 이게 먼저 출력됨
}
```

`for...of`를 쓴다. 순차적으로 실행된다.

```javascript
async function processUsers(userIds) {
    for (const id of userIds) {
        const user = await fetchUser(id);
        console.log(user);
    }
    
    console.log('완료!'); // 모든 유저 처리 후 출력
}
```

병렬로 실행하려면 `Promise.all`을 쓴다. 훨씬 빠르다.

```javascript
async function processUsers(userIds) {
    const promises = userIds.map(function(id) {
        return fetchUser(id);
    });
    
    const users = await Promise.all(promises);
    users.forEach(function(user) {
        console.log(user);
    });
    
    console.log('완료!');
}
```

<br>

## 타임아웃 구현

```javascript
function timeout(ms) {
    return new Promise((resolve, reject) => {
        setTimeout(() => reject(new Error('Timeout!')), ms);
    });
}

async function fetchWithTimeout(url, ms) {
    try {
        const result = await Promise.race([
            fetch(url),
            timeout(ms)
        ]);
        return result;
    } catch (error) {
        if (error.message === 'Timeout!') {
            console.error('요청 시간 초과');
        }
        throw error;
    }
}

// 사용
fetchWithTimeout('/api/data', 5000); // 5초 안에 완료 안 되면 에러
```

<br>

## await 빼먹으면 안 된다

```javascript
async function getUser() {
    const user = fetchUser(userId); // await 없음!
    console.log(user); // Promise 객체가 출력됨
}
```

`await` 안 붙이면 Promise 객체가 반환된다. 실제 값이 아니다.

<br>

## async 함수는 return 필수

```javascript
async function processData() {
    const data = await fetchData();
    // return 없음!
}

const result = await processData(); // undefined
```

`async` 함수는 항상 Promise를 반환한다. 명시적으로 return 해야 한다.

<br>

## 에러를 catch만 하고 끝내면 안 된다

```javascript
async function fetchData() {
    try {
        const data = await fetch('/api/data');
        return data;
    } catch (error) {
        console.error(error); // 로그만 찍고 끝
        // throw 안 함
    }
}

const data = await fetchData(); // 에러 발생해도 undefined 반환됨
```

에러를 잡았으면 처리하거나 다시 throw 해야 한다.

<br>

## Promise를 await 없이 반환하면 중첩된다

```javascript
async function getData() {
    return fetch('/api/data'); // await 없이 반환
}
```

`Promise<Promise<Response>>`가 된다.

```javascript
async function getData() {
    return await fetch('/api/data');
}
```

아니면 async를 뺀다.

```javascript
function getData() {
    return fetch('/api/data');
}
```

<br>

## 독립적인 요청은 병렬로 실행한다

순차 실행하면 느리다.

```javascript
async function getAll() {
    const users = await fetch('/api/users'); // 1초 대기
    const products = await fetch('/api/products'); // 1초 대기
    
    // 총 2초
}
```

병렬로 실행한다. 2배 빠르다.

```javascript
async function getAll() {
    const [users, products] = await Promise.all([
        fetch('/api/users'),
        fetch('/api/products')
    ]);
    
    // 총 1초
}
```

<br>

## 마이크로태스크 큐

Promise는 일반 콜백과 다르게 동작한다.

```javascript
console.log('1');

setTimeout(function() {
    console.log('2');
}, 0);

Promise.resolve().then(function() {
    console.log('3');
});

console.log('4');
```

출력은?

```
1
4
3
2
```

왜 3이 2보다 먼저 나올까?

**마이크로태스크 큐** 때문이다.

- `setTimeout` → 태스크 큐 (Callback Queue)
- `Promise.then` → 마이크로태스크 큐

이벤트 루프는 **마이크로태스크 큐를 먼저 확인한다**.

Call Stack 비면
1. 마이크로태스크 큐 확인 (Promise)
2. 마이크로태스크 큐 비었으면 태스크 큐 확인 (setTimeout)

그래서 Promise가 setTimeout보다 먼저 실행된다.

<br>

## 실무에서 자주 쓰는 패턴

### 1. Retry 로직

```javascript
async function fetchWithRetry(url, retries = 3) {
    for (let i = 0; i < retries; i++) {
        try {
            const response = await fetch(url);
            if (!response.ok) throw new Error('Failed');
            return await response.json();
        } catch (error) {
            if (i === retries - 1) throw error;
            
            console.log(`재시도 ${i + 1}/${retries}`);
            await new Promise(resolve => setTimeout(resolve, 1000));
        }
    }
}
```

실패하면 1초 기다렸다가 다시 시도한다. 3번까지.

### 2. 캐싱

```javascript
const cache = new Map();

async function fetchWithCache(url) {
    if (cache.has(url)) {
        console.log('캐시에서 가져옴');
        return cache.get(url);
    }
    
    const data = await fetch(url).then(r => r.json());
    cache.set(url, data);
    return data;
}
```

같은 요청은 캐시에서 가져온다. 서버 부담 줄인다.

### 3. Debounce (비동기 버전)

```javascript
function debounceAsync(fn, delay) {
    let timeoutId;
    
    return function(...args) {
        return new Promise((resolve) => {
            clearTimeout(timeoutId);
            
            timeoutId = setTimeout(async () => {
                const result = await fn(...args);
                resolve(result);
            }, delay);
        });
    };
}

// 사용
const searchAPI = debounceAsync(async (query) => {
    const response = await fetch(`/api/search?q=${query}`);
    return response.json();
}, 300);

// 타이핑할 때마다 호출해도 300ms 후에 한 번만 실행됨
await searchAPI('javascript');
```

### 4. 동시 실행 제한

API를 100개 동시에 호출하면 서버가 터진다. 제한해야 한다.

```javascript
async function promiseLimit(tasks, limit) {
    const results = [];
    const executing = [];
    
    for (const task of tasks) {
        const promise = task().then(result => {
            executing.splice(executing.indexOf(promise), 1);
            return result;
        });
        
        results.push(promise);
        executing.push(promise);
        
        if (executing.length >= limit) {
            await Promise.race(executing);
        }
    }
    
    return Promise.all(results);
}

// 사용
const tasks = userIds.map(id => () => fetchUser(id));
const users = await promiseLimit(tasks, 5); // 동시에 5개까지만
```

### 5. 순차적으로 Promise 실행

```javascript
async function executeSequentially(tasks) {
    const results = [];
    
    for (const task of tasks) {
        const result = await task();
        results.push(result);
    }
    
    return results;
}

// 혹은 reduce 사용
function executeSequentially(tasks) {
    return tasks.reduce(async (promise, task) => {
        const results = await promise;
        const result = await task();
        return [...results, result];
    }, Promise.resolve([]));
}
```

<br>

## React에서의 비동기 처리

### useEffect에서 async

`useEffect`에 async 함수를 직접 넣으면 안 된다.

```javascript
function MyComponent() {
    useEffect(async () => {
        const data = await fetchData();
        console.log(data);
    }, []);
}
```

cleanup 함수를 반환해야 하는데 Promise가 반환된다.

내부에서 async 함수를 만들어서 호출한다.

```javascript
function MyComponent() {
    useEffect(() => {
        async function loadData() {
            const data = await fetchData();
            console.log(data);
        }
        
        loadData();
    }, []);
}
```

아니면 Promise를 그냥 쓴다.

```javascript
function MyComponent() {
    useEffect(() => {
        fetchData().then(data => {
            console.log(data);
        });
    }, []);
}
```

### 취소 가능한 요청

컴포넌트 언마운트됐는데 setState 하면 경고 뜬다.

```javascript
function MyComponent() {
    const [data, setData] = useState(null);
    
    useEffect(() => {
        let isCancelled = false;
        
        async function loadData() {
            const result = await fetchData();
            
            if (!isCancelled) {
                setData(result);
            }
        }
        
        loadData();
        
        return () => {
            isCancelled = true;
        };
    }, []);
}
```

**AbortController 사용**

```javascript
function MyComponent() {
    const [data, setData] = useState(null);
    
    useEffect(() => {
        const controller = new AbortController();
        
        fetch('/api/data', { signal: controller.signal })
            .then(response => response.json())
            .then(data => setData(data))
            .catch(error => {
                if (error.name === 'AbortError') {
                    console.log('요청 취소됨');
                }
            });
        
        return () => {
            controller.abort();
        };
    }, []);
}
```

### 커스텀 훅

```javascript
function useFetch(url) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    
    useEffect(() => {
        const controller = new AbortController();
        
        async function fetchData() {
            try {
                setLoading(true);
                const response = await fetch(url, {
                    signal: controller.signal
                });
                
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                
                const data = await response.json();
                setData(data);
            } catch (error) {
                if (error.name !== 'AbortError') {
                    setError(error);
                }
            } finally {
                setLoading(false);
            }
        }
        
        fetchData();
        
        return () => {
            controller.abort();
        };
    }, [url]);
    
    return { data, loading, error };
}

// 사용
function MyComponent() {
    const { data, loading, error } = useFetch('/api/users');
    
    if (loading) return <div>로딩 중...</div>;
    if (error) return <div>에러: {error.message}</div>;
    
    return <div>{JSON.stringify(data)}</div>;
}
```

<br>

## 성능 최적화

### 불필요한 await 제거

이중 await는 불필요하다.

```javascript
async function getData() {
    const data = await fetch('/api/data');
    return data; // 여기서 또 await
}

const result = await getData(); // 이중 await
```

async 없이 Promise를 그냥 반환한다.

```javascript
function getData() {
    return fetch('/api/data');
}

const result = await getData();
```

### Promise.all로 병렬화

느림 (4초)

```javascript
async function loadPage() {
    const user = await fetchUser(); // 1초
    const posts = await fetchPosts(); // 1초
    const comments = await fetchComments(); // 1초
    const likes = await fetchLikes(); // 1초
    
    return { user, posts, comments, likes };
}
```

빠름 (1초)

```javascript
async function loadPage() {
    const [user, posts, comments, likes] = await Promise.all([
        fetchUser(),
        fetchPosts(),
        fetchComments(),
        fetchLikes()
    ]);
    
    return { user, posts, comments, likes };
}
```

### 동기 작업은 await 전에 실행

```javascript
async function processData() {
    const data = await fetchData();
    doSomethingSync(); // 동기 작업인데 await 뒤에 있음
}
```

이렇게 하면 동기 작업이 비동기 대기 시간에 실행된다.

```javascript
async function processData() {
    const dataPromise = fetchData();
    doSomethingSync(); // 데이터 받는 동안 실행됨
    const data = await dataPromise;
}
```

### else 대신 조기 반환

```javascript
async function getUser(id) {
    const cache = userCache.get(id);
    
    if (cache) {
        return cache;
    } else {
        const user = await fetchUser(id);
        userCache.set(id, user);
        return user;
    }
}
```

이렇게 쓴다.

```javascript
async function getUser(id) {
    const cache = userCache.get(id);
    if (cache) return cache; // 조기 반환
    
    const user = await fetchUser(id);
    userCache.set(id, user);
    return user;
}
```

<br>

## async/await는 스택 트레이스가 명확하다

Promise 체이닝

```javascript
function a() {
    return b().then(c).then(d);
}

// 에러 발생하면 스택 트레이스가 끊긴다
```

async/await

```javascript
async function a() {
    const resultB = await b();
    const resultC = await c(resultB);
    const resultD = await d(resultC);
    return resultD;
}

// 스택 트레이스가 명확하다
```

<br>

## 로깅으로 흐름 파악

```javascript
async function fetchData(url) {
    console.log(`요청 시작: ${url}`);
    
    try {
        const response = await fetch(url);
        console.log(`응답 받음: ${response.status}`);
        
        const data = await response.json();
        console.log(`데이터 파싱 완료`);
        
        return data;
    } catch (error) {
        console.error(`에러 발생: ${url}`, error);
        throw error;
    }
}
```

<br>

## 정리

JavaScript 비동기 처리는 진화했다.

**콜백** → 콜백 지옥  
**Promise** → 체이닝은 낫지만 여전히 복잡  
**async/await** → 동기 코드처럼 읽힌다

핵심은

1. **이벤트 루프를 이해한다** - Call Stack, Web APIs, Callback Queue
2. **Promise.all로 병렬 실행한다** - 성능 3배 차이 난다
3. **async/await로 가독성을 높인다** - 유지보수가 쉽다
4. **에러 처리를 빼먹지 않는다** - try-catch 필수
5. **불필요한 await를 제거한다** - 성능 최적화

비동기는 JavaScript의 핵심이다. 제대로 이해하면 코드 품질이 달라진다.

콜백 지옥과 async/await를 비교하면 차이가 명확하다. async/await가 압도적으로 읽기 쉽고 유지보수하기 좋다.

