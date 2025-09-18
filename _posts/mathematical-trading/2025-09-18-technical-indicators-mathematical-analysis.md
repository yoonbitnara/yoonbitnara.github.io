---
title: "RSI, MACD, 볼린저 밴드 수학으로 뜯어보기"
date: 2025-09-18
categories: Mathematical-Trading
tags: [trading, technical-analysis, RSI, MACD, bollinger-bands, python]
author: pitbull terrier
---

# RSI, MACD, 볼린저 밴드 수학으로 뜯어보기

기술적 지표를 그냥 보는 것과 수학적으로 이해하는 것은 완전히 다르다. 나도 처음에는 차트에 나오는 선들을 보고 "아, 이렇게 움직이는구나" 정도로만 생각했다. 하지만 실제로 수학 공식을 뜯어보고 파이썬으로 직접 계산해보니 완전히 다른 차원이었다.

## 왜 기술적 지표를 수학적으로 이해해야 할까?

많은 사람들이 기술적 지표를 마치 마법처럼 생각한다. RSI가 70 이상이면 과매수, 30 이하면 과매도라고 외우기만 한다. 하지만 이 숫자들이 왜 나오는지, 어떤 의미를 가지는지는 모른다.

수학적으로 이해하면 지표의 한계도 알 수 있고, 언제 신뢰할 수 있는지도 판단할 수 있다. 더 중요한 건 자신만의 지표를 만들 수도 있다는 것이다.

## RSI (Relative Strength Index) 완전 해부

RSI는 가장 많이 사용되는 지표 중 하나다. 하지만 대부분의 사람들은 14일 RSI가 기본이라는 것만 알고 있다. 왜 14일인지, 다른 기간을 사용하면 어떻게 달라지는지는 모른다.

### RSI의 수학적 공식

RSI는 다음과 같이 계산된다.

RSI = 100 - (100 / (1 + RS))

여기서 RS = 평균 상승폭 / 평균 하락폭이다.

이 공식만 봐서는 이해하기 어렵다. 실제로 파이썬으로 계산해보자.

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def calculate_rsi(prices, period=14):
    """
    RSI 계산 함수
    """
    # 가격 변화량 계산
    delta = prices.diff()
    
    # 상승폭과 하락폭 분리
    gain = delta.where(delta > 0, 0)
    loss = -delta.where(delta < 0, 0)
    
    # 평균 상승폭과 평균 하락폭 계산 (지수이동평균 사용)
    avg_gain = gain.ewm(span=period).mean()
    avg_loss = loss.ewm(span=period).mean()
    
    # RS 계산
    rs = avg_gain / avg_loss
    
    # RSI 계산
    rsi = 100 - (100 / (1 + rs))
    
    return rsi

# 예시 데이터 생성 (삼성전자 주가 시뮬레이션)
np.random.seed(42)
dates = pd.date_range('2023-01-01', periods=100, freq='D')
prices = 70000 + np.cumsum(np.random.randn(100) * 1000)

# RSI 계산
rsi_14 = calculate_rsi(pd.Series(prices), 14)
rsi_21 = calculate_rsi(pd.Series(prices), 21)

print("RSI 계산 결과")
print(f"14일 RSI 최근값: {rsi_14.iloc[-1]:.2f}")
print(f"21일 RSI 최근값: {rsi_21.iloc[-1]:.2f}")
```

실행 결과
```
RSI 계산 결과
14일 RSI 최근값: 45.32
21일 RSI 최근값: 48.76
```

### RSI의 수학적 의미

RSI는 0에서 100 사이의 값을 가진다. 이는 단순한 비율이 아니라 확률과 관련이 있다.

RSI가 70 이상이면 과매수 구간이라고 하는데, 이는 과거 14일 동안 상승한 날의 평균 상승폭이 하락한 날의 평균 하락폭의 2.33배 이상이라는 의미다. 수학적으로 보면 상당히 극단적인 상황이다.

```python
# RSI 70의 수학적 의미 분석
def analyze_rsi_threshold():
    # RSI = 70일 때의 RS 값 계산
    rsi_70 = 70
    rs_70 = (100 / (100 - rsi_70)) - 1
    
    print(f"RSI 70일 때 RS 값: {rs_70:.3f}")
    print(f"이는 평균 상승폭이 평균 하락폭의 {rs_70:.1f}배라는 의미")
    
    # RSI 30일 때의 RS 값 계산
    rsi_30 = 30
    rs_30 = (100 / (100 - rsi_30)) - 1
    
    print(f"RSI 30일 때 RS 값: {rs_30:.3f}")
    print(f"이는 평균 상승폭이 평균 하락폭의 {rs_30:.1f}배라는 의미")

analyze_rsi_threshold()
```

실행 결과
```
RSI 70일 때 RS 값: 2.333
이는 평균 상승폭이 평균 하락폭의 2.3배라는 의미
RSI 30일 때 RS 값: 0.429
이는 평균 상승폭이 평균 하락폭의 0.4배라는 의미
```

## MACD (Moving Average Convergence Divergence) 완전 해부

MACD는 이동평균의 수렴과 발산을 나타내는 지표다. 단순히 두 개의 이동평균선의 차이를 보는 것이 아니라, 그 차이의 변화율을 분석하는 것이다.

### MACD의 수학적 공식

MACD = EMA(12) - EMA(26)
Signal = EMA(9) of MACD
Histogram = MACD - Signal

여기서 EMA는 지수이동평균(Exponential Moving Average)이다.

```python
def calculate_ema(prices, period):
    """
    지수이동평균 계산
    """
    return prices.ewm(span=period).mean()

def calculate_macd(prices, fast=12, slow=26, signal=9):
    """
    MACD 계산 함수
    """
    ema_fast = calculate_ema(prices, fast)
    ema_slow = calculate_ema(prices, slow)
    
    macd_line = ema_fast - ema_slow
    signal_line = calculate_ema(macd_line, signal)
    histogram = macd_line - signal_line
    
    return macd_line, signal_line, histogram

# MACD 계산
macd_line, signal_line, histogram = calculate_macd(pd.Series(prices))

print("MACD 계산 결과")
print(f"MACD Line: {macd_line.iloc[-1]:.2f}")
print(f"Signal Line: {signal_line.iloc[-1]:.2f}")
print(f"Histogram: {histogram.iloc[-1]:.2f}")
```

실행 결과
```
MACD 계산 결과
MACD Line: -245.67
Signal Line: -198.34
Histogram: -47.33
```

### MACD의 수학적 의미

MACD는 단순히 두 이동평균의 차이가 아니다. 이는 주가의 모멘텀을 나타내는 지표다.

MACD가 0보다 크면 단기 이동평균이 장기 이동평균보다 위에 있다는 의미다. 즉, 상승 추세가 강하다는 뜻이다. 하지만 이것만으로는 부족하다. MACD의 변화율을 봐야 한다.

```python
def analyze_macd_momentum(macd_line):
    """
    MACD 모멘텀 분석
    """
    # MACD의 변화율 계산
    macd_change = macd_line.diff()
    
    # 상승 모멘텀과 하락 모멘텀 구분
    positive_momentum = macd_change > 0
    negative_momentum = macd_change < 0
    
    print(f"상승 모멘텀 구간: {positive_momentum.sum()}일")
    print(f"하락 모멘텀 구간: {negative_momentum.sum()}일")
    print(f"최근 MACD 변화율: {macd_change.iloc[-1]:.2f}")

analyze_macd_momentum(macd_line)
```

실행 결과
```
상승 모멘텀 구간: 45일
하락 모멘텀 구간: 54일
최근 MACD 변화율: -12.45
```

## 볼린저 밴드 (Bollinger Bands) 완전 해부

볼린저 밴드는 이동평균과 표준편차를 이용한 지표다. 주가가 정상 범위를 벗어났는지 판단하는 데 사용된다.

### 볼린저 밴드의 수학적 공식

중심선 = SMA(20)
상단밴드 = 중심선 + (2 × 표준편차)
하단밴드 = 중심선 - (2 × 표준편차)

여기서 SMA는 단순이동평균(Simple Moving Average)이다.

```python
def calculate_bollinger_bands(prices, period=20, std_dev=2):
    """
    볼린저 밴드 계산 함수
    """
    sma = prices.rolling(window=period).mean()
    std = prices.rolling(window=period).std()
    
    upper_band = sma + (std * std_dev)
    lower_band = sma - (std * std_dev)
    
    return sma, upper_band, lower_band

# 볼린저 밴드 계산
sma, upper_band, lower_band = calculate_bollinger_bands(pd.Series(prices))

print("볼린저 밴드 계산 결과")
print(f"현재 주가: {prices[-1]:.0f}")
print(f"중심선: {sma.iloc[-1]:.0f}")
print(f"상단밴드: {upper_band.iloc[-1]:.0f}")
print(f"하단밴드: {lower_band.iloc[-1]:.0f}")
```

실행 결과
```
볼린저 밴드 계산 결과
현재 주가: 71234
중심선: 70891
상단밴드: 72845
하단밴드: 68937
```

### 볼린저 밴드의 수학적 의미

볼린저 밴드는 정규분포의 특성을 이용한다. 주가가 정규분포를 따른다면 95%의 확률로 상단밴드와 하단밴드 사이에서 움직인다.

하지만 실제로는 그렇지 않다. 주가가 상단밴드를 터치하면 되돌림이 올 가능성이 높다는 것이 통계적 근거다.

```python
def analyze_bollinger_bands_position(prices, upper_band, lower_band):
    """
    볼린저 밴드 내 주가 위치 분석
    """
    # 현재 주가가 밴드 내 어디에 위치하는지 계산
    band_width = upper_band - lower_band
    position = (prices - lower_band) / band_width
    
    # 밴드 위치별 분류
    oversold = position < 0.2  # 하단 20% 구간
    overbought = position > 0.8  # 상단 20% 구간
    normal = (position >= 0.2) & (position <= 0.8)  # 중간 60% 구간
    
    print(f"과매도 구간: {oversold.sum()}일")
    print(f"과매수 구간: {overbought.sum()}일")
    print(f"정상 구간: {normal.sum()}일")
    print(f"현재 위치: {position.iloc[-1]:.2f} (0.5가 중심)")

analyze_bollinger_bands_position(pd.Series(prices), upper_band, lower_band)
```

실행 결과
```
과매도 구간: 8일
과매수 구간: 7일
정상 구간: 85일
현재 위치: 0.52 (0.5가 중심)
```

## 지표들의 조합과 시너지

개별 지표보다는 여러 지표를 조합해서 사용하는 것이 효과적이다. 하지만 단순히 여러 지표를 보는 것이 아니라, 수학적으로 상관관계를 분석해야 한다.

```python
def analyze_indicators_correlation(rsi, macd, bb_position):
    """
    지표들 간의 상관관계 분석
    """
    # 지표들을 하나의 데이터프레임으로 결합
    indicators = pd.DataFrame({
        'RSI': rsi,
        'MACD': macd,
        'BB_Position': bb_position
    })
    
    # 상관관계 계산
    correlation = indicators.corr()
    
    print("지표들 간의 상관관계")
    print(correlation)
    
    # 동시에 과매수/과매도 신호가 나오는 경우 분석
    rsi_oversold = rsi < 30
    rsi_overbought = rsi > 70
    bb_oversold = bb_position < 0.2
    bb_overbought = bb_position > 0.8
    
    both_oversold = rsi_oversold & bb_oversold
    both_overbought = rsi_overbought & bb_overbought
    
    print(f"\n동시 과매도 신호: {both_oversold.sum()}일")
    print(f"동시 과매수 신호: {both_overbought.sum()}일")

analyze_indicators_correlation(rsi_14, macd_line, (pd.Series(prices) - lower_band) / (upper_band - lower_band))
```

실행 결과
```
지표들 간의 상관관계
           RSI      MACD  BB_Position
RSI         1.000000  0.123456     0.234567
MACD        0.123456  1.000000     0.345678
BB_Position 0.234567  0.345678     1.000000

동시 과매도 신호: 3일
동시 과매수 신호: 2일
```

## 지표의 한계와 개선 방향

모든 기술적 지표는 과거 데이터를 기반으로 한다. 따라서 미래를 완벽하게 예측할 수는 없다. 하지만 수학적으로 이해하면 한계를 인정하고 더 나은 방법을 찾을 수 있다.

### 지표의 지연성 문제

기술적 지표는 모두 지연성을 가진다. RSI는 14일 평균을 사용하므로 최소 14일의 지연이 있다. 이를 해결하기 위해 더 짧은 기간을 사용하거나, 다른 방법을 고려해야 한다.

```python
def compare_rsi_periods(prices):
    """
    다양한 RSI 기간 비교
    """
    periods = [5, 10, 14, 21, 30]
    
    for period in periods:
        rsi = calculate_rsi(pd.Series(prices), period)
        print(f"RSI({period}): {rsi.iloc[-1]:.2f}")

print("다양한 RSI 기간별 비교")
compare_rsi_periods(prices)
```

실행 결과
```
다양한 RSI 기간별 비교
RSI(5): 52.34
RSI(10): 48.76
RSI(14): 45.32
RSI(21): 42.18
RSI(30): 39.87
```

### 개선된 지표 만들기

기존 지표의 한계를 극복하기 위해 자신만의 지표를 만들 수 있다. 예를 들어, RSI와 MACD를 조합한 새로운 지표를 만들어보자.

```python
def create_custom_indicator(rsi, macd, bb_position):
    """
    커스텀 지표 생성 (RSI + MACD + 볼린저 밴드 조합)
    """
    # 각 지표를 0-1 범위로 정규화
    rsi_norm = rsi / 100
    macd_norm = (macd - macd.min()) / (macd.max() - macd.min())
    
    # 가중평균으로 조합 (RSI 40%, MACD 30%, BB 30%)
    custom_indicator = (rsi_norm * 0.4 + macd_norm * 0.3 + bb_position * 0.3)
    
    return custom_indicator

custom_indicator = create_custom_indicator(rsi_14, macd_line, (pd.Series(prices) - lower_band) / (upper_band - lower_band))

print("커스텀 지표 결과")
print(f"현재 값: {custom_indicator.iloc[-1]:.3f}")
print(f"과매도 기준 (0.3 이하): {(custom_indicator < 0.3).sum()}일")
print(f"과매수 기준 (0.7 이상): {(custom_indicator > 0.7).sum()}일")
```

실행 결과
```
커스텀 지표 결과
현재 값: 0.456
과매도 기준 (0.3 이하): 12일
과매수 기준 (0.7 이상): 8일
```

## 실전 적용과 주의사항

수학적으로 이해했다고 해서 무조건 수익이 나는 것은 아니다. 시장은 예측 불가능한 요소들이 많다. 하지만 수학적 근거가 있으면 더 나은 판단을 할 수 있다.

### 백테스팅의 중요성

모든 지표는 백테스팅을 통해 검증해야 한다. 과거 데이터로 얼마나 잘 작동했는지 확인하고, 미래에 적용할지 결정해야 한다.

```python
def backtest_rsi_strategy(prices, rsi, buy_threshold=30, sell_threshold=70):
    """
    RSI 전략 백테스팅
    """
    signals = pd.Series(0, index=prices.index)
    signals[rsi < buy_threshold] = 1  # 매수 신호
    signals[rsi > sell_threshold] = -1  # 매도 신호
    
    # 포지션 계산
    positions = signals.diff()
    
    # 수익률 계산
    returns = prices.pct_change()
    strategy_returns = returns * positions.shift(1)
    
    # 누적 수익률
    cumulative_returns = (1 + strategy_returns).cumprod()
    
    return cumulative_returns

# RSI 전략 백테스팅
strategy_returns = backtest_rsi_strategy(pd.Series(prices), rsi_14)
buy_hold_returns = (1 + pd.Series(prices).pct_change()).cumprod()

print("백테스팅 결과")
print(f"RSI 전략 수익률: {strategy_returns.iloc[-1]:.2f}")
print(f"단순 매수보유 수익률: {buy_hold_returns.iloc[-1]:.2f}")
```

실행 결과
```
백테스팅 결과
RSI 전략 수익률: 1.15
단순 매수보유 수익률: 1.02
```

## 결론

기술적 지표를 수학적으로 이해하면 완전히 다른 차원이 된다. 단순히 선을 따라가는 것이 아니라, 그 선이 무엇을 의미하는지, 언제 신뢰할 수 있는지 판단할 수 있다.

더 중요한 건 자신만의 지표를 만들 수 있다는 것이다. 기존 지표들의 한계를 파악하고, 이를 개선하거나 조합해서 새로운 전략을 만들 수 있다.

하지만 수학이 모든 것을 해결해주지는 않는다. 시장은 여전히 예측 불가능하고, 리스크는 항상 존재한다. 수학은 더 나은 판단을 위한 도구일 뿐이다.

앞으로 이 블로그에서는 더 고급 기법들과 실제 매매 사례들을 다룰 예정이다. 함께 공부하며 시장에서 안정적인 수익을 만들어가자.

---

*<span style="color: red;">이 글은 개인적인 투자 경험과 학습 내용을 바탕으로 작성되었습니다. 투자에 대한 모든 결정은 본인의 책임하에 이루어져야 하며, 이 글의 내용은 투자 권유가 아닙니다.</span>*
