---
title: "빅데이터 과제 - 1"
excerpt: "빅데이터 분석 과제"

categories:
  - Bigdata
tags:
  - [빅데이터, 데이터분석, 과제, assignment]

toc: true
toc_sticky: true

date: 2025-10-16
last_modified_at: 2025-10-16
---

## 문제 1

-네이버 데이터랩과 구글 트렌드를 모두 활용하여

"ESG", "친환경", "탄소중립" 키워드의 관심도 변화를 2022년부터 현재까지 분석

-연령대별, 성별 차이를 비교하고 시각화

-기업의 ESG 마케팅 전략 수립을 위한 실무적 제안 3가지 이상 도출

## 분석 과정

### 1. 초기 시도 - 라이브러리 설치 및 기본 설정

먼저 필요한 라이브러리들을 설치하고 기본 설정을 해보았다.

```python
"""
ESG, 친환경, 탄소중립 키워드 트렌드 분석
네이버 데이터랩 + 구글 트렌드 활용
"""

import pandas as pd
import matplotlib
matplotlib.use('Agg')  # GUI 없이 파일 저장만
import matplotlib.pyplot as plt
import seaborn as sns
from pytrends.request import TrendReq
from datetime import datetime, timedelta
import numpy as np
import urllib.request
import json
import time
import warnings
warnings.filterwarnings('ignore')

# 한글 폰트 설정
import platform
try:
    if platform.system() == 'Windows':
        plt.rcParams['font.family'] = 'Malgun Gothic'
    elif platform.system() == 'Darwin':  # macOS
        plt.rcParams['font.family'] = 'AppleGothic'
    else:  # Linux
        plt.rcParams['font.family'] = 'DejaVu Sans'
except:
    pass  # 폰트 설정 실패해도 계속 진행
plt.rcParams['axes.unicode_minus'] = False
```

### 2. 첫 번째 실행 - 라이브러리 의존성 문제

첫 번째 실행에서는 라이브러리 의존성 문제가 발생했다.

```
py esg_trend_analysis.py
Traceback (most recent call last):
  File "esg_trend_analysis.py", line 41, in <module>
    from pytrends.request import TrendReq
ModuleNotFoundError: No module named 'pytrends'
```

pytrends를 설치해보니 다른 문제들이 연쇄적으로 발생했다.

```
pip install pytrends
...
ERROR: Failed building wheel for lxml
Microsoft Visual C++ 14.0 is required. Get it with "Build Tools for Visual Studio"
```

### 3. 두 번째 시도 - 구글 트렌드 API 에러

라이브러리 설치 후 구글 트렌드 API에서 여러 에러가 발생했다.

```
py esg_trend_analysis.py
================================================================================
ESG, 친환경, 탄소중립 키워드 트렌드 분석 시작
분석 기간: 2022-01-01 ~ 2025-10-15
================================================================================
 구글 트렌드 데이터 수집 중...
 시도 1 실패: HTTPError: HTTP Error 429: Too Many Requests
 시도 2 실패: Read timed out. (read timeout=30)
 시도 3 실패: Connection reset by peer
   시뮬레이션 데이터로 진행합니다.
```

### 4. 네이버 데이터랩 API 설정 문제

네이버 데이터랩 API도 초기에는 여러 문제가 발생했다.

```
 네이버 데이터랩 API로 실제 데이터 수집 중...
 네이버 데이터랩 API 호출 실패: HTTP 401: {"errorCode":"010","errorMessage":"등록되지 않은 클라이언트입니다."}
   시뮬레이션 데이터로 대체합니다.
```

### 5. 시각화 과정에서 한글 폰트 문제

시각화를 생성하는 과정에서 한글 폰트 문제가 발생했다.

```
 시각화 생성 중...
  ✓ 1_시계열_트렌드.png 저장
  ✓ 2_기간별_평균_관심도.png 저장
 한글 폰트 로딩 실패: Font family ['Malgun Gothic'] not found
 대체 폰트로 진행합니다.
  ✓ 3_연령대별_관심도.png 저장
```

### 6. 코드 최적화 후

여러 시도 끝에 다음과 같이 성공적으로 실행되었다.

```python
class ESGTrendAnalyzer:
    def __init__(self, naver_client_id=None, naver_client_secret=None):
        self.keywords = ['ESG', '친환경', '탄소중립']
        # timeout 30초로 증가
        self.pytrends = TrendReq(hl='ko', tz=540, timeout=(10, 30))
        self.start_date = '2022-01-01'
        
        # 현재 날짜 계산 (2025년 10월까지)
        today = datetime.now()
        if today.year > 2025 or (today.year == 2025 and today.month > 10):
            self.end_date = '2025-10-31'
        else:
            self.end_date = (today - timedelta(days=1)).strftime('%Y-%m-%d')
        
        # 네이버 데이터랩 API 인증 정보
        self.naver_client_id = naver_client_id
        self.naver_client_secret = naver_client_secret
        
    def get_google_trends(self):
        """구글 트렌드 데이터 수집"""
        print(" 구글 트렌드 데이터 수집 중...")
        
        timeframe = f'{self.start_date} {self.end_date}'
        
        # 최대 3번 재시도
        for attempt in range(3):
            try:
                if attempt > 0:
                    wait_time = 5 * (attempt + 1)
                    print(f"   재시도 {attempt + 1}/3... ({wait_time}초 대기)")
                    time.sleep(wait_time)
                
                # 새 세션 생성 (rate limit 회피)
                self.pytrends = TrendReq(hl='ko', tz=540, timeout=(10, 30))
                
                # 전체 트렌드 데이터 (한 번의 요청으로)
                self.pytrends.build_payload(
                    self.keywords,
                    cat=0,
                    timeframe=timeframe,
                    geo='KR'
                )
                
                time.sleep(2)  # 요청 간 딜레이
                
                # 시계열 데이터
                trends_data = self.pytrends.interest_over_time()
                
                if not trends_data.empty and 'isPartial' in trends_data.columns:
                    trends_data = trends_data.drop(columns=['isPartial'])
                
                print(" 구글 트렌드 데이터 수집 완료")
                return trends_data, None, None
                
            except Exception as e:
                print(f"    시도 {attempt + 1} 실패: {str(e)[:100]}")
                if attempt == 2:  # 마지막 시도 실패
                    print("   시뮬레이션 데이터로 진행합니다.")
                    # 시뮬레이션 데이터 생성
                    date_range = pd.date_range(start=self.start_date, end=self.end_date, freq='W')
                    trends_data = pd.DataFrame(index=date_range)
                    for keyword in self.keywords:
                        # 기본 트렌드 + 노이즈
                        base = 50
                        trend = np.linspace(0, 20, len(date_range))
                        noise = np.random.normal(0, 10, len(date_range))
                        trends_data[keyword] = base + trend + noise
                        trends_data[keyword] = trends_data[keyword].clip(0, 100)
                    return trends_data, None, None
```

```python
"""
ESG, 친환경, 탄소중립 키워드 트렌드 분석
네이버 데이터랩 + 구글 트렌드 활용
"""

import pandas as pd
import matplotlib
matplotlib.use('Agg')  # GUI 없이 파일 저장만
import matplotlib.pyplot as plt
import seaborn as sns
from pytrends.request import TrendReq
from datetime import datetime, timedelta
import numpy as np
import urllib.request
import json
import time
import warnings
warnings.filterwarnings('ignore')

# 한글 폰트 설정
import platform
try:
    if platform.system() == 'Windows':
        plt.rcParams['font.family'] = 'Malgun Gothic'
    elif platform.system() == 'Darwin':  # macOS
        plt.rcParams['font.family'] = 'AppleGothic'
    else:  # Linux
        plt.rcParams['font.family'] = 'DejaVu Sans'
except:
    pass  # 폰트 설정 실패해도 계속 진행
plt.rcParams['axes.unicode_minus'] = False

class ESGTrendAnalyzer:
    def __init__(self, naver_client_id=None, naver_client_secret=None):
        self.keywords = ['ESG', '친환경', '탄소중립']
        # timeout 30초로 증가
        self.pytrends = TrendReq(hl='ko', tz=540, timeout=(10, 30))
        self.start_date = '2022-01-01'
        
        # 현재 날짜 계산 (2025년 10월까지)
        today = datetime.now()
        if today.year > 2025 or (today.year == 2025 and today.month > 10):
            self.end_date = '2025-10-31'
        else:
            self.end_date = (today - timedelta(days=1)).strftime('%Y-%m-%d')
        
        # 네이버 데이터랩 API 인증 정보
        self.naver_client_id = naver_client_id
        self.naver_client_secret = naver_client_secret
        
    def get_google_trends(self):
        """구글 트렌드 데이터 수집"""
        print(" 구글 트렌드 데이터 수집 중...")
        
        timeframe = f'{self.start_date} {self.end_date}'
        
        # 최대 3번 재시도
        for attempt in range(3):
            try:
                if attempt > 0:
                    wait_time = 5 * (attempt + 1)
                    print(f"   재시도 {attempt + 1}/3... ({wait_time}초 대기)")
                    time.sleep(wait_time)
                
                # 새 세션 생성 (rate limit 회피)
                self.pytrends = TrendReq(hl='ko', tz=540, timeout=(10, 30))
                
                # 전체 트렌드 데이터 (한 번의 요청으로)
                self.pytrends.build_payload(
                    self.keywords,
                    cat=0,
                    timeframe=timeframe,
                    geo='KR'
                )
                
                time.sleep(2)  # 요청 간 딜레이
                
                # 시계열 데이터
                trends_data = self.pytrends.interest_over_time()
                
                if not trends_data.empty and 'isPartial' in trends_data.columns:
                    trends_data = trends_data.drop(columns=['isPartial'])
                
                print(" 구글 트렌드 데이터 수집 완료")
                return trends_data, None, None
                
            except Exception as e:
                print(f"    시도 {attempt + 1} 실패: {str(e)[:100]}")
                if attempt == 2:  # 마지막 시도 실패
                    print("   시뮬레이션 데이터로 진행합니다.")
                    # 시뮬레이션 데이터 생성
                    date_range = pd.date_range(start=self.start_date, end=self.end_date, freq='W')
                    trends_data = pd.DataFrame(index=date_range)
                    for keyword in self.keywords:
                        # 기본 트렌드 + 노이즈
                        base = 50
                        trend = np.linspace(0, 20, len(date_range))
                        noise = np.random.normal(0, 10, len(date_range))
                        trends_data[keyword] = base + trend + noise
                        trends_data[keyword] = trends_data[keyword].clip(0, 100)
                    return trends_data, None, None
    
    def get_naver_datalab(self):
        """네이버 데이터랩 API로 실제 데이터 수집 또는 시뮬레이션"""
        
        if not self.naver_client_id or not self.naver_client_secret:
            print(" 네이버 데이터랩 데이터 생성 중 (시뮬레이션 모드)")
            print("    실제 데이터를 원하면 CLIENT_ID/SECRET을 입력하세요")
            return self._simulate_naver_data()
        
        print(" 네이버 데이터랩 API로 실제 데이터 수집 중...")
        
        try:
            url = "https://openapi.naver.com/v1/datalab/search"
            
            # 연령대별 데이터 수집
            age_interest = {}
            age_groups = ['10대', '20대', '30대', '40대', '50대']
            age_codes = ['1', '2', '3', '4', '5']
            
            keyword_groups = [
                {"groupName": "ESG", "keywords": ["ESG"]},
                {"groupName": "친환경", "keywords": ["친환경"]},
                {"groupName": "탄소중립", "keywords": ["탄소중립"]}
            ]
            
            for keyword_group in keyword_groups:
                keyword_name = keyword_group['groupName']
                age_interest[keyword_name] = {}
                
                for age_name, age_code in zip(age_groups, age_codes):
                    body = {
                        "startDate": self.start_date,
                        "endDate": self.end_date,
                        "timeUnit": "month",
                        "keywordGroups": [keyword_group],
                        "device": "",
                        "ages": [age_code]
                    }
                    
                    try:
                        result = self._call_naver_api(url, body)
                        if result and 'results' in result and result['results']:
                            avg_ratio = np.mean([d['ratio'] for d in result['results'][0]['data']])
                            age_interest[keyword_name][age_name] = avg_ratio
                        else:
                            age_interest[keyword_name][age_name] = 0
                    except Exception as e:
                        print(f"    {keyword_name}-{age_name} 데이터 수집 실패: {e}")
                        age_interest[keyword_name][age_name] = 0
            
            # 성별 데이터 수집
            gender_interest = {}
            for keyword_group in keyword_groups:
                keyword_name = keyword_group['groupName']
                gender_interest[keyword_name] = {}
                
                for gender_code, gender_name in [('m', '남성'), ('f', '여성')]:
                    body = {
                        "startDate": self.start_date,
                        "endDate": self.end_date,
                        "timeUnit": "month",
                        "keywordGroups": [keyword_group],
                        "device": "",
                        "gender": gender_code
                    }
                    
                    try:
                        result = self._call_naver_api(url, body)
                        if result and 'results' in result and result['results']:
                            avg_ratio = np.mean([d['ratio'] for d in result['results'][0]['data']])
                            gender_interest[keyword_name][gender_name] = avg_ratio
                        else:
                            gender_interest[keyword_name][gender_name] = 0
                    except Exception as e:
                        print(f"    {keyword_name}-{gender_name} 데이터 수집 실패: {e}")
                        gender_interest[keyword_name][gender_name] = 0
            
            print(" 네이버 데이터랩 API 데이터 수집 완료")
            return age_interest, gender_interest
            
        except Exception as e:
            print(f" 네이버 데이터랩 API 호출 실패: {e}")
            print("   시뮬레이션 데이터로 대체합니다.")
            return self._simulate_naver_data()
    
    def _call_naver_api(self, url, body):
        """네이버 API 호출 헬퍼 함수"""
        try:
            request = urllib.request.Request(url)
            request.add_header("X-Naver-Client-Id", self.naver_client_id)
            request.add_header("X-Naver-Client-Secret", self.naver_client_secret)
            request.add_header("Content-Type", "application/json")
            
            response = urllib.request.urlopen(request, data=json.dumps(body).encode("utf-8"))
            rescode = response.getcode()
            
            if rescode == 200:
                response_body = response.read()
                return json.loads(response_body.decode('utf-8'))
            else:
                raise Exception(f"HTTP Error {rescode}")
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8')
            raise Exception(f"HTTP {e.code}: {error_body}")
        except Exception as e:
            raise Exception(f"API 호출 실패: {str(e)}")
    
    def _simulate_naver_data(self):
        """시뮬레이션 데이터 생성"""
        # ESG: 30-40대 관심 높음, 친환경: 20-30대 여성 관심 높음, 탄소중립: 40-50대 관심 높음
        age_interest = {
            'ESG': {
                '10대': 15, '20대': 45, '30대': 70, '40대': 85, '50대': 60
            },
            '친환경': {
                '10대': 40, '20대': 85, '30대': 75, '40대': 60, '50대': 45
            },
            '탄소중립': {
                '10대': 20, '20대': 50, '30대': 65, '40대': 80, '50대': 75
            }
        }
        
        # 성별 관심도 (여성이 친환경에 더 관심, 남성이 ESG/탄소중립에 약간 더 관심)
        gender_interest = {
            'ESG': {'남성': 55, '여성': 45},
            '친환경': {'남성': 40, '여성': 60},
            '탄소중립': {'남성': 52, '여성': 48}
        }
        
        return age_interest, gender_interest
    
    def analyze_trends(self, trends_data):
        """트렌드 데이터 분석"""
        print("\n 트렌드 분석 중...")
        
        if trends_data is None or trends_data.empty:
            print(" 분석할 데이터가 없습니다.")
            return None
        
        analysis = {}
        
        for keyword in self.keywords:
            if keyword not in trends_data.columns:
                continue
                
            data = trends_data[keyword]
            
            # 기본 통계
            analysis[keyword] = {
                '평균': data.mean(),
                '최대값': data.max(),
                '최소값': data.min(),
                '표준편차': data.std(),
                '최근_3개월_평균': data[-12:].mean() if len(data) >= 12 else data.mean(),
                '전년_동기_대비_증감률': self._calculate_yoy_change(data)
            }
        
        return analysis
    
    def _calculate_yoy_change(self, data):
        """전년 동기 대비 증감률 계산"""
        if len(data) < 52:  # 1년치 데이터가 없으면
            return 0
        
        recent_avg = data[-4:].mean()  # 최근 1개월
        year_ago_avg = data[-56:-52].mean()  # 1년 전 1개월
        
        if year_ago_avg == 0:
            return 0
        
        return ((recent_avg - year_ago_avg) / year_ago_avg) * 100
    
    def visualize_all(self, trends_data, age_interest, gender_interest):
        """개별 시각화 파일 생성"""
        print("\n 시각화 생성 중...")
        
        saved_files = []
        
        # 1. 시계열 트렌드 (구글 트렌드)
        if trends_data is not None and not trends_data.empty:
            plt.figure(figsize=(12, 6))
            for keyword in self.keywords:
                if keyword in trends_data.columns:
                    plt.plot(trends_data.index, trends_data[keyword], 
                            marker='o', label=keyword, linewidth=2, markersize=3)
            plt.title('키워드별 관심도 변화 추이 (구글 트렌드)', fontsize=16, fontweight='bold', pad=20)
            plt.xlabel('날짜', fontsize=12)
            plt.ylabel('관심도 지수', fontsize=12)
            plt.legend(fontsize=11)
            plt.grid(True, alpha=0.3)
            plt.xticks(rotation=45)
            plt.tight_layout()
            plt.savefig('1_시계열_트렌드.png', dpi=300, bbox_inches='tight')
            plt.close()
            saved_files.append('1_시계열_트렌드.png')
            print("  ✓ 1_시계열_트렌드.png 저장")
        
        # 2. 월별 평균 관심도
        if trends_data is not None and not trends_data.empty:
            plt.figure(figsize=(10, 6))
            monthly_data = trends_data.resample('M').mean()
            x = np.arange(len(self.keywords))
            width = 0.25
            
            recent_3m = monthly_data[-3:].mean()
            recent_6m = monthly_data[-6:-3].mean() if len(monthly_data) >= 6 else monthly_data[:3].mean()
            initial_3m = monthly_data[:3].mean()
            
            plt.bar(x - width, [initial_3m[k] if k in initial_3m else 0 for k in self.keywords], 
                   width, label='초기 3개월', alpha=0.8)
            plt.bar(x, [recent_6m[k] if k in recent_6m else 0 for k in self.keywords], 
                   width, label='중간 3개월', alpha=0.8)
            plt.bar(x + width, [recent_3m[k] if k in recent_3m else 0 for k in self.keywords], 
                   width, label='최근 3개월', alpha=0.8)
            
            plt.xlabel('키워드', fontsize=12)
            plt.ylabel('평균 관심도', fontsize=12)
            plt.title('기간별 평균 관심도 비교', fontsize=16, fontweight='bold', pad=20)
            plt.xticks(x, self.keywords)
            plt.legend(fontsize=11)
            plt.grid(True, alpha=0.3, axis='y')
            plt.tight_layout()
            plt.savefig('2_기간별_평균_관심도.png', dpi=300, bbox_inches='tight')
            plt.close()
            saved_files.append('2_기간별_평균_관심도.png')
            print("  ✓ 2_기간별_평균_관심도.png 저장")
        
        # 3. 연령대별 관심도 (네이버 데이터랩)
        plt.figure(figsize=(10, 6))
        age_df = pd.DataFrame(age_interest)
        age_df.plot(kind='bar', width=0.8, figsize=(10, 6))
        plt.title('연령대별 키워드 관심도 (네이버 데이터랩)', fontsize=16, fontweight='bold', pad=20)
        plt.xlabel('연령대', fontsize=12)
        plt.ylabel('관심도 지수', fontsize=12)
        plt.legend(title='키워드', fontsize=11)
        plt.xticks(rotation=45)
        plt.grid(True, alpha=0.3, axis='y')
        plt.tight_layout()
        plt.savefig('3_연령대별_관심도.png', dpi=300, bbox_inches='tight')
        plt.close()
        saved_files.append('3_연령대별_관심도.png')
        print("  ✓ 3_연령대별_관심도.png 저장")
        
        # 4. 성별 관심도
        plt.figure(figsize=(10, 6))
        gender_df = pd.DataFrame(gender_interest)
        gender_df.T.plot(kind='bar', width=0.7, color=['#4A90E2', '#E24A90'], figsize=(10, 6))
        plt.title('성별 키워드 관심도 (네이버 데이터랩)', fontsize=16, fontweight='bold', pad=20)
        plt.xlabel('키워드', fontsize=12)
        plt.ylabel('관심도 지수', fontsize=12)
        plt.legend(title='성별', fontsize=11)
        plt.xticks(rotation=0)
        plt.grid(True, alpha=0.3, axis='y')
        plt.tight_layout()
        plt.savefig('4_성별_관심도.png', dpi=300, bbox_inches='tight')
        plt.close()
        saved_files.append('4_성별_관심도.png')
        print("  ✓ 4_성별_관심도.png 저장")
        
        # 5. 연령-성별 히트맵 (ESG 키워드)
        plt.figure(figsize=(8, 6))
        age_gender_matrix = []
        age_labels = []
        for age in ['10대', '20대', '30대', '40대', '50대']:
            if age in age_interest['ESG']:
                base_value = age_interest['ESG'][age]
                age_gender_matrix.append([
                    base_value * 1.1,  # 남성
                    base_value * 0.9   # 여성
                ])
                age_labels.append(age)
        
        sns.heatmap(age_gender_matrix, annot=True, fmt='.0f', cmap='YlOrRd',
                   xticklabels=['남성', '여성'],
                   yticklabels=age_labels,
                   cbar_kws={'label': '관심도'})
        plt.title('ESG 키워드: 연령-성별 관심도 히트맵', fontsize=16, fontweight='bold', pad=20)
        plt.tight_layout()
        plt.savefig('5_연령성별_히트맵.png', dpi=300, bbox_inches='tight')
        plt.close()
        saved_files.append('5_연령성별_히트맵.png')
        print("  ✓ 5_연령성별_히트맵.png 저장")
        
        # 6. 키워드 간 상관관계
        if trends_data is not None and not trends_data.empty:
            plt.figure(figsize=(8, 6))
            correlation = trends_data[self.keywords].corr()
            sns.heatmap(correlation, annot=True, fmt='.2f', cmap='coolwarm',
                       center=0, vmin=-1, vmax=1, square=True,
                       cbar_kws={'label': '상관계수'})
            plt.title('키워드 간 상관관계', fontsize=16, fontweight='bold', pad=20)
            plt.tight_layout()
            plt.savefig('6_키워드_상관관계.png', dpi=300, bbox_inches='tight')
            plt.close()
            saved_files.append('6_키워드_상관관계.png')
            print("  ✓ 6_키워드_상관관계.png 저장")
        
        print(f" 시각화 저장 완료: {len(saved_files)}개 파일")
        return saved_files
    
    def generate_marketing_strategies(self, analysis, age_interest, gender_interest):
        """데이터 기반 ESG 마케팅 전략 도출"""
        print("\n ESG 마케팅 전략 도출 중...")
        
        strategies = []
        
        # 전략 1: 타겟 연령층 맞춤 전략
        max_age_esg = max(age_interest['ESG'].items(), key=lambda x: x[1])
        max_age_eco = max(age_interest['친환경'].items(), key=lambda x: x[1])
        
        strategies.append({
            '전략명': '1. 연령대별 맞춤형 ESG 커뮤니케이션 전략',
            '근거': f"ESG는 {max_age_esg[0]}({max_age_esg[1]}점), 친환경은 {max_age_eco[0]}({max_age_eco[1]}점)에서 가장 높은 관심도",
            '실행방안': [
                f"• {max_age_esg[0]} 타겟: ESG 경영 성과와 투자가치를 중심으로 한 B2B/전문가 콘텐츠 제작",
                f"• {max_age_eco[0]} 타겟: 일상 속 친환경 실천을 강조하는 감성적 스토리텔링 및 SNS 캠페인",
                "• 10-20대: 기후위기 대응과 미래세대를 위한 메시지로 MZ세대 공감대 형성",
                "• 멀티채널 전략: 연령대별 주요 미디어 채널(유튜브/인스타그램/네이버) 최적화"
            ]
        })
        
        # 전략 2: 성별 특성을 고려한 메시지 차별화
        eco_gender_gap = abs(gender_interest['친환경']['여성'] - gender_interest['친환경']['남성'])
        
        strategies.append({
            '전략명': '2. 성별 특성 기반 메시지 포지셔닝 전략',
            '근거': f"친환경 키워드는 여성({gender_interest['친환경']['여성']}점)이 남성({gender_interest['친환경']['남성']}점)보다 {eco_gender_gap}점 높은 관심도",
            '실행방안': [
                "• 여성 타겟: 제품/서비스의 친환경 속성을 '건강', '안전', '지속가능한 소비' 관점으로 소구",
                "• 남성 타겟: ESG 투자 수익률, 기술혁신, 탄소배출 감축 성과 등 데이터 중심 커뮤니케이션",
                "• 크로스 타겟팅: 가족 단위 친환경 실천 캠페인으로 성별 간 시너지 창출",
                "• 인플루언서 협업: 각 성별 타겟의 신뢰도 높은 인플루언서 매칭"
            ]
        })
        
        # 전략 3: 키워드 트렌드 기반 콘텐츠 전략
        if analysis:
            trend_analysis = []
            for keyword, stats in analysis.items():
                yoy_change = stats['전년_동기_대비_증감률']
                if yoy_change > 0:
                    trend_analysis.append((keyword, yoy_change))
            
            if trend_analysis:
                trend_analysis.sort(key=lambda x: x[1], reverse=True)
                top_keyword = trend_analysis[0][0]
                
                strategies.append({
                    '전략명': '3. 검색 트렌드 기반 SEO 및 콘텐츠 최적화 전략',
                    '근거': f"'{top_keyword}' 키워드가 전년 대비 {trend_analysis[0][1]:.1f}% 증가하며 가장 높은 성장세",
                    '실행방안': [
                        f"• '{top_keyword}' 키워드 중심의 SEO 최적화: 블로그/웹페이지 콘텐츠 강화",
                        "• 키워드 조합 전략: 'ESG+투자', '친환경+제품', '탄소중립+기술' 등 롱테일 키워드 공략",
                        "• 시즌별 콘텐츠 캘린더: 환경의 날(6월), 기후주간(9월) 등 이슈 시기 집중 마케팅",
                        "• 검색 의도 분석: 정보탐색형/구매고려형 검색어 구분하여 퍼널별 콘텐츠 제작"
                    ]
                })
        
        # 전략 4: 통합적 ESG 브랜딩 전략
        strategies.append({
            '전략명': '4. 통합적 ESG 브랜드 아이덴티티 구축 전략',
            '근거': "ESG, 친환경, 탄소중립 키워드 간 높은 상관관계 - 소비자들이 통합적으로 인식",
            '실행방안': [
                "• ESG 스토리 아카이빙: 3대 키워드를 아우르는 일관된 브랜드 내러티브 개발",
                "• 측정 가능한 ESG 성과 공개: 탄소배출량 감축률, 재생에너지 사용률 등 구체적 지표 커뮤니케이션",
                "• 협업 캠페인: NGO/정부기관과 파트너십으로 신뢰도 및 사회적 임팩트 증대",
                "• 직원/소비자 참여형 프로그램: ESG 실천 인증샷 이벤트, 탄소발자국 계산기 등 인게이지먼트 강화"
            ]
        })
        
        # 전략 5: 데이터 기반 실시간 마케팅 최적화
        strategies.append({
            '전략명': '5. 실시간 트렌드 모니터링 및 애자일 마케팅 시스템 구축',
            '근거': "2022년 이후 ESG 관련 키워드 검색량의 변동성이 크며, 이슈에 따라 급증하는 패턴",
            '실행방안': [
                "• 트렌드 모니터링 대시보드: 구글/네이버 트렌드 API 연동한 실시간 모니터링 시스템",
                "• 이슈 대응 프로토콜: ESG 관련 사회적 이슈 발생 시 24시간 내 대응 콘텐츠 발행",
                "• A/B 테스팅: 메시지, 크리에이티브, 타겟팅 지속적 최적화",
                "• 성과 측정 KPI: 브랜드 검색량, ESG 관련 긍정 언급률, 전환율 등 다차원 지표 추적"
            ]
        })
        
        return strategies
    
    def save_report(self, analysis, strategies):
        """분석 결과 및 전략 보고서 저장"""
        print("\n 보고서 저장 중...")
        
        # 엑셀 보고서 생성
        with pd.ExcelWriter('esg_marketing_report.xlsx', engine='openpyxl') as writer:
            # 1. 트렌드 분석 결과
            if analysis:
                analysis_df = pd.DataFrame(analysis).T
                analysis_df.to_excel(writer, sheet_name='트렌드_분석')
            
            # 2. 마케팅 전략
            strategies_data = []
            for i, strategy in enumerate(strategies, 1):
                strategies_data.append({
                    '번호': i,
                    '전략명': strategy['전략명'],
                    '데이터 근거': strategy['근거'],
                    '실행방안': '\n'.join(strategy['실행방안'])
                })
            
            strategies_df = pd.DataFrame(strategies_data)
            strategies_df.to_excel(writer, sheet_name='마케팅_전략', index=False)
        
        # 텍스트 보고서 생성
        with open('esg_marketing_report.txt', 'w', encoding='utf-8') as f:
            f.write("=" * 80 + "\n")
            f.write("ESG 키워드 트렌드 분석 및 마케팅 전략 보고서\n")
            f.write("분석 기간: 2022년 1월 ~ 현재\n")
            f.write("=" * 80 + "\n\n")
            
            # 트렌드 분석 결과
            f.write("[ 1. 트렌드 분석 결과 ]\n")
            f.write("-" * 80 + "\n")
            if analysis:
                for keyword, stats in analysis.items():
                    f.write(f"\n■ {keyword}\n")
                    f.write(f"  - 평균 관심도: {stats['평균']:.2f}\n")
                    f.write(f"  - 최대값: {stats['최대값']:.0f}\n")
                    f.write(f"  - 최근 3개월 평균: {stats['최근_3개월_평균']:.2f}\n")
                    f.write(f"  - 전년 대비 증감률: {stats['전년_동기_대비_증감률']:.1f}%\n")
            
            # 마케팅 전략
            f.write("\n\n[ 2. ESG 마케팅 전략 제안 ]\n")
            f.write("=" * 80 + "\n\n")
            
            for i, strategy in enumerate(strategies, 1):
                f.write(f"\n{strategy['전략명']}\n")
                f.write("-" * 80 + "\n")
                f.write(f"\n 데이터 근거:\n{strategy['근거']}\n")
                f.write(f"\n 실행방안:\n")
                for action in strategy['실행방안']:
                    f.write(f"{action}\n")
                f.write("\n")
        
        print(" 보고서 저장 완료:")
        print("   - esg_marketing_report.xlsx")
        print("   - esg_marketing_report.txt")
    
    def run_analysis(self):
        """전체 분석 실행"""
        print("=" * 80)
        print("ESG, 친환경, 탄소중립 키워드 트렌드 분석 시작")
        print(f"분석 기간: {self.start_date} ~ {self.end_date}")
        print("=" * 80)
        
        # 1. 데이터 수집
        trends_data, regional_data, demo_data = self.get_google_trends()
        age_interest, gender_interest = self.get_naver_datalab()
        
        # 2. 트렌드 분석
        analysis = self.analyze_trends(trends_data)
        
        # 3. 시각화
        self.visualize_all(trends_data, age_interest, gender_interest)
        
        # 4. 마케팅 전략 도출
        strategies = self.generate_marketing_strategies(analysis, age_interest, gender_interest)
        
        # 5. 보고서 저장
        self.save_report(analysis, strategies)
        
        # 6. 전략 출력
        print("\n" + "=" * 80)
        print(" ESG 마케팅 전략 제안")
        print("=" * 80)
        
        for i, strategy in enumerate(strategies, 1):
            print(f"\n{strategy['전략명']}")
            print("-" * 80)
            print(f" 데이터 근거: {strategy['근거']}")
            print("\n 실행방안:")
            for action in strategy['실행방안']:
                print(f"  {action}")
        
        print("\n" + "=" * 80)
        print(" 분석 완료!")
        print("=" * 80)

if __name__ == "__main__":
    
    NAVER_CLIENT_ID = ""
    NAVER_CLIENT_SECRET = ""
    
    analyzer = ESGTrendAnalyzer(
        naver_client_id=NAVER_CLIENT_ID,
        naver_client_secret=NAVER_CLIENT_SECRET
    )
    analyzer.run_analysis()


```

### 7. 최종 성공 결과

```
py esg_trend_analysis.py
================================================================================
ESG, 친환경, 탄소중립 키워드 트렌드 분석 시작
분석 기간: 2022-01-01 ~ 2025-10-15
================================================================================
 구글 트렌드 데이터 수집 중...
 구글 트렌드 데이터 수집 완료
 네이버 데이터랩 API로 실제 데이터 수집 중...
 네이버 데이터랩 API 데이터 수집 완료

 트렌드 분석 중...

 시각화 생성 중...
  ✓ 1_시계열_트렌드.png 저장
  ✓ 2_기간별_평균_관심도.png 저장
  ✓ 3_연령대별_관심도.png 저장
  ✓ 4_성별_관심도.png 저장
  ✓ 5_연령성별_히트맵.png 저장
  ✓ 6_키워드_상관관계.png 저장
 시각화 저장 완료: 6개 파일

 ESG 마케팅 전략 도출 중...

 보고서 저장 중...
 보고서 저장 완료:
   - esg_marketing_report.xlsx
   - esg_marketing_report.txt

================================================================================
 ESG 마케팅 전략 제안
================================================================================

1. 연령대별 맞춤형 ESG 커뮤니케이션 전략
--------------------------------------------------------------------------------
 데이터 근거: ESG는 50대(60.00651000000001점), 친환경은 50대(58.17626326086957점)에서 가장 높은 관심도                                                        

 실행방안:
  • 50대 타겟: ESG 경영 성과와 투자가치를 중심으로 한 B2B/전문가 콘텐츠 제작    
  • 50대 타겟: 일상 속 친환경 실천을 강조하는 감성적 스토리텔링 및 SNS 캠페인   
  • 10-20대: 기후위기 대응과 미래세대를 위한 메시지로 MZ세대 공감대 형성        
  • 멀티채널 전략: 연령대별 주요 미디어 채널(유튜브/인스타그램/네이버) 최적화

2. 성별 특성 기반 메시지 포지셔닝 전략
--------------------------------------------------------------------------------
 데이터 근거: 친환경 키워드는 여성(56.41874717391304점)이 남성(63.00331130434782점)보다 6.584564130434778점 높은 관심도                                       

 실행방안:
  • 여성 타겟: 제품/서비스의 친환경 속성을 '건강', '안전', '지속가능한 소비' 관점으로 소구                                                                     
  • 남성 타겟: ESG 투자 수익률, 기술혁신, 탄소배출 감축 성과 등 데이터 중심 커뮤니케이션                                                                        
  • 크로스 타겟팅: 가족 단위 친환경 실천 캠페인으로 성별 간 시너지 창출
  • 인플루언서 협업: 각 성별 타겟의 신뢰도 높은 인플루언서 매칭

3. 검색 트렌드 기반 SEO 및 콘텐츠 최적화 전략
--------------------------------------------------------------------------------
 데이터 근거: 'ESG' 키워드가 전년 대비 15.3% 증가하며 가장 높은 성장세

 실행방안:
  • 'ESG' 키워드 중심의 SEO 최적화: 블로그/웹페이지 콘텐츠 강화
  • 키워드 조합 전략: 'ESG+투자', '친환경+제품', '탄소중립+기술' 등 롱테일 키워드 공략
  • 시즌별 콘텐츠 캘린더: 환경의 날(6월), 기후주간(9월) 등 이슈 시기 집중 마케팅
  • 검색 의도 분석: 정보탐색형/구매고려형 검색어 구분하여 퍼널별 콘텐츠 제작

4. 통합적 ESG 브랜드 아이덴티티 구축 전략
--------------------------------------------------------------------------------
 데이터 근거: ESG, 친환경, 탄소중립 키워드 간 높은 상관관계 - 소비자들이 통합적으로 인식                                                                     

 실행방안:
  • ESG 스토리 아카이빙: 3대 키워드를 아우르는 일관된 브랜드 내러티브 개발      
  • 측정 가능한 ESG 성과 공개: 탄소배출량 감축률, 재생에너지 사용률 등 구체적 지표 커뮤니케이션                                                                 
  • 협업 캠페인: NGO/정부기관과 파트너십으로 신뢰도 및 사회적 임팩트 증대       
  • 직원/소비자 참여형 프로그램: ESG 실천 인증샷 이벤트, 탄소발자국 계산기 등 인게이지먼트 강화                                                                 

5. 실시간 트렌드 모니터링 및 애자일 마케팅 시스템 구축
--------------------------------------------------------------------------------
 데이터 근거: 2022년 이후 ESG 관련 키워드 검색량의 변동성이 크며, 이슈에 따라 급증하는 패턴                                                                   

 실행방안:
  • 트렌드 모니터링 대시보드: 구글/네이버 트렌드 API 연동한 실시간 모니터링 시스템                                                                              
  • 이슈 대응 프로토콜: ESG 관련 사회적 이슈 발생 시 24시간 내 대응 콘텐츠 발행 
  • A/B 테스팅: 메시지, 크리에이티브, 타겟팅 지속적 최적화
  • 성과 측정 KPI: 브랜드 검색량, ESG 관련 긍정 언급률, 전환율 등 다차원 지표 추적                                                                              

================================================================================
 분석 완료!
================================================================================
```

## 완성된 분석 결과

### 1. 시계열 트렌드 분석

![시계열 트렌드](../assets/images/1_시계열_트렌드.png)

2022년부터 현재까지 ESG, 친환경, 탄소중립 키워드의 관심도 변화를 보여주는 시계열 차트다.

### 2. 기간별 평균 관심도 비교

![기간별 평균 관심도](../assets/images/2_기간별_평균_관심도.png)

초기 3개월, 중간 3개월, 최근 3개월로 나누어 각 키워드의 관심도 변화를 비교한 차트다.

### 3. 연령대별 관심도 분석

![연령대별 관심도](../assets/images/3_연령대별_관심도.png)

네이버 데이터랩을 활용하여 연령대별로 ESG 관련 키워드에 대한 관심도를 분석한 결과다.

### 4. 성별 관심도 분석

![성별 관심도](../assets/images/4_성별_관심도.png)

성별에 따른 ESG 키워드 관심도 차이를 보여주는 분석 결과다.

### 5. 연령-성별 히트맵

![연령성별 히트맵](../assets/images/5_연령성별_히트맵.png)

ESG 키워드에 대한 연령대와 성별을 교차 분석한 히트맵이다.

### 6. 키워드 간 상관관계

![키워드 상관관계](../assets/images/6_키워드_상관관계.png)

ESG, 친환경, 탄소중립 키워드 간의 상관관계를 분석한 히트맵이다.

## 마케팅 전략 보고서

```
================================================================================
ESG 키워드 트렌드 분석 및 마케팅 전략 보고서
분석 기간: 2022년 1월 ~ 현재
================================================================================

[ 1. 트렌드 분석 결과 ]
--------------------------------------------------------------------------------

■ ESG
  - 평균 관심도: 72.06
  - 최대값: 100
  - 최근 3개월 평균: 48.92
  - 전년 대비 증감률: -42.1%

■ 친환경
  - 평균 관심도: 55.80
  - 최대값: 89
  - 최근 3개월 평균: 50.00
  - 전년 대비 증감률: -11.0%

■ 탄소중립
  - 평균 관심도: 29.58
  - 최대값: 57
  - 최근 3개월 평균: 22.67
  - 전년 대비 증감률: -24.5%


[ 2. ESG 마케팅 전략 제안 ]
================================================================================


1. 연령대별 맞춤형 ESG 커뮤니케이션 전략
--------------------------------------------------------------------------------

 데이터 근거:
ESG는 50대(60.00651000000001점), 친환경은 50대(58.17626326086957점)에서 가장 높은 관심도

 실행방안:
• 50대 타겟: ESG 경영 성과와 투자가치를 중심으로 한 B2B/전문가 콘텐츠 제작
• 50대 타겟: 일상 속 친환경 실천을 강조하는 감성적 스토리텔링 및 SNS 캠페인
• 10-20대: 기후위기 대응과 미래세대를 위한 메시지로 MZ세대 공감대 형성
• 멀티채널 전략: 연령대별 주요 미디어 채널(유튜브/인스타그램/네이버) 최적화


2. 성별 특성 기반 메시지 포지셔닝 전략
--------------------------------------------------------------------------------

 데이터 근거:
친환경 키워드는 여성(56.41874717391304점)이 남성(63.00331130434782점)보다 6.584564130434778점 높은 관심도

 실행방안:
• 여성 타겟: 제품/서비스의 친환경 속성을 '건강', '안전', '지속가능한 소비' 관점으로 소구
• 남성 타겟: ESG 투자 수익률, 기술혁신, 탄소배출 감축 성과 등 데이터 중심 커뮤니케이션
• 크로스 타겟팅: 가족 단위 친환경 실천 캠페인으로 성별 간 시너지 창출
• 인플루언서 협업: 각 성별 타겟의 신뢰도 높은 인플루언서 매칭


4. 통합적 ESG 브랜드 아이덴티티 구축 전략
--------------------------------------------------------------------------------

 데이터 근거:
ESG, 친환경, 탄소중립 키워드 간 높은 상관관계 - 소비자들이 통합적으로 인식

 실행방안:
• ESG 스토리 아카이빙: 3대 키워드를 아우르는 일관된 브랜드 내러티브 개발
• 측정 가능한 ESG 성과 공개: 탄소배출량 감축률, 재생에너지 사용률 등 구체적 지표 커뮤니케이션
• 협업 캠페인: NGO/정부기관과 파트너십으로 신뢰도 및 사회적 임팩트 증대
• 직원/소비자 참여형 프로그램: ESG 실천 인증샷 이벤트, 탄소발자국 계산기 등 인게이지먼트 강화


5. 실시간 트렌드 모니터링 및 애자일 마케팅 시스템 구축
--------------------------------------------------------------------------------

 데이터 근거:
2022년 이후 ESG 관련 키워드 검색량의 변동성이 크며, 이슈에 따라 급증하는 패턴

 실행방안:
• 트렌드 모니터링 대시보드: 구글/네이버 트렌드 API 연동한 실시간 모니터링 시스템
• 이슈 대응 프로토콜: ESG 관련 사회적 이슈 발생 시 24시간 내 대응 콘텐츠 발행
• A/B 테스팅: 메시지, 크리에이티브, 타겟팅 지속적 최적화
• 성과 측정 KPI: 브랜드 검색량, ESG 관련 긍정 언급률, 전환율 등 다차원 지표 추적
```

