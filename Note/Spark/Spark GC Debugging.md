## Spark GC Debugging
- Measuring the Impact of GC
    ```
    -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps
    ```
    - 자바 옵션으로 GC 옵션에 대해 확인할 수 있다.
    - 이후 spark job을 실행시킨다.
        - gc에 대한 workers log를 확인할 수 있음 
- Advanced GC Tuning
    - JVM
        - Java Heap은 **young**과 **old**영역으로 나뉨 
            - Young Generation
                - short-lived object 
            - Old Generation
                - longer life time
        - Young Generation은 **Eden**, **Servivor1**, **Servivor2**로 나뉨 
    - GC Procedure
        - Eden이 꽉 찼을 때, **Minor GC** 발생 
            - Eden과 Survivor1에 있는 내용을 Survivor2에 옮김
            - Servivor Reginos are swapped
        - object가 오래되었거나, servivor2가 가득 찼을 때, Old Gen.으로 옮김
            - Old가 꽉 차면 Full GC가 일어난다.
    - GC Tuning의 목적은
        - **long-lived RDD**를 **Old Generation**에 유지 
        - **Young Generation Size**를 short-lived object를 저장할 만큼 충분하게 설정하기
    - GC Tuning Step
        - **Full GC**가 많을 때
            - task를 실행하기 위한 메모리가 충분하지 않기 때문이다.
        - **Minor Collection**이 많이 일어나고, **Major GC**가 적을 때
            - Eden에 충분한 메모리가 없을 때
                - Eden을 *over-estimate* 하게 할당
                - Eden 메모리를 할당한 이후, Young Generation Size 설정 
                    - `-Xmn=4/3*E, E = Eden Size`
        - Old Generation이 full에 가까워질 때
            - reduce the amount of memory used for **caching by lowering** `spark.memory.fraction`
                - 캐시 object를 줄이는 것이 task를 slow down되는 것을 막아준다.
            - Young Generation의 사이즈 줄이기 
                - `-Xmn`과 같이 설정하기 = 낮아짐 
            - JVM's **NewRatio** 파라미터 변경하기
                - 대부분 2로 설정되어 있음 
                    - Old generation =  **Heaps 2/3**
                - 이 수치보다 충분히 커야함(`spark.memory.fraction`)
    - **G1GC**
        - `-XX:+UseG1GC`
        - bottleneck에 의한 GC에서 좋은 성능을 보인다.
        - `XX:G1HeapRegionSize`
        - example
            - HDFS에서 데이터를 읽는 task
            - task에서 사용될 memory는 HDFS에서 data block을 읽는 양으로 예측할 수 있음
            - `decompressed block size = block size * 2 | 3`
            - 따라서 3개나 4개의 작업을 HDFS block size가 128M인 곳에서 작업시,
                - `Eden Size = 4*3*128M` 으로 예측 가능
            - 이후 GC가 얼마나 많이 일어나는지 모니터링 한다.
    - GC Tuning은 memory와 app에 의존적임
        - 세부 옵션 설정 : [tuning options](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/index.html)
        - 하지만 high level에서는 **Full GC**가 overhead를 줄이는 데 발생하는 비용에 관심
    - executor에 대한 GC는 `job configuraion`내 `spark.executor.extraJavaOptions`로 설정 가능


referenced by [Spark Documentation](http://spark.apache.org/docs/latest/tuning.html#garbage-collection-tuning)