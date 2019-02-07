## IMPALA CREATE
- 임팔라 사용법을 간단하게 확인하기 

### CREATE TABLE FORMAL
```
CREATE EXTERNAL TABLE wshid.test
(id int, name string)
PARTITIONED BY (year string, month string, day string, hour string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY "\t" 
-- STORED AS PARQUET
LOCATION "/workspace/flume/"
```
- `EXTERNAL` : 테이블 제거시, 원본 데이터와 연동 여부 결정(cascade = external)
- `PARTITIONED BY` : 파티셔닝 인자를 결정한다.
    - 보통 날짜에 관련되게 분할할 수 있다.
- `STORED AS PARQUET` : parquet 파일로 저장한다.
- `LOCATION` : 테이블과 연관된 hdfs 데이터 저장 위치 지정


### 특징 
- Complex Type 지원 
    - colume에 `STRUCT`, `ARRAY`, `MAP`과 같은 데이터 형식을 지원한다.


### Cloning Table
```
CREATE EXTERNAL TABLE IF NOT EXISTS wshid.clone_table
    LIKE wshid.test
    -- LIKE `/workspace/flume`
...
```
- `IF NOT EXISTS` : 테이블이 없을 경우 생성한다.
    - 테이블이 이미 존재할경우, 구문 취소 
- `LIKE ...` : 원본이 되는 테이블 혹은 PARQUET 파일을 지정한다.


### CTAS(CREATE TABLE AS SELECT)
- 특정 테이블을 조건에 맞게 복제한다.
- `WHERE`로 조건을 붙이거나, `STORED AS PARQUET`과 같이 clone의 조건을 줄 수 있다.
- 컬럼의 경우 원본 테이블과 동일하게 따라간다.
- Example
>```
>CREATE TABLE clone_of_t1 AS SELECT * FROM t1;
>CREATE TABLE parquet_version_of_t1 STORED AS PARQUET AS SELECT * FROM t1;
>CREATE TABLE subset_of_t1 AS SELECT * FROM t1 WHERE x >= 2;
>```

### HDFS caching
- `CACHED IN`을 사용한다.
- 복제 인수를 지정할 수 있다.
- 이미 캐시된 데이터 블록이 여러번 처리될 때, 단일 호스트에서 과도한 CPU사용을 방지한다.
- 일반 리눅스 caching이 아닌, HDFS에 특화된 캐시 방법을 사용한다.


referenced by. [cloudera](https://www.cloudera.com/documentation/enterprise/5-8-x/topics/impala_create_table.html)