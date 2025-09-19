---
title: "Spring Boot 성능 최적화에 관하여"
tags: SpringBoot, 성능최적화, 실무
date: "2025.09.19"
categories: 
    - Spring
---

# Spring Boot 성능 최적화에 관하여

Spring Boot 애플리케이션을 개발하다 보면 성능 문제에 직면할 때가 있다. 처음에는 잘 동작하던 코드가 데이터가 늘어나고 사용자가 많아지면서 느려지기 시작한다.

성능 최적화는 개발 과정에서 계속 고려해야 할 중요한 요소다. 오늘은 실제 프로젝트에서 자주 마주치는 성능 문제들과 그 해결책들을 정리해보겠다.

## 1. 데이터베이스 연결 풀 최적화

### 기본 설정의 문제점

Spring Boot의 기본 HikariCP 설정은 개발 환경에 적합하다. 하지만 실제 운영 환경에서는 부족한 경우가 많다.

```yaml
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20          # 기본값: 10
      minimum-idle: 5                # 기본값: 10
      connection-timeout: 30000      # 30초
      idle-timeout: 600000           # 10분
      max-lifetime: 1800000          # 30분
      leak-detection-threshold: 60000 # 1분
```

### 연결 풀 크기 계산

적절한 연결 풀 크기를 계산하는 공식이 있다:

```
최적 풀 크기 = (CPU 코어 수 × 2) + 디스크 수
```

예를 들어 4코어 CPU, 1개 디스크인 경우: (4 × 2) + 1 = 9개

하지만 이는 시작점일 뿐이고, 실제 트래픽에 따라 조정해야 한다.

### 모니터링 방법

```java
@Component
public class HikariMonitor {
    
    @Autowired
    private DataSource dataSource;
    
    @Scheduled(fixedRate = 30000) // 30초마다
    public void monitorConnectionPool() {
        if (dataSource instanceof HikariDataSource) {
            HikariDataSource hikariDataSource = (HikariDataSource) dataSource;
            HikariPoolMXBean poolBean = hikariDataSource.getHikariPoolMXBean();
            
            log.info("Active connections: {}", poolBean.getActiveConnections());
            log.info("Idle connections: {}", poolBean.getIdleConnections());
            log.info("Total connections: {}", poolBean.getTotalConnections());
        }
    }
}
```

## 2. JPA 성능 최적화

### N+1 문제 해결

가장 흔한 JPA 성능 문제 중 하나다.

**문제가 있는 코드:**
```java
@Entity
public class Order {
    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<OrderItem> orderItems;
}

// 서비스에서
public List<Order> getOrders() {
    List<Order> orders = orderRepository.findAll();
    for (Order order : orders) {
        order.getOrderItems().size(); // N+1 문제 발생
    }
    return orders;
}
```

**해결 방법 1: JOIN FETCH 사용**
```java
@Query("SELECT o FROM Order o JOIN FETCH o.orderItems")
List<Order> findAllWithOrderItems();
```

**해결 방법 2: @EntityGraph 사용**
```java
@EntityGraph(attributePaths = {"orderItems"})
@Query("SELECT o FROM Order o")
List<Order> findAllWithOrderItems();
```

### 배치 사이즈 최적화

```java
@Entity
public class Order {
    @BatchSize(size = 10)
    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<OrderItem> orderItems;
}
```

### 쿼리 최적화

**불필요한 SELECT 방지:**
```java
// 나쁜 예
@Query("SELECT u FROM User u")
List<User> findAllUsers();

// 좋은 예
@Query("SELECT u.id, u.name FROM User u")
List<Object[]> findUserBasicInfo();
```

## 3. 캐싱 전략

### Spring Cache 활용

```java
@Service
public class ProductService {
    
    @Cacheable(value = "products", key = "#id")
    public Product getProduct(Long id) {
        return productRepository.findById(id).orElse(null);
    }
    
    @CacheEvict(value = "products", key = "#product.id")
    public Product updateProduct(Product product) {
        return productRepository.save(product);
    }
}
```

### Redis 캐시 설정

```yaml
spring:
  cache:
    type: redis
    redis:
      time-to-live: 600000 # 10분
  redis:
    host: localhost
    port: 6379
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
```

### 캐시 키 전략

```java
@Configuration
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
                
        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(config)
            .build();
    }
}
```

## 4. 비동기 처리

### @Async 활용

```java
@Service
public class EmailService {
    
    @Async("taskExecutor")
    public CompletableFuture<Void> sendEmail(String email, String content) {
        // 이메일 전송 로직
        return CompletableFuture.completedFuture(null);
    }
}

@Configuration
@EnableAsync
public class AsyncConfig {
    
    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.initialize();
        return executor;
    }
}
```

### CompletableFuture 활용

```java
@Service
public class OrderService {
    
    public OrderResponse processOrder(OrderRequest request) {
        CompletableFuture<User> userFuture = getUserAsync(request.getUserId());
        CompletableFuture<Product> productFuture = getProductAsync(request.getProductId());
        CompletableFuture<Inventory> inventoryFuture = checkInventoryAsync(request.getProductId());
        
        return CompletableFuture.allOf(userFuture, productFuture, inventoryFuture)
            .thenApply(v -> {
                User user = userFuture.join();
                Product product = productFuture.join();
                Inventory inventory = inventoryFuture.join();
                
                return new OrderResponse(user, product, inventory);
            }).join();
    }
}
```

## 5. 메모리 최적화

### JVM 옵션 설정

```bash
# 개발 환경
java -Xms512m -Xmx1024m -XX:+UseG1GC -jar app.jar

# 운영 환경
java -Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar app.jar
```

### 메모리 사용량 모니터링

```java
@Component
public class MemoryMonitor {
    
    @Scheduled(fixedRate = 60000) // 1분마다
    public void logMemoryUsage() {
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
        
        log.info("Used heap: {} MB", heapUsage.getUsed() / 1024 / 1024);
        log.info("Max heap: {} MB", heapUsage.getMax() / 1024 / 1024);
        log.info("Usage: {}%", (heapUsage.getUsed() * 100) / heapUsage.getMax());
    }
}
```

## 6. HTTP 클라이언트 최적화

### Connection Pool 설정

```java
@Configuration
public class HttpClientConfig {
    
    @Bean
    public RestTemplate restTemplate() {
        HttpComponentsClientHttpRequestFactory factory = 
            new HttpComponentsClientHttpRequestFactory();
        
        factory.setConnectTimeout(5000);
        factory.setReadTimeout(10000);
        
        // Connection Pool 설정
        PoolingHttpClientConnectionManager connectionManager = 
            new PoolingHttpClientConnectionManager();
        connectionManager.setMaxTotal(100);
        connectionManager.setDefaultMaxPerRoute(20);
        
        CloseableHttpClient httpClient = HttpClients.custom()
            .setConnectionManager(connectionManager)
            .build();
            
        factory.setHttpClient(httpClient);
        
        return new RestTemplate(factory);
    }
}
```

### WebClient 사용

```java
@Service
public class ExternalApiService {
    
    private final WebClient webClient;
    
    public ExternalApiService() {
        this.webClient = WebClient.builder()
            .baseUrl("https://api.example.com")
            .clientConnector(new ReactorClientHttpConnector(
                HttpClient.create()
                    .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 5000)
                    .responseTimeout(Duration.ofSeconds(10))
            ))
            .build();
    }
    
    public Mono<String> getData(String id) {
        return webClient.get()
            .uri("/data/{id}", id)
            .retrieve()
            .bodyToMono(String.class)
            .timeout(Duration.ofSeconds(5));
    }
}
```

## 7. 로깅 최적화

### 비동기 로깅 설정

```xml
<!-- logback-spring.xml -->
<configuration>
    <appender name="ASYNC_FILE" class="ch.qos.logback.classic.AsyncAppender">
        <appender-ref ref="FILE"/>
        <queueSize>1024</queueSize>
        <discardingThreshold>0</discardingThreshold>
        <includeCallerData>false</includeCallerData>
    </appender>
    
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/application.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/application.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="ASYNC_FILE"/>
    </root>
</configuration>
```

### 로그 레벨 최적화

```yaml
logging:
  level:
    com.example: INFO
    org.springframework.web: WARN
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

## 8. 성능 모니터링

### Actuator 설정

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
  metrics:
    export:
      prometheus:
        enabled: true
```

### 커스텀 메트릭 추가

```java
@Component
public class CustomMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Counter requestCounter;
    private final Timer requestTimer;
    
    public CustomMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.requestCounter = Counter.builder("custom.requests")
            .description("Number of custom requests")
            .register(meterRegistry);
        this.requestTimer = Timer.builder("custom.request.duration")
            .description("Duration of custom requests")
            .register(meterRegistry);
    }
    
    public void incrementRequestCounter() {
        requestCounter.increment();
    }
    
    public Timer.Sample startTimer() {
        return Timer.start(meterRegistry);
    }
}
```

## 9. 실제 최적화 사례

### 사례 1: 대용량 데이터 조회 최적화

**문제:** 10만 건의 주문 데이터를 조회할 때 30초 소요

**해결 과정:**
1. 페이징 적용 (한 번에 1000건씩)
2. 필요한 컬럼만 SELECT
3. 인덱스 추가
4. 캐싱 적용

**결과:** 30초 → 3초로 단축

```java
@Query(value = "SELECT o.id, o.orderDate, o.totalAmount FROM Order o WHERE o.status = :status",
       countQuery = "SELECT COUNT(o) FROM Order o WHERE o.status = :status")
Page<OrderSummary> findOrderSummariesByStatus(@Param("status") OrderStatus status, Pageable pageable);
```

### 사례 2: 외부 API 호출 최적화

**문제:** 외부 API 호출로 인한 응답 지연

**해결 방법:**
1. 병렬 처리 적용
2. 타임아웃 설정
3. 재시도 로직 추가
4. 캐싱 적용

```java
@Service
public class OptimizedApiService {
    
    @Cacheable(value = "externalData", key = "#id")
    public CompletableFuture<ApiResponse> getDataAsync(String id) {
        return webClient.get()
            .uri("/data/{id}", id)
            .retrieve()
            .bodyToMono(ApiResponse.class)
            .timeout(Duration.ofSeconds(5))
            .retry(3)
            .toFuture();
    }
}
```

## 10. 성능 테스트

### JMeter를 활용한 부하 테스트

```xml
<!-- JMeter 테스트 계획 예시 -->
<TestPlan>
  <ThreadGroup>
    <elementProp name="ThreadGroup.main_controller">
      <LoopController>
        <stringProp name="LoopController.loops">100</stringProp>
      </LoopController>
    </elementProp>
    <stringProp name="ThreadGroup.num_threads">50</stringProp>
    <stringProp name="ThreadGroup.ramp_time">10</stringProp>
  </ThreadGroup>
</TestPlan>
```

### 성능 기준 설정

```java
@Component
public class PerformanceTest {
    
    @Test
    public void testResponseTime() {
        long startTime = System.currentTimeMillis();
        
        // 테스트할 로직 실행
        String result = service.processRequest(request);
        
        long endTime = System.currentTimeMillis();
        long responseTime = endTime - startTime;
        
        assertThat(responseTime).isLessThan(1000); // 1초 이내
    }
}
```

## 마무리

성능 최적화는 한 번에 모든 것을 개선하려고 하지 말고, 단계적으로 접근하는 것이 좋다. 

먼저 성능 모니터링을 통해 병목 지점을 파악하고, 그 다음에 최적화 작업을 진행하는 것이 효율적이다.

**최적화 작업 순서:**
1. 성능 측정 및 병목 지점 파악
2. 데이터베이스 쿼리 최적화
3. 캐싱 전략 적용
4. 비동기 처리 도입
5. 메모리 및 JVM 튜닝
6. 지속적인 모니터링

모든 최적화는 실제 환경에서 테스트해보고, 개선 효과를 측정한 후에 적용하는 것이 중요하다.
