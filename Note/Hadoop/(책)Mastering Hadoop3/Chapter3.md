### 3. YARN Resource Management in Hadoop   
  
#### Architecture  
Hadoop 1 -> 2에서 아래의 한계를 극복하기 위해 YARN 을 만들게 되었다.  
- Scalability : JobTracker 가 잡에 대한 스케줄링, 모니터링 및 실패 시 재기동에 대한 책이이 있었는데, 4천 서버에 4만개의 task 라는 제약이 있었다.  
- Hight availability : JobTracker 자체가 SPOF 였으며, 아주 짧은시간에도 많은 변화가 있기 때문에 JobTracker 에 대한 HA 구성이 어려웠다.  
- Memory utilization : map 과 reduce 의 task tracker slot 에 대한 선점되는 리소스가 정해져 있어야만 했다.  
- Non MapReduce jobs : JobTracker 는 MR 과 매우 밀접했기 때문에 다른 요구사항을 받을 수 있는 환경이 필요했다.   
  
![image](https://user-images.githubusercontent.com/4033129/77248494-1eb34b80-6c7d-11ea-9acd-b8800ce2c173.png)  
  
- Resource Manager  
  - Scheduler  
  - Application Manager  
- Node manager  
- Application master  
  
* Resource Manager component  
RM 은 YARN 의 핵심 컴퍼넌트이다. RM 의 주요 역할들을 살펴보자.  
- Client component  
- Core component  
  - YarnScheduler  
  - RMStateStore  
  - SchedulingMonitor  
  - RMAppManager  
- Node Manager component  
- Application master component  
  
* Node manager core  
- Resource manager component  
- Container component  
  - Applicaiton master request  
  - ContainerLauncher  
  - ContainerMonitor  
  - LogHandler  
    
#### Introduction to YARN job scheduling  
  
#### FIFO scheduler  
  
#### Capacity scheduler  
  
* Configuring capacity scheduler  
  
#### Fair scheduler  
* Scheduling queues  
* Configuring fair scheduler  
  
#### Resource Manager high availability  
* Architecture of RM high availability  
* Configuring Resource Manager high availability  
  
#### Node labels  
* Configuring node labels   
  
#### YARN Timeline server in Hadoop 3.x  
* Configuring YARN Timeline server   
  
#### Opportunistic containers in Hadoop 3.x  
* Configuring opportunist container  
  
#### Docker containers in YARN  
* Configuring Docker containers  
Running the Docker image  
Running the container  
  
#### YARN REST APIs  
* Resource Manager API  
* Node Manager REST API  
  
#### YARN command reference  
* User command  
application commands  
Logs command  
* Administration commands  
Summary
