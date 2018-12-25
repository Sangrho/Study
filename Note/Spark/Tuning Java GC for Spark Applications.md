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
- GC latency에 의해 효율성 저하 시,
    - spark app이 memory limit을 넘었는지 확인
- memory를 적게 차지할 수록, program 실행을 위한 **heap 공간**이 더 많이 남게 됨
    - **GC의 효율성 증가**
- RDD의 메모리 사용이 높으면 
    - old generation의 많은 수의 buffered object 존재 -> 성능 저하 발생
- GC가 너무 자주 또는 오랜 시간 지속되는 것이 관측 되면 
    - 메모리 공간이 비효율적으로 사용되고 있음을 암시 
    - 성능을 개선하기 위해
        - 명시적으로 사용되지 않은 **cached RDD**를 **clean up** 해주어야 한다.

### Choosing a Garbage Collector
- Environment
    - 4대의 클러스터 
    - executor별 88G heap
- Before Tuning Configuration
    ```
    -XX:+UseParallelGC -XX:+UseParallelOldGC -XX:+PrintFlagsFinal -XX:+PrintReferenceGC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintAdaptiveSizePolicy -Xms88g -Xmx88g
    ```
    - **parallelGC**를 사용
    - 가끔식 **Full GC**가 발생
        - spark app의 memory 부하가 크다
        - 짧은 life-cycle 내에서 대부분의 object를 회수하지 못함
    - Full GC가 발생시, 성능 저하
    - parallelGC는 제약적인 파라미터를 제공
        - 기본 파라미터 조정
            - generation의 size ratio
            - object가 old gen.으로 이동 전, 복사 여부 등
        - **오히려 Full GC 시간이 증가**
- G1GC default
    ```
    -XX:+UseG1GC -XX:+PrintFlagsFinal -XX:+PrintReferenceGC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintAdaptiveSizePolicy -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -Xms88g -Xmx88g
    ```
    - 전체 실행시간은 Parallel GC보다 오래 소요
    - Performance 비교
        - `ParallelGC > CMS GC > G1 GC(default)`
- G1GC Tuning
    - default G1 GC에서 튜닝 작업을 시작한다.
    - GC log를 기반으로 G1 collecor를 최적화
    - `spark.executor.extraJavaOptions` 설정
        ```
        -XX:+PrintFlagsFinal -XX:+PrintReferenceGC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintAdaptiveSizePolicy -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark
        ```
        - 상세한 GC log를 남길 수 있도록 설정
    - G1GC log
        ```
        251.354: 
        [G1Ergonomics (Mixed GCs) continue mixed GCs, reason: candidate old regions available, candidate old regions: 363 regions, reclaimable: 9830652576 bytes (10.40 %), threshold: 10.00 %] 
        [Parallel Time: 145.1 ms, GC Workers: 23] 
        [GC Worker Start (ms): Min: 251176.0, Avg: 251176.4, Max: 251176.7, Diff: 0.7] 
        [Ext Root Scanning (ms): Min: 0.8, Avg: 1.2, Max: 1.7, Diff: 0.9, Sum: 28.1] 
        [Update RS (ms): Min: 0.0, Avg: 0.3, Max: 0.6, Diff: 0.6, Sum: 5.8] 
        [Processed Buffers: Min: 0, Avg: 1.6, Max: 9, Diff: 9, Sum: 37] 
        [Scan RS (ms): Min: 6.0, Avg: 6.2, Max: 6.3, Diff: 0.3, Sum: 143.0] 
        [Object Copy (ms): Min: 136.2, Avg: 136.3, Max: 136.4, Diff: 0.3, Sum: 3133.9] 
        [Termination (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.3] 
        [GC Worker Other (ms): Min: 0.0, Avg: 0.1, Max: 0.2, Diff: 0.2, Sum: 1.9] 
        [GC Worker Total (ms): Min: 143.7, Avg: 144.0, Max: 144.5, Diff: 0.8, Sum: 3313.0] 
        [GC Worker End (ms): Min: 251320.4, Avg: 251320.5, Max: 251320.6, Diff: 0.2] 
        [Code Root Fixup: 0.0 ms] 
        [Clear CT: 6.6 ms] 
        [Other: 26.8 ms] 
        [Choose CSet: 0.2 ms] 
        [Ref Proc: 16.6 ms] 
        [Ref Enq: 0.9 ms] 
        [Free CSet: 2.0 ms] 
        [Eden: 3904.0M(3904.0M)->0.0B(4448.0M) Survivors: 576.0M->32.0M Heap: 63.7G(88.0G)->58.3G(88.0G)] 
        [Times: user=3.43 sys=0.01, real=0.18 secs]
        ```
        - G1 GC의 위계 질서 파악 가능
        - pause가 발생하는 이유 시간 파악 가능
        - 다양한 thread.의 소요시간, 평균/최대 cpu time이 등급화
    - G1GC log 2
        ```
        (to-space exhausted), 1.0552680 secs] 
        [Parallel Time: 958.8 ms, GC Workers: 23] 
        [GC Worker Start (ms): Min: 759925.0, Avg: 759925.1, Max: 759925.3, Diff: 0.3] 
        [Ext Root Scanning (ms): Min: 1.1, Avg: 1.4, Max: 1.8, Diff: 0.6, Sum: 33.0] 
        [SATB Filtering (ms): Min: 0.0, Avg: 0.0, Max: 0.3, Diff: 0.3, Sum: 0.3] 
        [Update RS (ms): Min: 0.0, Avg: 1.2, Max: 2.1, Diff: 2.1, Sum: 26.9] 
        [Processed Buffers: Min: 0, Avg: 2.8, Max: 11, Diff: 11, Sum: 65] 
        [Scan RS (ms): Min: 1.6, Avg: 2.5, Max: 3.0, Diff: 1.4, Sum: 58.0] 
        [Object Copy (ms): Min: 952.5, Avg: 953.0, Max: 954.3, Diff: 1.7, Sum: 21919.4] 
        [Termination (ms): Min: 0.0, Avg: 0.1, Max: 0.2, Diff: 0.2, Sum: 2.2] 
        [GC Worker Other (ms): Min: 0.0, Avg: 0.0, Max: 0.0, Diff: 0.0, Sum: 0.6] 
        [GC Worker Total (ms): Min: 958.1, Avg: 958.3, Max: 958.4, Diff: 0.3, Sum: 22040.4] 
        [GC Worker End (ms): Min: 760883.4, Avg: 760883.4, Max: 760883.4, Diff: 0.0] 
        [Code Root Fixup: 0.0 ms] 
        [Clear CT: 0.4 ms] 
        [Other: 96.0 ms] 
        [Choose CSet: 0.0 ms] 
        [Ref Proc: 0.4 ms] 
        [Ref Enq: 0.0 ms] 
        [Free CSet: 0.1 ms] 
        [Eden: 160.0M(3904.0M)->0.0B(4480.0M) Survivors: 576.0M->0.0B Heap: 87.7G(88.0G)->87.7G(88.0G)] 
        [Times: user=1.69 sys=0.24, real=1.05 secs] 
        760.981: [G1Ergonomics (Heap Sizing) attempt heap expansion, reason: allocation request failed, allocation request: 90128 bytes] 
        760.981: [G1Ergonomics (Heap Sizing) expand the heap, requested expansion amount: 33554432 bytes, attempted expansion amount: 33554432 bytes] 
        760.981: [G1Ergonomics (Heap Sizing) did not expand the heap, reason: heap expansion operation failed] 
        760.981: [Full GC 87G->36G(88G), 67.4381220 secs]
        ```
        - 가장 큰 성능저하는 **Full GC**
            - log의 To-space Exhausted에 의해 기록
            - G1 GC가 특정 region에서 gc를 시도할 때,
                - live object를 복사할 **free region**을 찾지 X
            - 이를 **Evacation Failure**라고 한다.
        - 명백하게 **Full GC**는 G1 GC가 Parallel GC보다 **치명적**
    - G1GC의 Full GC 회피 방법
        - `InitiatingHeapOccupancyPercent` 수치 낮추기(default : 45)
            - G1 GC가 초기에 concurrent making을 더 빠른 시간에 하도록 함
        - `ConcGCThreads` 수치 증가
            - 더 많은 thread가 concurrent making을 하도록 함
                - **concurrent making**단계를 더 빠르게 할 수 있음
            - 단, 일부 worker의 **thread를 선점**할 수 있음
    - GC log pause 확인
        ```
        280.008: [G1Ergonomics (Concurrent Cycles) request concurrent cycle initiation, reason: occupancy higher than threshold, occupancy: 62344134656 bytes, allocation request: 46137368 bytes, threshold: 42520176225 bytes (45.00 %), source: concurrent humongous allocation]
        ```
        - 거대한 object
            - region의 50%이상
        - G1GC의 특성상, **큰 object**는 **연속된 region**에 배치
        - 거대한 object의 복사는 **많은 자원**을 소모
            - 거대한 object는 **old gen.에서 직접 할당**
                - **young gen.**에서는 bypassing
        - 이후 거대한 region으로 categorize
        - 거대한 object가 많으면
            - **heap**은 매우 빠른 속도로 채워짐
            - 해당 공간을 확보하는 것은 비용이 큼
    - 거대한 object 회피
        - `G1HeapRegionSize`값을 증가 시키기
            - 최대값 : 32M(default)
        - 프로그램 분석이 필요하며, **mix GC**와 관련된 설정 필요
            - `-XX:G1HeapWastePercent -XX:G1MixedGCLiveThresholdPercent`
    - mix GC 이후
        - mix GC의 **single GC cycle**분석
        - 시간이 너무 오래 소요될 경우 `ConcGCThreads`값을 증가
            - 단, CPU 자원을 더 많이 소모함
        - G1 GC는 STW(Stop The World) pause를 줄일 수 있음
            - gc의 **concurrent stage**에서 더 많은 작업 수행
        - RSet 유지
            - G1 GC 외부 region에서 지정된 region을 참조하는 object 추적
        - G1 Collector는 Rset을 **STW stage**와 **concurrent stage** 양쪽에 업데이트
    - STW pause 줄이기
        - `G1RSetUpdatingPauseTimePercent` 감소
            - 전체 **STW time**에서 **RSet update time**(default:10)의 비율 설정
        - `G1ConcRefinementThreads` 증가
            - program이 실행되는 동안 **RSets**을 유지하기 위해 필요한 **thread** 수 정의
        - 두가지 옵션을 통해 **RSet updating** 부하를
            - **concurrent stage**로 이동
    - `AlwaysPreTouch`
        - long-running app
        - JVM이 시작시에 OS에 필요한 **모든 메모리를 적용**
        - **dynamic application 방지**
            - start time의 비용 증가
            - runtime 성능 향상
- After Tuning G1GC
    ```
    -XX:+UseG1GC -XX:+PrintFlagsFinal -XX:+PrintReferenceGC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintAdaptiveSizePolicy -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -Xms88g -Xmx88g -XX:InitiatingHeapOccupancyPercent=35 -XX:ConcGCThread=20
    ```
    - tuning 이후 running time을 기존보다 **1.7**배 향상
    - spark app에서는 **G1 GC**를 권장
- Summary
    - Spark app에서 GC 튜닝은 중요하나,
        - GC관련 문제 발생시, **GC 자체를 디버깅하려고 서두르지 X**
    - spark app의 비효율적인 memory 관리 고려
        - persisting and freezing up RDD in cache 등
    - GC 튜닝 시에는, G1 GC 사용 권장
        - G1 Collector는 heap size를 잘 다루도록 구성됨
            - spark에서 자주 발생하는 현상
        - 적은 옵션으로 높은 처리량과 낮은 지연 보장 가능
    - 최종적으로 program logic과 code를 고려
        - **중간 object의 생성과 복사를 줄이고**
            - **거대한 object의 생성을 조절**
    - Future spark의 메모리 관리는
        - **java**가 아닌 **spark**에 중점
        - [project-tungsten-bringing-spark-closer-to-bare-metal](https://databricks.com/blog/2015/04/28/project-tungsten-bringing-spark-closer-to-bare-metal.html)
referenced by. [preepsw](http://blog.naver.com/PostView.nhn?blogId=freepsw&logNo=220680331433)
