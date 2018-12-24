## Tuning Java Garbage Collection for Spark Applications
### 전통적인 GC(2)
- CMS(Concurrent Mark Sweep)
    - 지연 ↓, 응답속도 ↑
    - 압축을 하지 않음
    - 실시간 처리시 사용(in intel)
- ParallelOld GC
    - 처리량 ↑
    - 전체 Heap 압축을 사용하여 멈춤 현상 발생
    - 오프라인 분석 시 사용(in intel)

### 전통적인 GC Flow
- ![image](https://user-images.githubusercontent.com/10006290/50391380-664fdc80-0787-11e9-893b-f953f08a9d48.png)
- 처음 생성된 객체, Eden 할당 
- Minor GC
    - Eden -> empty survivor(복사)
    - Another survivor -> empty survivor(복사)
    - **하나의 survivor은 객체 보유, 나머지는 새로운 객체 수집을 위해 비움**
- 여러번 Minor GC를 버틴 경우, Old Generation으로 복사 
- Old Generation Full, Major GC(Full GC)

### Spark GC
- 실시간 처리, 배치 처리가 둘다 가능 
- JVM 1.6부터 **G1GC** 사용 

### G1GC(The Garbage-First GC)
- CMS를 대체하기 위해 Oracle에서 개발
- G1GC Flow
- ![image](https://user-images.githubusercontent.com/10006290/50391416-fe4dc600-0787-11e9-9b45-8a512b0684d3.png)
- Heap을 동일 사이즈의 **region**으로 분할 
    - 가상 메모리 공간 
    - 특정한 region set은 `Eden`, `Survivor`, `Old`로 지정 
        - 정해진 사이즈는 존재하지 않음
- 순서 
    - object가 생성되면 가용한 region에 할당 
    - 해당 region이 가득차면 JVM이 새롭게 **region을 생성**후 object 저장 
    - **Minor GC**발생 시, G1은
        - 1개 또는 그 이상의 heap region에서 
            - **live object**를 하나의 region으로 복사
    - `비워진 새로운 region = Eden`으로 설정
    - **Full GC**
        - **모든 region**이 **live object**를 보유하고,
            - 완벽히 비워진 region이 하나도 없을 때 발생
- G1은 **Object Marking**시에, **RSets(Remeber Sets)**을 활용
    - 전체 heap scan을 회피 
    - region에 대한 parallel & independent scan 가능
    - G1 GC가 Full GC수행시,
        - heap 점유율에서 성능 향상 
        - minor GC의 멈춤시간을 제어 가능하게 함 
        - 대용량 메모리 환경에 친화적 

### G1GC Tuning
- young/aged object에 정해진 heap partition을 사용하지 않기 때문에 
    - GC 설정 옵션을 조정해야 함
- 가장 좋은 튜닝 방법은 **일단 아무것도 사용하지 않음**
    - `XX:+UseG1GC` 옵션만 사용한다.
- Multiple Thread를 사용하는 app에서
    - `-XX:-RsizePLAB` : 많은 thread 통신으로 인한 성능 개선 가능
- `-XX:+PringFlagsFinal` : 모든 GC Parameter 확인

### Understanding Memory Management in Spark
- RDD는 memory 소비와 직접 연관 
- persisting RDD = JVM의 모든 heap/일부 데이터 캐시
- spark executor의 heap space(2)
    - spark app에 의해 data를 persist하게 memory로 저장 
    - RDD transformation 과정에서 memory를 관리하는 JVM heap space
- heap space의 비율은 `spark.storage.memoryFraction * heap size`가 넘지 못하도록 설정 되며, 조절 가능하다.
- 사용되지 않은 RDD Cached도 JVM에 의해 사용됨 


referenced by. [preepsw](http://blog.naver.com/PostView.nhn?blogId=freepsw&logNo=220680331433)
