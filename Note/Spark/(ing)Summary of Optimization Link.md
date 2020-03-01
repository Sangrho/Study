Link : https://medium.com/@sambodhi_72782/spark-tuning-manual-47b98ccb2b2c  

M = spark.executor.memory + spark.yarn.executor.memoryOverhead (by default 0.1 of executor.memory) < container-memory.

When running Spark on YARN, each Spark executor runs as a YARN container. Multiple executors (and therefore containers) can run in one instance, where M cannot be less than yarn.scheduler.minimum-allocation-mb or more than yarn.scheduler.maximum-allocation-mb and sum M for all executors/containers on a single host cannot be more than yarn.nodemanager.resource.memory-mb.

* Easier to understand with an example
Let’s say we are using r4.4xlarge instances with 16 vCPUs, 130 GB RAM but available memory for containers is 116736 MB.
Leave one core for the OS and let’s say we set the number of executor-cores as 3 (16–1 = 15).
Calculate the number of executors: Number of executors per instance = (total number of virtual cores per instance — 1) / executor-cores with 3 cores per executor, we can have 5 executors-per-instance (16–1) / 3 = 5. So if our cluster has 4 instances, num-executors (in cluster) = 5 * 4 = 20.
Set spark.executor.memory 18 GB. Therefore, in our case: (18 + (0.1 * 18)) * 5 = 99GB < 116736MB (container memory)

* Understanding Spark’s memory usage is important
```
‘Usable’ memory (M) = (Java Heap — Reserved Memory) * spark.memory.fraction
Where M is the unified shared memory between execution and storage. The default value of spark.memory.fraction is 0.6 or 60%
The rest of 40% memory is used as ‘user memory’ reserved for user data structures, internal metadata, etc
```

```
M = execution memory + storage memory
Execution memory <= M * (1 — spark.memory.storageFraction)
Storage memory >= M * spark.memory.storageFraction
```



https://www.slideshare.net/databricks/strata-sj-everyday-im-shuffling-tips-for-writing-better-spark-programs
