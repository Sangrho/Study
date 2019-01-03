## Spark Optimization

## 기본 개념 및 유의점

### Tungsten
- Spark 1.5 이상부터 적용된 기술

### UDF(User Defined Function) 함수 피하기
- **Dataset API**를 사용하는 것을 권장
- **UDF**를 사용하는 것은
    - deserialize to scala 이후, reserialize 과정을 거치기 때문
- UDF는 충분히 **Spark SQL** 함수로 변환할 수 있음
- UDF의 장/단점
    - refactoring tradeoff **performance**
- UDF 사용 예시
    ```
    def currency = udf(
        (currencySub: String, currencyParent: String) ⇒
        Option(currencyParent) match {
            case Some(curr) ⇒ curr
            case _ ⇒ currencySub
        }
    )
    ```
    - 이 함수는 충분히 `coalese` 함수로 대체될 수 있음

### UDAFs(User Defined Aggregation Functions, 사용자 정의 집계 함수) 피하기
- UDAF를 사용하는 것은 내부적으로 **significantly**를 사용한다.
    - 이는 **hashAggregate**보다 10배 이상 느리다
- UDAF 대신, 내장 함수로 대체할 수 있다.
    ```
    # median value 계산을 위한 내장 함수(quantile, 0.5)
    df.stat.approxQuantile("value", Array(0,5), 0)
    ```
- **approxQuantile** 함수
    - *Greenwald-Khanna* 알고리즘을 사용
    - UDAF보다 10배 이상 빠름
- UDF를 분할하여, 결과 코드의 한 부분에 내장 함수를 이용하여 구성할 수 있다는 점에 유의


## 실행 결과 확인하여 튜닝하기
- execution plan을 확인하여 개선하기
    - 비정상적인 단계 확인
        - DF 기본 조인간에 2~3단계가 아닌, **10단계**를 요구하는 계획 확인 등
- spark에서는 셔플링을 피해야함
    - 셔플링은 `.join`이나 `.groupBy()`와 같은 연산에서 발생
    - stage간에 발생한다.
- **stage의 수를 줄여야 함**
- `.explan(true)`
    - execution plan을 확인할 수 있음
    - ![image](https://user-images.githubusercontent.com/10006290/50625485-e0dce100-0f6b-11e9-98be-58231475580f.png)
- Spark UI의 **DAG**
- [Cost-based Optimizer Framework](https://issues.apache.org/jira/browse/SPARK-16026)
    - 비용 기반 최적화 방식
    - `v2.3.0`이상부터 적용
    - broadcast join 외에 사용할 수 있는 방법


## 데이터 파악 및 효율적 관리
- data 측면에서의 최적화 방법

### Highly imbalanced datasets
- 프로세스 처리간 비정상적인 작업 시간 확인
    - 특정 task가 매우 느리게 작업되는 등
    - 전체 작업기간의 연장 발생
- SparkUI에서 최대/최소/중간 기간 확인하기
    - Summary Metric에서 **Min**, **Median**, **Max** 확인
    - 상세한 정보는 하단 **duration**에서 확인

### 부적절한 캐싱 사용
- 중간 결과를 캐싱하면 빠를 수 있음
- spark의 caching strategy(Mem -> disk swap)으로 인해,
    - 캐시의 저장속도가 느려질 수 있음
    - 캐싱을 위해 저장공간을 사용할 수 없는 경우 발생
        - 캐싱은 단순히 DF를 읽는 것보다 cost가 높을 수 있음
- Spark UI에서 **Storage** 탭 확인
    - **Fraction Cache** 내용 확인
        - ![image](https://user-images.githubusercontent.com/10006290/50625679-fb638a00-0f6c-11e9-88b6-2e8207b2b068.png)

### BroadCasting
- shuffle을 피하기 위해 사용
    - 작은 DF를 전체 노드에 정보 교환하기 위해
    ```
    aution
    .join(broadbase(website) as "w", $"w.id" === $"website_id")
    ```
- broadcast를 사용시,
    - 모든 task를 복사하여 보내는 대신,
    - 캐시된 RO 변수를 한번 보낼 수 있음
- spark는 broadcast를 해야하는 DF를 자동으로 식별함
    - 단, 공식 문서와 동일하게 동작하지 않을 수 있음


referenced by, [Medium Trends](https://medium.com/teads-engineering/spark-performance-tuning-from-the-trenches-7cbde521cf60)