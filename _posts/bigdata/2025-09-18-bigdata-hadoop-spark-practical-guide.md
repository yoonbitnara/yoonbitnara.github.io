---
title: "하둡과 스파크로 시작하는 데이터 엔지니어링"
date: 2025-09-18
categories: Bigdata
tags: [bigdata, hadoop, spark, data-engineering, python, scala]
author: pitbull terrier
---

# 빅데이터 실전 가이드: 하둡과 스파크로 시작하는 데이터 엔지니어링

빅데이터라는 말을 처음 들었을 때는 그냥 "큰 데이터" 정도로만 생각했다. 하지만 실제로 하둡과 스파크를 다뤄보니 완전히 다른 세계였다. 단순히 데이터가 크다는 게 아니라, 처리 방식 자체가 달라야 한다는 걸 깨달았다.

## 빅데이터가 뭔가요?

빅데이터는 전통적인 데이터베이스로는 처리하기 어려운 규모의 데이터를 말한다. 하지만 단순히 크기만의 문제가 아니다.

### 빅데이터의 3V (그리고 더 많은 V들)

**Volume (크기)**
- 테라바이트, 페타바이트 단위의 데이터
- 전통적인 DB로는 처리 불가능

**Velocity (속도)**
- 실시간으로 생성되는 데이터
- 스트리밍 처리 필요

**Variety (다양성)**
- 구조화, 반구조화, 비구조화 데이터
- 텍스트, 이미지, 비디오 등 다양한 형태

**Veracity (정확성)**
- 데이터의 품질과 신뢰성
- 노이즈가 많고 불완전한 데이터

**Value (가치)**
- 데이터에서 의미 있는 인사이트 추출
- 비즈니스 가치 창출

## 하둡 생태계 이해하기

하둡은 빅데이터 처리의 핵심이다. 분산 파일 시스템과 분산 처리 프레임워크를 제공한다.

### HDFS (Hadoop Distributed File System)

대용량 파일을 여러 서버에 분산 저장하는 시스템이다.

**HDFS의 특징:**
- 블록 단위로 파일 저장 (기본 128MB)
- 3개 복제본으로 안정성 보장
- 마스터-슬레이브 구조

**HDFS 명령어:**
```bash
# 파일 업로드
hdfs dfs -put localfile.txt /user/data/

# 파일 다운로드
hdfs dfs -get /user/data/remotefile.txt ./

# 디렉토리 생성
hdfs dfs -mkdir /user/data/newdir

# 파일 목록 보기
hdfs dfs -ls /user/data/

# 파일 삭제
hdfs dfs -rm /user/data/oldfile.txt

# 파일 복사
hdfs dfs -cp /user/data/source.txt /user/data/dest.txt
```

### MapReduce

대용량 데이터를 분산 처리하는 프로그래밍 모델이다.

**MapReduce의 동작 원리:**
1. **Map 단계**: 데이터를 키-값 쌍으로 변환
2. **Shuffle 단계**: 같은 키끼리 그룹화
3. **Reduce 단계**: 그룹화된 데이터를 집계

**간단한 MapReduce 예제 (Word Count):**

```java
public class WordCount {
    
    public static class TokenizerMapper 
        extends Mapper<Object, Text, Text, IntWritable> {
        
        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();
        
        public void map(Object key, Text value, Context context) 
            throws IOException, InterruptedException {
            
            StringTokenizer itr = new StringTokenizer(value.toString());
            while (itr.hasMoreTokens()) {
                word.set(itr.nextToken());
                context.write(word, one);
            }
        }
    }
    
    public static class IntSumReducer 
        extends Reducer<Text, IntWritable, Text, IntWritable> {
        
        private IntWritable result = new IntWritable();
        
        public void reduce(Text key, Iterable<IntWritable> values, 
                          Context context) throws IOException, InterruptedException {
            
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }
}
```

## 아파치 스파크로 현대적 빅데이터 처리

스파크는 하둡보다 훨씬 빠르고 사용하기 쉽다. 메모리 기반 처리로 성능이 크게 향상되었다.

### 스파크의 핵심 개념

**RDD (Resilient Distributed Dataset)**
- 분산 메모리 기반 데이터 구조
- 불변성과 복원력 보장
- 지연 실행 (Lazy Evaluation)

**DataFrame**
- 구조화된 데이터를 다루는 API
- SQL과 유사한 인터페이스
- 최적화된 실행 계획

**Dataset**
- 타입 안전성을 제공하는 API
- 컴파일 타임 에러 검출

### 스파크 설치 및 설정

**로컬 환경에서 스파크 실행:**

```bash
# 스파크 다운로드
wget https://archive.apache.org/dist/spark/spark-3.4.0/spark-3.4.0-bin-hadoop3.tgz
tar -xzf spark-3.4.0-bin-hadoop3.tgz
cd spark-3.4.0-bin-hadoop3

# 스파크 실행
./bin/spark-shell
```

**Python에서 스파크 사용:**

```python
from pyspark.sql import SparkSession

# 스파크 세션 생성
spark = SparkSession.builder \
    .appName("BigDataExample") \
    .getOrCreate()

# 데이터 읽기
df = spark.read.csv("data.csv", header=True, inferSchema=True)

# 데이터 보기
df.show()

# 스키마 확인
df.printSchema()

# 기본 통계
df.describe().show()
```

### 스파크 SQL로 데이터 분석

스파크 SQL은 구조화된 데이터를 SQL로 분석할 수 있게 해준다.

```python
# 테이블로 등록
df.createOrReplaceTempView("sales")

# SQL 쿼리 실행
result = spark.sql("""
    SELECT 
        product_category,
        COUNT(*) as total_sales,
        AVG(price) as avg_price,
        SUM(quantity) as total_quantity
    FROM sales 
    WHERE date >= '2023-01-01'
    GROUP BY product_category
    ORDER BY total_sales DESC
""")

result.show()
```

### 스파크 스트리밍

실시간 데이터 처리를 위한 스트리밍 API다.

```python
from pyspark.streaming import StreamingContext

# 스트리밍 컨텍스트 생성
ssc = StreamingContext(spark.sparkContext, 1)  # 1초 배치

# 소켓에서 데이터 읽기
lines = ssc.socketTextStream("localhost", 9999)

# 단어 개수 계산
words = lines.flatMap(lambda line: line.split(" "))
word_counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)

# 결과 출력
word_counts.pprint()

# 스트리밍 시작
ssc.start()
ssc.awaitTermination()
```

## 실제 프로젝트: 웹 로그 분석

실제 웹 서버 로그를 분석하는 프로젝트를 만들어보자.

### 1. 데이터 준비

웹 로그 데이터를 생성한다.

```python
import random
from datetime import datetime, timedelta

def generate_web_log():
    """웹 로그 데이터 생성"""
    ips = ["192.168.1.1", "192.168.1.2", "10.0.0.1", "10.0.0.2"]
    pages = ["/home", "/about", "/products", "/contact", "/login"]
    methods = ["GET", "POST", "PUT", "DELETE"]
    status_codes = [200, 301, 404, 500]
    
    log_entry = {
        "ip": random.choice(ips),
        "timestamp": datetime.now() - timedelta(minutes=random.randint(0, 1440)),
        "method": random.choice(methods),
        "page": random.choice(pages),
        "status": random.choice(status_codes),
        "response_time": random.randint(10, 2000)
    }
    
    return log_entry

# 로그 데이터 생성
logs = [generate_web_log() for _ in range(1000)]
```

### 2. 스파크로 데이터 처리

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

# 스파크 세션 생성
spark = SparkSession.builder \
    .appName("WebLogAnalysis") \
    .getOrCreate()

# 로그 데이터를 DataFrame으로 변환
df = spark.createDataFrame(logs)

# 데이터 타입 변환
df = df.withColumn("timestamp", col("timestamp").cast("timestamp"))

# 기본 통계
print("=== 기본 통계 ===")
df.describe().show()

# 페이지별 접근 횟수
print("=== 페이지별 접근 횟수 ===")
page_views = df.groupBy("page").count().orderBy(desc("count"))
page_views.show()

# 시간대별 접근 패턴
print("=== 시간대별 접근 패턴 ===")
hourly_views = df.withColumn("hour", hour("timestamp")) \
    .groupBy("hour").count().orderBy("hour")
hourly_views.show()

# IP별 접근 통계
print("=== IP별 접근 통계 ===")
ip_stats = df.groupBy("ip") \
    .agg(
        count("*").alias("total_requests"),
        avg("response_time").alias("avg_response_time"),
        countDistinct("page").alias("unique_pages")
    ).orderBy(desc("total_requests"))
ip_stats.show()

# 에러 페이지 분석
print("=== 에러 페이지 분석 ===")
error_pages = df.filter(col("status") >= 400) \
    .groupBy("page", "status").count() \
    .orderBy(desc("count"))
error_pages.show()
```

### 3. 고급 분석

**상관관계 분석:**

```python
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.stat import Correlation
from pyspark.ml import Pipeline

# 수치형 컬럼만 선택
numeric_cols = ["response_time", "status"]
assembler = VectorAssembler(inputCols=numeric_cols, outputCol="features")

# 상관관계 계산
pipeline = Pipeline(stages=[assembler])
model = pipeline.fit(df)
result = model.transform(df)

# 상관관계 행렬
correlation_matrix = Correlation.corr(result, "features").head()[0]
print("상관관계 행렬:")
print(correlation_matrix.toArray())
```

**실시간 모니터링:**

```python
from pyspark.sql.functions import window

# 5분 윈도우로 집계
windowed_counts = df \
    .withWatermark("timestamp", "10 minutes") \
    .groupBy(
        window(col("timestamp"), "5 minutes"),
        col("page")
    ).count() \
    .orderBy("window")

print("=== 5분 윈도우별 페이지 접근 ===")
windowed_counts.show(truncate=False)
```

## 성능 최적화 팁

### 1. 파티셔닝 전략

데이터를 적절히 파티셔닝하면 성능이 크게 향상된다.

```python
# 날짜별로 파티셔닝
df.write \
    .partitionBy("date") \
    .parquet("hdfs://namenode:9000/data/logs/")

# 읽을 때도 파티션 프루닝
df = spark.read.parquet("hdfs://namenode:9000/data/logs/") \
    .filter(col("date") == "2023-09-18")
```

### 2. 캐싱 활용

자주 사용하는 데이터는 메모리에 캐시하자.

```python
# 데이터 캐시
df.cache()

# 또는 persist 사용
df.persist(StorageLevel.MEMORY_AND_DISK_SER)

# 캐시된 데이터 사용
df.count()  # 첫 번째 액션에서 캐시됨
df.show()   # 캐시된 데이터 사용
```

### 3. 브로드캐스트 변수

작은 데이터를 모든 노드에 복사할 때 사용한다.

```python
# 작은 룩업 테이블
lookup_table = {"page1": "category1", "page2": "category2"}

# 브로드캐스트 변수로 등록
broadcast_var = spark.sparkContext.broadcast(lookup_table)

# 사용
def lookup_category(page):
    return broadcast_var.value.get(page, "unknown")

df.withColumn("category", udf(lookup_category)(col("page")))
```

## 모니터링과 디버깅

### 1. 스파크 UI 활용

스파크 UI에서 작업 상태를 모니터링할 수 있다.

- **Jobs**: 실행된 작업 목록
- **Stages**: 각 스테이지의 실행 시간
- **Storage**: 캐시된 데이터 정보
- **Environment**: 설정 정보

### 2. 로그 분석

```python
# 로그 레벨 설정
spark.sparkContext.setLogLevel("WARN")

# 커스텀 로깅
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def process_data(df):
    logger.info(f"Processing {df.count()} records")
    # 데이터 처리 로직
    return result
```

### 3. 성능 프로파일링

```python
# 실행 계획 확인
df.explain()

# 실행 계획 (코스트 포함)
df.explain(True)

# 스테이지별 실행 시간
df.count()  # 실행 후 UI에서 확인
```

## 실제 운영 환경 고려사항

### 1. 클러스터 관리

**YARN 설정:**
```xml
<!-- yarn-site.xml -->
<property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>8192</value>
</property>
<property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>8192</value>
</property>
```

**스파크 설정:**
```bash
# 스파크 실행 시 설정
spark-submit \
    --master yarn \
    --deploy-mode cluster \
    --num-executors 10 \
    --executor-memory 4g \
    --executor-cores 2 \
    --driver-memory 2g \
    my_application.py
```

### 2. 데이터 품질 관리

```python
# 데이터 검증
def validate_data(df):
    # null 값 체크
    null_counts = df.select([count(when(col(c).isNull(), c)).alias(c) for c in df.columns])
    null_counts.show()
    
    # 중복 데이터 체크
    duplicate_count = df.count() - df.dropDuplicates().count()
    print(f"중복 데이터: {duplicate_count}개")
    
    # 데이터 타입 검증
    df.printSchema()

# 데이터 클리닝
def clean_data(df):
    # null 값 제거
    df_cleaned = df.dropna()
    
    # 이상치 제거 (IQR 방법)
    numeric_cols = ["response_time"]
    for col_name in numeric_cols:
        Q1 = df_cleaned.approxQuantile(col_name, [0.25], 0.0)[0]
        Q3 = df_cleaned.approxQuantile(col_name, [0.75], 0.0)[0]
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR
        
        df_cleaned = df_cleaned.filter(
            (col(col_name) >= lower_bound) & 
            (col(col_name) <= upper_bound)
        )
    
    return df_cleaned
```

### 3. 에러 처리

```python
def robust_data_processing(df):
    try:
        # 데이터 처리
        result = df.filter(col("status") == 200) \
            .groupBy("page").count() \
            .orderBy(desc("count"))
        
        return result
        
    except Exception as e:
        logger.error(f"데이터 처리 중 오류 발생: {str(e)}")
        # 에러 발생 시 빈 DataFrame 반환
        return spark.createDataFrame([], StructType([]))
```

## 결론

빅데이터는 단순히 기술이 아니라 사고방식의 전환이다. 전통적인 데이터 처리 방식으로는 해결할 수 없는 문제들을 새로운 도구와 방법론으로 접근해야 한다.

하둡과 스파크는 그 시작일 뿐이다. 실제로는 더 많은 도구들과 기술들이 필요하다. 하지만 기본기를 탄탄히 다지면 어떤 새로운 기술이 나와도 쉽게 적응할 수 있다.

---

*<span style="color: red;">이 글은 개인적인 빅데이터 프로젝트 경험과 학습 내용을 바탕으로 작성되었습니다. 실제 운영 환경에서는 더 많은 고려사항이 있으니 신중하게 접근하시기 바랍니다.</span>*
