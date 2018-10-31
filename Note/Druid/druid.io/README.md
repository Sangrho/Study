Druid 공식홈페이지의 Docs 를 번역하여, 이해를 돕는다. </br>
버전은 최신버전으로 한다.

URL : http://druid.io/docs/latest/design/

-----------------------

## Getting Started

### [Design](http://druid.io/docs/latest/design/index.html) 
[What is Druid?](http://druid.io/docs/latest/design/index.html#what-is-druid) </br>
[When should I use Druid](http://druid.io/docs/latest/design/index.html#when-to-use-druid) </br>
[Architecture](http://druid.io/docs/latest/design/index.html#architecture) </br>
[Datasources & Segments](http://druid.io/docs/latest/design/index.html#datasources-and-segments) </br>
[Query processing](http://druid.io/docs/latest/design/index.html#query-processing) </br>
[External dependencies](http://druid.io/docs/latest/design/index.html#external-dependencies) </br>
[Ingestion overview](http://druid.io/docs/latest/ingestion/index.html) </br>

### [Quickstart](http://druid.io/docs/latest/tutorials/index.html)
[Tutorial: Loading a file](http://druid.io/docs/latest/tutorials/tutorial-batch.html) </br>
[Tutorial: Loading stream data from Kafka](http://druid.io/docs/latest/tutorials/tutorial-kafka.html) </br>
[Tutorial: Loading a file using Hadoop](http://druid.io/docs/latest/tutorials/tutorial-batch-hadoop.html) </br>
[Tutorial: Loading stream data using HTTP push](http://druid.io/docs/latest/tutorials/tutorial-tranquility.html) </br>
[Tutorial: Querying data](http://druid.io/docs/latest/tutorials/tutorial-query.html) </br>

### Further tutorials

[Tutorial: Rollup](http://druid.io/docs/latest/tutorials/tutorial-rollup.html) </br>
[Tutorial: Configuring retention](http://druid.io/docs/latest/tutorials/tutorial-retention.html) </br>
[Tutorial: Updating existing data](http://druid.io/docs/latest/tutorials/tutorial-update-data.html) </br>
[Tutorial: Compacting segments](http://druid.io/docs/latest/tutorials/tutorial-compaction.html) </br>
[Tutorial: Deleting data](http://druid.io/docs/latest/tutorials/tutorial-delete-data.html) </br>
[Tutorial: Writing your own ingestion specs](http://druid.io/docs/latest/tutorials/tutorial-ingestion-spec.html) </br>
[Tutorial: Transforming input data](http://druid.io/docs/latest/tutorials/tutorial-transform-spec.html) </br>

### [Clustering](http://druid.io/docs/latest/tutorials/cluster.html) </br>

## Data Ingestion

[Ingestion overview](http://druid.io/docs/latest/ingestion/index.html) </br>
[Data Formats](http://druid.io/docs/latest/ingestion/data-formats.html) </br>
[Tasks Overview](http://druid.io/docs/latest/ingestion/tasks.html) </br>
[Ingestion Spec](http://druid.io/docs/latest/ingestion/ingestion-spec.html) </br>
[Transform Specs](http://druid.io/docs/latest/ingestion/transform-spec.html) </br>
[Firehoses](http://druid.io/docs/latest/ingestion/firehose.html) </br>
[Schema Design](http://druid.io/docs/latest/ingestion/schema-design.html) </br>
[Schema Changes](http://druid.io/docs/latest/ingestion/schema-changes.html) </br>
[Batch File Ingestion](http://druid.io/docs/latest/ingestion/batch-ingestion.html) </br>
[Native Batch Ingestion](http://druid.io/docs/latest/ingestion/native-batch.html) </br>
[Hadoop Batch Ingestion](http://druid.io/docs/latest/ingestion/hadoop.html)</br>
[Stream Ingestion](http://druid.io/docs/latest/ingestion/stream-ingestion.html) </br>
[Kafka Indexing Service (Stream Pull)](http://druid.io/docs/latest/development/extensions-core/kafka-ingestion.html) </br>
[Stream Push](http://druid.io/docs/latest/ingestion/stream-push.html) </br>
[Compaction](http://druid.io/docs/latest/ingestion/compaction.html) </br>
[Updating Existing Data](http://druid.io/docs/latest/ingestion/update-existing-data.html) </br>
[Deleting Data](http://druid.io/docs/latest/ingestion/delete-data.html) </br>
[Task Locking & Priority](http://druid.io/docs/latest/ingestion/locking-and-priority.html) </br>
[FAQ](http://druid.io/docs/latest/ingestion/faq.html) </br>
[Misc. Tasks](http://druid.io/docs/latest/ingestion/misc-tasks.html) </br>

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
