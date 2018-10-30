Druid 공식홈페이지의 Docs 를 번역하여, 이해를 돕는다. </br>
버전은 최신버전으로 한다.

URL : http://druid.io/docs/latest/design/

### Design 
[What is Druid?](http://druid.io/docs/latest/design/index.html#what-is-druid) </br>
[When should I use Druid](http://druid.io/docs/latest/design/index.html#when-to-use-druid) </br>
[Architecture](http://druid.io/docs/latest/design/index.html#architecture) </br>
[Datasources & Segments](http://druid.io/docs/latest/design/index.html#datasources-and-segments) </br>
[Query processing](http://druid.io/docs/latest/design/index.html#query-processing) </br>
[External dependencies](http://druid.io/docs/latest/design/index.html#external-dependencies) </br>
[Ingestion overview](http://druid.io/docs/latest/ingestion/index.html) </br>

### Quickstart
Tutorial: Loading a file </br>
Tutorial: Loading stream data from Kafka </br>
Tutorial: Loading a file using Hadoop </br>
Tutorial: Loading stream data using HTTP push </br>
Tutorial: Querying data </br>
Further tutorials </br>
Tutorial: Rollup </br>
Tutorial: Configuring retention </br>
Tutorial: Updating existing data </br>
Tutorial: Compacting segments </br>
Tutorial: Deleting data </br>
Tutorial: Writing your own ingestion specs </br>
Tutorial: Transforming input data </br>
Clustering </br>

### Data Ingestion

Ingestion overview </br>
Data Formats </br>
Tasks Overview </br>
Ingestion Spec </br>
Transform Specs </br>
Firehoses </br>
Schema Design </br>
Schema Changes </br>
Batch File Ingestion </br>
Native Batch Ingestion </br>
Hadoop Batch Ingestion
Stream Ingestion </br>
Kafka Indexing Service (Stream Pull) </br>
Stream Push </br>
Compaction </br>
Updating Existing Data </br>
Deleting Data </br>
Task Locking & Priority </br>
FAQ </br>
Misc. Tasks </br>

### Querying 

Overview </br>
Timeseries </br>
TopN </br>
GroupBy </br>
Time Boundary </br>
Segment Metadata </br>
DataSource Metadata </br>
Search </br>
Select </br>
Scan </br>
Components </br>
Datasources </br>
Filters </br>
Aggregations </br>
Post Aggregations </br>
Granularities </br>
DimensionSpecs </br>
Context </br>
Multi-value dimensions </br>
SQL </br>
Lookups </br>
Joins </br>
Multitenancy </br>
Caching </br>
Sorting Orders </br>
Virtual Columns </br>

### Design

Overview </br>
Storage </br>
Segments </br>
Node Types </br>
Historical </br>
Broker </br>
Coordinator </br>
Indexing Service </br>
Overlord </br>
MiddleManager </br>
Peons </br>
Realtime (Deprecated) </br>
Dependencies </br>
Deep Storage </br>
Metadata Storage </br>
ZooKeeper </br>

### Operations 

API Reference </br>
Coordinator </br>
Overlord </br>
MiddleManager </br>
Peon </br>
Broker </br>
Historical </br>
Good Practices </br>
Including Extensions </br>
Data Retention </br>
Metrics and Monitoring </br>
Alerts </br>
Updating the Cluster </br>
Different Hadoop Versions </br>
Performance FAQ </br>
Dump Segment Tool </br>
Insert Segment Tool </br>
Pull Dependencies Tool </br>
Recommendations </br>
TLS Support </br>
Password Provider </br>

### Configuration 

Configuration Reference </br>
Recommended Configuration File Organization </br>
JVM Configuration Best Practices </br>
Common Configuration </br>
Coordinator </br>
Overlord </br>
MiddleManager & Peons </br>
Broker </br>
Historical </br>
Caching </br>
General Query Configuration </br>
Configuring Logging </br>
