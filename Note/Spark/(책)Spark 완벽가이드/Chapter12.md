### 12.1 저수준 API란   
크게 두 종류의 저수준 API 가 있다.  
1. 분산데이터 처리를 위한 RDD  
2. 브로드캐스트 변수와 어큐물레이터처럼 분산형 공유 변수를 배포하고 다루기 위한 API  
  
### 12.2 RDD 개요   
RDD 는 스파크 1.x 버전의 핵심 API 이다.   
2버전 부터 나온 DataFrame이나 3버전부터 나온 Dataset 코드는 RDD로 컴파일 된다.  
스파크 Web UI 에서도 RDD단위로 잡이 수행됨을 알 수 있기 때문에, 적어도 무엇이고 어떻게 사용하는지를 알아야만 한다.  
  
RDD 는 *불변성을 가지며 병렬로 처리할 수 있는 파티셔닝된 레코트의 모음* 이다.  
DataFrame 의 각 레코드는 스키마를 알고 있는 필드로 구성된 구조화된 로우인 반면, RDD의 레코드는 그저 프로그래머가 선택하는 자바, 스칼라, 파이썬의 객체이다.  
  
#### 12.2.1 RDD 유형  
두 가지 타입의 RDD 가 있다.  
1. 제네릭 RDD  
2. 키 기반의 집계가 가능한 키-값 RDD  
  
RDD의 주요속성은 아래와 같다.  
1. 파티션의 목록  
2. 각 조각을 연산하는 함수  
3. 다른 RDD와의 의존성 목록  
4. 부가적으로 키-값 RDD를 위한 Partitioner  
5. 부가적으로 각 조각을 연산하기 위한 기본 위치 목록  
   
! Partitioner 는 RDD 를 사용하는 주된 이유다.  
RDD 는 ROW 라는 개념이 없으며, Python 에서도 사용 가능하다. 다만 Python 을 통한 RDD 사용은 기능저하를 불러일으킨다.  
  
#### 12.2.2 RDD는 언제 사용할까  
정말 필요할 경우가 아니라면 수동으로 RDD 를 생성하면 안된다.  
물리적으로 분산된 데이터 ( 자체적으로 구성한 데이터 파티셔닝 ) 에 세부적인 제어가 필요할 때 RDD 를 사용하는 것이 가장 적합하다.  
  
### 12.3 RDD 생성하기   
  
#### 12.3.2 로컬 컬렉션으로 RDD 생성하기  
컬렉션 객체를 RDD 로 만들려면 sparkContext 의 parallelize 메서드를 호출해야 한다.  
이 메서드는 단일 노드에 있는 컬렉션을 병렬 컬렉션으로 전환하며, 파티션 수를 명시적으로 지정할 수 있다.  
  
```  
myCollection ="Spark The Definitive Guide : Big Data Processing Made Simple"  
words = spark.spark(Context.parallelize(myCollection,2)  
```  
  
### 12.4 RDD 다루기   
  
### 12.5 트랜스포메이션   
* distinct  
* filter  
```  
def startsWithS(individual):  
    return individual.startswith("S")  
words.filter(lambda word: startsWith(word)).collect()  
```  
* map  
```  
words2 = words.map(lambda word: (word, word[0],word.startswith("S")))  
words2.filter(lambda record: record[2]).take(5)  
```  
-> Spark 의 S, true 와 Simple, S, true 가 결과로 나온다.  
* flatMap  
```  
words.flatMap(lambda word: list(word)).take(5)  
```  
-> S, P, A, R, K  
* sordBy  
* randomSplit  
  
### 12.6 액션   
*  12.6.1 reduce  
RDD 의 모든 값을 하나의 값으로 만들려면 reduce 메서드를 사용한다.  
```  
spark.sparkcontext.parallelize(range(1,21)).reduce(lambda x, y:x +y)  
```  
-> 210  
* count  
	- countApprox : count 함수의 근사치를 제한 시간 내에 계산  
	- countApproxDistinct   
	- countByValue : RDD 값의 개수, 익스큐터의 연산 결과가 드라이버 메모리에 모두 적재되므로 결과가 작은 경우에만 사용해야 한다.  
	- countByValueApprox : 근사치를 계산  
* first  
* max / min  
* take : RDD 에서 가져올 값의 개수를 파라미터로 사용한다.  
이 메서드는 먼저 하나의 파티션을 스캔한다. 그 다음에 해당 파티션의 결과 수를 이용해 파라미터로 지정된 ㅏㄱㅂㅅ을 만족하는 데 필요한 추가 파티션 수를 예측한다.  
  
### 12.7 파일 저장하기   
* saveAsTextFile  
* 시퀀스 파일  
* 하둡파일  
  
### 12.8 캐싱   
캐싱 : 캐시와 저장(persist) 은 메모리에 있는 데이터만을 대상으로 한다.  
```  
words.cache()  
```  
  
### 12.9 체크포인팅   
DataFrame 에서는 사용할 수 없는 기능으로, RDd 를 디스크에 저장하는 방식  
디스크에 저장한다는 사실만 제외하면 캐싱과 유사하며, 반복적인 연산 수행시 매우 유용하다.  
```  
spark.sparkContext.setCheckpointDir("/some/path/for/checkpoininting")  
words.checkpoint()  
```  
  
### 12.10 RDD를 시스템 명령으로 전송하기   
* pipe  
```  
words.pipe("wc -l").collect()  
```  
  
#### 12.10.1 mapPartitions  
스파크는 실제 코드를 실행할 때 파티션 단위로 동작한다.  
mapPartitions 는 개별 파티션에 대해 map 여낫ㄴ을 수행할 수 있다. 그 이유는 클러스터에서 물리적인 단위로 개별 파티션을 처리하기 때문.  
이 메서드는 기본적으로 파티션 단위로 작업한다.  
따라서 전체 파티션에 대한 연산을 수행할 수 있다.  
```  
words.mapPartitions(lambda part: [1]).sum()  
```  
-> 2  
  
#### 12.10.2 foreachPartition  
mapPartitions 와 차이점은 데이터를 순회할 뿐(interator) 결과를 반환하진 안흔ㄴ다.  
각 파티션의 데이터를 DB에 저장하는 것과 같은 작업에 적합하다.  
  
#### 12.10.3 glom  
데이터셋의 모든 파티션을 배열로 변환한다.  
데이터를 드라이버로 모으고 데이터가 존재하는 파티션의 배열이 필요할 경우에 매우 유용.  
하지만 파티션이 크거나 파티션 수가 많다면 드라이버가 비정상적으로 종료될 수 있으므로 유의한다.  
