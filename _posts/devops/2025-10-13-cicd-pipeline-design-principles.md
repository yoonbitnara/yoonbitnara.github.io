---
title: "CI/CD 파이프라인 설계"
excerpt: "Jenkins 설치했다고 CI/CD 끝? 제대로 된 파이프라인 설계 원칙과 실전 전략을 알아보자."

categories:
  - DevOps
tags:
  - [DevOps, CI/CD, Pipeline, Automation]

toc: true
toc_sticky: true

date: 2025-10-13
last_modified_at: 2025-10-13
---

## 시작하며

CI/CD를 처음 공부하면서 가장 큰 착각을 했다. Jenkins 설치하고, GitHub 연동하고, 빌드 성공하면 끝인 줄 알았다. 그런데 여러 팀들의 사례를 찾아보니 문제가 그렇게 간단하지 않았다.

빌드는 성공하는데 배포하면 터지는 경우, 테스트는 돌아가는데 커버리지는 엉망인 경우, 파이프라인은 있는데 아무도 신뢰하지 않는 경우. 그때 알았다. CI/CD는 도구가 아니라 설계의 문제라는 걸.

개인 프로젝트에 CI/CD를 적용하면서, 그리고 여러 자료들을 찾아보면서 배운 파이프라인 설계 원칙들을 정리해보려 한다. 도구 사용법이 아니라, 어떻게 설계해야 하는지에 집중할 것이다.

## 왜 파이프라인 설계가 중요한가

### 망가진 파이프라인의 특징

여러 사례들을 보면 망가진 파이프라인에는 공통점이 있다.

**1. 느리다**

빌드 한 번에 30분씩 걸린다. 개발자들은 커피 마시러 가고, 집중력은 떨어지고, 피드백 루프는 끊긴다. 결국 아무도 파이프라인을 신뢰하지 않게 된다.

**2. 자주 실패한다**

이유도 모르게 실패한다. 같은 코드인데 어제는 성공하고 오늘은 실패한다. 네트워크 타임아웃, 디스크 풀, 의존성 충돌... 원인은 무궁무진하다. 개발자들은 "또 파이프라인 문제겠지" 하며 무시하기 시작한다.

**3. 알 수 없다**

실패했는데 뭐가 문제인지 모른다. 로그는 수천 줄이고, 에러 메시지는 불친절하고, 디버깅은 불가능하다. 결국 "로컬에선 되는데요?"로 돌아간다.

**4. 롤백이 안 된다**

배포했는데 문제가 생겼다. 근데 롤백이 어떻게 되는지 모른다. 파이프라인을 다시 돌리면 되나? 아니면 수동으로 복구해야 하나? 이 사이에 서비스는 다운되어 있다.

이런 파이프라인은 없느니만 못하다. 자동화가 아니라 자동 장애물이 되어버린다.

### 좋은 파이프라인의 조건

반대로 좋은 파이프라인은 이렇다.

**빠르다** - 5분 안에 피드백을 준다. 개발자가 다른 작업으로 넘어가기 전에 결과를 알 수 있다.

**안정적이다** - 같은 코드는 항상 같은 결과를 낸다. 랜덤 실패는 없다.

**명확하다** - 실패하면 무엇이 문제인지 5초 안에 알 수 있다. 로그를 뒤질 필요가 없다.

**자동이다** - 수동 개입이 필요 없다. 승인 단계는 있어도 괜찮지만, 수동 스크립트 실행은 안 된다.

**안전하다** - 배포해도 무섭지 않다. 롤백은 1분이면 된다.

이런 파이프라인을 만들려면 어떻게 설계해야 할까?

## 파이프라인 설계 원칙

### 1. 단계를 명확히 분리하라

파이프라인은 여러 단계로 나뉜다. 각 단계는 명확한 책임을 가져야 한다.

```yaml
# GitHub Actions 예시

name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # 1단계: 린트와 정적 분석
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run linter
        run: |
          npm run lint
          npm run type-check
    timeout-minutes: 5

  # 2단계: 단위 테스트
  unit-test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v3
      - name: Run unit tests
        run: npm run test:unit
      - name: Upload coverage
        uses: codecov/codecov-action@v3
    timeout-minutes: 10

  # 3단계: 통합 테스트
  integration-test:
    runs-on: ubuntu-latest
    needs: unit-test
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
    steps:
      - uses: actions/checkout@v3
      - name: Run integration tests
        run: npm run test:integration
    timeout-minutes: 15

  # 4단계: 빌드
  build:
    runs-on: ubuntu-latest
    needs: integration-test
    steps:
      - uses: actions/checkout@v3
      - name: Build application
        run: npm run build
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Push to registry
        run: docker push myapp:${{ github.sha }}
    timeout-minutes: 10

  # 5단계: 배포 (Production)
  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://myapp.com
    steps:
      - name: Deploy to production
        run: |
          kubectl set image deployment/myapp \
            myapp=myapp:${{ github.sha }}
          kubectl rollout status deployment/myapp
    timeout-minutes: 5
```

여기서 핵심은 **단계별 독립성**이다. 린트 실패하면 테스트는 돌지 않는다. 테스트 실패하면 빌드는 하지 않는다. 각 단계는 이전 단계가 성공했을 때만 실행된다.

왜 이렇게 할까? 피드백을 빠르게 받기 위해서다. 린트 에러는 30초면 발견된다. 굳이 10분짜리 테스트를 돌릴 필요가 없다. 빠른 피드백이 개발 속도를 높인다.

### 2. Fail Fast 원칙

문제는 최대한 빨리 발견해야 한다. 늦게 발견할수록 비용이 커진다.

**비용 피라미드**

```
배포 후 발견 (1000배 비용)
    ↑
통합 테스트 실패 (100배 비용)
    ↑
단위 테스트 실패 (10배 비용)
    ↑
린트 실패 (1배 비용)
```

린트는 30초 만에 발견하지만, 배포 후 버그는 고객이 신고하고, 디버깅하고, 핫픽스하고, 재배포하는 데 며칠이 걸린다. 비용이 천 배 차이 난다.

그래서 파이프라인 초반에 최대한 많은 문제를 걸러내야 한다.

```yaml
# 가벼운 체크를 먼저 실행
jobs:
  quick-checks:
    runs-on: ubuntu-latest
    steps:
      # 1. 포맷 체크 (5초)
      - name: Check formatting
        run: npm run format:check
      
      # 2. 린트 (30초)
      - name: Lint
        run: npm run lint
      
      # 3. 타입 체크 (1분)
      - name: Type check
        run: npm run type-check
      
      # 4. 보안 취약점 스캔 (2분)
      - name: Security audit
        run: npm audit --audit-level=high
    timeout-minutes: 5

  # 무거운 테스트는 quick-checks 통과 후에만
  heavy-tests:
    needs: quick-checks
    runs-on: ubuntu-latest
    steps:
      - name: Run all tests
        run: npm run test:all
    timeout-minutes: 15
```

5분 내에 80%의 문제를 발견할 수 있다면, 그게 최고의 전략이다.

### 3. 테스트 피라미드를 존중하라

테스트도 단계가 있다. 전통적인 테스트 피라미드를 생각해보자.

```
       E2E Tests (적고 느림)
      /            \
     /              \
    Integration Tests (중간)
   /                  \
  /                    \
 Unit Tests (많고 빠름)
```

**단위 테스트**는 많고 빨라야 한다. 수천 개가 있어도 1-2분 안에 끝나야 한다.

**통합 테스트**는 중간 정도다. 수백 개 정도, 5-10분 정도가 적당하다.

**E2E 테스트**는 적고 느리다. 핵심 시나리오만 체크한다. 10-20분 걸려도 괜찮다.

문제는 이 비율을 지키지 않는 경우다.

```yaml
# 나쁜 예: E2E에 너무 많은 케이스
e2e-tests:
  steps:
    - name: Run 500 E2E tests  # 1시간 소요
      run: npm run test:e2e:all
```

E2E로 모든 케이스를 검증하려다 보면 파이프라인이 1시간씩 걸린다. 이건 지속 가능하지 않다.

```yaml
# 좋은 예: 적절한 분배
unit-tests:
  steps:
    - name: Run 2000 unit tests  # 2분
      run: npm run test:unit

integration-tests:
  needs: unit-tests
  steps:
    - name: Run 200 integration tests  # 8분
      run: npm run test:integration

e2e-smoke-tests:
  needs: integration-tests
  steps:
    - name: Run 10 critical E2E tests  # 5분
      run: npm run test:e2e:smoke

# 전체 E2E는 nightly로
e2e-full:
  if: github.event_name == 'schedule'
  steps:
    - name: Run all E2E tests  # 1시간
      run: npm run test:e2e:all
```

핵심 E2E는 매 커밋마다, 전체 E2E는 야간에. 이렇게 하면 속도와 커버리지 둘 다 잡을 수 있다.

### 4. 병렬화할 수 있는 건 병렬로

순차적으로 돌려야 할 이유가 없다면 병렬로 돌려라.

```yaml
jobs:
  # 린트와 타입 체크는 동시에 돌릴 수 있다
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Lint
        run: npm run lint

  type-check:
    runs-on: ubuntu-latest
    steps:
      - name: Type check
        run: npm run type-check

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Security scan
        run: npm audit

  # 셋 다 성공해야 다음 단계로
  tests:
    needs: [lint, type-check, security-scan]
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: npm test
```

린트 30초, 타입 체크 30초, 보안 스캔 30초를 순차적으로 돌리면 1분 30초다. 병렬로 돌리면 30초다. 3배 빠르다.

테스트도 병렬화할 수 있다.

```yaml
test:
  strategy:
    matrix:
      shard: [1, 2, 3, 4]
  steps:
    - name: Run tests shard ${{ matrix.shard }}
      run: npm test -- --shard=${{ matrix.shard }}/4
```

테스트를 4개로 쪼개서 동시에 돌리면 4배 빨라진다. 20분 걸리던 테스트가 5분이 된다.

### 5. 캐시를 적극 활용하라

매번 의존성을 다운로드하고, 빌드하는 건 시간 낭비다.

```yaml
jobs:
  build:
    steps:
      - uses: actions/checkout@v3
      
      # 의존성 캐시
      - name: Cache node modules
        uses: actions/cache@v3
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-
      
      - name: Install dependencies
        run: npm ci  # npm install보다 빠르고 안정적
      
      # 빌드 캐시
      - name: Cache build
        uses: actions/cache@v3
        with:
          path: .next/cache
          key: ${{ runner.os }}-nextjs-${{ hashFiles('**/package-lock.json') }}
      
      - name: Build
        run: npm run build
```

`package-lock.json`이 바뀌지 않았다면 의존성 캐시를 재사용한다. 2분이 10초로 줄어든다.

Docker 이미지도 레이어 캐시를 활용해야 한다.

```dockerfile
# 나쁜 예: 매번 전체 재빌드
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# 좋은 예: 레이어 캐시 활용
FROM node:18
WORKDIR /app

# 의존성은 자주 바뀌지 않으니 먼저 복사
COPY package*.json ./
RUN npm ci

# 소스코드는 자주 바뀌니 나중에
COPY . .
RUN npm run build
```

`package.json`이 바뀌지 않으면 `npm ci` 레이어는 캐시된다. 빌드 시간이 5분에서 30초로 줄어든다.

### 6. 환경을 격리하라

"로컬에선 되는데 CI에선 안 돼요" 문제의 주범은 환경 차이다.

```yaml
# 나쁜 예: 호스트 환경에 의존
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: |
          # 시스템에 설치된 DB 사용
          PGHOST=localhost npm test
```

이러면 DB 버전, 포트, 설정에 따라 결과가 달라진다.

```yaml
# 좋은 예: 컨테이너로 격리
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - name: Run tests
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379
        run: npm test
```

매번 같은 버전의 컨테이너로 테스트한다. 환경이 격리되어 있어서 일관성이 보장된다.

### 7. 실패는 명확하게, 성공은 조용하게

실패했을 때 무엇이 문제인지 즉시 알 수 있어야 한다.

```yaml
jobs:
  test:
    steps:
      - name: Run tests
        run: npm test
        continue-on-error: false  # 실패하면 즉시 중단
      
      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results/
      
      - name: Comment PR with failure
        if: failure() && github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## ❌ Tests Failed\n\nCheck the [test results](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId})`
            })
```

실패하면 PR에 자동으로 코멘트가 달린다. 개발자는 어디 가서 로그를 봐야 하는지 즉시 알 수 있다.

성공했을 때는 조용하다. 매번 "테스트 통과했어요!" 알림을 보낼 필요는 없다. 실패할 때만 알려줘도 충분하다.

## 배포 전략

빌드와 테스트는 그나마 쉽다. 진짜 어려운 건 배포다.

### Blue-Green 배포

가장 안전한 배포 전략이다. 두 개의 동일한 환경을 유지한다.

```yaml
deploy:
  steps:
    - name: Deploy to Green environment
      run: |
        # Green 환경에 새 버전 배포
        kubectl apply -f k8s/green/
        
        # Health check
        for i in {1..30}; do
          if curl -f https://green.myapp.com/health; then
            echo "Green environment is healthy"
            break
          fi
          sleep 10
        done
    
    - name: Run smoke tests
      run: |
        npm run test:smoke -- --url=https://green.myapp.com
    
    - name: Switch traffic to Green
      run: |
        # Load balancer를 Green으로 전환
        kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'
    
    - name: Monitor
      run: |
        # 5분간 모니터링
        sleep 300
        
        # 에러율 체크
        if [ $(check_error_rate) -gt 1 ]; then
          echo "Error rate too high, rolling back"
          exit 1
        fi
```

Green에 배포하고, 테스트하고, 트래픽을 전환한다. 문제 있으면 즉시 Blue로 롤백한다.

**장점**: 롤백이 즉각적이다. 그냥 트래픽을 다시 Blue로 돌리면 된다.

**단점**: 리소스가 2배 필요하다. 모든 서비스를 이중으로 돌려야 한다.

**언제**: 트래픽이 많고 다운타임이 절대 안 되는 서비스.

### Canary 배포

점진적으로 트래픽을 새 버전으로 전환한다.

```yaml
deploy-canary:
  steps:
    - name: Deploy Canary (10% traffic)
      run: |
        kubectl set image deployment/myapp-canary \
          myapp=myapp:${{ github.sha }}
        
        # Canary에 10% 트래픽
        kubectl patch virtualservice myapp -p '
          spec:
            http:
            - match:
              - headers:
                  x-canary:
                    exact: "true"
              route:
              - destination:
                  host: myapp-canary
            - route:
              - destination:
                  host: myapp-stable
                weight: 90
              - destination:
                  host: myapp-canary
                weight: 10
        '
    
    - name: Monitor canary for 10 minutes
      run: |
        for i in {1..60}; do
          ERROR_RATE=$(get_error_rate myapp-canary)
          if [ $ERROR_RATE -gt 1 ]; then
            echo "Canary error rate too high: $ERROR_RATE%"
            exit 1
          fi
          sleep 10
        done
    
    - name: Increase to 50%
      run: |
        kubectl patch virtualservice myapp -p '
          spec:
            http:
            - route:
              - destination:
                  host: myapp-stable
                weight: 50
              - destination:
                  host: myapp-canary
                weight: 50
        '
    
    - name: Monitor for 10 more minutes
      run: |
        # 모니터링 반복...
    
    - name: Full rollout
      run: |
        kubectl set image deployment/myapp \
          myapp=myapp:${{ github.sha }}
```

10% → 50% → 100%로 점진적으로 증가시킨다. 각 단계마다 모니터링하고, 문제 생기면 중단한다.

**장점**: 리스크가 분산된다. 10%만 영향받고 발견할 수 있다.

**단점**: 모니터링이 복잡하다. 자동화가 잘 되어야 한다.

**언제**: 새 기능을 검증하거나, 큰 변경사항이 있을 때.

### Rolling 배포

인스턴스를 하나씩 교체한다. Kubernetes 기본 전략이다.

```yaml
# Kubernetes Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1   # 최대 1개까지 다운 허용
      maxSurge: 2         # 최대 2개 추가 생성 허용
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
```

10개 인스턴스가 있으면:
1. 2개 새 버전 시작 (총 12개)
2. Health check 통과하면 1개 구버전 제거 (총 11개)
3. 다시 1개 새 버전 시작 (총 12개)
4. 반복...

**장점**: 리소스 효율적이다. 약간의 추가 리소스만 필요하다.

**단점**: 롤백이 복잡하다. 다시 Rolling update를 돌려야 한다.

**언제**: 일반적인 배포. 리소스 제약이 있을 때.

## 모니터링과 알림

파이프라인은 배포하고 끝이 아니다. 모니터링이 핵심이다.

### 메트릭 수집

배포 후 핵심 메트릭을 추적한다.

```yaml
post-deploy:
  steps:
    - name: Wait for metrics
      run: sleep 300  # 5분 대기
    
    - name: Check metrics
      run: |
        # Prometheus 쿼리
        ERROR_RATE=$(curl -s 'http://prometheus/api/v1/query?query=rate(http_requests_total{status=~"5.."}[5m])' | jq -r '.data.result[0].value[1]')
        
        LATENCY_P99=$(curl -s 'http://prometheus/api/v1/query?query=histogram_quantile(0.99, http_request_duration_seconds_bucket[5m])' | jq -r '.data.result[0].value[1]')
        
        if (( $(echo "$ERROR_RATE > 0.01" | bc -l) )); then
          echo "Error rate too high: $ERROR_RATE"
          exit 1
        fi
        
        if (( $(echo "$LATENCY_P99 > 1.0" | bc -l) )); then
          echo "P99 latency too high: $LATENCY_P99"
          exit 1
        fi
```

에러율, 레이턴시, 처리량을 모니터링한다. 임계값을 넘으면 자동 롤백한다.

### 로그 집계

문제 생기면 즉시 로그를 확인할 수 있어야 한다.

```yaml
- name: Collect logs on failure
  if: failure()
  run: |
    # 최근 로그 수집
    kubectl logs -l app=myapp --tail=1000 > deployment-logs.txt
    
    # 에러 로그만 필터링
    grep -i "error\|exception\|fatal" deployment-logs.txt > errors.txt

- name: Upload logs
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: deployment-logs
    path: |
      deployment-logs.txt
      errors.txt
```

### 알림 설정

실패는 즉시 알려야 한다.

```yaml
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "🚨 Deployment Failed",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Deployment to production failed*\n\nCommit: `${{ github.sha }}`\nAuthor: ${{ github.actor }}\n\n<${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View logs>"
            }
          }
        ]
      }
```

Slack에 바로 알림이 간다. 로그 링크도 함께 전달된다.

## 보안 고려사항

파이프라인은 프로덕션에 접근할 수 있다. 보안이 중요하다.

### 시크릿 관리

절대로 시크릿을 코드에 넣지 마라.

```yaml
# 나쁜 예
- name: Deploy
  run: |
    export AWS_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE  # 절대 안 됨!
    aws s3 sync . s3://mybucket

# 좋은 예
- name: Deploy
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  run: aws s3 sync . s3://mybucket
```

GitHub Secrets, AWS Secrets Manager, HashiCorp Vault 등을 사용한다.

### 권한 최소화

파이프라인에 필요한 최소한의 권한만 부여한다.

```yaml
# GitHub Actions permission
permissions:
  contents: read      # 코드 읽기만
  packages: write     # 패키지 푸시
  deployments: write  # 배포 상태 업데이트
  # admin 권한은 절대 주지 않는다
```

### 이미지 스캔

배포 전 취약점을 스캔한다.

```yaml
- name: Scan Docker image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    format: 'sarif'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'  # 취약점 발견시 실패
```

Critical이나 High 취약점이 있으면 배포를 차단한다.

## 실전 팁

### 1. Timeout 설정

모든 단계에 timeout을 설정한다.

```yaml
jobs:
  test:
    timeout-minutes: 10  # 10분 넘으면 강제 종료
    steps:
      - name: Run tests
        timeout-minutes: 8  # Step별로도 설정
        run: npm test
```

무한 대기하는 파이프라인만큼 짜증나는 건 없다.

### 2. 재시도 로직

네트워크 이슈 같은 일시적 오류는 재시도한다.

```yaml
- name: Download dependencies
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 5
    max_attempts: 3
    retry_wait_seconds: 10
    command: npm ci
```

네트워크 타임아웃 같은 랜덤 실패를 줄일 수 있다.

### 3. Dry Run

프로덕션 배포 전에 dry run으로 검증한다.

```yaml
- name: Dry run
  run: |
    kubectl apply --dry-run=server -f k8s/
    
    # 문법 에러, 권한 문제 등을 사전에 발견
```

### 4. 수동 승인

프로덕션 배포는 수동 승인을 넣는다.

```yaml
deploy-production:
  environment:
    name: production
  needs: deploy-staging
  steps:
    - name: Deploy to production
      run: ./deploy.sh
```

GitHub에서 승인 버튼을 눌러야 배포가 진행된다. 실수로 배포하는 걸 방지한다.

### 5. 배포 시간 제한

업무 시간에만 배포한다.

```yaml
deploy:
  if: |
    github.event_name == 'workflow_dispatch' ||
    (github.ref == 'refs/heads/main' && 
     github.event.head_commit.message !contains '[skip-deploy]' &&
     github.event.head_commit.timestamp >= '09:00' &&
     github.event.head_commit.timestamp <= '18:00')
```

금요일 밤 11시에 자동 배포되는 악몽을 방지한다.

## 안티패턴

### 1. 모든 걸 하나의 파이프라인에

```yaml
# 나쁜 예: 100줄짜리 모노리식 파이프라인
jobs:
  everything:
    steps:
      - lint
      - test
      - build
      - deploy-dev
      - test-dev
      - deploy-staging
      - test-staging
      - deploy-production
      - test-production
      # ... 끝이 없다
```

이러면 중간에 실패하면 처음부터 다시 돌려야 한다. 재사용도 안 되고, 읽기도 힘들다.

```yaml
# 좋은 예: 분리된 워크플로우
# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  lint: ...
  test: ...
  build: ...

# .github/workflows/deploy-staging.yml
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [develop]

# .github/workflows/deploy-production.yml
on:
  workflow_dispatch:  # 수동 트리거만
```

워크플로우를 분리하면 각각 독립적으로 실행할 수 있다.

### 2. 수동 단계가 있는 자동화

```yaml
# 나쁜 예
- name: Deploy
  run: |
    echo "Now SSH to server and run: ./deploy.sh"
    # 개발자가 직접 SSH 접속해야 함
```

이건 자동화가 아니다. 완전히 자동화하거나, 수동 승인 단계를 명시적으로 만들어라.

### 3. 환경별 파이프라인 중복

```yaml
# 나쁜 예: dev, staging, prod 파이프라인이 거의 동일
# deploy-dev.yml (100줄)
# deploy-staging.yml (100줄)
# deploy-production.yml (100줄)
```

공통 로직을 재사용 가능한 액션으로 추출한다.

```yaml
# .github/actions/deploy/action.yml
name: Deploy
inputs:
  environment:
    required: true
  image-tag:
    required: true
runs:
  using: composite
  steps:
    - run: ./deploy.sh ${{ inputs.environment }} ${{ inputs.image-tag }}

# deploy.yml
jobs:
  deploy-dev:
    steps:
      - uses: ./.github/actions/deploy
        with:
          environment: dev
          image-tag: ${{ github.sha }}
  
  deploy-prod:
    steps:
      - uses: ./.github/actions/deploy
        with:
          environment: production
          image-tag: ${{ github.sha }}
```

### 4. 테스트 없는 배포

```yaml
# 나쁜 예
on:
  push:
    branches: [main]
jobs:
  deploy:
    steps:
      - run: ./deploy.sh  # 테스트 없이 바로 배포
```

이건 러시안 룰렛이다. 최소한 smoke test는 돌려라.

## 마치며

CI/CD 파이프라인 설계는 한 번에 완성되지 않는다. 계속 개선해나가는 과정이다.

개인 프로젝트로 시작한다면 간단하게 시작하면 된다. 린트 → 테스트 → 빌드 정도면 충분하다. 그리고 필요에 따라 점진적으로 개선하면 된다.

파이프라인이 느리면 병렬화하고 캐시를 추가하고, 자주 실패하면 재시도 로직과 timeout을 추가하고, 배포가 불안하면 Blue-Green이나 Canary를 고려하면 된다.

중요한 건 **신뢰**다. 파이프라인을 신뢰할 수 있어야 자주 배포하고, 빠르게 피드백받고, 품질을 높일 수 있다.

파이프라인이 느려서 커밋을 미루거나, 불안해서 배포를 주저하거나, 실패를 무시하게 되면 뭔가 잘못된 거다. 그럴 땐 설계를 다시 봐야 한다.

도구는 중요하지 않다. Jenkins든 GitHub Actions든 GitLab CI든, 원칙은 같다. 빠르게 피드백하고, 안정적으로 배포하고, 안전하게 롤백할 수 있으면 된다.

