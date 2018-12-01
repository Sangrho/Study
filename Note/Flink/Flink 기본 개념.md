## Flink 기본 개념
- Flink란
    - **Apache Storm**, **Spark Streaming**과 같은 스트리밍 & 배치 프로세싱 플랫폼
    - Streaming Model이 **Batch가 아닌 Native**방식
        - **Low Latency** 특성을 가진다
    - **Exactly-once**를 보장하고, 높은 처리량을 보임
        - [실시간 처리 프레임워크 비교(https://www.popit.kr/%EC%95%84%ED%8C%8C%EC%B9%98-%EC%8B%A4%EC%8B%9C%EA%B0%84-%EC%B2%98%EB%A6%AC-%ED%94%84%EB%A0%88%EC%9E%84%EC%9B%8C%ED%81%AC-%EB%B9%84%EA%B5%90%EB%B6%84%EC%84%9D-1/)
- 추상화 레벨
    - ![image](https://user-images.githubusercontent.com/10006290/49299942-559fa400-f504-11e8-8c3f-e9c98b1ffbb5.png)
    - low-level
        - 사용자가 직접 state, time 등을 관리
    - Core APIs
        - 가장 많이 사용되는 **dataStream, Dataset API**를 사용
    - Declarative DSL
        - Library로 제공되는 Table API
        - **select, join, aggregate**등의 고차원 함수 사용 가능
    - High-level Language
        - SQL문 사용 가능
- 프로그램과 데이터플로우
    - 용어 정리
        - Input stream : **Source**
        - Operation : **Transformation**
        - Output : **Slink**
    - Streaming DataFlow
        - **Source**로 스트림 데이터를 받음
        - 여러 **Transformation**으로 데이터를 가공
        - **Slink**로 데이터를 처리(저장)
        ```
        # Source
        DataStream<String> lindes = env.addSource(new FlinkKafkaConsumer<>(...));

        # Transformation
        DataStream<Event> events = lines.map((line) -> parse(line));

        # Transformation2
        DataStream<Statistics> stats = events
            .keyBy("id")
            .timeWindow(Time.secondes(10))
            .apply(new MyWindowAggreagationFunction());
        
        # Slink
        stats.addSink(new RollingSink(path));
        ```
        - 데이터 가공을 두단계로 진행한다.
        - Source -> Transformation -> Slink간에 데이터는
            - **stream**형태로 전달된다.
        - ![image](https://user-images.githubusercontent.com/10006290/49300383-6ef52000-f505-11e8-9925-280f3c702234.png)
- Parallel Dataflows
    - Flink는 분산환경에서 각각의 Operator들이 Parallel하게 처리될 수 있음
    - Stream은 여러 **stream partitions**로 구성될 수 있음
    - Operator는 **operator subtasks**로 나뉠 수 있음
    - ![image](https://user-images.githubusercontent.com/10006290/49325281-1fedd000-f583-11e8-977d-b3030a38eb90.png)
        - 여러 스레드에서 parallel하게 분산처리를 한다.
        - 2개의 paralleism을 설정하면 각 operator들이 각각의 스레드에서 실행하여 처리한다
            - 각 operator 특성에 따라 모든 stream에서 데이터를 받아 처리될 수 있고, 1:1 매핑 될 수 있다.
            - ```keyby()``` perator는 각 subtasks에서 key별로 처리되기 때문에
                - 이전의 transformation에서 map으로 처리된 데이터를
                    양쪽 모두에서 받아 처리한다.
- Distributed Execution
    - Flink의 두가지 프로세스
        - **Master Process**(Job Manager)
            - task를 스케줄링 하고, 체크포인트, 리커버리 담당
        - **Worker Process**(Task Manager)
            - task를 실행
    - Master가 worker들을 관리하고,
        - Worker는 task를 실행하는 구조
    - Client는 런타임 안에서 실행되지 않고,
        - 접속하여 컨트롤 및 정보 전달 수행
    - flink는 **standalone**으로 구성될 수 있고,
        - Container, Yarn, Mesos와 같은 **Resource Framework**환경에서 실행할 수 있다.
    - ![image](https://user-images.githubusercontent.com/10006290/49325688-0bf99c80-f58a-11e8-815c-c6ba055afa9e.png)
    - 각 worker는 JVM 프로세스 단위로 동작
        - 1개 이상의 subtask가 thread로 실행
    - task는 **task slot**안에서 실행
        - task slot
            - worker내의 resource(메모리)를 나누어 관리
        - slot별로 개별적인 메모리 공간에서 task들이 실행되는 구조
        - slot의 개수는 **CPU core**갯수로 지정하는 것이 좋음
    - ![image](https://user-images.githubusercontent.com/10006290/49325710-63980800-f58a-11e8-90cc-e5726d9d50d8.png)
- Windows
    - 스트림 데이터는 기본적으로 **unbounded data**
        - 시작과 끝이 존재하지 않음
    - 집계연산을 수행하기 위해, **시작과 끝이 일정한 룰에 따라 연산을 수행**하기 위해 사용
    - Windows의 종류
        - Tumbling
        - Sliding
        - Session
        - Global
    - 각 windows는 시간/갯수 기반으로 설정 가능
    - ![image](https://user-images.githubusercontent.com/10006290/49325735-be316400-f58a-11e8-9558-9d15c6e9cba2.png)
        - 데이터를 어떻게 분석할지에 대해 맞게 사용하면 됨
- Time
    - Time의 3가지 종류
        - **Event Time** : 데이터가 발생한 시간
        - **Ingestion Time** : 데이터가 Flink로 유입된 시간
        - **Processing Time** : 데이터가 처리된 시간
    - ![image](https://user-images.githubusercontent.com/10006290/49325753-f2a52000-f58a-11e8-9f32-6204ede0b1c4.png)
- StateFul Operations
    - 각 operator들이 데이터의 처리 상태를 관리
- Checkpoints for Fault Tolerance
    - 대부분의 스트림 처리 시스템에서 Fault Tolerance 기능을 지원
    - Flink에서는 **Checkpoint** 방식 사용
    - 처리되는 스트림 중간에 **checkpoint barrier**를 삽입하여 **ack**를 처리하는 방식
    - fault가 발생하면, checkpoint부터 처리하는 방식
    - 모든 레코드마다 진행하지 않기 때문에, 빠름
    - **exactly-once** 보장
        - 정확하게 한번의 메세지 전송을 보장
        - 중복과 유실을 모두 허용하지 않음
    - ![image](https://user-images.githubusercontent.com/10006290/49325787-5e878880-f58b-11e8-9a68-12c570e6da93.png)
- Batch on Streaming
    - bounded stream 데이터를 streaming으로 처리하는 방식
    - **Dataset API**를 사용
    - DataStream 방식에서 사용하고 있는 checkpoint방식을 사용하지 않고
        - **fault시 모두 재실행하는 방식을 사용**



Referenced by [Minsub's Blog](http://gyrfalcon.tistory.com/entry/Flink-1-%EC%86%8C%EA%B0%9C-Basic-Concept)