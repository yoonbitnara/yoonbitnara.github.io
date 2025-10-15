---
title: "Docker Compose"
excerpt: "로컬 개발 환경 구축부터 활용까지, Docker Compose 가이드"

categories:
  - DevOps
tags:
  - [Docker, Docker Compose, DevOps, 개발환경, 컨테이너]

toc: true
toc_sticky: true

date: 2025-10-15
last_modified_at: 2025-10-15
---

# Docker Compose

팀에 새로운 개발자가 합류한다고 생각해보자.

개발 환경을 세팅하려면 어떻게 해야 할까? MySQL 설치하고, Redis 설치하고, 환경 변수 설정하고... 중간에 버전이 안 맞아서 에러가 나면 처음부터 다시 해야 한다. 반나절은 기본이다.

"더 쉬운 방법이 없을까?"

Docker Compose를 사용하면 달라진다. `docker-compose up` 명령어 하나면 끝이다. 몇 분 안에 전체 개발 환경이 구축된다.

## Docker와 Docker Compose의 차이

### Docker만 쓸 때의 문제

Docker는 컨테이너를 만들어주지만, 여러 컨테이너를 관리하려면 복잡해진다.

```bash
# MySQL 컨테이너 실행
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -e MYSQL_DATABASE=myapp \
  -p 3306:3306 \
  mysql:8.0

# Redis 컨테이너 실행
docker run -d \
  --name redis \
  -p 6379:6379 \
  redis:7.0

# 애플리케이션 컨테이너 실행
docker run -d \
  --name app \
  --link mysql:mysql \
  --link redis:redis \
  -p 8080:8080 \
  myapp:latest
```

이렇게 하나씩 명령어를 치면 실수하기 쉽다. 포트 번호를 틀리거나, 환경 변수를 빠뜨리거나, 컨테이너 연결을 잘못하면 작동하지 않는다.

### Docker Compose의 등장

Docker Compose는 여러 컨테이너를 하나의 파일로 정의하고 관리한다.

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: myapp
    ports:
      - "3306:3306"

  redis:
    image: redis:7.0
    ports:
      - "6379:6379"

  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - mysql
      - redis
```

이제 `docker-compose up` 명령어 하나로 모든 컨테이너가 실행된다.

## 기본 사용법

### 설치

Docker Desktop을 설치하면 Docker Compose도 함께 설치된다.

```bash
# 설치 확인
docker-compose --version
```

### 프로젝트 구조

```
my-project/
├── docker-compose.yml
├── Dockerfile
├── src/
│   └── main/
│       └── java/
└── application.yml
```

### 첫 번째 docker-compose.yml

가장 간단한 예제부터 시작한다.

```yaml
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
```

이제 실행한다.

```bash
# 컨테이너 시작
docker-compose up

# 백그라운드로 실행
docker-compose up -d

# 컨테이너 중지
docker-compose down

# 로그 확인
docker-compose logs

# 특정 서비스 로그
docker-compose logs web
```

## Spring Boot + MySQL + Redis

자주 사용하는 구성이다.

### 디렉토리 구조

```
my-app/
├── docker-compose.yml
├── Dockerfile
├── src/
│   └── main/
│       ├── java/
│       └── resources/
│           └── application.yml
└── init.sql
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  # MySQL 데이터베이스
  mysql:
    image: mysql:8.0
    container_name: myapp-mysql
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: myapp
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppass
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis 캐시
  redis:
    image: redis:7.0-alpine
    container_name: myapp-redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # Spring Boot 애플리케이션
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: myapp-server
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/myapp
      SPRING_DATASOURCE_USERNAME: appuser
      SPRING_DATASOURCE_PASSWORD: apppass
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PORT: 6379
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: on-failure

volumes:
  mysql-data:
  redis-data:
```

### Dockerfile

```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### init.sql

```sql
-- 초기 데이터 설정
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (email, name) VALUES 
    ('admin@example.com', 'Admin'),
    ('user@example.com', 'User');
```

### application.yml

```yaml
spring:
  datasource:
    url: ${SPRING_DATASOURCE_URL}
    username: ${SPRING_DATASOURCE_USERNAME}
    password: ${SPRING_DATASOURCE_PASSWORD}
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  
  redis:
    host: ${SPRING_REDIS_HOST}
    port: ${SPRING_REDIS_PORT}
```

## 환경별 설정

### 개발 환경과 운영 환경 분리

환경별로 다른 설정이 필요한 경우가 많다.

**docker-compose.yml** (기본)

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: myapp
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql

  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - mysql

volumes:
  mysql-data:
```

**docker-compose.dev.yml** (개발 환경)

```yaml
version: '3.8'

services:
  app:
    environment:
      SPRING_PROFILES_ACTIVE: dev
      DEBUG: "true"
    volumes:
      - ./src:/app/src  # 핫 리로드
```

**docker-compose.prod.yml** (운영 환경)

```yaml
version: '3.8'

services:
  mysql:
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}  # 환경 변수로 관리
  
  app:
    restart: always
    environment:
      SPRING_PROFILES_ACTIVE: prod
```

### 실행 방법

```bash
# 개발 환경
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# 운영 환경
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# .env 파일 사용
docker-compose --env-file .env.prod up -d
```

## 네트워크 설정

### 컨테이너 간 통신

Docker Compose는 자동으로 네트워크를 생성한다.

```yaml
version: '3.8'

services:
  backend:
    image: myapp-backend
    networks:
      - app-network
  
  frontend:
    image: myapp-frontend
    networks:
      - app-network
  
  database:
    image: postgres:14
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### 외부 네트워크 연결

```yaml
version: '3.8'

services:
  app:
    image: myapp
    networks:
      - default
      - external-network

networks:
  external-network:
    external: true
```

## 볼륨 관리

### 데이터 영속성

컨테이너가 삭제되어도 데이터는 유지되어야 한다.

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14
    volumes:
      # Named volume (권장)
      - postgres-data:/var/lib/postgresql/data
      
      # Bind mount (개발용)
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
      
      # 설정 파일 마운트
      - ./postgres.conf:/etc/postgresql/postgresql.conf

volumes:
  postgres-data:
    driver: local
```

### 볼륨 백업

```bash
# 볼륨 목록 확인
docker volume ls

# 볼륨 백업
docker run --rm \
  -v myapp_mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mysql-backup.tar.gz /data

# 볼륨 복원
docker run --rm \
  -v myapp_mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/mysql-backup.tar.gz -C /
```

## 환경 변수 관리

### .env 파일 사용

민감한 정보는 .env 파일로 분리한다.

**.env**

```env
MYSQL_ROOT_PASSWORD=root123
MYSQL_DATABASE=myapp
MYSQL_USER=appuser
MYSQL_PASSWORD=apppass

REDIS_PASSWORD=redis123

APP_PORT=8080
APP_ENV=development
```

**docker-compose.yml**

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}

  app:
    build: .
    ports:
      - "${APP_PORT}:8080"
    environment:
      APP_ENV: ${APP_ENV}
```

### .gitignore 설정

```gitignore
.env
.env.local
.env.prod
docker-compose.override.yml
```

## 전체 스택 구성

전체 스택을 구성하는 예제다.

```yaml
version: '3.8'

services:
  # Nginx 리버스 프록시
  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - backend
    networks:
      - app-network

  # Spring Boot 백엔드
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: myapp-backend
    environment:
      SPRING_PROFILES_ACTIVE: dev
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/myapp
      SPRING_DATASOURCE_USERNAME: ${DB_USER}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD}
      SPRING_REDIS_HOST: redis
      SPRING_REDIS_PORT: 6379
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    restart: unless-stopped

  # React 프론트엔드
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: myapp-frontend
    environment:
      REACT_APP_API_URL: http://localhost:8080
    depends_on:
      - backend
    networks:
      - app-network

  # MySQL 데이터베이스
  mysql:
    image: mysql:8.0
    container_name: myapp-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      TZ: Asia/Seoul
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d
      - ./mysql/conf.d:/etc/mysql/conf.d
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
      - --default-authentication-plugin=mysql_native_password
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${DB_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # Redis 캐시
  redis:
    image: redis:7.0-alpine
    container_name: myapp-redis
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql-data:
  redis-data:
```

## 개발 환경 구축 예제

### Node.js + MongoDB + Redis

```yaml
version: '3.8'

services:
  # Node.js 백엔드
  api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: nodejs-api
    volumes:
      - ./src:/app/src
      - ./node_modules:/app/node_modules
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: development
      MONGODB_URI: mongodb://mongodb:27017/myapp
      REDIS_URL: redis://redis:6379
    depends_on:
      - mongodb
      - redis
    command: npm run dev

  # MongoDB
  mongodb:
    image: mongo:6.0
    container_name: nodejs-mongodb
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin123
      MONGO_INITDB_DATABASE: myapp
    volumes:
      - mongodb-data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js

  # Redis
  redis:
    image: redis:7.0-alpine
    container_name: nodejs-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  mongodb-data:
  redis-data:
```

### Python + PostgreSQL

```yaml
version: '3.8'

services:
  # Python 애플리케이션
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: python-app
    volumes:
      - ./app:/app
    ports:
      - "5000:5000"
    environment:
      DATABASE_URL: postgresql://postgres:postgres123@postgres:5432/myapp
      FLASK_ENV: development
    depends_on:
      postgres:
        condition: service_healthy
    command: flask run --host=0.0.0.0

  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: python-postgres
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres-data:
```

## 유용한 명령어

### 기본 명령어

```bash
# 컨테이너 시작
docker-compose up

# 백그라운드 실행
docker-compose up -d

# 특정 서비스만 실행
docker-compose up mysql redis

# 재빌드 후 실행
docker-compose up --build

# 컨테이너 중지
docker-compose stop

# 컨테이너 삭제
docker-compose down

# 볼륨까지 삭제
docker-compose down -v

# 이미지까지 삭제
docker-compose down --rmi all
```

### 서비스 관리

```bash
# 실행 중인 컨테이너 확인
docker-compose ps

# 로그 확인 (전체)
docker-compose logs

# 로그 확인 (특정 서비스)
docker-compose logs app

# 실시간 로그 확인
docker-compose logs -f

# 로그 마지막 100줄
docker-compose logs --tail=100

# 서비스 재시작
docker-compose restart app

# 서비스 중지
docker-compose stop app

# 서비스 시작
docker-compose start app
```

### 컨테이너 내부 접근

```bash
# 컨테이너 쉘 접속
docker-compose exec app sh
docker-compose exec mysql bash

# 명령어 실행
docker-compose exec app ls -la
docker-compose exec mysql mysql -uroot -p

# 파일 복사
docker-compose cp app:/app/logs/app.log ./local-logs/
```

## 개발 환경에서 사용하기

### 핫 리로드 설정

개발 중 코드 변경 시 자동으로 반영되게 한다.

**Node.js**

```yaml
services:
  api:
    build: .
    volumes:
      - ./src:/app/src
      - /app/node_modules  # node_modules는 컨테이너 것 사용
    command: npm run dev  # nodemon 사용
```

**Spring Boot**

```yaml
services:
  app:
    build: .
    volumes:
      - ./src:/app/src
    environment:
      SPRING_DEVTOOLS_RESTART_ENABLED: "true"
```

### 로그 관리

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 리소스 제한

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### 헬스체크

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 트러블슈팅

### 컨테이너가 계속 재시작될 때

**원인 파악**

```bash
# 로그 확인
docker-compose logs app

# 컨테이너 상태 확인
docker-compose ps

# 이벤트 확인
docker events
```

**해결 방법**

```yaml
services:
  app:
    # 재시작 정책 변경
    restart: "no"  # 디버깅용
    
    # 또는
    restart: on-failure
    
    # depends_on 조건 추가
    depends_on:
      mysql:
        condition: service_healthy
```

### 포트 충돌

**확인**

```bash
# 포트 사용 확인 (Windows)
netstat -ano | findstr :3306

# 포트 사용 확인 (Linux/Mac)
lsof -i :3306
```

**해결**

```yaml
services:
  mysql:
    ports:
      - "3307:3306"  # 다른 포트로 변경
```

### 볼륨 권한 문제

```yaml
services:
  app:
    user: "${UID}:${GID}"  # 현재 사용자 권한 사용
    volumes:
      - ./data:/app/data
```

```bash
# 환경 변수 설정
export UID=$(id -u)
export GID=$(id -g)

docker-compose up
```

### 네트워크 연결 실패

**확인**

```bash
# 네트워크 확인
docker network ls

# 네트워크 상세 정보
docker network inspect myapp_app-network

# 컨테이너 IP 확인
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' myapp-mysql
```

**해결**

```yaml
services:
  app:
    networks:
      app-network:
        aliases:
          - backend
```

## 성능 최적화

### 빌드 최적화

**멀티 스테이지 빌드**

```dockerfile
# 빌드 스테이지
FROM gradle:7.6-jdk17 AS builder
WORKDIR /app
COPY . .
RUN gradle build -x test

# 실행 스테이지
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**빌드 캐시 활용**

```yaml
services:
  app:
    build:
      context: .
      cache_from:
        - myapp:latest
```

### 이미지 크기 줄이기

```dockerfile
# Alpine 이미지 사용
FROM node:18-alpine

# 불필요한 파일 제거
RUN apk add --no-cache \
    && rm -rf /var/cache/apk/*

# .dockerignore 활용
```

**.dockerignore**

```
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.*
```

## 활용 예시

### 마이크로서비스 구성

```yaml
version: '3.8'

services:
  # API Gateway
  gateway:
    build: ./gateway
    ports:
      - "80:8000"
    depends_on:
      - user-service
      - order-service
    networks:
      - app-network

  # User Service
  user-service:
    build: ./user-service
    environment:
      DATABASE_URL: postgresql://postgres:5432/users
    depends_on:
      - postgres
    networks:
      - app-network

  # Order Service
  order-service:
    build: ./order-service
    environment:
      DATABASE_URL: postgresql://postgres:5432/orders
    depends_on:
      - postgres
      - rabbitmq
    networks:
      - app-network

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"
    networks:
      - app-network

  # PostgreSQL
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres123
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

networks:
  app-network:

volumes:
  postgres-data:
```

### 모니터링 스택 구성

```yaml
version: '3.8'

services:
  # 애플리케이션
  app:
    build: .
    ports:
      - "8080:8080"
    networks:
      - monitoring

  # Prometheus (메트릭 수집)
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    networks:
      - monitoring

  # Grafana (시각화)
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin123
    volumes:
      - grafana-data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - monitoring

  # Node Exporter (시스템 메트릭)
  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
    networks:
      - monitoring

networks:
  monitoring:

volumes:
  prometheus-data:
  grafana-data:
```

## 개발 워크플로우

### 일반적인 작업 흐름

```bash
# 1. 프로젝트 클론
git clone https://github.com/myteam/myapp.git
cd myapp

# 2. 환경 변수 설정
cp .env.example .env
# .env 파일 수정

# 3. 컨테이너 시작
docker-compose up -d

# 4. 로그 확인
docker-compose logs -f

# 5. 데이터베이스 마이그레이션
docker-compose exec app npm run migrate

# 6. 개발 시작
# 코드 수정...

# 7. 컨테이너 재시작 (필요시)
docker-compose restart app

# 8. 작업 종료
docker-compose down
```

### CI/CD 통합

**.gitlab-ci.yml**

```yaml
test:
  stage: test
  script:
    - docker-compose -f docker-compose.test.yml up -d
    - docker-compose exec -T app npm test
    - docker-compose down -v
```

**GitHub Actions**

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          docker-compose -f docker-compose.test.yml up -d
          docker-compose exec -T app npm test
          docker-compose down -v
```

## 주의할 점

### 1. 서비스 이름은 명확하게

```yaml
# 나쁜 예
services:
  db:
  cache:
  app:

# 좋은 예
services:
  mysql:
  redis:
  backend:
```

### 2. 버전 명시

```yaml
# 나쁜 예
services:
  mysql:
    image: mysql:latest

# 좋은 예
services:
  mysql:
    image: mysql:8.0.34
```

### 3. 헬스체크 활용

```yaml
services:
  mysql:
    healthcheck:
      test: ["CMD", "mysqladmin", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  app:
    depends_on:
      mysql:
        condition: service_healthy
```

### 4. 환경별 파일 분리

```
docker-compose.yml          # 공통 설정
docker-compose.dev.yml      # 개발 환경
docker-compose.prod.yml     # 운영 환경
docker-compose.test.yml     # 테스트 환경
```

### 5. 민감 정보는 .env로

```yaml
services:
  mysql:
    environment:
      # 나쁜 예
      MYSQL_ROOT_PASSWORD: root123
      
      # 좋은 예
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

## 자주 하는 실수

### 1. depends_on의 오해

`depends_on`은 컨테이너가 시작되는 순서만 보장한다. 서비스가 준비되었는지는 보장하지 않는다.

```yaml
# 잘못된 기대
services:
  app:
    depends_on:
      - mysql  # MySQL이 준비되지 않아도 app 시작

# 올바른 사용
services:
  app:
    depends_on:
      mysql:
        condition: service_healthy  # MySQL이 준비될 때까지 대기
```

### 2. 볼륨 경로 실수

```yaml
# 잘못된 예 (상대 경로)
volumes:
  - data:/var/lib/mysql  # 'data' 디렉토리가 아니라 Named Volume

# 올바른 예
volumes:
  - ./data:/var/lib/mysql  # 현재 디렉토리의 data 폴더
```

### 3. 네트워크 설정 누락

```yaml
# 문제가 생길 수 있는 구성
services:
  app:
    # networks 설정 없음
  
  mysql:
    networks:
      - db-network

# app과 mysql이 다른 네트워크에 있어서 통신 불가
```

### 4. 포트 바인딩 혼동

```yaml
services:
  app:
    ports:
      - "8080:3000"  # 호스트:컨테이너
      # 호스트 8080 포트 → 컨테이너 3000 포트
```

## 문제 해결

### 문제 진단 순서

```bash
# 1. 컨테이너 상태 확인
docker-compose ps

# 2. 로그 확인
docker-compose logs app

# 3. 컨테이너 내부 확인
docker-compose exec app sh

# 4. 네트워크 확인
docker network inspect myapp_default

# 5. 볼륨 확인
docker volume ls
docker volume inspect myapp_mysql-data
```

### 컨테이너 내부에서 디버깅

```bash
# MySQL 접속
docker-compose exec mysql mysql -uroot -p

# Redis 접속
docker-compose exec redis redis-cli

# 파일 시스템 확인
docker-compose exec app ls -la /app

# 환경 변수 확인
docker-compose exec app env

# 프로세스 확인
docker-compose exec app ps aux

# 네트워크 연결 확인
docker-compose exec app ping mysql
```

## 마무리

Docker Compose는 개발 환경을 표준화하고 팀 협업을 쉽게 만든다.

처음에는 설정이 복잡해 보이지만, 한 번 제대로 설정해두면 모든 팀원이 동일한 환경에서 개발할 수 있다. "내 컴퓨터에서는 되는데"라는 말이 사라진다.

**Docker Compose의 장점**
- 개발 환경 구축 시간 단축 (몇 시간 → 몇 분)
- 환경 불일치 문제 해결
- 새로운 팀원 온보딩 간소화
- 로컬에서 운영 환경과 유사한 테스트 가능

**시작하는 방법**
1. 간단한 프로젝트부터 시작
2. 서비스를 하나씩 추가
3. 문제가 생기면 로그 확인
4. 팀원들과 공유하며 개선

Docker Compose는 한 번 익혀두면 계속 유용하게 쓸 수 있는 도구다.

