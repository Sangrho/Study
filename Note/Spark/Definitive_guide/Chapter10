[ Chapter 10 ]

10. 스파크 SQL
10.1 SQL 이란
10.2 빅데이터와 SQL : 아파치 하이브
10.3 빅데이터와 SQL : 스파크 SQL
	스파크 SQL 은 온라인 트랜잭션 처리(OLTP) 데이터베이스가 아닌 온라인 분석용(OLAP) 데이터베이스로 동작한다.
	즉, 매우 낮은 지연 시간이 필요한 쿼리를 수행하기 위한 용도로 사용할 수 없다.
	언젠가는 in-place modification 방식을 지원하겠지만 현재는 사용할 수 없다.
	10.3.1 스파크와 하이브의 관계
10.4 스파크 SQL 쿼리 실행 방법
	10.4.1 스파크 SQL CLI
		spark-sql 명령어를 수행하기 위해서는, 스파크가 설치된 경로의 conf 디렉토리에 hive-site.xml, core-site.xml, hdfs-site.xml 파일을 배치하면 하이브를 사용할 수 있다.
	10.4.2 스파크의 프로그래밍 SQL 인터페이스
		sql 메서드를 사용한 결과는 DataFrame 을 반환한다.
	10.4.3 스파크 SQL 쓰리프트 JDBC / ODBC 서버
10.5 카탈로그
	스파크 SQL 에서 가장 높은 추상화 단계는 카탈로그이다.
	카탈로그는 테이블에 저장된 데이터에 대한 메타데이터뿐만 아니라 데이터베이스, 테이블, 함수 그리고 뷰에 대한 정보를 추상화한다.
10.6 테이블
	10.6.1 스파크 관리형 테이블
		관리형 테이블 / 외부 테이블 두 개념이 있다. (Hive 와 동일한 개념)
		saveAsTable 메서드는 테이블을 읽고 데이터를 스파크 포맷으로 변환한 후 새로운 경로에 저장한다.
		기본 저장 경로는 /user/hive/warehouse 이며 변경하려면 SparkSession 을 생성할 때 spark.sql.warehouse.dir 속성을 변경하면 된다.
	10.6.2 테이블 생성하기
		* USING / STORED AS 구문
			CREATE TABLE flights (
				DEST_COUNTRY_NAME STRING, ORIGIN_COUNTRY_NAME STRING, count LONG)
			USING JSON OPTIONS (path '/data/json/2015-summary.json')
			포맷을 지정하지 않으면 스파크는 기본적으로 하이브 SerDe 설정을 사용한다.
			하이브 SerDe는 스파크의 자체 직렬화보다 훨씬 느리므로 테이블을 사용하는 Reader 와 Writer 성능에 영향을 미친다.
			하이브 사용자는 STORED AS 구문으로 하이브 테이블을 생성할 수 있다.
	10.6.3 외부 테이블 생성하기
	10.6.4 테이블에 데이터 삽입하기
	10.6.5 테이블 메타데이터 확인하기
	10.6.6 테이블 메타데이터 갱신하기
		테이블 메타데이터 갱신하는 두 가지 방법.
			1. 테이블과 관련된 모든 캐싱된 항목(기본적으로 파일) 을 갱신한다. 테이블이 이미 캐싱되어 있다면 다음번 스캔이 동작하는 시점에 다시 캐싱한다.
			$> REFRESH table parittions_flights
			2. 카탈로그에서 관리하는 테이블의 파티션 정보를 새로 고치는 방법이다. 이 명령은 새로운 파티션 정보를 수집하는 데 초점을 맞춘다.
			$> MSCK REPAIR TABLE partitions_flights
	10.6.7 테이블 제거하기
	10.6.8 테이블 캐싱하기
		아래 명령어로 캐싱할 수 있다.
		$> CACHE TABLE flights
10.7 뷰
	기존 테이블에 여러 트랜스포메이션 작업을 지정한다. 기본적으로 뷰는 단순 쿼리 실행 계획일 뿐이다.
	10.7.1 뷰 생성하기
		최종 사용자에게 뷰는 테이블처럼 보인다.
		$> CREATE VIEW asdf_view AS SELECT * FROM asdf
		테이블처럼 데이터베이스에 등록되지 않고 현재 세션에서만 사용할 수 있는 임시뷰로 만들 수 있다.
		$> CREATE TEMP VIEW asdf_view AS SELECT * FROM asdf
		전역적 임시 뷰(global temp view) 도 만들 수 있다. 데이터베이스에 상관없이 사용할 수 있으므로, 전체 스파크 어플리케이션에서 볼 수 있다.
		하지만 세션이 종료되면 뷰도 사라진다.
		$> CREATE GLOBAL TEMP VIEW asdf.view AS SELECT * FROM asdf
	10.7.2 뷰 제거하기
10.8 데이터베이스
	10.8.1 데이터베이스 생성하기
	10.8.2 데이터베이스 설정하기
	10.8.3 데이터베이스 제거하기
10.9 select 구문
	10.9.1 case_when_then 구문
10.10 고급 주제
	10.10.1 복합 데이터 타입
		* 구조체
		구조체는 맵에 더 가까우며 스파크에서 중첩 데이터를 생성하거나 쿼리하는 방법을 제공한다.
		$> CREATE VIEW IF NOT EXISTS nested_Data AS
		     SELECT (DEST_COUNTRY_NAME, ORIGIN_COUNTRY_NAME) as country, count FROM flights
		위와 같이 생성한 뷰를 아래와 같이 검색할 수 있따.
		$> SELECT country.DEST_COUNTRY_NAME, count FROM nested_data
		* 리스트
		$> SELECT DEST_COUNTRY_NAME as new_name, collect_list(count) as flight_counts, collect_set(ORIGIN_COUNTRY_NAME) as origin_set
		    FROM flights GROUP BY DEST_COUNTRY NAME
		위와 같이 생성한 리스트를 아래와 같이 조회할 수 있다.
		$> SELECT DEST_COUNTRY_NAME as new_name, collect_list(count)[0]
		   FROM flights GROUP BY DEST_COUNTRY_NAME
	10.10.2 함수
	10.10.3 서브쿼리
10.11 다양한 기능
	10.11.1 설정
	10.11.2 SQL 에서 설정값 지정하기 
