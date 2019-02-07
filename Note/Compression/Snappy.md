## Snappy Compression
- 압축/압축해제 라이브러리
- 주요 목적이 높은 압축률이나 다른 압축라이브러리와의 호환성에 중점을 둔 것이 아니라,
    - **매우 빠른 속도의 압축 속도**와 **합리적인 압축률**을 제공하는 것에 중점을 두고 있는 오픈 소스 압축 툴이다.
- 250MB/s (어셈블리 코드 제외)
- 구현과 인터페이스 모두 c++로 작성 됨
- 구글에서 만들어짐
- 현재 **hadoop ecosystem**에서 파일 포맷을 지원한다.
    - impala에서 해당 파일 확장자를 발견하면, 자동으로 com/decompression을 지원 
- 네트워크 트래픽이 매우 중요한 분산 환경에서 사용 


### 사용 기술 스택 
- MongoDB
- Cassandra
- couchbase
- Hadoop
- LessFS
- LevelDB
- Lucene
- VoltDB


referenced by, [snappy](http://google.github.io/snappy/)