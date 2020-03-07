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
```  
(number_of_replicas-1)/number_of_racks+2  
```
  
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
네임노드가 하는 기능들은 아래와 같다.  
- HDFS 에 저장된 파일들과 디렉토리들에 대한 메타데이터  
- 파일 또는 디렉토리에 저장된 Access control 리스트들에 관련한 어떠한 파일 작업이든 제어한다.  
- 사용자에게 데이터블락에 대한 정보를 제공한다.  
- 데이터노드에 대한 헬스 Status(missing block 등) 를 보여준다  
  
네임노드는 INodes 라 불리우는 Data Structure 를 메모리에서 관리한다.   
INodes 는 파일과 디렉토리에 대한 모든 정보를 갖고 있다. (이름, 유저이름, 그룹이름, 권한, ACL, 수정된 시간, 접근 시간, 디스크 Space Quota)  
  
Data locality and rack awareness    
하둡의 목표 중 하나는, 데이터를 연산하는 곳으로 옮기는거보다 데이터가 있는 곳에서 연산하는 것이다.  
Data Local 이라 불리우는 것은 MR Job 이 기동될 때 Input data 와 연관된 데이터노드에서 Mapper Job 을 띄우는 것이다.  
다만 여러 Mapper Job 에서 나온 결과들을 하나의 Reduce Job 에서 사용할 수 있기 때문에, Reduce Job 은 Data Locality 를 사용하지 않는다.  
이러한 Data Locality 를 지키기 위해 세가지 복제 정책을 사용하는데, 종류는 Data Local, Rack Loca, Off Rack 이라 불리운다.   
만약 input data 의 복제본이 있는 노드에서 Job 이 기동될 수 없는 상황이면, 동일한 Rack 에 있는 여유있는 노드에서 수행된다.  
만약 동일한 Rack 에도 여유가 없다면 완전 다른 Rack 에서 수행된다.  
  
![image](https://user-images.githubusercontent.com/4033129/76144922-2a711080-60c8-11ea-8316-a09f492afe6d.png)  
  
그러므로 Rack awareness 를 위해 Cluster Topology 는 매우 중요하다.  
  
#### DataNode internals    
크게 3가지 작업을 한다.  
 - 클라이언트로 부터 읽기/쓰기 작업  
 - 복제 작업  
 - 네임노드에게 Block Report 와 Heartbeats 정보를 보낸다.  
  
#### Quorum Journal Manager (QJM)    
QJM은 클러스터의 N개 시스템에서 실행되는 JournalNode의 로컬 디스크에 편집을 기록한다. 이러한 JournalNode는 NameNode 시스템과 공유되며 활성 NameNode에 의해 수행된 모든 수정은 이러한 공유 노드의 편집 파일에 기록된다  
  
#### HDFS high availability in Hadoop 3.x   
NN HA 을 위해 중요한 설정값은 아래와 같다.  
  
```
<property> <name>dfs.nameservices</name><value>mycluster</value></property>  
  
<property> <name>dfs.ha.namenodes.mycluster</name><value>nn1,nn2,nn3</value></property>  
  
<property> <name>dfs.namenode.rpc-address.mycluster.nn1</name><value>masternode1.example.com:9820</value></property>  
<property><name>dfs.namenode.rpc-address.mycluster.nn2</name><value>masternode2.example.com:9820</value> </property>  
<property><name>dfs.namenode.rpc-address.mycluster.nn3</name><value>masternode3.example.com:9820</value> </property>  
<property> <name>dfs.namenode.http-address.mycluster.nn1</name><value>masternode1.example.com:9870</value></property>  
<property><name>dfs.namenode.http-address.mycluster.nn2</name><value>masternode2.example.com:9870</value> </property>  
<property><name>dfs.namenode.http-address.mycluster.nn3</name><value>masternode3.example.com:9870</value> </property>  
  
``` 
  
Metadata management    
    
fsimage 파일은 파일 시스템 수정 시마다 고유하고 변조되지 않은 증가 트랜잭션 ID가 할당되는 파일 시스템의 전체 상태를 포함한다. fsimage 파일은 특정 트랜잭션 ID까지의 파일 시스템 상태를 나타낸다.  
아래명령어도 readable 하게 볼 수 있다.  
  
```
<property>  
<name>dfs.cluster.administrators</name>  
<value>user1,user2,user3 group1,group2,group3</value>  
</property>  
  
hdfs dfsadmin -fetchImage ./josh  
hdfs oiv -i ./josh/fsimage_00000000007685439 -o ./josh/fsimage_output.csv -p Delimited  
sed -i -e "1d" ./josh/fsimage_output.csv  
```
  
Checkpoint using a secondary NameNode    
SKIP !!  

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
