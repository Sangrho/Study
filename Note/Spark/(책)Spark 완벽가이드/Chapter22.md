### CHAPTER 22 이벤트 시간과 상태 기반 처리   
이벤트 시간 처리는 이벤트가 생성된 시간을 기준으로 정보를 분석해 늦게 도착한 이벤트까지 처리해주는 녀석이다.  
이벤트 시간 처리와 상태 기반 처리의 핵심 아이디어는 잡의 전체 생명주기 동안 관련 상태를 유지하는 것이다.  
이 두 가지 방식을 사용해 데이터를 싱크로 출력하기 전에 정보를 갱신할 수 있다.  
  
#### 22.1 이벤트 시간 처리   
스트림 처리 시스템은 두 가지 이벤트 시간 유형을 가진다.  
1. 이벤트가 실제로 발생한 시간(Event Time)  
	데이터에 기록되어 있는 시간.  
	지연되거나 무작위로 도착하는 이벤트를 해결해야 한다.  
2. 이벤트가 시스템에 도착한 시간 또는 처리된 시간(Processing Time)  
	데이터를 실제로 수신한 시간이다.  
	처리 시간은 세부 구현과 관련된 내용이므로 이벤트 시간보다 덜 중요하다.  
  
#### 22.2 상태 기반 처리   
오랜 시간에 걸쳐 중간 처리 정보를 사용하거나 갱신하는 경우(마이크로 배치, 레코드 단위 처리) 에만 필요하다.  
이벤트 시간을 사용하거나 키에 대한 집계를 사용하는 상황에서 일어나는데, 집계키가 반드시 이벤트 시간과 연관성을 가져야 하는 것은 아니다.  
상태 기반 연산에 필요한 중간 상태 정보를 상태 저장소(State Store) 에 저장하게 되는데, 인메모리 상태 저장소를 제공한다.  
상태 저장소는 중간 상태를 체크포인트 디렉터리에 저장해 내고장성을 보장한다.  
  
#### 22.3 임의적인 상태 기반 처리   
상태의 유형, 갱신 방법 그리고 제거 시점에 따라 세밀한 제어가 필요할 수 있는데 이럴 때 처리하는 것을 말한다.  
사용자는 스트림 처리에 필요한 모든 정보를 스파크에 저장할 수 있다.   
  
#### 22.4 이벤트 시간 처리의 기본   
  
#### 22.5 이벤트 시간 윈도우   
##### 22.5.1 텀블링 윈도우  
* 텀블링 윈도우   
![image](https://user-images.githubusercontent.com/4033129/82149079-28c68480-9891-11ea-9728-a0565c56064a.png)  
``` python  
from pyspark.sql.functions import window, col  
  
withEventTime.groupBy(window(col("event_time"), "10 minutes")).count() \  
	.writeStream \  
	.queryName("window") \  
	.format("memory") \  
	.outputMode("complete") \  
	.start()  
```  
  
* 슬라이딩 윈도우  
![image](https://user-images.githubusercontent.com/4033129/82149303-9f638200-9891-11ea-92ec-c33e74774688.png)  
윈도우를 윈도우 시작 시간에서 분리하는 방법을 사용한다.  
아래 예제는 5분마다 시작하는 10분짜리 윈도우를 사용한다.  
``` python  
from pyspark.sql.functions import window, col  
  
withEventTime.groupBy(window(col("event_time"), "10 minutes", "5 minutes")).count() \  
	.writeStream \  
	.queryName("window") \  
	.format("memory") \  
	.outputMode("complete") \  
	.start()  
```  
  
##### 22.5.2 워터마크로 지연 데이터 제어하기  
이전 예제에서는, 얼마나 늦게 도착한 데이터까지 받아들일지 기준을 정하지 않았다.  
데이터가 필요 없어지는 시간을 지정하지 않았기 때문에 스파크는 중간 결과 데이터를 영원히 저장한다.  
따라서 스트림에서 오래된 데이터를 제거하는 데 필요한 워터마크를 반드시 지정해야 한다.  
  
``` python  
from pyspark.sql.functions import window, col  
  
withEventTime \  
	.withWatermark("event_time", "30 minutes") \  
	.groupBy(window(col("event_time"), "10 minutes", "5 minutes")).count() \  
	.writeStream \  
	.queryName("window") \  
	.format("memory") \  
	.outputMode("complete") \  
	.start()  
```  
#### 22.6 스트림에서 중복 데이터 제거하기   
스트림에서 중복을 제거하는 연산은 레코드 단위 처리 시스템에서 가장 처리하기 어려운 연산 중 하나이다.  
중복을 제거해야 하는 컬럼(User) 와 이벤트 시간 컬럼(event_time) 으로 중복을 제거한다.  
  
``` python  
from pyspark.sql.functions import window, col  
  
withEventTime \  
	.withWatermark("event_time", "30 minutes") \  
	.dropDuplicates(["User", "event_time"]) \  
	.groupBy(window(col("event_time"), "10 minutes", "5 minutes")).count() \  
	.writeStream \  
	.queryName("window") \  
	.format("memory") \  
	.outputMode("complete") \  
	.start()  
```  
#### 22.7 임의적인 상태 기반 처리   
비교를 한다면,  
  
* 상대 기반 처리 시 가능한 처리  
	- 특정 키의 개수를 기반으로 윈도우 생성하기  
	- 특정 시간 범위 안에 일정 개수 이상의 이벤트가 있는 경우 알림 발생시키기  
	- 결정되지 않은 시간 동안 사용자 세션을 유지하고 향후 분석을 위해 세션 저장하기  
  
* 임의적인 상태 기반 처리를 수행하면 결과 적으로 두 가지 처리 유형을 만나게 된다.	  
	- 데이터의 각 그룹에 맵 연산을 수행하고 각 그룹에서 최대 한 개의 로우를 만들어 낸다.(mapGroupWithState)  
	- 데이터의 각 그룹에 맵 연산을 수행하고 각 그룹에서 하나 이상의 로우를 만들어 낸다.(flatMapGroupsWithState)  
  
##### 22.7.1 타임아웃  
타임아웃은 중간 상태를 제거하기 전에 기다려야 하는 시간이다.  
각 키별로 그룹이 존재한다고 했을 때, 타임아웃은 전체 그룹에 대한 전역 파라미터로 동작한다.  
  
##### 22.7.2 출력 모드  
사용자 정의 상태 기반 처리에서는 출력 모드를 모두 지원하지 않는다.  
  
##### 22.7.3 mapGroupsWithState  
갱신된 데이터셋을 입력으로 받고 값을 특정 키로 분배하는 사용자 정의 집계 함수와 유사하다.  
아래와 같은 사항을 정의해야 한다.  
	- 세 가지 클래스 정의 : 입력, 상태, 출력 클래스  
	- 키, 이벤트 이터레이터 그리고 이전 상태를 기반으로 상태를 갱신하는 함수  
	- 타임아웃 파라미터  
  
##### 22.7.4 flatMapGroupsWithState  
단일 키의 출력 결과가 여러 개 만들어지는 것 제외하고는 mapGroupsWithState 와 유사하다.  
