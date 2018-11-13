## Lambda Architecutre
- 람다 아키텍처(Lambda Architecture)란?
    - 실시간 분석을 지원하는 빅데이터 아키텍처
    - 대량의 데이터를 실시간으로 분석하기 위하여
        - batch로 미리만든 데이터와 실시간 데이터를 혼합하여 사용하는 방식
    - 람다 방정식
        ```
        Query =  λ(Complete data) =  λ(live Streaming Data) *  λ(Stored data)
        # 스트리밍 데이터와 기존 데이터의 combine으로 이루어짐
        ```
- 람다 아키텍처 로직
    - ![Lambda](http://lambda-architecture.net/img/la-overview_small.png)
    - 데이터가 생성되면 데이터 저장소에 저장
    - 데이터는 batch로 일정 주기별 배치 뷰를 만든다.
    - 데이터를 실시간 처리를 통하여 real-time 뷰를 만든다.
    - batch와 real-time을 동시 분석하여 실시간 데이터가 반영된 분석이 가능
- 람다 아키텍처 적용
    - 사용자 쿼리가 변하지 않는 데이터 공간을 사용하여 처리
    - 빠른 응답을 요구하면서, 새로운 데이터 스트림 형태로 다양한 업데이트 처리
    - 저장된 레코드는 지워지지 않으면서 업데이트 및 새 데이터를 DB에 추가 가능
- Layer
    - Batch Layer
        - raw 데이터가 저장
        - **batch view** 생성
    - Serving Layer
        - batch로 분석된 데이터 저장
        - batch 외에 쓰기 불가
        - batch와 speed의 결과를 취합하여 사용자로부터 쿼리를 처리
    - Speed Layer
        - 실시간 데이터 집계
    - **batch view**와 **real-time view**의 데이터가 겹치지 않도록 관리
        - **timestamp**로 해결
        - batch로 데이터가 만들어진 후,
            - 실시간 뷰의 데이터를 주기적으로 지워주어야 함
- Layer Component
    - 적용 시스템 리스트
    - Batch Layer Component
        - Hadoop MapReduce
        - Spark
        - Hive
        - SparkSQL
        - Pig
        - Sport
        - Cascading.Scalding
        - Cascalog
        - Crunch/Scrunch
        - Pangool
    - Serving Layer Component    
        - ElephantDB
        - SploutSQL
        - Voldemort
        - Hbase
        - Druid
    - Speed Layer Component
        - Apache Storm
        - Apache Spark Streaming
        - Apache Samza
        - Apache S4
        - Spring XD
- 람다 아키텍처의 장단점
    - 장점
        - 시스템 장애가 발생하더라도 Batch Layer의 Fault Tolerance로 안정성 보장
        - Fault Tolerant
    - 단점
        - 포괄 처리를 포함, overhead 발생
        - Re-processes every batch cycle which is not beneficial in certain scenarios
        - Migration이나 재구성하기 어려움

---
reference : [All of link in Architecture markdown](/Link/Architecture.md)