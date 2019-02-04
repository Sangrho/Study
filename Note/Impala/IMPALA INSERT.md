## IMPALA INSERT
- INSERT 문에 대한 간단한 정리 

### INSERT BASIC
>```
>INSERT INTO insert_test PARTITION(year='2019', month='02', day='04', hour='23') VALUES (...)
>INSERT OVERWRITE overwrite_test ..
>```
- `OVERWRITE`
    - 이전의 데이터를 대체함. 
    - HDFS trash machanism을 거치지 않는다.
- `INTO`
    - 일반적인 append 구문 

### 특징
- Complex Type(`ARRAY`, `STRUCT`, `MAP`)를 지원하지 않음 
- Impala는 기본적으로 `Hive Metadata`와 연관되어 있음 
    - `Hive Metadata`가 변경 될 시, `REFRESH`명령을 통해 값을 업데이트 할 수 있음 
- 기존 데이터 파일이 HDFS의 다른곳의 위치할 경우,
    - `INSERT`문이 아닌,
    - `LOAD DATA`구문을 사용해야 함
- type casting시, 자동으로 작은 형태의 값으로 casting 된다.
- parquet table에 insert를 하려면, HDFS에서 블록 할당이 필요하다.
    - 기본적으로 parquet table에 대한 블록 크기는 **1GB**이다.
    - 작은 데이터 삽입 시에도, 1GB가 필요하여, 용량 부족 문제가 발생할 수 있음 
- `INSERT ... VALUES`
    - 삽입작업을 **병렬처리** 할 수 없기 때문에, HDFS에 많은 데이터 로드시 적합하지 않음 
    - 각각 별도의 파일을 생성함 
    - 단일값 입력시 사용하는 것이 좋음 
- 작업 취소(cancellation)이 가능함 
    - 쉘의 경우에는
        - `Ctrl`+`C`
    - `Hue`의 경우에는
        - `Actions` -> `Cancel` on Queries List

### EXAMPLE
```
DROP TABLE IF EXISTS test_table;
INSERT INTO TABLE test_table SELECT * FROM origin_table;
INSERT OVERWRITE val_example VALUES (10,false,pow(2,5)), (50,true,10/3); -- multi value
```
- `INSERT INTO TABLE`을 이용하여, 기타 테이블에서 신규 테이블로 데이터를 append할 수 있다. 

### HDFS Consideration
- 기본적으로 테이블을 생성하게 되면 기본 사용자 권한(impala)의 권한으로 기록된다.
- 특정 위치에 테이블을 사용하려면 해당 위치에 대한 **HDFS 권한**을 가지고 있어야 한다.
- 데이터를 입력하게 되면, 특정 개수의 파일들이 생성 됨
- 성능 문제가 발생시, 많은 파일이나, 많고 작은 파티션과 같은 문제가 출력파일에 발생하지 않는지 확인 
- 숨겨진 파일이 존재(작업 디렉토리)
    - `.impala_insert_staging`
    - `_impala_insert_staging` : v2.0.1 이후 

referenced by. [cloudera](https://www.cloudera.com/documentation/enterprise/5-8-x/topics/impala_insert.html)