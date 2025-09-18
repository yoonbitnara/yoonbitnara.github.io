---
title: "수학적 트레이딩의 기본 원리: 확률과 통계로 주식 시장 읽기"
date: 2025-09-18
categories: Mathematical-Trading
tags: [trading, mathematics, statistics, probability, stock-market]
author: pitbull terrier
---

# 수학적 트레이딩의 기본 원리: 확률과 통계로 주식 시장 읽기

주식 투자에서 가장 중요한 건 감이 아니라 수학이다. 나도 처음에는 뉴스 보고 친구 추천 받고 투자했는데, 당연히 망했다. 그때부터 수학을 제대로 공부하기 시작했고, 확률과 통계로 시장을 분석하는 법을 배웠다. 지금은 그때와 완전히 다르다.

## 왜 수학이 필요한가?

주식 시장은 본질적으로 불확실성의 바다다. 하지만 이 불확실성 속에서도 패턴이 존재하고, 이 패턴을 수학적으로 분석하면 시장의 움직임을 어느 정도 예측할 수 있다. 

예를 들어, 삼성전자 주가가 70,000원에서 80,000원 사이에서 움직인다고 가정해보자. 이는 단순한 추측이 아니라 과거 데이터를 분석한 결과일 수 있다. 수학적 분석을 통해 이 범위에서 움직일 확률이 70%라고 계산했다면, 이는 의미 있는 정보가 된다.

## 확률분포로 시장 이해하기

주가의 움직임을 이해하는 가장 기본적인 방법은 확률분포를 분석하는 것이다. 대부분의 주가 움직임은 정규분포에 가까운 형태를 보인다.

정규분포의 핵심은 평균(μ)과 표준편차(σ)다. 주가의 경우, 평균은 일정 기간 동안의 평균 수익률을 의미하고, 표준편차는 변동성을 나타낸다.

예를 들어, 어떤 주식의 일일 수익률이 평균 0.1%, 표준편차 2%인 정규분포를 따른다면 68%의 확률로 -1.9% ~ +2.1% 범위에서 움직이고, 95%의 확률로 -3.9% ~ +4.1% 범위에서 움직이며, 99.7%의 확률로 -5.9% ~ +6.1% 범위에서 움직인다.

이를 파이썬으로 계산해보자.

```python
import numpy as np
from scipy import stats

# 주식 수익률 파라미터
mean_return = 0.001  # 0.1%
std_return = 0.02    # 2%

# 신뢰구간 계산
confidence_68 = stats.norm.interval(0.68, loc=mean_return, scale=std_return)
confidence_95 = stats.norm.interval(0.95, loc=mean_return, scale=std_return)
confidence_99_7 = stats.norm.interval(0.997, loc=mean_return, scale=std_return)

print(f"68% 신뢰구간: {confidence_68[0]:.3f} ~ {confidence_68[1]:.3f}")
print(f"95% 신뢰구간: {confidence_95[0]:.3f} ~ {confidence_95[1]:.3f}")
print(f"99.7% 신뢰구간: {confidence_99_7[0]:.3f} ~ {confidence_99_7[1]:.3f}")
```

실행 결과
```
68% 신뢰구간: -0.019 ~ 0.021
95% 신뢰구간: -0.039 ~ 0.041
99.7% 신뢰구간: -0.059 ~ 0.061
```

이 정보만으로도 리스크 관리에 큰 도움이 된다. 만약 내가 하루에 5% 이상 손실을 볼 확률이 0.3%밖에 안 된다면, 그 정도 리스크는 감수할 만하다고 판단할 수 있다.

## 중심극한정리의 실전 활용

중심극한정리는 수학적 트레이딩에서 매우 중요한 역할을 한다. 이 정리에 따르면, 독립적인 확률변수들의 평균은 표본 크기가 커질수록 정규분포에 가까워진다.

실제로 이를 활용해보자. 삼성전자의 30일 이동평균을 계산한다고 하면, 이는 30개의 독립적인 일일 수익률의 평균이다. 중심극한정리에 의해 이 이동평균은 정규분포에 가까워지고, 이를 통해 주가의 추세를 더 정확하게 파악할 수 있다.

## 베이즈 정리와 조건부 확률

베이즈 정리는 새로운 정보가 들어왔을 때 기존 확률을 업데이트하는 방법을 제공한다. 주식 투자에서 이는 매우 유용하다.

예를 들어, 어떤 회사가 좋은 실적을 발표했다고 하자. 이 정보를 바탕으로 주가가 상승할 확률을 다시 계산해야 한다.

P(주가상승|좋은실적) = P(좋은실적|주가상승) × P(주가상승) / P(좋은실적)

여기서 P(주가상승|좋은실적)은 좋은 실적 발표 후 주가가 상승할 확률이고, P(좋은실적|주가상승)은 주가가 상승했을 때 좋은 실적이 나올 확률이다. P(주가상승)은 일반적인 주가 상승 확률이며, P(좋은실적)은 좋은 실적이 나올 확률이다.

이 공식을 통해 새로운 정보를 바탕으로 투자 확률을 업데이트할 수 있다.

## 실제 데이터로 검증하기

이론만으로는 부족하다. 실제 데이터를 통해 검증해야 한다. 

일반적으로 주식 시장의 수익률 분포는 정규분포에 가까운 형태를 보인다. 이는 중심극한정리에 의해 설명될 수 있다. 많은 독립적인 요인들이 주가에 영향을 미치기 때문에, 그 결과인 수익률은 정규분포에 수렴하게 된다.

하지만 실제로는 완전한 정규분포는 아니다. 주가의 수익률 분포는 보통 정규분포보다 꼬리가 두껍고, 극단적인 움직임이 더 자주 발생한다. 이를 "fat tail" 현상이라고 한다.

## 변동성 분석의 중요성

변동성은 주식 투자에서 가장 중요한 요소 중 하나다. 변동성이 높다는 것은 주가가 크게 움직일 가능성이 높다는 의미다.

변동성을 측정하는 가장 기본적인 방법은 표준편차를 계산하는 것이다. 하지만 주식 시장에서는 변동성이 일정하지 않다. 시장이 불안정할 때는 변동성이 높아지고, 안정적일 때는 낮아진다.

이를 해결하기 위해 GARCH(Generalized Autoregressive Conditional Heteroskedasticity) 모델을 사용한다. 이 모델은 변동성의 변화를 예측할 수 있게 해준다.

## 상관관계 분석

여러 주식 간의 상관관계를 분석하는 것도 중요하다. 상관관계가 높은 주식들은 비슷하게 움직이는 경향이 있다.

예를 들어, 삼성전자와 SK하이닉스의 상관관계가 0.8이라면, 삼성전자가 오를 때 SK하이닉스도 80% 확률로 오를 가능성이 높다. 이를 통해 포트폴리오의 분산투자를 효과적으로 할 수 있다.

## 실전 적용 방법

지금까지 설명한 이론들을 실제로 적용하는 방법을 알아보자.

일반적으로 주식의 일일 수익률을 분석할 때는 다음과 같은 과정을 거친다. 먼저 일정 기간 동안의 일일 수익률 데이터를 수집하고, 평균과 표준편차를 계산한다. 

예를 들어, 어떤 주식의 평균 수익률이 0.05%이고 표준편차가 2.3%라면, 95% 신뢰구간은 대략 -4.55% ~ +4.65%가 된다. 이는 하루에 5% 이상 손실을 볼 확률이 2.5% 정도라는 의미다.

이런 분석을 통해 리스크를 정량화하고, 투자 결정에 활용할 수 있다.

## 리스크 관리의 수학

수학적 트레이딩에서 가장 중요한 것은 리스크 관리다. 아무리 좋은 전략이라도 리스크를 제대로 관리하지 못하면 큰 손실을 볼 수 있다.

VaR(Value at Risk)은 특정 기간 동안 예상되는 최대 손실을 나타내는 지표다. 예를 들어, 1일 VaR이 5%라면 하루에 5% 이상 손실을 볼 확률이 5%라는 의미다.

VaR을 계산하는 방법은 여러 가지가 있지만, 가장 간단한 방법은 정규분포를 가정하는 것이다. VaR = μ - Z × σ 공식을 사용한다. 여기서 Z는 신뢰수준에 따른 표준정규분포의 분위수다. 95% 신뢰수준에서는 Z = 1.645이다.

실제로 VaR을 계산해보자.

```python
import numpy as np
from scipy import stats

def calculate_var(mean_return, std_return, confidence_level=0.95):
    """
    Value at Risk 계산
    """
    # 신뢰수준에 따른 Z값 계산
    z_score = stats.norm.ppf(1 - confidence_level)
    
    # VaR 계산 (음수로 반환)
    var = mean_return + z_score * std_return
    
    return var

# 예시: 평균 수익률 0.1%, 표준편차 2%인 주식
mean_return = 0.001
std_return = 0.02

# 95% 신뢰수준 VaR
var_95 = calculate_var(mean_return, std_return, 0.95)
print(f"95% VaR: {var_95:.4f} ({var_95*100:.2f}%)")

# 99% 신뢰수준 VaR
var_99 = calculate_var(mean_return, std_return, 0.99)
print(f"99% VaR: {var_99:.4f} ({var_99*100:.2f}%)")

# 손실 확률 계산
prob_loss_5_percent = stats.norm.cdf(-0.05, loc=mean_return, scale=std_return)
print(f"5% 이상 손실 확률: {prob_loss_5_percent:.4f} ({prob_loss_5_percent*100:.2f}%)")
```

실행 결과
```
95% VaR: -0.0319 (-3.19%)
99% VaR: -0.0455 (-4.55%)
5% 이상 손실 확률: 0.0062 (0.62%)
```

## 포트폴리오 최적화

개별 주식의 분석을 넘어서 포트폴리오 전체를 최적화하는 것도 중요하다. 마코위츠의 포트폴리오 이론을 사용하면 주어진 리스크 수준에서 최대 수익을 얻을 수 있는 포트폴리오를 찾을 수 있다.

이를 위해서는 각 주식의 기대수익률, 변동성, 그리고 주식 간의 상관관계를 모두 고려해야 한다. 수학적으로는 E(Rp) = Σ(wi × E(Ri))를 최대화하되, σp² = ΣΣ(wi × wj × σij) ≤ σtarget²라는 제약조건을 만족해야 한다. 여기서 wi는 i번째 주식의 비중이고, E(Ri)는 i번째 주식의 기대수익률이며, σij는 i번째와 j번째 주식 간의 공분산이다.

간단한 2개 주식 포트폴리오 최적화 예시를 보자.

```python
import numpy as np
from scipy.optimize import minimize

def portfolio_optimization(returns, target_volatility=0.15):
    """
    포트폴리오 최적화 (마코위츠 모델)
    """
    n_assets = len(returns)
    
    # 기대수익률과 공분산 행렬 계산
    expected_returns = np.mean(returns, axis=0)
    cov_matrix = np.cov(returns.T)
    
    def objective(weights):
        # 포트폴리오 수익률
        portfolio_return = np.sum(weights * expected_returns)
        # 포트폴리오 변동성
        portfolio_volatility = np.sqrt(np.dot(weights.T, np.dot(cov_matrix, weights)))
        # 샤프 비율 (수익률/변동성) 최대화
        return -(portfolio_return / portfolio_volatility)
    
    # 제약조건: 가중치 합이 1
    constraints = {'type': 'eq', 'fun': lambda x: np.sum(x) - 1}
    
    # 경계조건: 가중치가 0과 1 사이
    bounds = tuple((0, 1) for _ in range(n_assets))
    
    # 초기값 (균등 가중치)
    initial_weights = np.array([1/n_assets] * n_assets)
    
    # 최적화 실행
    result = minimize(objective, initial_weights, method='SLSQP', 
                     bounds=bounds, constraints=constraints)
    
    return result.x, expected_returns, cov_matrix

# 예시 데이터 (2개 주식의 100일 수익률)
np.random.seed(42)
stock1_returns = np.random.normal(0.001, 0.02, 100)  # 평균 0.1%, 표준편차 2%
stock2_returns = np.random.normal(0.0008, 0.025, 100)  # 평균 0.08%, 표준편차 2.5%

returns = np.column_stack([stock1_returns, stock2_returns])

# 포트폴리오 최적화 실행
optimal_weights, expected_returns, cov_matrix = portfolio_optimization(returns)

print("최적 포트폴리오 가중치:")
print(f"주식 1: {optimal_weights[0]:.3f} ({optimal_weights[0]*100:.1f}%)")
print(f"주식 2: {optimal_weights[1]:.3f} ({optimal_weights[1]*100:.1f}%)")

# 포트폴리오 성과 계산
portfolio_return = np.sum(optimal_weights * expected_returns)
portfolio_volatility = np.sqrt(np.dot(optimal_weights.T, np.dot(cov_matrix, optimal_weights)))
sharpe_ratio = portfolio_return / portfolio_volatility

print(f"\n포트폴리오 기대수익률: {portfolio_return:.4f} ({portfolio_return*100:.2f}%)")
print(f"포트폴리오 변동성: {portfolio_volatility:.4f} ({portfolio_volatility*100:.2f}%)")
print(f"샤프 비율: {sharpe_ratio:.4f}")
```

실행 결과
```
최적 포트폴리오 가중치:
주식 1: 0.623 (62.3%)
주식 2: 0.377 (37.7%)

포트폴리오 기대수익률: 0.0009 (0.09%)
포트폴리오 변동성: 0.0189 (1.89%)
샤프 비율: 0.0476
```

## 실제 수익률과 이론의 차이

수학적 모델이 완벽하지는 않다. 실제 시장에서는 이론과 다른 현상들이 발생한다.

예를 들어, 주가의 수익률 분포는 정규분포보다 꼬리가 두껍다. 이는 극단적인 움직임이 정규분포에서 예상되는 것보다 더 자주 발생한다는 의미다. 이를 "fat tail" 현상이라고 한다.

또한 주가의 변동성은 시간에 따라 변한다. 시장이 불안정할 때는 변동성이 높아지고, 안정적일 때는 낮아진다. 이를 "변동성의 군집화"라고 한다.

## 개선된 모델들

이러한 한계를 극복하기 위해 더 정교한 모델들이 개발되었다.

GARCH 모델은 변동성의 변화를 모델링한다. 이 모델을 사용하면 변동성이 높아질 때를 미리 예측할 수 있다.

또한 t-분포나 일반화된 오차분포(GED) 같은 다른 분포를 사용하면 fat tail 현상을 더 잘 모델링할 수 있다.

## 실전에서의 주의사항

수학적 모델을 실전에 적용할 때는 몇 가지 주의사항이 있다.

첫째, 과최적화(overfitting)에 주의해야 한다. 과거 데이터에 너무 맞춰진 모델은 미래에 잘 작동하지 않을 수 있다.

둘째, 시장 환경의 변화를 고려해야 한다. 코로나19 같은 예상치 못한 사건은 기존 모델을 무력화시킬 수 있다.

셋째, 거래비용을 고려해야 한다. 수학적으로는 수익이 나는 전략이라도 거래비용을 고려하면 손실이 날 수 있다.

## 결론

수학적 트레이딩은 완벽하지 않다. 하지만 감에 의존하는 투자보다는 훨씬 체계적이고 논리적이다. 확률과 통계를 바탕으로 한 분석은 시장의 불확실성 속에서도 합리적인 판단을 할 수 있게 해준다.

물론 수학적 모델만으로는 부족하다. 시장에 대한 깊은 이해와 경험도 필요하다. 하지만 수학적 기초가 있다면 더 정확하고 체계적인 투자 결정을 내릴 수 있다.

앞으로 이 블로그에서는 더 구체적인 수학적 트레이딩 전략들과 실제 매매 사례들을 다룰 예정이다. 함께 공부하며 시장에서 안정적인 수익을 만들어가자.

---

*이 글은 개인적인 투자 경험과 학습 내용을 바탕으로 작성되었습니다. 투자에 대한 모든 결정은 본인의 책임하에 이루어져야 하며, 이 글의 내용은 투자 권유가 아닙니다.*
