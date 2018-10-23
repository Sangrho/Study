## 드루이드란 무엇인가?

드루이드는 큰 데이터 셋에서 OLAP 스타일이라 불리는 고성능의 분석을 위해 디자인된 데이터 저장소이다. 드루이드는 강력한 GUI 분석 어플리케이션을 위한 데이터 저장소로서 사용되거나 빠른 Aggregation 이 필요한 highly-concurrent API 의 Backend 로서도 사용된다. 드루이드가 갖고있는 일반적인 어플리케이션 영역은 다음과 같다: </br>
* Clickstream analytics</br>
* Network flow analytics</br>
* Server metrics storage</br>
* Application performance metrics</br>
* Digital marketing analytics</br>
* Business intelligence / OLAP</br>
드루이드의 주요 피쳐는 다음과 같다:</br>
1. Columnar storage format. 드루이드는 열지향 저장소를 사용하는데, 이는 특정 쿼리에서 필요한 정확한 열들을 로그하는 것이 필요하다는 의미이다. 이 의미는 오직 몇개의 열들을 건드리는 것만으로 쿼리를 하는데 엄청난 속도를 낼 수 있다. 게다가 각각의 열은 빠른 스캔과 aggregation 을 지원하는 특별한 데이터 타입으로 최적화된 상태로 저장된다.</br>
2. Scalable distributed system. 드루이드는 전형적으로 </br>
3. Massively parallel processing.</br>
4. Realtime or batch ingestion.</br>
5. Self-healing, self-balancing, easy to operate.</br>
6. Cloud-native, fault-tolerant architecture that won’t lose data.</br>
7. Indexes for quick filtering.</br>
8. Approximate algorithms.</br>
9. Automatic summarization at ingest time.</br>
