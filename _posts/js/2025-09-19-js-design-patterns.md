---
title: "JavaScript 디자인 패턴"
date: 2025-09-19
categories: Js
tags: [javascript, design-patterns, singleton, factory, observer, mvc, 실무패턴]
author: pitbull terrier
---

# JavaScript 디자인 패턴

JavaScript로 복잡한 애플리케이션을 개발하다 보면 코드의 구조화와 유지보수성을 고민하게 된다. 특히 팀으로 개발할 때는 일관된 코드 스타일과 구조가 중요하다.

디자인 패턴은 이런 문제들을 해결하기 위한 검증된 해결책들이다. 실무에서 자주 사용되는 패턴들을 익히면 코드 품질을 크게 향상시킬 수 있다.

오늘은 JavaScript에서 실무에서 자주 사용되는 디자인 패턴들을 코드 예시와 함께 정리해보겠다.

## 디자인 패턴이란?

디자인 패턴은 소프트웨어 설계에서 자주 발생하는 문제에 대한 재사용 가능한 해결책이다. 특정 상황에서 어떤 구조를 사용하면 좋은지에 대한 가이드라인을 제공한다.

**디자인 패턴의 장점:**
- 코드의 재사용성 향상
- 유지보수성 개선
- 팀 내 일관된 코딩 스타일
- 문제 해결 시간 단축

## 1. 싱글톤 패턴 (Singleton Pattern)

### 개념
클래스의 인스턴스가 하나만 생성되도록 보장하는 패턴이다. 전역 상태 관리나 설정 객체 등에 자주 사용된다.

### 기본 구현
```js
class Database {
    constructor() {
        if (Database.instance) {
            return Database.instance;
        }
        
        this.connectionString = 'localhost:3306';
        this.isConnected = false;
        Database.instance = this;
    }
    
    connect() {
        this.isConnected = true;
        console.log('데이터베이스 연결됨');
    }
    
    disconnect() {
        this.isConnected = false;
        console.log('데이터베이스 연결 해제됨');
    }
}

// 사용 예시
const db1 = new Database();
const db2 = new Database();

console.log(db1 === db2); // true - 같은 인스턴스

db1.connect();
console.log(db2.isConnected); // true - 같은 객체 상태 공유
```

### 모듈 패턴을 활용한 싱글톤
```js
const Config = (function() {
    let instance;
    
    function createInstance() {
        return {
            apiUrl: 'https://api.example.com',
            timeout: 5000,
            retries: 3,
            get: function(key) {
                return this[key];
            },
            set: function(key, value) {
                this[key] = value;
            }
        };
    }
    
    return {
        getInstance: function() {
            if (!instance) {
                instance = createInstance();
            }
            return instance;
        }
    };
})();

// 사용 예시
const config1 = Config.getInstance();
const config2 = Config.getInstance();

console.log(config1 === config2); // true
config1.set('apiUrl', 'https://newapi.com');
console.log(config2.get('apiUrl')); // 'https://newapi.com'
```

### 실무 활용 사례
```js
// 로거 싱글톤
class Logger {
    constructor() {
        if (Logger.instance) {
            return Logger.instance;
        }
        
        this.logs = [];
        this.level = 'info';
        Logger.instance = this;
    }
    
    setLevel(level) {
        this.level = level;
    }
    
    log(message, level = 'info') {
        const timestamp = new Date().toISOString();
        const logEntry = { timestamp, level, message };
        
        this.logs.push(logEntry);
        
        if (this.shouldLog(level)) {
            console.log(`[${level.toUpperCase()}] ${timestamp}: ${message}`);
        }
    }
    
    shouldLog(level) {
        const levels = { error: 0, warn: 1, info: 2, debug: 3 };
        return levels[level] <= levels[this.level];
    }
    
    getLogs() {
        return [...this.logs];
    }
}

// 사용 예시
const logger = new Logger();
logger.setLevel('debug');

logger.log('애플리케이션 시작', 'info');
logger.log('사용자 로그인 시도', 'debug');
logger.log('데이터베이스 연결 실패', 'error');
```

## 2. 팩토리 패턴 (Factory Pattern)

### 개념
객체 생성을 담당하는 팩토리 함수나 클래스를 통해 객체를 생성하는 패턴이다. 복잡한 객체 생성 로직을 캡슐화한다.

### 기본 구현
```js
// 상품 타입별 팩토리
class ProductFactory {
    static createProduct(type, options) {
        switch (type) {
            case 'book':
                return new Book(options);
            case 'electronics':
                return new Electronics(options);
            case 'clothing':
                return new Clothing(options);
            default:
                throw new Error(`알 수 없는 상품 타입: ${type}`);
        }
    }
}

class Book {
    constructor({ title, author, price, isbn }) {
        this.title = title;
        this.author = author;
        this.price = price;
        this.isbn = isbn;
        this.category = 'book';
    }
    
    getDescription() {
        return `${this.title} by ${this.author} (ISBN: ${this.isbn})`;
    }
}

class Electronics {
    constructor({ name, brand, price, warranty }) {
        this.name = name;
        this.brand = brand;
        this.price = price;
        this.warranty = warranty;
        this.category = 'electronics';
    }
    
    getDescription() {
        return `${this.brand} ${this.name} (보증: ${this.warranty}년)`;
    }
}

// 사용 예시
const book = ProductFactory.createProduct('book', {
    title: 'JavaScript 완벽 가이드',
    author: 'David Flanagan',
    price: 50000,
    isbn: '978-89-6848-123-4'
});

const laptop = ProductFactory.createProduct('electronics', {
    name: 'MacBook Pro',
    brand: 'Apple',
    price: 2000000,
    warranty: 1
});

console.log(book.getDescription());
console.log(laptop.getDescription());
```

### 추상 팩토리 패턴
```js
// UI 컴포넌트 팩토리
class UIComponentFactory {
    static createButton(type) {
        switch (type) {
            case 'primary':
                return new PrimaryButton();
            case 'secondary':
                return new SecondaryButton();
            case 'danger':
                return new DangerButton();
            default:
                throw new Error(`알 수 없는 버튼 타입: ${type}`);
        }
    }
    
    static createInput(type) {
        switch (type) {
            case 'text':
                return new TextInput();
            case 'email':
                return new EmailInput();
            case 'password':
                return new PasswordInput();
            default:
                throw new Error(`알 수 없는 입력 타입: ${type}`);
        }
    }
}

class PrimaryButton {
    render(text) {
        return `<button class="btn btn-primary">${text}</button>`;
    }
}

class TextInput {
    render(placeholder) {
        return `<input type="text" placeholder="${placeholder}" class="form-control">`;
    }
}

// 사용 예시
const button = UIComponentFactory.createButton('primary');
const input = UIComponentFactory.createInput('email');

document.body.innerHTML = `
    ${input.render('이메일을 입력하세요')}
    ${button.render('전송')}
`;
```

### 실무 활용 사례 - HTTP 클라이언트 팩토리
```js
class HttpClientFactory {
    static createClient(type, config = {}) {
        const baseConfig = {
            timeout: 5000,
            headers: {
                'Content-Type': 'application/json'
            }
        };
        
        const mergedConfig = { ...baseConfig, ...config };
        
        switch (type) {
            case 'fetch':
                return new FetchClient(mergedConfig);
            case 'axios':
                return new AxiosClient(mergedConfig);
            case 'xhr':
                return new XHRClient(mergedConfig);
            default:
                throw new Error(`지원하지 않는 HTTP 클라이언트: ${type}`);
        }
    }
}

class FetchClient {
    constructor(config) {
        this.config = config;
    }
    
    async get(url) {
        const response = await fetch(url, {
            method: 'GET',
            headers: this.config.headers,
            signal: AbortSignal.timeout(this.config.timeout)
        });
        return response.json();
    }
    
    async post(url, data) {
        const response = await fetch(url, {
            method: 'POST',
            headers: this.config.headers,
            body: JSON.stringify(data),
            signal: AbortSignal.timeout(this.config.timeout)
        });
        return response.json();
    }
}

// 사용 예시
const apiClient = HttpClientFactory.createClient('fetch', {
    timeout: 10000,
    headers: {
        'Authorization': 'Bearer token123'
    }
});

// API 호출
apiClient.get('/api/users')
    .then(users => console.log(users))
    .catch(error => console.error(error));
```

## 3. 옵저버 패턴 (Observer Pattern)

### 개념
객체의 상태 변화를 관찰하는 관찰자들을 등록하고, 상태가 변화할 때마다 관찰자들에게 알림을 보내는 패턴이다.

### 기본 구현
```js
class EventEmitter {
    constructor() {
        this.events = {};
    }
    
    on(event, callback) {
        if (!this.events[event]) {
            this.events[event] = [];
        }
        this.events[event].push(callback);
    }
    
    off(event, callback) {
        if (!this.events[event]) return;
        
        this.events[event] = this.events[event].filter(cb => cb !== callback);
    }
    
    emit(event, data) {
        if (!this.events[event]) return;
        
        this.events[event].forEach(callback => {
            callback(data);
        });
    }
    
    once(event, callback) {
        const onceCallback = (data) => {
            callback(data);
            this.off(event, onceCallback);
        };
        this.on(event, onceCallback);
    }
}

// 사용 예시
const eventEmitter = new EventEmitter();

// 이벤트 리스너 등록
eventEmitter.on('userLogin', (user) => {
    console.log(`사용자 로그인: ${user.name}`);
});

eventEmitter.on('userLogin', (user) => {
    console.log(`로그인 시간 기록: ${new Date()}`);
});

// 이벤트 발생
eventEmitter.emit('userLogin', { name: '김철수', id: 1 });
```

### 실무 활용 사례 - 상태 관리 시스템
```js
class StateManager {
    constructor(initialState = {}) {
        this.state = initialState;
        this.subscribers = [];
    }
    
    getState() {
        return { ...this.state };
    }
    
    setState(newState) {
        const prevState = { ...this.state };
        this.state = { ...this.state, ...newState };
        
        this.notifySubscribers(this.state, prevState);
    }
    
    subscribe(callback) {
        this.subscribers.push(callback);
        
        // 구독 해제 함수 반환
        return () => {
            this.subscribers = this.subscribers.filter(sub => sub !== callback);
        };
    }
    
    notifySubscribers(newState, prevState) {
        this.subscribers.forEach(callback => {
            callback(newState, prevState);
        });
    }
}

// 사용 예시
const store = new StateManager({
    user: null,
    cart: [],
    isLoading: false
});

// 상태 변화 구독
const unsubscribeUser = store.subscribe((newState, prevState) => {
    if (newState.user !== prevState.user) {
        console.log('사용자 상태 변화:', newState.user);
        updateUserUI(newState.user);
    }
});

const unsubscribeCart = store.subscribe((newState, prevState) => {
    if (newState.cart.length !== prevState.cart.length) {
        console.log('장바구니 변화:', newState.cart);
        updateCartUI(newState.cart);
    }
});

// 상태 변경
store.setState({ user: { name: '이영희', id: 2 } });
store.setState({ cart: [{ id: 1, name: '상품1', price: 10000 }] });

// 구독 해제
unsubscribeUser();
```

## 4. MVC 패턴 (Model-View-Controller)

### 개념
애플리케이션을 Model(데이터), View(화면), Controller(로직)로 분리하여 개발하는 패턴이다.

### 기본 구현
```js
// Model
class UserModel {
    constructor() {
        this.users = [
            { id: 1, name: '김철수', email: 'kim@example.com' },
            { id: 2, name: '이영희', email: 'lee@example.com' }
        ];
    }
    
    getUsers() {
        return [...this.users];
    }
    
    getUserById(id) {
        return this.users.find(user => user.id === id);
    }
    
    addUser(user) {
        const newUser = { ...user, id: this.users.length + 1 };
        this.users.push(newUser);
        return newUser;
    }
    
    updateUser(id, updates) {
        const userIndex = this.users.findIndex(user => user.id === id);
        if (userIndex !== -1) {
            this.users[userIndex] = { ...this.users[userIndex], ...updates };
            return this.users[userIndex];
        }
        return null;
    }
    
    deleteUser(id) {
        const userIndex = this.users.findIndex(user => user.id === id);
        if (userIndex !== -1) {
            return this.users.splice(userIndex, 1)[0];
        }
        return null;
    }
}

// View
class UserView {
    constructor() {
        this.container = document.getElementById('user-list');
    }
    
    render(users) {
        this.container.innerHTML = users.map(user => `
            <div class="user-card" data-id="${user.id}">
                <h3>${user.name}</h3>
                <p>${user.email}</p>
                <button onclick="userController.editUser(${user.id})">수정</button>
                <button onclick="userController.deleteUser(${user.id})">삭제</button>
            </div>
        `).join('');
    }
    
    showForm(user = null) {
        const form = document.getElementById('user-form');
        form.style.display = 'block';
        
        if (user) {
            document.getElementById('user-name').value = user.name;
            document.getElementById('user-email').value = user.email;
            form.dataset.userId = user.id;
        } else {
            form.reset();
            delete form.dataset.userId;
        }
    }
    
    hideForm() {
        const form = document.getElementById('user-form');
        form.style.display = 'none';
        form.reset();
        delete form.dataset.userId;
    }
}

// Controller
class UserController {
    constructor(model, view) {
        this.model = model;
        this.view = view;
        this.init();
    }
    
    init() {
        this.loadUsers();
        this.bindEvents();
    }
    
    bindEvents() {
        document.getElementById('add-user-btn').addEventListener('click', () => {
            this.showAddForm();
        });
        
        document.getElementById('user-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveUser();
        });
        
        document.getElementById('cancel-btn').addEventListener('click', () => {
            this.view.hideForm();
        });
    }
    
    loadUsers() {
        const users = this.model.getUsers();
        this.view.render(users);
    }
    
    showAddForm() {
        this.view.showForm();
    }
    
    editUser(id) {
        const user = this.model.getUserById(id);
        if (user) {
            this.view.showForm(user);
        }
    }
    
    deleteUser(id) {
        if (confirm('정말 삭제하시겠습니까?')) {
            this.model.deleteUser(id);
            this.loadUsers();
        }
    }
    
    saveUser() {
        const name = document.getElementById('user-name').value;
        const email = document.getElementById('user-email').value;
        const form = document.getElementById('user-form');
        const userId = form.dataset.userId;
        
        if (userId) {
            // 수정
            this.model.updateUser(parseInt(userId), { name, email });
        } else {
            // 추가
            this.model.addUser({ name, email });
        }
        
        this.view.hideForm();
        this.loadUsers();
    }
}

// 애플리케이션 초기화
const userModel = new UserModel();
const userView = new UserView();
const userController = new UserController(userModel, userView);
```

## 5. 모듈 패턴 (Module Pattern)

### 개념
코드를 독립적인 모듈로 분리하여 네임스페이스 오염을 방지하고 재사용성을 높이는 패턴이다.

### 기본 구현
```js
// 네임스페이스 모듈
const MyApp = (function() {
    // private 변수
    let config = {
        apiUrl: 'https://api.example.com',
        timeout: 5000
    };
    
    // private 함수
    function validateData(data) {
        return data && typeof data === 'object';
    }
    
    function makeRequest(url, options = {}) {
        return fetch(url, {
            timeout: config.timeout,
            ...options
        });
    }
    
    // public API
    return {
        // public 변수
        version: '1.0.0',
        
        // public 함수
        init: function(appConfig) {
            config = { ...config, ...appConfig };
        },
        
        getUsers: async function() {
            try {
                const response = await makeRequest(`${config.apiUrl}/users`);
                const data = await response.json();
                
                if (validateData(data)) {
                    return data;
                }
                throw new Error('유효하지 않은 데이터');
            } catch (error) {
                console.error('사용자 데이터 조회 실패:', error);
                throw error;
            }
        },
        
        createUser: async function(userData) {
            if (!validateData(userData)) {
                throw new Error('유효하지 않은 사용자 데이터');
            }
            
            try {
                const response = await makeRequest(`${config.apiUrl}/users`, {
                    method: 'POST',
                    body: JSON.stringify(userData),
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
                return await response.json();
            } catch (error) {
                console.error('사용자 생성 실패:', error);
                throw error;
            }
        }
    };
})();

// 사용 예시
MyApp.init({ timeout: 10000 });

MyApp.getUsers()
    .then(users => console.log(users))
    .catch(error => console.error(error));
```

### ES6 모듈 패턴
```js
// utils.js - 유틸리티 모듈
export const formatDate = (date) => {
    return new Intl.DateTimeFormat('ko-KR').format(date);
};

export const formatCurrency = (amount) => {
    return new Intl.NumberFormat('ko-KR', {
        style: 'currency',
        currency: 'KRW'
    }).format(amount);
};

export const debounce = (func, wait) => {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
};

// api.js - API 모듈
import { debounce } from './utils.js';

class ApiService {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
        this.cache = new Map();
    }
    
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const cacheKey = `${url}-${JSON.stringify(options)}`;
        
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }
        
        try {
            const response = await fetch(url, options);
            const data = await response.json();
            
            this.cache.set(cacheKey, data);
            return data;
        } catch (error) {
            console.error('API 요청 실패:', error);
            throw error;
        }
    }
    
    get(endpoint) {
        return this.request(endpoint);
    }
    
    post(endpoint, data) {
        return this.request(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
    }
}

export const apiService = new ApiService('https://api.example.com');
```

## 6. 데코레이터 패턴 (Decorator Pattern)

### 개념
객체에 새로운 기능을 동적으로 추가하는 패턴이다. 상속 없이 기능을 확장할 수 있다.

### 기본 구현
```js
// 기본 컴포넌트
class Coffee {
    getDescription() {
        return '기본 커피';
    }
    
    getCost() {
        return 1000;
    }
}

// 데코레이터 추상 클래스
class CoffeeDecorator {
    constructor(coffee) {
        this.coffee = coffee;
    }
    
    getDescription() {
        return this.coffee.getDescription();
    }
    
    getCost() {
        return this.coffee.getCost();
    }
}

// 구체적인 데코레이터들
class MilkDecorator extends CoffeeDecorator {
    getDescription() {
        return this.coffee.getDescription() + ', 우유 추가';
    }
    
    getCost() {
        return this.coffee.getCost() + 500;
    }
}

class SugarDecorator extends CoffeeDecorator {
    getDescription() {
        return this.coffee.getDescription() + ', 설탕 추가';
    }
    
    getCost() {
        return this.coffee.getCost() + 200;
    }
}

class VanillaDecorator extends CoffeeDecorator {
    getDescription() {
        return this.coffee.getDescription() + ', 바닐라 시럽';
    }
    
    getCost() {
        return this.coffee.getCost() + 300;
    }
}

// 사용 예시
let coffee = new Coffee();
console.log(`${coffee.getDescription()} - ${coffee.getCost()}원`);

coffee = new MilkDecorator(coffee);
console.log(`${coffee.getDescription()} - ${coffee.getCost()}원`);

coffee = new SugarDecorator(coffee);
console.log(`${coffee.getDescription()} - ${coffee.getCost()}원`);

coffee = new VanillaDecorator(coffee);
console.log(`${coffee.getDescription()} - ${coffee.getCost()}원`);
```

### 실무 활용 사례 - 함수 데코레이터
```js
// 함수 데코레이터들
function withLogging(fn) {
    return function(...args) {
        console.log(`함수 호출: ${fn.name}`, args);
        const result = fn.apply(this, args);
        console.log(`함수 결과: ${fn.name}`, result);
        return result;
    };
}

function withTiming(fn) {
    return function(...args) {
        const start = performance.now();
        const result = fn.apply(this, args);
        const end = performance.now();
        console.log(`${fn.name} 실행 시간: ${end - start}ms`);
        return result;
    };
}

function withRetry(fn, maxRetries = 3) {
    return async function(...args) {
        let lastError;
        
        for (let i = 0; i < maxRetries; i++) {
            try {
                return await fn.apply(this, args);
            } catch (error) {
                lastError = error;
                console.log(`${fn.name} 재시도 ${i + 1}/${maxRetries}:`, error.message);
                
                if (i < maxRetries - 1) {
                    await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
                }
            }
        }
        
        throw lastError;
    };
}

// 사용 예시
const apiCall = async (url) => {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
    }
    return response.json();
};

// 데코레이터 적용
const enhancedApiCall = withLogging(withTiming(withRetry(apiCall)));

// 사용
enhancedApiCall('https://api.example.com/data')
    .then(data => console.log('성공:', data))
    .catch(error => console.error('실패:', error));
```

## 7. 전략 패턴 (Strategy Pattern)

### 개념
알고리즘을 클래스로 캡슐화하여 런타임에 알고리즘을 선택할 수 있게 하는 패턴이다.

### 기본 구현
```js
// 정렬 전략들
class SortStrategy {
    sort(data) {
        throw new Error('정렬 전략을 구현해야 합니다.');
    }
}

class BubbleSortStrategy extends SortStrategy {
    sort(data) {
        const arr = [...data];
        const n = arr.length;
        
        for (let i = 0; i < n - 1; i++) {
            for (let j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]];
                }
            }
        }
        
        return arr;
    }
}

class QuickSortStrategy extends SortStrategy {
    sort(data) {
        if (data.length <= 1) return [...data];
        
        const pivot = data[Math.floor(data.length / 2)];
        const left = data.filter(x => x < pivot);
        const middle = data.filter(x => x === pivot);
        const right = data.filter(x => x > pivot);
        
        return [...this.sort(left), ...middle, ...this.sort(right)];
    }
}

class MergeSortStrategy extends SortStrategy {
    sort(data) {
        if (data.length <= 1) return [...data];
        
        const mid = Math.floor(data.length / 2);
        const left = this.sort(data.slice(0, mid));
        const right = this.sort(data.slice(mid));
        
        return this.merge(left, right);
    }
    
    merge(left, right) {
        const result = [];
        let i = 0, j = 0;
        
        while (i < left.length && j < right.length) {
            if (left[i] <= right[j]) {
                result.push(left[i++]);
            } else {
                result.push(right[j++]);
            }
        }
        
        return result.concat(left.slice(i), right.slice(j));
    }
}

// 컨텍스트 클래스
class Sorter {
    constructor(strategy) {
        this.strategy = strategy;
    }
    
    setStrategy(strategy) {
        this.strategy = strategy;
    }
    
    sort(data) {
        return this.strategy.sort(data);
    }
}

// 사용 예시
const data = [64, 34, 25, 12, 22, 11, 90];
const sorter = new Sorter(new BubbleSortStrategy());

console.log('버블 정렬:', sorter.sort(data));

sorter.setStrategy(new QuickSortStrategy());
console.log('퀵 정렬:', sorter.sort(data));

sorter.setStrategy(new MergeSortStrategy());
console.log('머지 정렬:', sorter.sort(data));
```

### 실무 활용 사례 - 결제 전략
```js
// 결제 전략들
class PaymentStrategy {
    pay(amount) {
        throw new Error('결제 전략을 구현해야 합니다.');
    }
}

class CreditCardStrategy extends PaymentStrategy {
    constructor(cardNumber, cvv, expiryDate) {
        super();
        this.cardNumber = cardNumber;
        this.cvv = cvv;
        this.expiryDate = expiryDate;
    }
    
    pay(amount) {
        console.log(`${amount}원을 신용카드로 결제합니다.`);
        console.log(`카드번호: ****-****-****-${this.cardNumber.slice(-4)}`);
        
        // 실제 결제 로직
        return this.processCreditCardPayment(amount);
    }
    
    processCreditCardPayment(amount) {
        // 신용카드 결제 처리 로직
        return {
            success: true,
            transactionId: `CC_${Date.now()}`,
            amount: amount,
            method: 'credit_card'
        };
    }
}

class PayPalStrategy extends PaymentStrategy {
    constructor(email) {
        super();
        this.email = email;
    }
    
    pay(amount) {
        console.log(`${amount}원을 PayPal로 결제합니다.`);
        console.log(`PayPal 계정: ${this.email}`);
        
        // 실제 결제 로직
        return this.processPayPalPayment(amount);
    }
    
    processPayPalPayment(amount) {
        // PayPal 결제 처리 로직
        return {
            success: true,
            transactionId: `PP_${Date.now()}`,
            amount: amount,
            method: 'paypal'
        };
    }
}

class BankTransferStrategy extends PaymentStrategy {
    constructor(accountNumber, bankName) {
        super();
        this.accountNumber = accountNumber;
        this.bankName = bankName;
    }
    
    pay(amount) {
        console.log(`${amount}원을 은행 계좌로 결제합니다.`);
        console.log(`은행: ${this.bankName}, 계좌번호: ${this.accountNumber}`);
        
        // 실제 결제 로직
        return this.processBankTransfer(amount);
    }
    
    processBankTransfer(amount) {
        // 은행 계좌 결제 처리 로직
        return {
            success: true,
            transactionId: `BT_${Date.now()}`,
            amount: amount,
            method: 'bank_transfer'
        };
    }
}

// 결제 컨텍스트
class PaymentProcessor {
    constructor() {
        this.strategy = null;
    }
    
    setPaymentMethod(strategy) {
        this.strategy = strategy;
    }
    
    processPayment(amount) {
        if (!this.strategy) {
            throw new Error('결제 방법을 선택해주세요.');
        }
        
        return this.strategy.pay(amount);
    }
}

// 사용 예시
const paymentProcessor = new PaymentProcessor();

// 신용카드 결제
const creditCard = new CreditCardStrategy('1234567890123456', '123', '12/25');
paymentProcessor.setPaymentMethod(creditCard);
const result1 = paymentProcessor.processPayment(50000);

// PayPal 결제
const paypal = new PayPalStrategy('user@example.com');
paymentProcessor.setPaymentMethod(paypal);
const result2 = paymentProcessor.processPayment(30000);
```

## 8. 패턴 선택 가이드

### 상황별 패턴 추천

**상태 관리가 필요한 경우**
- 싱글톤 패턴 (전역 상태)
- 옵저버 패턴 (상태 변화 알림)

**객체 생성이 복잡한 경우**
- 팩토리 패턴
- 빌더 패턴

**코드 구조화가 필요한 경우**
- MVC 패턴
- 모듈 패턴

**기능 확장이 필요한 경우**
- 데코레이터 패턴
- 전략 패턴

### 패턴 조합 예시
```js
// 싱글톤 + 팩토리 + 옵저버 패턴 조합
class NotificationManager {
    constructor() {
        if (NotificationManager.instance) {
            return NotificationManager.instance;
        }
        
        this.subscribers = [];
        this.notifications = [];
        NotificationManager.instance = this;
    }
    
    // 팩토리 메서드
    createNotification(type, message, options = {}) {
        switch (type) {
            case 'success':
                return new SuccessNotification(message, options);
            case 'error':
                return new ErrorNotification(message, options);
            case 'warning':
                return new WarningNotification(message, options);
            default:
                return new InfoNotification(message, options);
        }
    }
    
    // 옵저버 패턴
    subscribe(callback) {
        this.subscribers.push(callback);
        return () => {
            this.subscribers = this.subscribers.filter(sub => sub !== callback);
        };
    }
    
    notify(notification) {
        this.notifications.push(notification);
        this.subscribers.forEach(callback => callback(notification));
    }
    
    show(type, message, options = {}) {
        const notification = this.createNotification(type, message, options);
        this.notify(notification);
        return notification;
    }
}

// 사용 예시
const notificationManager = new NotificationManager();

notificationManager.subscribe((notification) => {
    console.log('새 알림:', notification);
    // UI 업데이트 로직
});

notificationManager.show('success', '저장되었습니다!');
notificationManager.show('error', '오류가 발생했습니다.');
```

## 마무리

디자인 패턴은 코드의 품질을 크게 향상시킬 수 있는 강력한 도구들이다. 하지만 모든 상황에 모든 패턴을 적용하려고 하면 오히려 복잡성만 증가할 수 있다.

**패턴 사용 시 주의사항:**
1. **문제가 있을 때만 사용**: 패턴을 위한 패턴은 피하기
2. **단순함 우선**: 복잡한 패턴보다는 단순한 해결책이 나을 수 있음
3. **팀 컨벤션**: 팀 내에서 일관된 패턴 사용
4. **점진적 적용**: 한 번에 모든 패턴을 적용하지 말고 필요에 따라 점진적으로 적용
