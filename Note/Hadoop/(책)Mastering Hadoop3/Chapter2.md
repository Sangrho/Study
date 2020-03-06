### 2.Deep Dive into the Hadoop Distributed File System   
해당 쳅터에서는 아래 4개의 꼭지로 설명하기로 한다.  
- The details of the HDFS architecture  
- Read/write operations  
- The internals of HDFS components  
- HDFS commands and understanding their internal working  
  
####Defining HDFS  
HDFS 몇가지 중요한 피쳐들을 소개하자면,  
  
* Fault tolerance  
HDFS 는 블락이란 청크 단위로 데이터가 저장되며, 여러 클러스터를 거쳐서 복제 팩터로 뿌려진다.  
그래서 하나의 블락이 없어져도, 복구가 가능하다.  
* Streaming data access  
HDFS 의 기본 철학은 한 번 쓰고 여러번 읽는다 이다.  
HDFS 는 모든 데이터가 전송될때까지 못 보게 하지 않는다.(DB 의 Transaction lock 같은..?)  
* Scalability  
* Simplicity  
쉽게 구축할 수 있고, 커맨드라인으로 쉽게 핸들링 가능하다.  
* High availability  
기본적으로 하둡 에코의 대부분은 모두 HA가 가능하다.  
  
####Deep dive into the HDFS architecture  
  
HDFS logical architecture  
  
Concepts of the data group  
  
Blocks  
  
Replication  
  
HDFS communication architecture  
  
#### NameNode internals  
  
Data locality and rack awareness  
  
#### DataNode internals  
  
#### Quorum Journal Manager (QJM)  
  
#### HDFS high availability in Hadoop 3.x Data management  
  
Metadata management  
  
Checkpoint using a secondary NameNode  
  
Data integrity  
  
HDFS Snapshots  
  
Data rebalancing  
  
Best practices for using balancer&#xA0;  
  
#### HDFS reads and writes  
  
Write workflows  
  
Read workflows  
  
Short circuit reads  
  
#### Managing disk-skewed data in Hadoop 3.x  
  
#### Lazy persist writes in HDFS   
  
#### Erasure encoding in Hadoop 3.x  
  
Advantages of erasure coding  
  
Disadvantages of erasure coding  
  
HDFS common interfaces  
  
HDFS read&#xA0;  
  
HDFS write&#xA0;  
  
HDFSFileSystemWrite.java  
  
HDFS delete&#xA0;  
  
#### HDFS command reference  
  
File System commands  
  
Distributed copy  
  
Admin commands  
  
#### Points to remember  
  
Summary
