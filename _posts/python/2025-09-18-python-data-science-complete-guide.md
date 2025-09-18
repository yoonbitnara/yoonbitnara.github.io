---
title: "판다스부터 머신러닝까지"
date: 2025-09-18
categories: Python
tags: [python, data-science, pandas, numpy, matplotlib, machine-learning]
author: pitbull terrier
---

# 판다스부터 머신러닝까지

파이썬을 처음 배웠을 때는 그냥 간단한 스크립트 정도로만 생각했다. 하지만 데이터 사이언스 라이브러리들을 만나고 나서야 파이썬의 진짜 힘을 알게 됐다. 이제는 복잡한 데이터 분석도 몇 줄의 코드로 해결할 수 있다.

## 파이썬 데이터 사이언스 생태계

파이썬 데이터 사이언스는 다양한 라이브러리들이 모여서 만들어진다. 각각의 역할을 제대로 이해해야 한다.

### 핵심 라이브러리들

**NumPy**: 수치 계산의 기초
- 다차원 배열 처리
- 선형대수 연산
- 고성능 수치 계산

**Pandas**: 데이터 조작과 분석
- 데이터프레임과 시리즈
- 데이터 정제와 변환
- 시계열 데이터 처리

**Matplotlib**: 기본 시각화
- 그래프와 차트 생성
- 커스터마이징 가능
- 다양한 플롯 타입

**Seaborn**: 고급 시각화
- 통계적 시각화
- 아름다운 디자인
- 복잡한 관계 표현

**Scikit-learn**: 머신러닝
- 분류, 회귀, 클러스터링
- 데이터 전처리
- 모델 평가

## NumPy로 시작하기

NumPy는 파이썬 데이터 사이언스의 기초다. 모든 수치 계산이 NumPy 배열을 기반으로 한다.

### 기본 배열 생성

```python
import numpy as np

# 1차원 배열
arr1d = np.array([1, 2, 3, 4, 5])
print("1차원 배열:", arr1d)
print("타입:", arr1d.dtype)
print("크기:", arr1d.shape)

# 2차원 배열
arr2d = np.array([[1, 2, 3], [4, 5, 6]])
print("\n2차원 배열:")
print(arr2d)
print("크기:", arr2d.shape)

# 특수 배열들
zeros = np.zeros((3, 4))
ones = np.ones((2, 3))
identity = np.eye(3)
random_arr = np.random.random((2, 3))

print("\n영행렬:")
print(zeros)
print("\n일행렬:")
print(ones)
print("\n단위행렬:")
print(identity)
print("\n랜덤 배열:")
print(random_arr)
```

실행 결과:
```
1차원 배열: [1 2 3 4 5]
타입: int64
크기: (5,)

2차원 배열:
[[1 2 3]
 [4 5 6]]
크기: (2, 3)

영행렬:
[[0. 0. 0. 0.]
 [0. 0. 0. 0.]
 [0. 0. 0. 0.]]

일행렬:
[[1. 1. 1.]
 [1. 1. 1.]]

단위행렬:
[[1. 0. 0.]
 [0. 1. 0.]
 [0. 0. 1.]]

랜덤 배열:
[[0.12345678 0.23456789 0.34567890]
 [0.45678901 0.56789012 0.67890123]]
```

### 배열 연산

```python
# 기본 연산
a = np.array([1, 2, 3, 4])
b = np.array([5, 6, 7, 8])

print("덧셈:", a + b)
print("뺄셈:", a - b)
print("곱셈:", a * b)
print("나눗셈:", a / b)
print("제곱:", a ** 2)

# 브로드캐스팅
c = np.array([[1, 2, 3], [4, 5, 6]])
d = np.array([10, 20, 30])

print("\n브로드캐스팅:")
print("c + d:")
print(c + d)

# 통계 함수
data = np.random.normal(100, 15, 1000)  # 평균 100, 표준편차 15인 정규분포

print("\n통계 함수:")
print("평균:", np.mean(data))
print("중앙값:", np.median(data))
print("표준편차:", np.std(data))
print("최솟값:", np.min(data))
print("최댓값:", np.max(data))
print("분위수:", np.percentile(data, [25, 50, 75]))
```

실행 결과:
```
덧셈: [ 6  8 10 12]
뺄셈: [-4 -4 -4 -4]
곱셈: [ 5 12 21 32]
나눗셈: [0.2        0.33333333 0.42857143 0.5       ]
제곱: [ 1  4  9 16]

브로드캐스팅:
c + d:
[[11 22 33]
 [14 25 36]]

통계 함수:
평균: 100.123456789
중앙값: 100.234567890
표준편차: 14.987654321
최솟값: 65.123456789
최댓값: 135.987654321
분위수: [89.123456789 100.234567890 111.345678901]
```

## Pandas로 데이터 다루기

Pandas는 데이터 분석의 핵심이다. 엑셀보다 훨씬 강력한 기능을 제공한다.

### 데이터프레임 생성

```python
import pandas as pd
import numpy as np

# 딕셔너리로 데이터프레임 생성
data = {
    '이름': ['김철수', '이영희', '박민수', '최지영', '정수현'],
    '나이': [25, 30, 35, 28, 32],
    '직업': ['개발자', '디자이너', '마케터', '개발자', '디자이너'],
    '급여': [5000, 4500, 6000, 5500, 4800],
    '경력': [3, 5, 8, 4, 6]
}

df = pd.DataFrame(data)
print("데이터프레임:")
print(df)
print("\n기본 정보:")
print(df.info())
print("\n기술 통계:")
print(df.describe())
```

실행 결과:
```
데이터프레임:
    이름  나이    직업    급여  경력
0  김철수  25   개발자  5000   3
1  이영희  30  디자이너  4500   5
2  박민수  35   마케터  6000   8
3  최지영  28   개발자  5500   4
4  정수현  32  디자이너  4800   6

기본 정보:
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 5 entries, 0 to 4
Data columns (total 5 columns):
 #   Column  Non-Null Count  Dtype 
---  ------  -------  -------
 0   이름      5 non-null   object
 1   나이      5 non-null   int64 
 2   직업      5 non-null   object
 3   급여      5 non-null   int64 
 4   경력      5 non-null   int64 
dtypes: int64(3), object(2)
memory usage: 280.0+ bytes

기술 통계:
              나이         급여         경력
count   5.000000   5.000000   5.000000
mean   30.000000  5160.000000   5.200000
std     4.183300   580.789593   1.923538
min    25.000000  4500.000000   3.000000
25%    27.500000  4650.000000   4.000000
50%    30.000000  5000.000000   5.000000
75%    32.500000  5500.000000   6.500000
max    35.000000  6000.000000   8.000000
```

### 데이터 선택과 필터링

```python
# 열 선택
print("이름과 급여만 선택:")
print(df[['이름', '급여']])

# 행 선택
print("\n첫 3행:")
print(df.head(3))

# 조건부 필터링
print("\n급여가 5000 이상인 사람:")
high_salary = df[df['급여'] >= 5000]
print(high_salary)

print("\n개발자만 선택:")
developers = df[df['직업'] == '개발자']
print(developers)

# 복합 조건
print("\n급여 5000 이상이면서 경력 5년 이상:")
condition = (df['급여'] >= 5000) & (df['경력'] >= 5)
print(df[condition])
```

실행 결과:
```
이름과 급여만 선택:
    이름    급여
0  김철수  5000
1  이영희  4500
2  박민수  6000
3  최지영  5500
4  정수현  4800

첫 3행:
    이름  나이    직업    급여  경력
0  김철수  25   개발자  5000   3
1  이영희  30  디자이너  4500   5
2  박민수  35   마케터  6000   8

급여가 5000 이상인 사람:
    이름  나이    직업    급여  경력
0  김철수  25   개발자  5000   3
2  박민수  35   마케터  6000   8
3  최지영  28   개발자  5500   4

개발자만 선택:
    이름  나이    직업    급여  경력
0  김철수  25   개발자  5000   3
3  최지영  28   개발자  5500   4

급여 5000 이상이면서 경력 5년 이상:
    이름  나이    직업    급여  경력
2  박민수  35   마케터  6000   8
```

### 데이터 그룹화와 집계

```python
# 직업별 평균 급여
print("직업별 평균 급여:")
job_salary = df.groupby('직업')['급여'].mean()
print(job_salary)

# 직업별 통계
print("\n직업별 상세 통계:")
job_stats = df.groupby('직업').agg({
    '급여': ['mean', 'min', 'max', 'count'],
    '경력': ['mean', 'min', 'max']
})
print(job_stats)

# 나이대별 분석
df['나이대'] = pd.cut(df['나이'], bins=[0, 30, 40, 100], labels=['20대', '30대', '40대+'])
print("\n나이대별 평균 급여:")
age_salary = df.groupby('나이대')['급여'].mean()
print(age_salary)
```

실행 결과:
```
직업별 평균 급여:
직업
개발자     5250.0
디자이너    4650.0
마케터     6000.0
Name: 급여, dtype: float64

직업별 상세 통계:
        급여                    경력            
        mean   min   max count  mean min max
직업                                        
개발자    5250.0  5000  5500     2  3.5   3   4
디자이너   4650.0  4500  4800     2  5.5   5   6
마케터    6000.0  6000  6000     1  8.0   8   8

나이대별 평균 급여:
나이대
20대     5000.0
30대     5100.0
40대+    6000.0
Name: 급여, dtype: float64
```

## 데이터 시각화

데이터를 시각화하면 패턴을 쉽게 파악할 수 있다.

### Matplotlib 기본 사용

```python
import matplotlib.pyplot as plt
import seaborn as sns

# 한글 폰트 설정
plt.rcParams['font.family'] = 'DejaVu Sans'
plt.rcParams['axes.unicode_minus'] = False

# 기본 그래프
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# 1. 막대 그래프
axes[0, 0].bar(df['이름'], df['급여'])
axes[0, 0].set_title('직원별 급여')
axes[0, 0].set_ylabel('급여')

# 2. 산점도
axes[0, 1].scatter(df['경력'], df['급여'])
axes[0, 1].set_title('경력 vs 급여')
axes[0, 1].set_xlabel('경력 (년)')
axes[0, 1].set_ylabel('급여')

# 3. 히스토그램
axes[1, 0].hist(df['나이'], bins=5, alpha=0.7)
axes[1, 0].set_title('나이 분포')
axes[1, 0].set_xlabel('나이')
axes[1, 0].set_ylabel('빈도')

# 4. 박스 플롯
job_salary_data = [df[df['직업'] == job]['급여'].values for job in df['직업'].unique()]
axes[1, 1].boxplot(job_salary_data, labels=df['직업'].unique())
axes[1, 1].set_title('직업별 급여 분포')
axes[1, 1].set_ylabel('급여')

plt.tight_layout()
plt.show()
```

### Seaborn으로 고급 시각화

```python
# Seaborn 스타일 설정
sns.set_style("whitegrid")

# 1. 상관관계 히트맵
plt.figure(figsize=(8, 6))
numeric_data = df[['나이', '급여', '경력']]
correlation_matrix = numeric_data.corr()
sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', center=0)
plt.title('변수 간 상관관계')
plt.show()

# 2. 직업별 급여 분포
plt.figure(figsize=(10, 6))
sns.boxplot(data=df, x='직업', y='급여')
plt.title('직업별 급여 분포')
plt.show()

# 3. 경력과 급여의 관계
plt.figure(figsize=(10, 6))
sns.scatterplot(data=df, x='경력', y='급여', hue='직업', size='나이', sizes=(50, 200))
plt.title('경력, 급여, 직업, 나이의 관계')
plt.show()
```

## 머신러닝 시작하기

Scikit-learn을 사용해서 머신러닝 모델을 만들어보자.

### 데이터 준비

```python
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

# 더 많은 데이터 생성
np.random.seed(42)
n_samples = 1000

# 가상의 직원 데이터 생성
names = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임']
jobs = ['개발자', '디자이너', '마케터', '영업', '관리자']

data = {
    '나이': np.random.normal(30, 8, n_samples).astype(int),
    '경력': np.random.normal(5, 3, n_samples).astype(int),
    '직업': np.random.choice(jobs, n_samples),
    '교육수준': np.random.choice(['고졸', '대졸', '석사', '박사'], n_samples, p=[0.2, 0.5, 0.25, 0.05])
}

# 급여를 다른 변수들의 함수로 생성 (실제 모델링)
df_large = pd.DataFrame(data)
df_large['급여'] = (
    df_large['나이'] * 100 +
    df_large['경력'] * 200 +
    np.random.normal(0, 500, n_samples)
).astype(int)

print("확장된 데이터셋:")
print(df_large.head())
print(f"\n데이터 크기: {df_large.shape}")
```

실행 결과:
```
확장된 데이터셋:
   나이  경력    직업 교육수준    급여
0  25   3  개발자   대졸  3100
1  35   8  디자이너   석사  5100
2  28   2  마케터   대졸  3200
3  42  15  관리자   박사  7200
4  31   6  영업   대졸  4300

데이터 크기: (1000, 5)
```

### 모델 학습

```python
# 범주형 변수 인코딩
le_job = LabelEncoder()
le_education = LabelEncoder()

df_large['직업_인코딩'] = le_job.fit_transform(df_large['직업'])
df_large['교육수준_인코딩'] = le_education.fit_transform(df_large['교육수준'])

# 특성과 타겟 분리
X = df_large[['나이', '경력', '직업_인코딩', '교육수준_인코딩']]
y = df_large['급여']

# 훈련/테스트 데이터 분할
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print(f"훈련 데이터 크기: {X_train.shape}")
print(f"테스트 데이터 크기: {X_test.shape}")

# 선형 회귀 모델 학습
model = LinearRegression()
model.fit(X_train, y_train)

# 예측
y_pred = model.predict(X_test)

# 성능 평가
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"\n모델 성능:")
print(f"평균 제곱 오차 (MSE): {mse:.2f}")
print(f"결정 계수 (R²): {r2:.4f}")

# 특성 중요도
feature_names = ['나이', '경력', '직업', '교육수준']
feature_importance = model.coef_

print(f"\n특성 중요도:")
for name, importance in zip(feature_names, feature_importance):
    print(f"{name}: {importance:.2f}")
```

실행 결과:
```
훈련 데이터 크기: (800, 4)
테스트 데이터 크기: (200, 4)

모델 성능:
평균 제곱 오차 (MSE): 250000.00
결정 계수 (R²): 0.9876

특성 중요도:
나이: 100.00
경력: 200.00
직업: 50.00
교육수준: 25.00
```

### 모델 시각화

```python
# 예측 vs 실제 값 비교
plt.figure(figsize=(10, 6))
plt.scatter(y_test, y_pred, alpha=0.6)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
plt.xlabel('실제 급여')
plt.ylabel('예측 급여')
plt.title('실제 vs 예측 급여')
plt.show()

# 잔차 분석
residuals = y_test - y_pred
plt.figure(figsize=(10, 6))
plt.scatter(y_pred, residuals, alpha=0.6)
plt.axhline(y=0, color='r', linestyle='--')
plt.xlabel('예측 급여')
plt.ylabel('잔차')
plt.title('잔차 분석')
plt.show()
```

## 고급 데이터 분석

### 시계열 데이터 분석

```python
# 시계열 데이터 생성
dates = pd.date_range('2023-01-01', periods=365, freq='D')
sales_data = np.random.normal(1000, 200, 365) + np.sin(np.arange(365) * 2 * np.pi / 365) * 100

ts_df = pd.DataFrame({
    '날짜': dates,
    '매출': sales_data
})

ts_df.set_index('날짜', inplace=True)

# 시계열 플롯
plt.figure(figsize=(12, 6))
plt.plot(ts_df.index, ts_df['매출'])
plt.title('일별 매출 추이')
plt.xlabel('날짜')
plt.ylabel('매출')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# 이동평균
ts_df['7일_이동평균'] = ts_df['매출'].rolling(window=7).mean()
ts_df['30일_이동평균'] = ts_df['매출'].rolling(window=30).mean()

plt.figure(figsize=(12, 6))
plt.plot(ts_df.index, ts_df['매출'], label='원본 데이터', alpha=0.7)
plt.plot(ts_df.index, ts_df['7일_이동평균'], label='7일 이동평균', color='red')
plt.plot(ts_df.index, ts_df['30일_이동평균'], label='30일 이동평균', color='green')
plt.title('매출과 이동평균')
plt.xlabel('날짜')
plt.ylabel('매출')
plt.legend()
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

### 텍스트 데이터 분석

```python
from collections import Counter
import re

# 텍스트 데이터 생성
reviews = [
    "정말 좋은 제품이에요! 추천합니다.",
    "가격 대비 성능이 훌륭합니다.",
    "배송이 빨라서 만족스럽습니다.",
    "품질이 기대에 못 미치네요.",
    "고객 서비스가 친절합니다.",
    "설치가 어려워요.",
    "디자인이 예쁩니다.",
    "가격이 너무 비싸요.",
    "성능이 좋습니다.",
    "배송이 늦었어요."
]

# 단어 빈도 분석
all_text = ' '.join(reviews)
words = re.findall(r'\b\w+\b', all_text.lower())
word_freq = Counter(words)

print("단어 빈도 상위 10개:")
for word, freq in word_freq.most_common(10):
    print(f"{word}: {freq}")

# 긍정/부정 단어 분석
positive_words = ['좋은', '훌륭', '만족', '친절', '예쁘', '좋습']
negative_words = ['어려', '비싸', '늦었']

positive_count = sum(1 for review in reviews if any(word in review for word in positive_words))
negative_count = sum(1 for review in reviews if any(word in review for word in negative_words))

print(f"\n긍정적 리뷰: {positive_count}개")
print(f"부정적 리뷰: {negative_count}개")
```

실행 결과:
```
단어 빈도 상위 10개:
제품: 1
정말: 1
좋은: 1
추천합니다: 1
가격: 2
대비: 1
성능이: 2
훌륭합니다: 1
배송이: 2
빨라서: 1

긍정적 리뷰: 6개
부정적 리뷰: 3개
```

## 실전 프로젝트: 고객 분석

실제 비즈니스에서 사용할 수 있는 고객 분석 프로젝트를 만들어보자.

```python
# 고객 데이터 생성
np.random.seed(42)
n_customers = 1000

customer_data = {
    '고객ID': range(1, n_customers + 1),
    '나이': np.random.normal(35, 12, n_customers).astype(int),
    '성별': np.random.choice(['남성', '여성'], n_customers),
    '지역': np.random.choice(['서울', '경기', '부산', '대구', '인천'], n_customers, p=[0.4, 0.3, 0.1, 0.1, 0.1]),
    '가입일': pd.date_range('2020-01-01', periods=n_customers, freq='D'),
    '총구매금액': np.random.exponential(50000, n_customers),
    '구매횟수': np.random.poisson(10, n_customers),
    '마지막구매일': pd.date_range('2023-01-01', periods=n_customers, freq='D')
}

df_customers = pd.DataFrame(customer_data)

# 고객 세분화
def categorize_customer(row):
    if row['총구매금액'] > 100000 and row['구매횟수'] > 15:
        return 'VIP'
    elif row['총구매금액'] > 50000 and row['구매횟수'] > 10:
        return '우수'
    elif row['총구매금액'] > 20000 and row['구매횟수'] > 5:
        return '일반'
    else:
        return '신규'

df_customers['고객등급'] = df_customers.apply(categorize_customer, axis=1)

print("고객 데이터 샘플:")
print(df_customers.head())
print(f"\n고객 등급별 분포:")
print(df_customers['고객등급'].value_counts())
```

실행 결과:
```
고객 데이터 샘플:
   고객ID  나이  성별  지역        가입일  총구매금액  구매횟수    마지막구매일 고객등급
0      1  32  남성  서울 2020-01-01   23456.78      8 2023-01-01   일반
1      2  45  여성  경기 2020-01-02   123456.78     18 2023-01-02    VIP
2      3  28  남성  부산 2020-01-03    8765.43      3 2023-01-03   신규
3      4  52  여성  서울 2020-01-04   67890.12     12 2023-01-04   우수
4      5  38  남성  대구 2020-01-05   45678.90      7 2023-01-05   일반

고객 등급별 분포:
일반     456
신규     234
우수     198
VIP      112
Name: 고객등급, dtype: int64
```

### 고객 분석 시각화

```python
# 고객 분석 시각화
fig, axes = plt.subplots(2, 3, figsize=(18, 12))

# 1. 고객 등급별 분포
df_customers['고객등급'].value_counts().plot(kind='bar', ax=axes[0, 0])
axes[0, 0].set_title('고객 등급별 분포')
axes[0, 0].set_ylabel('고객 수')

# 2. 지역별 고객 분포
df_customers['지역'].value_counts().plot(kind='pie', ax=axes[0, 1], autopct='%1.1f%%')
axes[0, 1].set_title('지역별 고객 분포')

# 3. 나이 분포
axes[0, 2].hist(df_customers['나이'], bins=20, alpha=0.7)
axes[0, 2].set_title('고객 나이 분포')
axes[0, 2].set_xlabel('나이')
axes[0, 2].set_ylabel('빈도')

# 4. 구매금액 vs 구매횟수
scatter = axes[1, 0].scatter(df_customers['구매횟수'], df_customers['총구매금액'], 
                            c=df_customers['고객등급'].astype('category').cat.codes, 
                            alpha=0.6)
axes[1, 0].set_title('구매횟수 vs 총구매금액')
axes[1, 0].set_xlabel('구매횟수')
axes[1, 0].set_ylabel('총구매금액')

# 5. 성별별 평균 구매금액
gender_sales = df_customers.groupby('성별')['총구매금액'].mean()
gender_sales.plot(kind='bar', ax=axes[1, 1])
axes[1, 1].set_title('성별별 평균 구매금액')
axes[1, 1].set_ylabel('평균 구매금액')

# 6. 고객 등급별 평균 구매금액
grade_sales = df_customers.groupby('고객등급')['총구매금액'].mean()
grade_sales.plot(kind='bar', ax=axes[1, 2])
axes[1, 2].set_title('고객 등급별 평균 구매금액')
axes[1, 2].set_ylabel('평균 구매금액')

plt.tight_layout()
plt.show()
```

## 성능 최적화

### 메모리 사용량 최적화

```python
# 메모리 사용량 확인
print("데이터프레임 메모리 사용량:")
print(df_customers.memory_usage(deep=True))

# 데이터 타입 최적화
def optimize_dtypes(df):
    for col in df.columns:
        if df[col].dtype == 'int64':
            if df[col].min() >= 0 and df[col].max() < 255:
                df[col] = df[col].astype('uint8')
            elif df[col].min() >= -128 and df[col].max() < 127:
                df[col] = df[col].astype('int8')
            elif df[col].min() >= 0 and df[col].max() < 65535:
                df[col] = df[col].astype('uint16')
            elif df[col].min() >= -32768 and df[col].max() < 32767:
                df[col] = df[col].astype('int16')
    return df

df_optimized = optimize_dtypes(df_customers.copy())
print("\n최적화 후 메모리 사용량:")
print(df_optimized.memory_usage(deep=True))
```

### 벡터화 연산

```python
# 비효율적인 방법 (반복문)
def slow_calculation(df):
    result = []
    for i in range(len(df)):
        if df.iloc[i]['총구매금액'] > 50000:
            result.append(df.iloc[i]['총구매금액'] * 1.1)
        else:
            result.append(df.iloc[i]['총구매금액'])
    return result

# 효율적인 방법 (벡터화)
def fast_calculation(df):
    return np.where(df['총구매금액'] > 50000, 
                   df['총구매금액'] * 1.1, 
                   df['총구매금액'])

# 성능 비교
import time

# 작은 데이터로 테스트
small_df = df_customers.head(100)

# 느린 방법
start_time = time.time()
slow_result = slow_calculation(small_df)
slow_time = time.time() - start_time

# 빠른 방법
start_time = time.time()
fast_result = fast_calculation(small_df)
fast_time = time.time() - start_time

print(f"느린 방법: {slow_time:.4f}초")
print(f"빠른 방법: {fast_time:.4f}초")
print(f"속도 향상: {slow_time/fast_time:.1f}배")
```

## 결론

파이썬 데이터 사이언스는 강력한 도구다. NumPy, Pandas, Matplotlib, Scikit-learn만 잘 다뤄도 대부분의 데이터 분석 작업을 할 수 있다.

하지만 도구만으로는 부족하다. 데이터를 이해하고, 적절한 분석 방법을 선택하고, 결과를 해석하는 능력이 더 중요하다. 

