---
title: "R 코드 성능 최적화"
date: 2025-09-19
categories: Bigdata
tags: [r, performance, optimization, 벡터화, 데이터처리, 성능튜닝]
author: pitbull terrier
---

# R 코드 성능 최적화 - 느린 코드를 빠르게 만드는 방법

R을 사용하다 보면 코드의 속도 때문에 답답할 때가 많다. 특히 대용량 데이터를 다룰 때는 더욱 그렇다.

하지만 R의 성능 최적화 방법들을 익히면 같은 작업을 몇 배 빠르게 처리할 수 있다. 벡터화 연산, 효율적인 함수 사용, 메모리 관리 등 다양한 기법들이 있다.

오늘은 실무에서 자주 마주치는 성능 문제들과 그 해결책들을 정리해보겠다.

## R이 느린 이유는 무엇인가?

### 인터프리터 언어의 특성
R은 인터프리터 언어로, 코드를 한 줄씩 해석하면서 실행한다. 컴파일 언어와 달리 실행 시점에 해석하기 때문에 상대적으로 느릴 수밖에 없다.

**성능 차이 예시**
- for문을 사용한 10만 행 데이터 처리: 30분
- 벡터화 연산으로 변경 후: 30초
- 같은 작업임에도 불구하고 60배의 성능 차이 발생

### 메모리 관리의 복잡성
R은 메모리 관리가 복잡하다. 객체를 복사할 때마다 메모리가 추가로 할당되고, 가비지 컬렉션이 자주 발생한다.

## 성능 측정 방법

### system.time() 사용하기
코드 실행 시간을 측정하는 가장 기본적인 방법이다.

```r
# 기본 사용법
system.time({
  # 측정하고 싶은 코드
  result <- sum(1:1000000)
})

# 출력 예시
# user  system elapsed 
# 0.02   0.00    0.02
```

**출력 해석**
- **user**: CPU가 사용자 코드를 실행하는 데 걸린 시간
- **system**: CPU가 시스템 코드를 실행하는 데 걸린 시간  
- **elapsed**: 실제 경과 시간 (가장 중요)

### microbenchmark 패키지 활용
더 정확한 성능 측정을 위해서는 microbenchmark 패키지를 사용한다.

```r
# 패키지 설치 및 로드
install.packages("microbenchmark")
library(microbenchmark)

# 성능 비교 예시
microbenchmark(
  for_loop = {
    result <- 0
    for(i in 1:1000) {
      result <- result + i
    }
  },
  vectorized = sum(1:1000),
  times = 100  # 100번 실행해서 평균 계산
)
```

### profvis 패키지로 프로파일링
코드의 어느 부분이 가장 느린지 찾아내는 프로파일링 도구다.

```r
install.packages("profvis")
library(profvis)

profvis({
  # 분석하고 싶은 코드
  data <- rnorm(100000)
  result <- data[data > 0]
  mean(result)
})
```

## 1. 벡터화 연산 활용하기

### 벡터화 vs 반복문 성능 비교

**느린 코드 (반복문 사용)**
```r
# 10만 개 데이터의 제곱을 계산하는 예시
data <- rnorm(100000)

# 방법 1: for문 사용 (느림)
system.time({
  result1 <- numeric(length(data))
  for(i in 1:length(data)) {
    result1[i] <- data[i]^2
  }
})
# user  system elapsed 
# 0.45   0.00    0.45
```

**빠른 코드 (벡터화 연산)**
```r
# 방법 2: 벡터화 연산 (빠름)
system.time({
  result2 <- data^2
})
# user  system elapsed 
# 0.01   0.00    0.01
```

### 실제 성능 차이
벡터화 연산이 for문보다 **45배** 빠르다! R의 내장 함수들은 C로 구현되어 있어서 매우 빠르다.

### 벡터화 연산 활용 예시들

#### 조건부 연산
```r
# 데이터 준비
data <- rnorm(100000)

# 느린 방법
result_slow <- numeric(length(data))
for(i in 1:length(data)) {
  if(data[i] > 0) {
    result_slow[i] <- data[i] * 2
  } else {
    result_slow[i] <- data[i] * 0.5
  }
}

# 빠른 방법
result_fast <- ifelse(data > 0, data * 2, data * 0.5)
```

#### 문자열 처리
```r
# 데이터 준비
text_data <- rep(c("apple", "banana", "cherry"), 10000)

# 느린 방법
result_slow <- character(length(text_data))
for(i in 1:length(text_data)) {
  result_slow[i] <- toupper(text_data[i])
}

# 빠른 방법
result_fast <- toupper(text_data)
```

## 2. 효율적인 데이터 구조 사용하기

### matrix vs data.frame 성능 비교

**matrix 사용 (빠름)**
```r
# 1000x1000 행렬 생성
mat <- matrix(rnorm(1000000), nrow = 1000, ncol = 1000)

system.time({
  result <- rowSums(mat)
})
# user  system elapsed 
# 0.02   0.00    0.02
```

**data.frame 사용 (상대적으로 느림)**
```r
# 같은 크기의 데이터프레임 생성
df <- as.data.frame(matrix(rnorm(1000000), nrow = 1000, ncol = 1000))

system.time({
  result <- rowSums(df)
})
# user  system elapsed 
# 0.15   0.00    0.15
```

### data.table 패키지 활용
대용량 데이터 처리에 특화된 data.table 패키지는 기본 data.frame보다 훨씬 빠르다.

```r
install.packages("data.table")
library(data.table)

# 데이터 준비
n <- 1000000
dt <- data.table(
  id = 1:n,
  value1 = rnorm(n),
  value2 = rnorm(n),
  category = sample(LETTERS[1:5], n, replace = TRUE)
)

# data.table의 빠른 그룹 연산
system.time({
  result <- dt[, .(mean_val = mean(value1), sum_val = sum(value2)), by = category]
})
# user  system elapsed 
# 0.05   0.00    0.05

# 같은 작업을 data.frame으로
df <- as.data.frame(dt)
system.time({
  result2 <- aggregate(cbind(value1, value2) ~ category, data = df, 
                      FUN = function(x) c(mean = mean(x), sum = sum(x)))
})
# user  system elapsed 
# 2.34   0.00    2.34
```

**성능 차이**: data.table이 약 **47배** 빠르다!

## 3. apply 계열 함수 활용하기

### apply 함수들의 성능 비교

```r
# 데이터 준비
mat <- matrix(rnorm(100000), nrow = 1000, ncol = 100)

# apply() 사용
system.time({
  result1 <- apply(mat, 1, mean)
})

# rowMeans() 사용 (가장 빠름)
system.time({
  result2 <- rowMeans(mat)
})

# for문 사용
system.time({
  result3 <- numeric(nrow(mat))
  for(i in 1:nrow(mat)) {
    result3[i] <- mean(mat[i, ])
  }
})
```

**성능 순서**: `rowMeans()` > `apply()` > `for문`

### 특화된 함수들 사용하기
```r
# 행/열 합계
rowSums(mat)    # apply(mat, 1, sum)보다 빠름
colSums(mat)    # apply(mat, 2, sum)보다 빠름

# 행/열 평균
rowMeans(mat)   # apply(mat, 1, mean)보다 빠름
colMeans(mat)   # apply(mat, 2, mean)보다 빠름

# 행/열 표준편차
rowSds(mat)     # matrixStats 패키지 필요
colSds(mat)
```

## 4. 메모리 효율적인 프로그래밍

### 객체 재사용하기

**메모리 낭비하는 코드**
```r
# 매번 새로운 객체 생성
result1 <- data^2
result2 <- data^3
result3 <- data^4
result4 <- data^5
```

**메모리 효율적인 코드**
```r
# 같은 객체 재사용
result <- data^2
result <- data^3
result <- data^4
result <- data^5
```

### 불필요한 객체 제거하기
```r
# 큰 객체 사용 후 제거
large_data <- rnorm(10000000)
result <- mean(large_data)
rm(large_data)  # 메모리에서 제거
gc()            # 가비지 컬렉션 강제 실행
```

### 메모리 사용량 확인하기
```r
# 현재 메모리 사용량
memory.size()

# R 객체들의 메모리 사용량
object.size(large_data)

# 메모리 사용량 상위 10개 객체
sort(sapply(ls(), function(x) object.size(get(x))), decreasing = TRUE)[1:10]
```

## 5. 패키지별 성능 최적화

### dplyr vs 기본 R 함수

```r
library(dplyr)

# 데이터 준비
df <- data.frame(
  id = 1:100000,
  value = rnorm(100000),
  category = sample(LETTERS[1:5], 100000, replace = TRUE)
)

# dplyr 사용 (가독성 좋음)
system.time({
  result1 <- df %>%
    group_by(category) %>%
    summarise(
      mean_val = mean(value),
      count = n()
    )
})

# 기본 R 함수 사용 (빠름)
system.time({
  result2 <- aggregate(value ~ category, data = df, 
                      FUN = function(x) c(mean = mean(x), count = length(x)))
})
```

### 병렬 처리 활용

#### parallel 패키지 사용
```r
library(parallel)

# CPU 코어 수 확인
n_cores <- detectCores()
print(paste("사용 가능한 코어 수:", n_cores))

# 병렬 처리 예시
system.time({
  # 순차 처리
  result1 <- lapply(1:1000, function(x) sum(rnorm(1000)))
})

system.time({
  # 병렬 처리
  cl <- makeCluster(n_cores - 1)  # 코어 하나는 남겨둠
  result2 <- parLapply(cl, 1:1000, function(x) sum(rnorm(1000)))
  stopCluster(cl)
})
```

#### foreach 패키지 사용
```r
install.packages("foreach")
install.packages("doParallel")
library(foreach)
library(doParallel)

# 병렬 백엔드 등록
cl <- makeCluster(n_cores - 1)
registerDoParallel(cl)

system.time({
  result <- foreach(i = 1:1000, .combine = c) %dopar% {
    sum(rnorm(1000))
  }
})

stopCluster(cl)
```

## 6. 실무에서 자주 마주치는 성능 문제들

### 문제 1: 대용량 CSV 파일 읽기

**느린 방법**
```r
# 기본 read.csv() 사용
system.time({
  data <- read.csv("large_file.csv")
})
```

**빠른 방법**
```r
# data.table::fread() 사용
library(data.table)
system.time({
  data <- fread("large_file.csv")
})

# 또는 readr::read_csv() 사용
library(readr)
system.time({
  data <- read_csv("large_file.csv")
})
```

### 문제 2: 반복적인 데이터 조인

**느린 방법**
```r
# 기본 merge() 사용
system.time({
  result <- merge(df1, df2, by = "id")
})
```

**빠른 방법**
```r
# data.table 조인 사용
library(data.table)
dt1 <- as.data.table(df1)
dt2 <- as.data.table(df2)

system.time({
  result <- dt1[dt2, on = "id"]
})
```

### 문제 3: 그룹별 연산

**느린 방법**
```r
# for문 사용
result <- data.frame()
for(cat in unique(df$category)) {
  subset_data <- df[df$category == cat, ]
  mean_val <- mean(subset_data$value)
  result <- rbind(result, data.frame(category = cat, mean_value = mean_val))
}
```

**빠른 방법**
```r
# data.table 사용
library(data.table)
dt <- as.data.table(df)
result <- dt[, .(mean_value = mean(value)), by = category]
```

## 7. 성능 최적화 체크리스트

### 코드 작성 전 확인사항
- [ ] 벡터화 연산을 사용할 수 있는가?
- [ ] 적절한 데이터 구조를 선택했는가?
- [ ] 불필요한 객체 생성은 없는가?
- [ ] 반복문 대신 apply 계열 함수를 사용할 수 있는가?

### 코드 작성 후 확인사항
- [ ] system.time()으로 성능을 측정했는가?
- [ ] 메모리 사용량을 확인했는가?
- [ ] 다른 방법과 성능을 비교했는가?

### 성능 최적화 우선순위
1. **알고리즘 최적화**: 벡터화 연산, 효율적인 데이터 구조
2. **함수 최적화**: 특화된 함수 사용, apply 계열 활용
3. **메모리 최적화**: 객체 재사용, 불필요한 객체 제거
4. **병렬 처리**: CPU 집약적 작업에 병렬 처리 적용

## 8. 성능 최적화 적용 예시

### 예시 1: 대용량 고객 데이터 분석
**상황**: 100만 고객의 구매 이력을 분석해야 하는 경우

**비효율적인 방법**
```r
# 각 고객별로 반복문 사용
customer_analysis <- data.frame()
for(i in 1:length(customers)) {
  customer_data <- purchases[purchases$customer_id == customers[i], ]
  total_amount <- sum(customer_data$amount)
  purchase_count <- nrow(customer_data)
  customer_analysis <- rbind(customer_analysis, 
                           data.frame(customer_id = customers[i],
                                    total_amount = total_amount,
                                    purchase_count = purchase_count))
}
```

**효율적인 방법**
```r
# data.table 그룹 연산 사용
library(data.table)
dt_purchases <- as.data.table(purchases)
customer_analysis <- dt_purchases[, .(
  total_amount = sum(amount),
  purchase_count = .N
), by = customer_id]
```

**성능 비교**: 2시간 → 3분 (40배 향상)

### 예시 2: 대용량 시계열 데이터 처리
**상황**: 5년간의 일별 주식 데이터를 분석해야 하는 경우

**비효율적인 방법**
```r
# 모든 데이터를 메모리에 로드
all_data <- read.csv("5_years_stock_data.csv")  # 1.8GB 파일
```

**효율적인 방법**
```r
# 필요한 컬럼만 선택해서 로드
library(data.table)
all_data <- fread("5_years_stock_data.csv", 
                  select = c("date", "symbol", "close", "volume"))

# 청크 단위로 처리
process_chunk <- function(chunk) {
  chunk[, daily_return := close / shift(close) - 1, by = symbol]
  return(chunk)
}

# 파일을 청크 단위로 읽어서 처리
result <- fread("5_years_stock_data.csv", 
                select = c("date", "symbol", "close", "volume"),
                nrows = 100000)  # 10만 행씩 처리
```

**성능 비교**: 메모리 사용량 80% 감소, 처리 시간 50% 단축

## 9. 성능 분석 도구들

### Rprof() 함수 사용
```r
# 프로파일링 시작
Rprof("profile.out")

# 분석하고 싶은 코드 실행
for(i in 1:1000) {
  result <- sum(rnorm(1000))
}

# 프로파일링 종료
Rprof(NULL)

# 결과 확인
summaryRprof("profile.out")
```

### bench 패키지 사용
```r
install.packages("bench")
library(bench)

# 여러 방법의 성능 비교
mark(
  for_loop = {
    result <- 0
    for(i in 1:1000) result <- result + i
  },
  vectorized = sum(1:1000),
  apply_method = sum(sapply(1:1000, identity))
)
```

## 10. 주의사항 및 한계

### 과도한 최적화 방지
- 모든 코드를 최적화하려고 하면 코드 가독성이 떨어짐
- 실제 병목이 되는 부분만 최적화하는 것이 중요

### 메모리 vs 속도 트레이드오프
- 메모리를 많이 사용하면 속도는 빨라지지만 메모리 부족 위험 증가
- 시스템 리소스를 고려한 균형 잡힌 접근 필요

### 패키지 의존성 관리
- 성능 최적화 패키지들이 많아서 의존성이 복잡해질 수 있음
- 핵심 패키지들만 사용하고 정기적으로 정리하는 것이 좋음

## 마무리

R 코드 성능 최적화는 처음에는 복잡해 보이지만, 몇 가지 핵심 원칙만 익히면 큰 차이를 만들 수 있다.

**가장 중요한 최적화 원칙들**
1. **벡터화 연산 우선**: for문보다 벡터화 연산이 훨씬 빠르다
2. **적절한 데이터 구조**: data.table, matrix 등 상황에 맞는 구조 선택
3. **특화된 함수 사용**: rowSums, colMeans 등 내장 함수 활용
4. **메모리 관리**: 불필요한 객체 제거, 객체 재사용
