## Flink
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


Referenced by [Minsub's Blog](http://gyrfalcon.tistory.com/entry/Flink-1-%EC%86%8C%EA%B0%9C-Basic-Concept)