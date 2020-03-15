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
      
* Data locality and rack awareness        
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
      
* Metadata management        
        
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
      
* Checkpoint using a secondary NameNode        
SKIP !!      
    
* Data integrity        
HDFS 는 checksum 메카니즘으로 데이터 인티그리티를 보장한다.    
HDFS 는 각 블락에 대한 checksum 을 관리하고, 데이터를 읽을 때 checksum 을 인증한다.    
Datanode 가 데이터를 저장하는데에 책임이 있다고 하면, checksum 은 데이터가 데이터노드에 잘 저장되어 있는거에 대한 책임이 있다.    
데이터를 읽게 되면 Datanode 는 block scanner 를 통해서 저장하고 있는 데이터 블락을 스캔한다.    
만약 데이터가 corrupt 되어 있다면, 새로운 복제본으로 바꾼다.    
	- HDFS write :     
	- HDFS read :  Client 가 데이터노드로 부터 데이터를 읽을 때, 블락의 checksum 을 비교하는데 checksum 이 일치 하지 않으면 그 정보를 NN 에게 보내고 NN 은 해당 블락을 corrupt 됐따고 마킹 하고 다른 복제본으로 대체에 필요한 액션을 취한다. 그리고 NN 은 해당 데이터에 대해서 해당 데이터노드가 복구가 될때까지 사용하지 않는다.    
    
* HDFS Snapshots        
SKIP!!    
* Data rebalancing        
HDFS 는 scalable 시스템이며, 데이터 사이즈가 클수록 데이터노드의 실패 확률도 높아지게 된다.(데이터 스큐)    
또한 새로운 데이터노드를 추가하거나 삭제할 때 데이터 스큐가 발생할 수 있다.    
이러한 문제를 해결하기 위해 balancer 라는 툴이 있다.    
일반적으로 block 을 write 할 때 아래와 같은 과정을 거친다.    
	- 클러스터의 데이터노드들에 데이터를 흩뿌린다.    
	- 첫 번째 블락이 저장된 동일한 랙에 복제본을 저장하는데 이는 cross-rack I/O 의 최적화를 돕는다.    
	- 새로운 노드가 추가될 때, HDFS 는 이전에 저장된 블락들을 옮기지 않고, 새로운 블락들만 저장한다.    
	- 만약 데이터느드가 죽거나 정상이 아닐 때, 해당 데이터노드가 들고 있는 블락들은 'under replicated'상태가 되며 다른 데이터노드에 저장되게 된다.    
balancer 툴에서 threadhold 라는 개념이 있는데, 이는 편차를 말하는 것이다.    
만약 아래와 같은 명령어를 수행하게 되면, 평균 60% 데이터 usage 를 나타날 때, 45% ~ 75% 사이에 데이터 usage가 있게 된다.    
$> hdfs balancer -threadhold 15    
balancer 는 두 가지 정책이 있다.    
	- Datanode : Default방법이며, Datanode 레벨에서 데이터 사용량을 일치시킨다.    
	- Blockpool 만약 HDFS Federation 을 사용하고 있다면 Blockpool 로 변경해야만 한다.    
    
* Best practices for using balancer    
Balancer 는 기존의 Balancer 가 끝날 때 까지, 새로운 Balancer 를 실행시키지 않는다.    
Balancer 도 하나의 task 이기 때문에 가능한한 빨리 끝내야만 한다.    
각각의 데이터노드는 10MBPS bandwidth 로 balancer job 을 수행한다.    
다른 job 에도 영향을 줄 수 있기 때문에, 일반적으로 전체 bandwidth  의 10% 으로 지정을 한다.    
Bandwidth 를 설정하는 명령어는 아래와 같다.    
    
$> hdfs -c 'hdfs dfsadmin -setBalancerBandwidth 157286540'    
    
#### HDFS reads and writes        
        
* Write workflows        
![image](https://user-images.githubusercontent.com/4033129/76694071-7d8f2880-66b1-11ea-9485-ad4099e8d6b0.png)    
        
* Read workflows        
![image](https://user-images.githubusercontent.com/4033129/76694083-bfb86a00-66b1-11ea-87fa-ea7f2e8497c5.png)    
    
* Short circuit reads        
dfs.client.read.shortcircuit 라는 옵션이 있는데, 이는    
만약 사용자가 Datanode 에서, 해당 Datanode 에 있는 데이터를 읽을 때 TCP socket 을 사용해서 데이터를 받을 수 있도록 한다.    
즉, Datanode를 모두 탐색하지 않는다는 것이다.    
    
#### Managing disk-skewed data in Hadoop 3.x        
기존에 데이터가 분산되어 저장되는 방법에는 2가지 문제점이 있다.    
	- corrupt 된 디스크를 대체해야만 하거나 더 많은 데이터를 위해 더 많은 디스크들을 추가해야만 한다.    
	- 동일한 데이터 노드에 디스크 크기들이 다양할 수 있다.    
이럴 경우 데이터 스큐가 발생할 수 있다는 것이다.    
Hadoop 3에서는 이러한 단점을 보완하기 위해 Diskbalancer 툴을 만들었다.    
명령어는 아래와 같다.    
$> hdfs diskbalancer -plan datanode1.hadoopcluster.com -out <file_folder_location>    
datanode1 에 대해서 disk balancer 에 대한 계획을 json 파일로 만들어 준다.    
$> hdfs distbalancer -execute <file_folder_location>/<datanode1>.plan.json    
$> hdfs diskbalancer -query datanode1.hadoopcluster.com    
실제로 diskbalancer 를 수행한다.    
    
#### Lazy persist writes in HDFS         
DISK I/O 는 하둡 퍼포먼스에 항상 중요한 관심사엿다.    
하둡 2.6 버전부터 데이터 노드의 off-heap 을 사용해서 데이터를 write 할 수 있게 하였는데, 비동기 방식이였다.    
이러한 방식을 lazy persist write 라고 불리웠다.    
하지만 이러한 방식은 데이터 유실의 가능성이 있고, 재시작 전에 write 하지 않는 방식으로 risk 를 최소화 할 수는 있다.    
그러나 완벽히 보장하는 것은 아니다.     
이러한 기능을 사용하기 위해서는 일부 RAM 영역을 지정해서 다른 Process 가 사용하지 못하게 한다.(RAM Disk 라고 불리운다.)    
RAM disk 는 재시작 전에 자동으로 Disk 에 데이터를 Write 하게 된다.    
  
<img width="690" alt="image" src="https://user-images.githubusercontent.com/4033129/76694262-10c95d80-66b4-11ea-9620-41e2e824f800.png">    
    
(Reference : https://hadoop.apache.org/docs/r3.1.2/hadoop-project-dist/hadoop-hdfs/MemoryStorage.html)    
    
#### Erasure encoding in Hadoop 3.x        
Erasure coding(EC) 는 적은 storage 비용으로 데이터를 저장하는 방법이다.  
데이터를 사용하는 패턴에 따라 라밸링을 하는 방식이다.  
3가지 라벨링 타입이 있다.  
	- Hot data : Default 값이다.하루에 20번 이상 해당 데이터에 접근하고 생성일이 7일보다 적을 때 해당된다. 이럴 경우 기존 하둡 2버전대와 동일하게 replication factor 가 3 으로 세팅되어있으면, 200% 의 추가 스토리지가 필요하게 된다.  
	- Warm data : 한 주동안 겨우 몇 번 접근한 데이터에 대해서 하나의 복제본만 갖게 되며, archive tier 로 저장되게 된다.  
	- Cold data : 한 달 동안 겨우 몇 번 접근하고, 생성된지 한 달 보다 큰 데이터에 대해 Cold layer 로 저장되게 된다.이러한 경우 EC 로 사용할 수 있게 된다.  
![image](https://user-images.githubusercontent.com/4033129/76694424-d3fe6600-66b5-11ea-8cb4-d77625853cc3.png)  
  
* Advantages of erasure coding        
3 가지 장점이 있다.  
	- Cold data에 대해 스토리지를 절약할 수 있다.  
	- 단순한 명령어로 hot, cold 에 대한 데이터를 마킹할 수 있다.  
	- 몇 퍼센트의 데이터가 유실되도, EC 도움으로 쉽게 복구할 수 있다.  
  
* Disadvantages of erasure coding        
3 가지 단점이 있다.  
	- Data locality !  
	- encoding / Decoding 비용  
	- EC를 통해 encode 된 데이터는 네트워크를 통해 데이터를 이동하지 않고서는 읽을 수가 없다. 그러므로 복사 비용이 필요하다.  
  
* HDFS common interfaces        
* HDFS read        
* HDFS write          
* HDFSFileSystemWrite.java        
* HDFS delete    
        
#### HDFS command reference        
* File System commands        
(자주 사용하지 않았떤 명령어만 기술한다.)  
$> hadoop fs -getmerge /user/packt/dir1 /home/sshuser  
하나의 파일로 만드는 방법.  
$> hadoop fs -skip-empty-file  
빈 파일들은 skip 하는 방법.  
  
* Distributed copy        
* Admin commands        
$> hdfs dfsadmin -report -live  
$> hdfs dfsadmin -report -dead  
  
#### Points to remember        
  
- HDFS consists of two main components: NameNode and DataNode. NameNode is a master node that stores metadata information, whereas DataNodes are slave nodes that store file blocks.  
- Secondary NameNode is responsible for performing checkpoint operations in which edit log changes are applied to fsimage. This is also known as a checkpoint node.  
- Files in HDFS are split into blocks and blocks are replicated across a number of DataNodes to ensure fault tolerance. The replication factor and block size are configurable.  
- HDFS Balancer is used to distribute data in an equal fashion between all DataNodes. It is a good practice to run balancer whenever a new DataNode is added and schedule a job to run balancer at regular intervals.  
- In Hadoop 3, high availability can now have more than two NameNodes running at a time. If an active NameNode fails, a new NameNode will be elected from an other NameNode and will become an active NameNode.  
- Quorum Journal Manager writes namespace modifications into multiple JournalNodes. These changes are then read by the Standby NameNode and they apply these changes to their fsimage file.  
- Erasure coding is a new feature that was introduced in Hadoop 3, which reduces storage overhead by up to 50%. The replication factor in HDFS costs us 200% more space. Erasure coding provides the same durability guarantee using less disk storage.
