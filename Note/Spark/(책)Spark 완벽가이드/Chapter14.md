### CHAPTER 14 분산형 공유 변수   
* 브로드캐스트 변수  
	- 모든 워크 노드에 큰 값을 저장하므로 재전송 없이 많은 스파크 액션에서 재사용할 수 있다.  
	- 분산된 큰 값들에 사용  
* 어큐뮬레이터  
	- 모든 태스크의 데이터를 공유 결과에 추가할 수 있다.  
	- 특정 컬렉션의 정보를 합산할 때 사용  
  
#### 14.1 브로드캐스트 변수   
브로드캐스트 변수는 불변성 값을 Closure 함수의 변수로 캡슐화하지 않고 클러스터에서 효율적으로 공유하는 방법을 제공한다.  
태스크에서 드라이버 노드의 변수를 사용할 때 Closure 함수 내부에서 단순하게 참조하는 방법을 사용하는데, 이 방법은 비효율적이다.  
룩업 테이블이나 머신러닝 모델 같은 큰 변수를 사용하는 경우 더 비효율적이다.  
그 이유는 Closure 함수에서 변수를 사용할 때 워커 노드에서 여러 번(Task 당 한 번) 역직렬화가 일어나기 때문이다. 게다가 여러 스파크 액션과 잡에서 동일한 변수를 사용하면 잡을 실행할 때마다 워커로 큰 변수를 재전송한다.  
  
이런 경우 브로드캐스트 변수를 사용해야만 한다. 브로드캐스트 변수는 모든 태스크마다 직렬화하지 않고 클러스터의 모든 머신에 캐시하는 불변성 공유 변수이다.  
아래 그림과 같이 익스큐터 메모리 크기에 맞는 조회용 테이블을 전달하고 함수에서 사용하는 것이 대표적인 예이다.  
  
![image](https://user-images.githubusercontent.com/4033129/77248641-6090c180-6c7e-11ea-84f4-0ff0715bc597.png)  
  
예)  
```  
# 단어나 값의 목록을 가지고 있다.  
  
my_collection = " Spark The Definitive Guide : Big Data Processing Made Simple".split(" ")  
words = spark.sparkContext.parallelize(my_collection,2)  
  
# 수 킬로에서 기가바이트 크기를 가진 다른 정보와 함께 단어 목록을 추가해야 할 수 있다.(right Join)  
  
supplementalData = {"Spark":1000,"Definitive":200,"Big":-300,"Simple":100}  
  
# 해당 구조체를 브로드캐스트 하는 코드이다.  
  
suppbroadcast = spark.sparkContext.broadcast(supplementalData)  
  
# suppBroadcast 변수의 value메서드를 사용해 값을 참조할 수 있다. value 메서드는 데이터를 직렬화 하지 않아도 접근할 수 있다.  
  
suppBroadcast.value  
  
# 브로드캐스트된 데이터를 사용해 RDD 를 변환할 수 있다.  
  
words.map(lambda word: (word, suppBroadcast.value.get(word,0))).  
	.sortBy(lambda wordPair: wordPari[1])  
	.collect()  
```  
데이터카 크면 클 수록 직렬화 하는데에 큰 부하가 발생할 수 있으므로, 브로드캐스트가 훨씬 유용하게 사용하게 될 것이다.  
  
#### 14.2 어큐뮬레이터   
어큐뮬레이터는 트랜스포메이션 내부의 다양한 값을 갱신하는 데 사용한다. 그리고 내고장성을 보장하면서 효율적인 방식으로 드라이버에 값을 전달할 수 있다.  
  
![image](https://user-images.githubusercontent.com/4033129/77248765-43102780-6c7f-11ea-9a42-aa19f59a565f.png)  
  
어큐뮬레이터의 동작 단계는 아래와 같다.  
1. 드라이버에서 SparkContext.accumulator(initialValue)를 호출해서 초기값을 가진 어큐뮬레이터를 만든다.  
반환타입은 org.apache.spark.Accumulator[T]객체고 T는 선언한 초기값 타입이다.  
2. 스파크 클로져 작업 노드에서 어큐뮬레이터에 값을 더했다.  
3. 드라이버 프로그램에서 value속성으로 어큐뮬레이터 값에 접근한다  
  
어큐뮬레이터의 값은 액션을 처리하는 과정에서만 갱신된다.  
예)  
```  
flights = spark.read.parquet("2020-summary.parquet")  
  
# 출발지나 도착지가 중국인 항공편의 수를 구하는 어큐뮬레이터를 생성해보자.  
  
accChina = spark.sparkContext.accumulator(0)  
  
# 함수로 구현을 해본다면..  
  
def accChinaFunc(flight_row):  
	destination = flight_row["DEST_COUNTRY_NAME"]  
	origin = flight_row["ORIGIN_COUNTRY_NAME"]  
  
	if destination == "China":  
		accChina.add(flight_row["count"])  
	if origin == "China":  
		accChina.add(flight_row["count"])  
  
# foreach 메서드를 사용해 항공운항 데이터셋의 전체 로우를 처리해 본다.  
  
flights.foreach(lambda flight_row: accChinaFunc(flight_row))  
```  
