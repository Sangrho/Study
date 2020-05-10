### CHAPTER 21 구조적 스트리밍의 기초   
  
#### 21.1 구조적 스트리밍의 기초   
구조적 스트리밍의 핵심 아이디어는 스트림 데이터를 데이터가 계속해서 추가되는 테이블처럼 다루는 것이다.  
  
![image](https://user-images.githubusercontent.com/4033129/81496137-4ecbb200-92f0-11ea-9156-8ce0eba7cf09.png)  
  
구조적 스트리밍에서는 DataFrame 도 스트리밍 방식으로 동작한다.  
  
#### 21.2 핵심 개념   
##### 21.2.1 트랜스포메이션과 액션  
##### 21.2.2 입력소스  
##### 21.2.3 싱크  
입력소스로 데이터를 얻듯이, 싱크로 스트림의 결과를 저장할 목적지를 명시한다.  
##### 21.2.4 출력모드  
- append  
- update  
- complete: 전체 출력 내용 재작성하기  
  
##### 21.2.5 트리거  
데이터 출력 시점을 정의하며, 구조적 스티리밍에서 언제 신규 데이터를 확인하고 결과를 갱신할지 정의한다.  
구조적 스티리밍은 기본적으로 마지막 입력 데이터를 처리한 직후에 신규 입력 데이터를 조회해 최단 시간 내에 새로운 처리 결과를 만들어 낸다.  
하지만 이런 동작 방식 때문에 파일 싱크를 사용하는 경우 작은 크기의 파일이 여러 개 생길 수 있으므로 처리시간 기반의 트리거를 지원한다.  
  
##### 21.2.6 이벤트 시간 처리  
무작위로 도착한 레코드 내부에 기록된 타임스탬프를 기준으로 한다.  
    1. 이벤트 시간 데이터  
    데이터에 기록된 시간 필드를 이용한다.  
    2. 워터마크  
    - 늦게 들어온 이벤트를 어디까지 처리할지 시간을 제한할 수 있다.  
    - 특정 이벤트 시간의 윈도우 결과를 출력하는 시점을 제어할 때도 사용한다.  
  
#### 21.3 구조적 스트리밍 활용   
1. 정적 방식  
``` python  
static = spark.read.json("/data/activity-data/")  
dataSchema = static.schema  
```  
2. 동적 방식  
``` python  
streaming = spark.readStream.schema(dataSchema).option("maxFilesPerTrigger",1).json("/data/activity-data")  
activityCounts = streaming.groupBy("gt").count()  
activityQuery = activityCounts.writeStream.queryName("activity_counts") \  
    .format("memory").outputMode("complete").start()  
activityQuery.awaitTermination() # 쿼리 종료 시까지 대기할 수 있도록 반드시 지정을해야하며, 드라이버 프로세스가 종료되는 상황을 막을 수 있다.  
```  
  
#### 21.4 스트림 트랜스포메이션   
##### 21.4.1 선택과 필터링  
``` python  
simpleTransform = streaming.withColumn("stairs",expr("gt like '%stairs%'")) \  
    .where() \  
    .writeStream \  
    .queryName("query") \  
    .format("memory") \  
    .outputMode("append") \  
    .start()  
```  
##### 21.4.2 집계  
구조적 스트리밍은 매우 뛰어난 집계 기능을 지원한다.  
  
##### 21.4.3 조인  
스파크 2.2 기준, 오른쪽 스트림 데이터를 대상으로 전체 외부 조인과 왼쪽 조인을 지원하지만, 왼쪽 스트림 데이터에 대한 오른쪽 조인은 지원하지 않는다.  
  
#### 21.5 입력과 출력   
##### 21.5.1 데이터를 읽고 쓰느 장소(소스와 싱크)  
##### 카프카 소스에서 메시지 읽기  
1. 메시지를 읽기 위해 먼저 선택해야 할 옵션은 아래와 같다.  
    - assign : 토픽과 파티션까지 세밀하게 지정하는 옵션  
    - subscribe  
    - subscribePattern  
2. 두번째로 kafka.bootstrap.servers 값 지정  
3. 기타 옵션  
    - startingOffset / endingOffsets : earliest, latest  
    - failOnDataLoss : 데이터 유실이 일어났을 경우 쿼리를 중단할지 말지를 지정하며 default 는 true.  
    - maxOffsetsPerTrigger : 특정 트리거 시점에 읽을 포트셋의 전체 개수  
  
``` python  
df1 = spark.readStream.format("kafka") \  
    .option("kafka.bootstrap.servers",) \  
    .option("subscribe", "topic1") \  
    .load()  
df2 = spark.readStream.format("kafka") \  
    .option("kafka.bootstrap.servers",) \  
    .option("subscribe", "topic1, topic2") # 여러개의 토픽 컨슘\  
    .load()  
df3 = spark.readStream.format("kafka") \  
    .option("kafka.bootstrap.servers",) \  
    .option("subscribePattern", "topic.*") # 패턴에 맞는 토픽 수신 \  
    .load()  
  
```  
  
##### 21.5.3 카프카 싱크에 메세지 쓰기  
``` python  
dfa.selectExpr("topic"," ") \  
    .writeStream \  
    .format("kafka") \  
    .option("kafka.bootstrap.servers") \  
    .option("checkpointLocation","HDFS/dir") \  
    .start()  
```  
  
##### 21.5.4 데이터 출력 방법(출력모드)  
##### 21.5.5 데이터 출력 시점(트리거)  
데이터를 싱크로 출력하는 시점을 제어하려면 트리거를 설정해야한다.  
기본적으로 구조적 스트리밍에서는 직전 트리거가 처리를 마치자마자 즉시 데이터를 출력한다.  
* 처리 시간 기반 트리거  
``` python  
activityCounts.writeStream.trigger(processingTime='5 seconds') \  
    .format("console").outputMode("complete").start()  
```  
  
* 일회성 트리거  
``` python  
activityCounts.writeStream.trigger(once=True) \  
    .format("console").outputMode("complete").start()  
```  
  
#### 21.6 스트리밍 Dataset API   
  
