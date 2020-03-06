### 1.Journey to Hadoop 3  
Hadoop 1에서 2로 넘어오면서 중요 포인트는  
- 리소스 매니저  
- 잡 스케줄링  
- HDFS HA  
- HDFS Federation  
- HDFS Snapshot   
  
Hadoop 3로 넘어오면서 중요 포인트는  
- Erasure coding  
- A new YARN Timeline service  
- YARN ooportunistic containers  
- Distributed scheduling  
- Support for three name nodes,  
- Intra-data-node load balancers  
  
#### Hadoop origins and Timelines  
Origins  
MapReduce origin  
Timelines  
#### Overview of Hadoop 3 and its features  
HDFS 는 기본적으로 3 복제 정책을 갖고 있다. Data locality 와 Fualt-tolerant, 데이터노드에서의 로드밸런싱에는 좋다.  
하지만 이는 곳 200% 이상의 오버헤드를 갖고 있다.  
  
* Overhead due to data replication factor:  
I/O 활동이 적은 자주 액세스하지 않는 데이터 세트의 경우, 이러한 복제된 블록은 정상적인 운영 과정에서 결코 액세스되지 않는다. 반면에, 그들은 다른 주요 자원들과 같은 수의 자원을 소비한다.  
자주 액세스하지 않는 데이터로 이러한 오버헤드를 완화하기 위해 Hadoop 3은 Erasure coding 이라는 주요 기능을 도입했다. 이것은 공간을 크게 절약하면서 데이터를 내구성이 있게 저장한다.  
  
* Improving existing YARN Timeline services  
YARN 타임라인 서비스 버전 1은 안정성, 성능 및 확장성에 영향을 미치는 한계를 가지고 있다. 예를 들어 많은 수의 요청으로 확장할 수 없는 로컬 디스크 기반 LevelDB 스토리지를 사용한다. 더욱이 타임라인 서버는 단일 장애 지점이다. 이러한 단점을 완화하기 위해 YARN 타임라인 서버는 Hadoop 3 릴리즈를 통해 다시 설계되었다.  
LevelDB?  
  
* Optimizing map output collector  
JNI 측면에서 효율성을 강조하였다. 셔플이 많은 작업에 유용하게 적용될 것이다.  
  
* The need for a higher availability factor of NameNode  
2개를 초과하는 네임노드를 설정할 수 있다.  
  
* Dependency on Linux ephemeral port range  
리눅스 포트 한계를 넘어선다고?  
  
* Disk-level data skew  
디스크 사이즈와 종류가 다른 데이터노드별로 발란싱을 맞춰주는 내용인갑다.  
  
#### Hadoop logical view  
![image](https://user-images.githubusercontent.com/4033129/76091027-18c43600-6000-11ea-9f86-9cc8a36b791b.png)  
  
#### Hadoop distributions  
On-premise distribution  
Cloud distributions  
Points to remember  
  
- Doug Cutting, the founder of Hadoop, started the development of Hadoop at Nutch based on a Google research paper on Google File System and MapReduce.  
- Apache Lucene is a full-text open-source search library initially written by Doug Cutting in Java.  
- Hadoop consists of two important parts, one called the Hadoop Distributed File System and the other called MapReduce.  
- YARN is a resource management framework used to schedule and run applications such as MapReduce and Spark.  
- Hadoop distributions are a complete package of all open source big data tools integrated together to work with each other in an efficient way.
