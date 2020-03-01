[ Chapter 11 ]
### CHAPTER 11 Dataset     
"org/apache/spark/sql/package.scala" 에서    
type DataFrame = Dataset[Row] 로 선언됨을 알 수 있다.    
Dataset 은 JVM 을 사용하는 스칼라, 자바에서만 사용할 수 있다.    
스칼라에서는 스키마가 정의된 케이스 클래스 객체를 사용해 정의하고, 자바에서는 자바 빈 객체를 사용해 정의한다.     
프로그래밍 언어를 전환하는 것이 사용자 정의 데이터 타입을 상요하는 것보다 훨씬 느리다 ?    
  
#### 11.1 Dataset을 사용할 시기   
Dataset 을 사용하면 성능은 더 떨어지지만 사용해야만 하는 이유는 아래와 같다.   
- DataFrame 기능만으로는 수행할 연산을 표현할 수 없는 경우  
- 성능 저하를 감수하더라도 타입 안정성을 가진 데이터 타입을 사용하고 싶은 경우  
    예를 들어 두 문자열을 사용해 뺄셈 연산을 하는 것처럼 데이터 타입이 유효하지 않은 작업은 러타임이 아닌 컴파일 타임에 오류가 발생한다.  
    따라서 정화도와 방어적 코드를 가장 중요시한다면 성능을 조금 희생하더라도 Dataset 을 사용하는 것이 좋다.  

단일 노드의 워크로드와 스파크 워크로드에서 전체 로우에 대한 다양한 트랜스포메이션을 재사용하려면 Dataset 을 상요하는 것이 적합하다 ?  


#### 11.2 Dataset 생성   
11.2.1 자바: Encoders  

```  
import org.apache.spark.Sql.Encoders;  
  
public class FIight implements Serializable{   
String DEST COUNTRY=NAME;  
String 0RIGIN COUNTRY=NAME;  
Long DEST COUNTRY-NAME;  
}  
  
Dataset<FIight> flights = Spark.read   
.parquet(‘'/data/flight.data/parquet/2@10-summary.parquet/'')   
.as(Encoders.bean(FIight.cla5s));  

```  
11.2.2 스칼라: 케이스 크래스  

#### 11.3 액션   

#### 11.4 트랜스포메이션   
Dataset 의 트랜스포메이션은 DataFrame 과 동일하다.  
11.4.1 필터링  
```  
def originIsDestination(flight_row: Flight): Boolean = {  
    return flight_row.ORIGIN_COUNTRY_NAME == flight_row.DEST_COUNTRY_NAME  
}  

flights.filter(flight_row => originIsDestination(flight_row)).first() // 각행이 true 를 반환하는지 평가한다.  

//결과는 아래와 같다.  

Flight = Flight(United States, United States, 348113)  
```  
이 코드는 양이 적기 때문에 드라이버에서 아래와 같이 수행해도 된다.  
```  
flights.collect().filter(flight_row => originIsDestination(flight_row))  
```  
11.4.2 매핑  
```  
목적지 컬럼을 추출하는 예제  
val destinations = flights.map(f => f.DEST_COUNTRY_NAME)  
드라이버는 결과값을 모아 문자열 타입의 배열로 반환한다.  
val localDestinations = destinations.take(5)  
```  
?  
#### 11.5 조인   
Dataset 에서는 Dataframe에 없는 joinWith 처럼 정교한 메서드를 제공한다.  
```  
cas class flightMetadata(count: BigInt, randomData: BigInt)  

val flightsMeta = spark.range(500).map(x => (x, scala.util.Random.nextLong))  
.withColumnRenamed("_1"), "count").withColumnRenamed("_2","randomData")  
.as[FlightMetadata]  

val flights2 = flgiths  
.joinWith(flightMeta, flights.col("count") === flightsMeta.col("count"))  

//최종적으로 로우는 Flight 와 FlgithMetadata 로 이루어진 일종의 키-값 형태의 Dataset을 반환한다.  

flights2.selectExpr("_1.DEST_COUNTRY_NAME")  

flights2.take(2)  
```  
아래와 같이 일반 조인도 잘 작동하지만, DataFrame 을 반환하므로 JVM데이터 타입 정보를 모두 잃게 된다.  
```  
val flights2 = flights.join(flightsMeta, Seq("count"))  

//이 정보를 다시 얻으려면 다른 Dataset 을 정의해야 한다.  

val flights2 = flights.join(flightsMeta.toDF(), Seq("count"))  
```  
#### 11.6 그룹화와 집계   
이 역시 DataFrame 으로도 사용할 수 있지만 데이터 타입 정보를 잃어버린다.  
```  
//DataFrame  
flights.groupBy("DEST_COUNTRY_NAME").count()  
//Dataset  
flights.groupByKey(x => x.DEST_COUNTRY_NAME).count()  
```  
#### 11.7 정리   
