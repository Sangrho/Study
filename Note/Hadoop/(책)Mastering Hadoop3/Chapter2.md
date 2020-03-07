### 2.Deep Dive into the Hadoop Distributed File System   
해당 쳅터에서는 아래 4개의 꼭지로 설명하기로 한다.  
	- The details of the HDFS architecture  
	- Read/write operations  
	- The internals of HDFS components  
	- HDFS commands and understanding their internal working  
  
#### Defining HDFS  
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
  
#### Deep dive into the HDFS architecture  
(개인의견 : 해당 챕터는 이미 하둡에 대해서 익히 알고 있는 사람들은 알고 있는 내용이다.)

큰 데이터를 다루는데 여러가지 문제점들이 있고, HDFS 는 아래와 같이 해결했다.
	- 큰 데이터셋을 다룰 때 처리 비용이 큰 점 : MR 을 적용해서 완화하였다.
	- 분산처리때문에 발생되는 네트워크 비용이 큰 점 : 데이터가 있는 곳에서 연산할 수 있도록 하여 완화하였다.
	- SPOF : HA 구성을 하였다.
	- 다양한 유저가 사용을 할 때, 일관성 모델을 지원한다. 한 번 써진 파일에 대해서 수정할 수 없다..?
HDFS logical architecture  
![image](https://user-images.githubusercontent.com/4033129/76139157-1e1d9100-6091-11ea-802f-3c45497ac58d.png)

##### Concepts of the data group  
  
* Blocks  
Block 을 사용해서 얻는 장점은 아래와 같다.
  1. 각 데이터 블락별로 메타데이터를 관리하기 수월한다.
  하지만 작은 파일일수록 메타데이터를 젖아하는 NN 에 부하를 주게되고, RPC Call이 많아진다. 
  2. 데이터 블록 사이즈가 클수록 Disk 에서 데이터를 찾는 탐색 시간이 줄어 든다.
* Replication  
reliability, Scalibility 그리고 Performance 에서 가장 중요한 포인트이다.
기본 복제 값이 3인데, 하나는 동일한 랙에 저장하고, 하나는 다른 랙에 저장해서 랙 장애에도 대비를 한다.
복제본 최대값은  데이터노드의 수와 동일한다.
랙과 복제본에 대한 산식은 아래와 같다.
₩₩₩
(number_of_replicas-1)/number_of_racks+2
₩₩₩

##### HDFS communication architecture  
![image](https://user-images.githubusercontent.com/4033129/76140019-8ff9d880-6099-11ea-8497-2f23ac1c791c.png)
* Client Protocol
	- create : HDFS 에 새로운 파일을 생성한다.
	- append : 파일의 끝에 붙인다.
	- setReplication : 파일의 복제본을 결정하는 값
	- addBlock : 추가적으로 데이터 블락을 결정하는 값

* Data Transfer Protocol
	- readBlock : 데이터노드로부터 데이터 블락을 읽는다.
	- writeBlock : 데이터노드에 데이터 블락을 쓴다.
	- transferBlock : 데이터노드에서 다른 데이터노드로 데이터블락을 전송한다.
	- blockChecksum : 데이터 블락에 대한 checksum 벨류를 받는다.

* Data Node Protocol
	- registerDatanode : 새로운 또는 재부팅된 데이터노드를 네임노드에 등록한다.
	- sendHeartbeat : 데이터 노드가 살아있는지 적절히 일하고 있는지 네임노드에 알려준다.
	이 메소드는 데이터노드가 살아있는지 체크하는 것으로 중요할 뿐만 아니라, 네임노드에게 실행하는 명령어들에 대한 데이터노드의 응답을 알수 있는 아주 중요한 메소드이다.
	- blockReport : 데이터노드가 로컬로 갖고 있는 블락 관련 정보를 네임노드에게 전달할 때 사용된다. 이 메소드를 통해 네임노드는 데이터노드에게 삭제해야 할 블락을 알려준다.

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
