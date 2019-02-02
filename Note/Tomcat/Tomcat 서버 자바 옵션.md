## Tomcat 서버 자바 옵션
### `-XX:-UseAdaptiveSizePolicy`
- JDK 1.4버전부터 `default=true`
- java에서 자동으로 total heap size를 동적으로 변화시킴
- 잘 사용하면 메모리를 효율적으로 사용할 수 있으나,
    - 잘못하면 `Full GC`가 계속적으로 발생하여, 서비스가 비정상적으로 운용될 수 있음

### `-XX:+UseG1GC`
- G1GC를 활성화 하는 옵션

### `-verbose:gc`
- GC 기록을 남긴다.

### `-XX:+PrintGCTimeStamps`
- GC 발생 시간 정보 출력ㅖ

### `-XX:+PrintGCDetails`
- GC 수행 상세 내용 출력

### `-Xloggc:/workspace/logs/gc.log`
- GC 로그 파일 지정 
- 해당 옵션이 없을경우, gc관련 로그는 콘솔에 출력 

### 다양한 GC 부가 옵션 
```
-XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=2M
```

### `-XX:+HeapDumpOnOutOfMemoryError`
- java heap또는 permanent generation에서 정상적인 할당이 이루어지지 못할경우, heap dump

### `-XX:HeapDumpPath=/workspace/logs/heap-was1.hprof`
- heapdump 파일의 경로를 지정한다.


### 최종 옵션 
```
# in catalina.sh

CATALINA_OPTS="$CATALINA_OPTS -server -Xms2048M -Xmx2048M -XX:-UseAdaptiveSizePolicy -XX:+UseG1GC -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/workspace/logs/gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=2M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/workspace/logs/heap-was1.hprof"
```