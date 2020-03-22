### CHAPTER 13 RDD 고급 개념 
```
myCollection = "Spark The Definitive Guide : Big Data Processing Made Simple".split(" ")
words = spark.sparkContext.parallelize(myCollection,2)
```
#### 13.1 키-값 형태의 기초(키-값 형태의 RDD) 
키-값 형태로 다룰 수 있는 다양한 메서드가 있는데, <연산명>Bykey 형태의 이름으로 되어 있다.
Bykey 가 있다면 PairRDD 타입만 사용할 수 있다.
예)
```
words.map(lamda word: (word.lower(),1))
words.take(10)
# 결과 : ['Spark', 'The', 'Definitive', 'Guide', ':', 'Big', 'Data', 'Processing', 'Made', 'Simple']
```
* 13.1.1 keyBy
```
keyword = words.keyBy(lambda word: word.lower()[0])
keyword.take(10)
# 결과 : [('s', 'Spark'), ('t', 'The'), ('d', 'Definitive'), ('g', 'Guide'), (':', ':'), ('b', 'Big'), ('d', 'Data'), ('p', 'Processing'), ('m', 'Made'), ('s', 'Simple')]
```
* 13.1.2 값 매핑하기
- mapValues ( 튜플의 첫 번째 요소를 키로, 두 번째 요소를 값으로 추정한다. )
```
keyword.mapValues(lambda word: word.upper()).collect()
# 결과 : [('s', 'SPARK'), ('t', 'THE'), ('d', 'DEFINITIVE'), ('g', 'GUIDE'), (':', ':'), ('b', 'BIG'), ('d', 'DATA'), ('p', 'PROCESSING'), ('m', 'MADE'), ('s', 'SIMPLE')]
```
- flatMapValues ( 단어의 각 문자를 값으로 하는 배열이 생성된다. )
```
keyword.flatMapValues(lambda word: word.upper()).collect()
# 결과 : [('s', 'S'), ('s', 'P'), ('s', 'A'), ('s', 'R'), ('s', 'K'), ('t', 'T'), ('t', 'H'), ('t', 'E'), ('d', 'D'), ('d', 'E'), ('d', 'F'), ('d', 'I'), ('d', 'N'), ('d', 'I'), ('d', 'T'), ('d', 'I'), ('d', 'V'), ('d', 'E'), ('g', 'G'), ('g', 'U'), ('g', 'I'), ('g', 'D'), ('g', 'E'), (':', ':'), ('b', 'B'), ('b', 'I'), ('b', 'G'), ('d', 'D'), ('d', 'A'), ('d', 'T'), ('d', 'A'), ('p', 'P'), ('p', 'R'), ('p', 'O'), ('p', 'C'), ('p', 'E'), ('p', 'S'), ('p', 'S'), ('p', 'I'), ('p', 'N'), ('p', 'G'), ('m', 'M'), ('m', 'A'), ('m', 'D'), ('m', 'E'), ('s', 'S'), ('s', 'I'), ('s', 'M'), ('s', 'P'), ('s', 'L'), ('s', 'E')]
```
* 13.1.3 키와 값 추출하기
```
keyword.keys().collect()
keyword.values().collect()
# 결과 : ['Spark', 'The', 'Definitive', 'Guide', ':', 'Big', 'Data', 'Processing', 'Made', 'Simple']
```
* 13.1.4 lookup
특정 키에 관한 결과를 찾을 수 있다. 예를 들어 lookup 함수의 인수로 's' 를 입력하면 키가 's' 인 게 출력된다.
```
keyword.lookup("s")
# 결과 : ['Spark', 'Simple']
```

* 13.1.5sampleByKey
RDD 를 한 번만 처리하면서 간단한 무작위 샘플링을 사용하게 된다.
```
import random
distinctChars = words.flatMap(lambda word: list(word.lower())).distinct().collect()
sampleMap = dict(map(lambda c: (c, random.random()), distinctChars))
words.map(lambda word: (word.lower()[0],word)).sampleByKey(True, sampleMap, 6).collect()
# 결과 : [('t', 'The'), ('d', 'Definitive'), ('g', 'Guide'), (':', ':'), ('d', 'Data'), ('s', 'Simple'), ('s', 'Simple')]
```

#### 13.2 집계 
```
chars = words.flatMap(lambda word: word.lower())
KVcharacters = chars.map(lambda letter: (letter,1))

def maxFunc(left,right):
    return max(left,right)
def addFunc(left,right):
    return left + right
nums = sc.parallelize(range(1,31),5)
nums.take(10)
```
* 13.2.1 countByKey
키 별 아이템 수를 구해본다.
```
KVcharacters.countByKey()
# 결과 : defaultdict(<class 'int'>, {'s': 4, 'p': 3, 'a': 4, 'r': 2, 'k': 1, 't': 3, 'h': 1, 'e': 7, 'd': 4, 'f': 1, 'i': 7, 'n': 2, 'v': 1, 'g': 3, 'u': 1, ':': 1, 'b': 1, 'o': 1, 'c': 1, 'm': 2, 'l': 1})
```
* 13.2.2 집계 연산 구현 방식 이해하기
키-값 형태의 ParRDD 를 생성하기 위해 여러가지 방법이 있는데, 이때 구현 방식은 잡의 안정성을 위해 매우 중요하다.
이를 설명하기 위해 groupBy 와 reduce함수를 키를 기준으로 비교해 본다.
	- groypByKey
	각 키의 총 레코드수를 구하는 경우 groupByKey 의 결과로 만들어진 그룹에 map 연산을 수행하는 방식이 가장 좋아 보인다.
	하지만 가장 큰 문제는 모든 익스큐터에서 함수를 적용하기 전에 해당 키와 관련된 모든 값을 메모리로 읽어 들여야 한다는 것이다.
	치우쳐진 키(?) 가 있다면 일부 파티션이 엄청난 양의 값을 가질 수 있으므로 OOM이 발생할 수 있다.
	그러므로 각 키에 대한 값의 크기가 일정하고, 익스큐터에 할당된 메모리에서 처리 가능할 정도일 때만 해당 메서드를 사용한다.
	```
	from functools import reduce
	KVcharacters.groupByKey().map(lambda row: (row[0], reduce(addFunc, row[1]))).collect()
	# 결과 : [('s', 4), ('p', 3), ('r', 2), ('h', 1), ('d', 4), ('i', 7), ('g', 3), ('b', 1), ('c', 1), ('l', 1), ('a', 4), ('t', 3), ('o', 1), ('e', 7), ('n', 2), ('m', 2), ('k', 1), ('f', 1), ('v', 1), ('u', 1), (':', 1)]
	```
	- reduceByKey
	해당 메소ㄹ드를 사용하면, 각 파티센여세 리듀스 작업을 수행하기 때문에 훨씬 안정적이며 모든 값을 메모리에 유지하지 않아도 된다.
	또한 최종 리듀스 과정ㅇ르 제외한 모든 작업은 개별 워커에서 처리하기 때문에 연산중에 셔플이 발생하지 않게 된다.
	하지만 정렬되어 있지 않기 때문에, 작업부하를 줄이는 경우만 사용하고 순서가 중요한 경우는 사용하지 말자.
	```
	KVcharacters.reduceByKey(addFunc).collect()
	# 결과 : [('b', 1), ('i', 7), ('g', 3), ('d', 4), ('p', 3), ('r', 2), ('c', 1), ('s', 4), ('l', 1), ('h', 1), ('a', 4), ('k', 1), ('t', 3), ('e', 7), ('f', 1), ('n', 2), ('v', 1), ('u', 1), (':', 1), ('o', 1), ('m', 2)]
	```
* 13.2.3 기타 집계 메서드
	- aggregate : 드라이버에서 최종 집계를 수행하기 때문에, 익스큐터의 결과가 너무 크면 OOM이 발생할 수 있다.
	- treeAggregate : 드라이버에서 최종 집계를 수행하기 전에 익스큐터끼리 트리를 형성해 집계 처리의 일부 하위 과정을 푸시다운 방식으로 먼저 수행한다.
	집계 처리를 여러 단계로 나누기 때문에 드라이버의 메모리를 소비하는데 절약할 수 있다.
	- aggregateByKey : aggregate 함수와 동일하지만 파티션 대신 키를 기준으로 연산을 수행한다.
	- combineByKey : combiner 를 사용하는데, 키를 기준으로 연산ㅇ르 수행하며 파라미터로 사용된 함수에 따라 값을 병합한다. 그런 다음 여러 컴바이너의 결과값을 	병합해 결과르 판단한다.
	- foldByKey 

#### 13.3 cogroup 
파이썬을 사용하는 경우 최대 2개의 키-값 형태의 RDD 를 그룹화할 수 있으며 각 키를 기준으로 값을 결합한다.
즉, RDD 를 그룹화할 수 있으며 각 키를 기준으로 값을 결합한다.
즉, RDD 에 대한 그룹기반의 조인을 수행한다.
출력 파티션 수나 클러스터에 데이터 분산 방식을 정확하게 제어하기 위해 사용자 정의 파티션 함수를 파라미터롤 사용할 수 있다.

#### 13.4 조인 


#### 13.5 파티션 제어하기 
* 13.5.1 coalesce
파티션을 재분배할 때 발생하는 데이터 셔플을 방지하기 위해 동일한 워커에 존재하는 파티션을 합치는 메서드다.

* 13.5.2 repartition
파티션 수를 늘리거나 줄일 수 있지만, 처리 시 노드 간의 셔플이 발생할 수 있다.
파티션 수를 늘리면 맵 타입이나 필터 타입의 연산을 수행할 때 병렬 처리 수준을 높일 수 있다.
* 13.5.3 repartitionAndSortWithinPartitions
* 13.5.4 사용자 정의 파티셔닝

```
df = spark.read.option("header","true").option("inferSchema", "true").csv("/tmp/aa.txt")
rdd = df.coalesce(10).rdd

df.printSchema()
# 결과 : root
# |-- a: integer (nullable = true)
# |-- b: string (nullable = true)
# |-- c: integer (nullable = true)
```

#### 13.6 사용자 정의 직렬화 
기본 직렬화 기능은 매우 느리며, 스파크는 kryo 라이브러리를 사용해 더 빠르게 객체를 직혈화 할 수 있다. 일반적으로 10 배 이상 성능이 좋으며 더 간결하다.
SparkConf 사용해 잡을 초기화 하는 시점에 spark.serializer 에 org.apache.spark.serializer.KryoSerializer 로 설정하면 된다.
```

```
#### 13.7 정리 
