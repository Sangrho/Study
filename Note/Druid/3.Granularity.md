## Granularity
Druid 는 Timestamp 기반으로 데이터가 저장되고 조회되며, Granularity 라는 단위로 다양한 설정이 가능하다.

## Granularity 의 상관관계
indexGranularity < intermediatePersistPeriod =< windowPeriod < segmentGranularity

![image](https://user-images.githubusercontent.com/4033129/44765771-415cab80-ab91-11e8-83ff-e418487d6838.png)<br/>
(Reference : https://github.com/streamlyzer/druidForSL/blob/master/docs/content/Realtime-ingestion.md)

## Granularity 설명

1.Segment Granularity<br/><br/>
Druid 에 저장되는 데이터는 Segment 라는 단위로 저장이되며,
이 설정 값을 통해 Segment 를 나누는 단위를 지정하게 된다. 곧 Indexing을 하는 파일 단위가 된다.

2.Query Granularity<br/><br/>
실시간 데이터들을 묶는 개념이다.
만약 1분으로 설정했을 경우, Broker 를 통해 데이터를 조회할 때 Timestamp 조건은 분 단위로 조회가 가능하게 된다.

3.WindowPeriod<br/><br/>
Event 에 허용된 여유시간이다.
이 설정 값이 필요한 이유는, 시간이 바뀌어도 이전 시간 데이터가 들어올 수 있기 때문이다.

## Granularity 설정에 따른 데이터 흐름

예를 하나 들어보겠다.
Task(Peon) 을 8개를 띄웠으며,
SegmentGranularity 는 PT1H, WindowPeriod 는 PT5M 로 설정할 경우 아래와 같다.<br/>
![image](https://user-images.githubusercontent.com/4033129/44766024-67368000-ab92-11e8-9ba0-39d6761cc2f7.png)<br/><br/>
[ 설명 ]<br/>
1. 14:00 ~ 15:00 에는 Task 가 8개가 떠있게 된다.<br/>
2. 15:00 ~ 15:15 는 Task 가 16개가 있게 된다. 14:00 ~ 15:00 Task 가 아직 끝나지 않았기 때문에 떠있게 되고, 15:00 ~ 16:00 Task 도 떠있게 된다.


## Granularity 에 사용가능한 포맷
![image](https://user-images.githubusercontent.com/4033129/44765988-43733a00-ab92-11e8-9e8b-d6b793137b42.png)
(Reference : http://druid.io/docs/latest/querying/granularities.html)
