
# 一、Flink简介
## 1.基本概念
Apache Fline是一个**框架**和**分布式**处理引擎，用于**无界和有界流**进行**状态**计算

## 2.Flink的优势
流数据更真实地反映了我们的生活方式
传统的数据架构是基于有线数据集的
目标，低延迟、高吞吐、结果的准确性和良好的容错性

## 3.应用领域
电商和市场营销(数据报表、广告投放、业务流程需要)
物联网(传感器实时数据采集和显示、实时预警，交通运输业)
电信业(基站流量调配)
银行和金融业(实时计算和通知推送，实时监测异常行为)

## 4.传统数据处理架构

### 4.1 事务处理

### 4.2 分析处理
 * 将数据从业务数据库复制到数仓，再进行分析和查询

### 4.3 有状态的流式处理

## 5.流与批处理的世界观

### 5.1 流处理

#### 5.1.2 流处理的演变


## 6.Flink主要特点

### 6.1 事件驱动

### 6.2 基于流的世界观



# 二、快速入门
 * 见maven工程 https://github.com/Tiankx1003/BigData-Flink/tree/master/FlinkTutorial

# 三、Flink快速部署

## 1.Standalone模式

## 2.Yarn模式
```bash
# 分发jar包
xsync /opt/jars
# 启动hadoop集群
# 启动yarn-session
./yarn-session.sh -n 2 -s 2 -jm 1024 -tm 1024 -nm test -d
# 执行任务
./flink run  \
-m yarn-cluster \
-c com.tian.flink.wc.StreamWordCount  \
/opt/jars/FlinkTutorial-1.0-SNAPSHOT.jar  \
--host hadoop102 \
--port 7777
```
## 3.Kubernetes部署

# 四、Flink运行时架构
 * 因为Flink是用Java和Scala实现的，所以所有组件都会运行在Java虚拟机上。

## 1. Flink运行时的组件

### 1.1 作业管理器 JobManager
控制一个应用程序执行的主进程，每个应用都会被一个单独的JobManager所控制执行。JobManager会先收到要执行的应用程序，这个应用程序会包括作业图(JobGraph)、逻辑数据流图(logical dataflow graph)和打包了所有的类、库和其他资源的Jar包。JobManager会把JobGraph转换成一个物理层面的数据流图，这个图被叫做执行图(ExecutionGraph)，包含了所有可以并发执行的任务。JobManager会向资源管理器(ResourceManager)请求执行任务必要的资源，也就是任务管理器(TaskManager)上的插槽(slot)。一旦获取了足够的资源，就会将执行图分发到真正运行他们的TaskManager上。而在运行过程中，JobManager会负责所有需要中央协调的操作，如检查点(checkpoints)的协调。

### 1.2 资源管理器 ResourceManager
主要负责管理任务管理器(TaskManager)的插槽(slot)，TaskManager插槽是Flink中定义的处理资源单元，Flink为不同的环境和资源管理工具提供了不同资源管理器，如Yarn、Mesos、K8s，以及standalone部署。当JobManager申请插槽资源时，ResourceManager会将所有空闲插槽的TaskManager分配给JobManager。如果ResourceManager没有足够的插槽来满足JobManager的请求，他还可以向资源提供平台发起会话，以提供启动TaskManager进程的容器。另外，ResourceManager还负责终止空闲的TaskManager，释放计算资源。

### 1.3 任务管理器 TaskManager
Flink中的工作进程，通常在Flink中会有多个TaskManager运行，每一个TaskManager都会包含一定数量的插槽(slots)。插槽的数量限制了TaskManager能够执行的任务数量。启动之后，TaskManager会向资源管理器注册他的插槽；收到资源管理器的指令后，TaskManager就会将一个或者多个插槽提供给JobManager调用。JobManager就可以向插槽分配给任务(tasks)来执行了。在执行过程中，一个TaskManager可以跟其他运行同一应用程序的TaskManager交换数据。

### 1.4 分发器 Dispatcher
可以跨作业运行，它为应用提交提供了REST接口。当一个应用被提交执行时，分发器就会启动并将应用提交给一个JobManager。由于是REST接口，所以Dispatcher可以作为集群的一个HTTP接入点，这样就能够不受防火墙阻挡。Dispatcher也会启动一个WebUI，用来方便的展示和监控作业执行的信息。Dispatcher在架构中可能并不是必须的，这取决于应用提交运行的方式。

## 2.任务提交流程
### 2.1 任务提交和组件交互流程

### 2.2 Yarn模式下的任务提交


Flink任务提交后，Client向HDFS上传Flink的Jar包和配置，之后向Yarn ResourceManager提交任务，ResourceManager分配Container资源并统治对应的NodeManager启动ApplicationMaster，Application启动后家在Flink的Jar包和配置构建环境，然后启动JobManager，之后ApplicationMaster向ResourceManager申请资源启动TaskManager，ResourceManager分配Container资源后，由ApplicationMaster家在Flink的Jar包和配置构建环境并启动TaskManager，TaskManager启动都向JobManager发送心跳包，并等待JobManager向其分配任务。


## 3.任务调度原理
客户端不是运行时和程序执行的一部分，但它用于准备并发送dataflow(JobGraph)给Master(JobManager)，然后，客户端断开连接或者维持连接以等待接收计算结果。
当 Flink 集群启动后，首先会启动一个 JobManger 和一个或多个的 TaskManager。由 Client 提交任务给 JobManager，JobManager 再调度任务到各个 TaskManager 去执行，然后 TaskManager 将心跳和统计信息汇报给 JobManager。TaskManager 之间以流的形式进行数据的传输。上述三者均为独立的 JVM 进程。

**Client** 为提交 Job 的客户端，可以是运行在任何机器上（与 JobManager 环境连通即可）。提交 Job 后，Client 可以结束进程（Streaming的任务），也可以不结束并等待结果返回

**JobManager** 主要负责调度 Job 并协调 Task 做 checkpoint，职责上很像 Storm 的 Nimbus。从 Client 处接收到 Job 和 JAR 包等资源后，会生成优化后的执行计划，并以 Task 的单元调度到各个 TaskManager 去执行。

**TaskManager** 在启动的时候就设置好了槽位数（Slot），每个 slot 能启动一个 Task，Task 为线程。从 JobManager 处接收需要部署的 Task，部署启动后，与自己的上游建立 Netty 连接，接收数据并处理。


### 3.1 TaskManager和Slots

### 3.2 程序和数据流(DataFlow)

### 3.3 执行图(ExecutionGraph)

### 3.4 并行度(Parallelism)

### 3.5 任务链(Operator Chains)


# 五、Flink流处理API

## 1.Environment
 * 创建一个执行环境，表示当前执行程序的上下文。
 使用`getExecutionEnvironment`如果程序是独立调用的，则此方法返回本地执行环境；如果从命令行客户端调用程序以提交到集群，则此方法返回此集群的执行环境，也就是说，getExecutionEnvironment会根据查询运行的方式决定返回什么样的运行环境，是最常用的一种创建执行环境的方式。

```scala
//根据查询运行的方式决定返回对应的运行环境
//如果没有设置并行度，会以flink-conf.yaml中的配置为准，默认是1
val env: ExecutionEnvironment = ExecutionEnvironment.getExecutionEnvironment

//返回一个本地执行环境，需要指定并行度
val env = StreamExecutionEnvironment.createLocalEnvironment(1)

//返回一个集群运行环境，指定远程IP、端口号和运行的jar包
val env = ExecutionEnvironment.createRemoteEnvironment("jobmanage-hostname", 6123,"YOURPATH//wordcount.jar")
```

## 2.Source

### 2.1 从集合读取数据
```scala

```

### 2.2 从文件读取数据
```scala

```


### 2.3 以kafka消息队列的数据作为来源

```scala

```

### 2.4 自定义source
```scala

```

## 3.Transform

## 4.UDF

## 5.sink
### 5.1 Kafka Sink
```xml
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-connector-kafka-0.11_2.11</artifactId>
    <version>1.7.2</version>
</dependency>
```
```scala
resultDataStream.addSink(new FlinkKafkaProducer011[String](
    "localhost:9092", 
    "test", 
    new SimpleStringSchema())
)
```

### 5.2 Redis Sink
```xml
<dependency>
    <groupId>org.apache.bahir</groupId>
    <artifactId>flink-connector-redis_2.11</artifactId>
    <version>1.0</version>
</dependency>
```
```scala
// 定义一个redis的mapper类，用于定义保存到redis时调用的命令
class MyRedisMapper extends RedisMapper[SensorReading]{
  override def getCommandDescription: RedisCommandDescription = {
    new RedisCommandDescription(RedisCommand.HSET, "sensor_temperature")
  }
  override def getValueFromData(t: SensorReading): String = t.temperature.toString

  override def getKeyFromData(t: SensorReading): String = t.id
}
```
```scala
val conf = new FlinkJedisPoolConfig.Builder().setHost("localhost").setPort(6379).build()
dataStream.addSink( new RedisSink[SensorReading](conf, new MyRedisMapper) )
```

### 5.3 ElasticSearch Sink
```xml
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-connector-elasticsearch6_2.11</artifactId>
    <version>1.7.2</version>
</dependency>
```
```scala
val httpHosts = new util.ArrayList[HttpHost]()
httpHosts.add(new HttpHost("localhost", 9200))

val esSinkBuilder = new ElasticsearchSink.Builder[SensorReading]( httpHosts, new ElasticsearchSinkFunction[SensorReading] {
  override def process(t: SensorReading, runtimeContext: RuntimeContext, requestIndexer: RequestIndexer): Unit = {
    println("saving data: " + t)
    val json = new util.HashMap[String, String]()
    json.put("data", t.toString)
    val indexRequest = Requests.indexRequest().index("sensor").`type`("readingData").source(json)
    requestIndexer.add(indexRequest)
    println("saved successfully")
  }
} )
dataStream.addSink( esSinkBuilder.build() )
```

### 5.4 JDBC自定义Sink
```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.44</version>
</dependency>
```
```scala
class MyJdbcSink() extends RichSinkFunction[SensorReading]{
  var conn: Connection = _
  var insertStmt: PreparedStatement = _
  var updateStmt: PreparedStatement = _

  // open 主要是创建连接
  override def open(parameters: Configuration): Unit = {
    super.open(parameters)

    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "123456")
    insertStmt = conn.prepareStatement("INSERT INTO temperatures (sensor, temp) VALUES (?, ?)")
    updateStmt = conn.prepareStatement("UPDATE temperatures SET temp = ? WHERE sensor = ?")
  }
  // 调用连接，执行sql
  override def invoke(value: SensorReading, context: SinkFunction.Context[_]): Unit = {
    
updateStmt.setDouble(1, value.temperature)
    updateStmt.setString(2, value.id)
    updateStmt.execute()

    if (updateStmt.getUpdateCount == 0) {
      insertStmt.setString(1, value.id)
      insertStmt.setDouble(2, value.temperature)
      insertStmt.execute()
    }
  }

  override def close(): Unit = {
    insertStmt.close()
    updateStmt.close()
    conn.close()
  }
}
```
```scala
dataStream.addSink(new MyJdbcSink())
```

# 六、Flink中的Window
streaming流式计算是一种被设计用于处理无限数据集的数据处理引擎，而无限数据集是指一种不断增长的本质上无限的数据集，而window是一种切割无限数据为有限块进行处理的手段。

## 1.TimeWindow
 * TimeWindow是将指定时间范围内的所有数据组成一个window，一次对一个window里面的所有数据进行计算

### 1.1 滚动窗口
 * 时间对齐，窗口长度固定，没有重叠
Flink默认的时间窗口根据Processing Time进行窗口的划分，将Flink获取到的数据根据进入Flink的时间按划分到不同的窗口中

```scala
val minTempPerWindow = dataStream
    .map(r => (r.id, r.temperature))
    .keyBy(_._1)
    .timeWindow(Time.seconds(15))
    .reduce((r1,r2) => (r1._1,r1._2.min(r2._2)))
```
时间间隔可以通过Time.milliseconds(x), Time.seconds(x), Time.minutes(x)等其中的一个来指定。

### 1.2 滑动窗口
 * 时间对齐，窗口长度固定，可以有重叠
滑动窗口和滚动窗口函数名一致，需要传入window_size和sliding_size
```scala
val minTempPerWindow: DataStream[(String, Double)] = dataStream
    .map(r => (r.id, r.temperature))
    .keyBy(_._1)
    .timeWindow(Time.seconds(15), Time.seconds(5))
    .reduce((r1,r2) => (r1._1,r1._2.min(r2._2)))
    .window(EventTimeSessionWindows.withGap(Time.minutes(10)))
```
每5s计算一次15s之内的所有元素
 * 时间间隔可以通过`Time.milliseconds(x)`, `Time.seconds(x)`, `Time.minutes(x)`来设置

## 2.CountWindow
 * CountWindow根据窗口中相同key元素的数量来触发执行，执行时值计算元素数量达到窗口大小的key对应的结果
 * CountWindow的window_size指的是相同key的元素的个数，不是输入的所有元素的总数

### 2.1 滚动窗口
默认的CountWindow是一个滚动窗口，只需要指定窗口大小，当元素数量达到窗口大小时，会触发窗口的执行
```scala
val minTempPerWindow: DataStream[(String, Double)] = dataStream
    .map(r => (r.id, r.temperature))
    .keyBy(_._1)
    .countWindow(5)
    .reduce((r1,r2) => (r1._1,r1._2.min(r2._2)))
```

### 2.2 滑动窗口
countWindow同时传入window_size和sliding_size
```scala
val keyedStream: KeyedStream[(String, Int), Tuple] = dataStream
    .map(r => (r.id, r.temperature))
    .keyBy(0)
//当某个key个数达到2时触发计算，计算该key最近10个元素的内容
val windowedStream: WindowedStream[(String,Int),Tuple,GlobleWindow] =
    keyedStream.countWindow(10, 2)
val sumDstream: DataStream[(String, Int)] = windowedStream.sum(1)
```

## 3.window function
window function 定义了要对窗口中收集的数据做的计算操作，主要可以分为两类：
**增量聚合函数**(incremental aggregation functions)
每条数据到来就进行计算，保持一个简单的状态。典型的增量聚合函数有ReduceFunction, AggregateFunction。
**全窗口函数**(full window functions)
先把窗口所有数据收集起来，等到计算的时候会遍历所有数据。ProcessWindowFunction就是一个全窗口函数。

## 4.其他可选API
|         API          | 作用                                               |
| :------------------: | :------------------------------------------------- |
|      trigger()       | 触发器，定义window什么时候关闭，触发计算并输出结果 |
|       evitor()       | 移除器，定义移除某些数据的逻辑                     |
|  allowedLateness()   | 允许处理迟到的数据                                 |
| sideOutputLateData() | 将迟到的数据放入侧输出流                           |
|   getSideOutPut()    | 获取输出流                                         |


# 七、时间语义和Watermark
## 1.Flink中的时间语义
<!-- TODO 配图 -->

**Event Time** 事件创建的时间，通常由时间中的事件戳描述，例如采集的日志数据中，每一条日志都会记录自己的生成时间，Flink通过时间戳分配器访问事件时间戳
**Ingestion Time** 是数据进入Flink的时间
**Processing Time** 是每一个执行基于时间操作的算子的本地系统时间，与机器相关，默认的时间属性就是Processing Time

## 2.Event Time的引入
在Flink的流式处理中，绝大部分的业务都会使用eventTime，一般只在eventTime无法使用时，才会被迫使用ProcessingTime或者IngestionTime
```scala
//引入EventTime时间属性
val env = StreamExecutionEnvironment.getExecutionEnvironment
//从调用时刻开始给env创建的每一个stream追加时间特征
env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime)
```

## 3.Watermark
### 3.1 基本概念

### 3.2 Watermark引入

## 4.EventTime在window中的使用

# 八、ProcessFunction API(底层API)
## 1. KeyedProcessFunction

## 2. TimerService和定时器(Timers)

## 3. 侧输出流(SideOutput)

## 4. CoProcessFunction



# 九、状态编程和容错机制
 * 由一个任务维护，并且用来计算某个结果的所有数据，都属于这个任务的转台
 * 可以认为转台就是一个本地变量，可以被任务的业务逻辑访问
 * 无状态计算观察每个独立事件
 * 有状态计算基于多个事件输出结果
下图展示了无状态流处理和有状态流处理的主要区别。无状态流处理分别接收每条数据记录(图中的黑条)，然后根据最新输入的数据生成输出数据(白条)。有状态流处理会维护状态(根据每条输入记录进行更新)，并基于最新输入的记录和当前的状态值生成输出记录(灰条)。
<!-- TODO 配图 -->
上图中输入数据由黑条表示。无状态流处理每次只转换一条输入记录，并且仅根据最新的输入记录输出结果(白条)。有状态 流处理维护所有已处理记录的状态值，并根据每条新输入的记录更新状态，因此输出记录(灰条)反映的是综合考虑多个事件之后的结果。

## 1.有状态的算子和应用程序
### 1.1 算子状态(operator state)
 * 算子状态的作用范围限定为算子任务
 * 同一并行任务所处理的所有数据都可以访问到相同的状态，状态对于同一任务而言是共享的
 * 算子状态不能由相同或不同算子的另一个任务访问

<!-- TODO 配图 -->

Flink为算子状态提供了三种基本数据结构
**列表状态List state**
将状态表示为一组数据的列表

**联合列表状态Union list state**
将状态表示为数据的列表，与常规列表状态的区别在于，在发生故障时，或者从保存点(savepoint)启动应用程序时如何恢复

**广播状态Broadcast state**
如果一个算子有多项任务，而他的每项任务状态又都相同，那么这种特殊情况最适合应用广播状态

### 1.2 键控状态(keyed state)
键控状态是根据输入数据流中定义的键(key)来维护和访问。Flink为每个键值维护一个状态实例，并将具有相同键的所有数据，都分区到同一个算子任务中，这个任务会维护和处理这个key对应的状态。当任务处理一条数据时，它会自动将状态的访问范围限定为当前数据的key。因此，具有相同key的所有数据都会访问相同的状态。Keyed State很类似于一个分布式的key-value map数据结构，只能用于KeyedStream（keyBy算子处理之后）。

Flink中Keyed State支持一下数据类型(结构)
**值状态Value State**
将状态表示为单个的值

**列表状态List state**
将状态表示为一组数据的列表

**映射状态Map state**
将状态表示为一组Key-Value对

**聚合状态Reducing state & Aggregating state**
将状态表示为一个用于聚合操作的列表

### 1.3 状态后端State Backends
 * 每传入一条数据，有状态的算子任务都会读取和更新状态
 * 由于有效的状态访问对于处理数据的低延迟至关重要，因此每个并行任务都会在本地维护其状态，以确保快速的状态访问
 * 状态的存储、访问以及维护，有一个可插入的组建决定，这个组建叫做**状态后端**
 * 状态后端主要负责:本地的状态管理，以及将检查点checkpoint状态吸入远程存储

状态后端有以下几种:
**MemoryStateBacked**
内存级的状态后端，会将键控状态桌位内存中的对象就行管理，将他们存储在TaskManager的JVM堆，而将checkpoint存储在JobManager的内存中
快速、低延迟、不稳定

**FsStateBackend**
将checkpoint存到远程的持久化文件系统上，而对于本地状态，更MemoryStateBackend一样，也会存在TaskManager的JVM堆上
同时拥有内存级的本地访问速度，和更好的容错保证

**RocksDBStateBackend**
将所有状态序列化后，存入本地的RocksDB中存储

>**代码实现**

RocksDB的支持并不直接包含在flink中，需要引入依赖
```xml
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-statebackend-rocksdb_2.11</artifactId>
    <version>1.7.2</version>
</dependency>
```
```scala
val env = StreamExecutionEnvironment.getExecutionEnvironment
val checkpointPath: String = ???
val backend = new RocksDBStateBackend(checkpointPath)
env.setStateBackend(backend)
env.setStateBackend(new FsStateBackend("file:///tmp/checkpoints"))
env.enableCheckpointing(1000)
// 配置重启策略
env.setRestartStrategy(RestartStrategies.fixedDelayRestart(60, Time.of(10, TimeUnit.SECONDS)))
```



## 2.状态一致性
 * 状态一致性，就是计算结果正确性的另一种说法，即发生故障并恢复后得到的计算结果和没有发生故障相比的正确性。

### 2.1 状态一致性分类
**at-most-once最多一次**
当任务故障时，最简单的做法就是什么都不做，既不恢复丢失的状态，也不重播丢失的数据，at-most-once语义的含义是最多处理一次事件

**at-least-once至少一次**
在大多数的真实应用场景，我们不希望数据丢失id，即所有的事件都得到了处理，而一些事件还可能被处理多次

**exactly-once精确一次**
恰好处理一次是最严格的保证，也是最难实现的，精准处理一次语义不仅仅意味着没有时间丢失，还意味着针对每一个数据，内部状态仅仅更新一次

 * Flink既能保证exactly-once，也具有低延迟和高吞吐的处理能力。

### 2.2 端到端(end-to-end)状态一致性
实际应用时，不只是要求流处理器阶段的状态一致性，还要求source到sink阶段(从数据源到输出到持久化系统)的状态一致性

 * 内部保证 -- 依赖checkpoint
 * source端 -- 需要外部源可以重设数据的读取位置
 * sink端 -- 需要保证从故障恢复时，数据不会重复写入外部系统

### 2.3  sink端实现方式
对于sink端有两种实现方式，幂等(Idempotent)写入和事务性(Transactional)写入
**幂等写入**
所谓幂等操作，是说一个操作，可以重复执行很多次，但是只导致一次结果更改，也就是说后面再重复执行就不起作用了

**事务写入**
需要构建事务来写入外部系统，构建的事务对应着checkpoint，等到checkpoint真正完成的时候，才把所有对应的结果写入sink系统中


### 2.4 事务性写入的实现方式
 * 对于事务性写入，具体又有两种实现方式：预写日志（WAL）和两阶段提交（2PC）。
 * DataStream API 提供了GenericWriteAheadSink模板类和TwoPhaseCommitSinkFunction 接口，可以方便地实现这两种方式的事务性写入。

**预写日志**(Writ-Ahead-Log, WAL)
 * 把结果数据先当成状态保存，然后在收到checkpoint完成的通知时，一次性写入sink系统
 * 简单易于实现，由于数据提前在状态后端中做了缓存，所以无论什么sink系统，都能用这种方式一批搞定
 * DataStream API提供了一个模版类: GenericWriteAheadSink，来实现这种事务性sink

**两阶段提交**(Two-Phase-Commit, 2PC)
 * 对于每个checkpoint，sink任务会启动一个事务，并将接下来所有接受的数据添加到事务里
 * 然后将这些数据写入外部sink系统，但不真正提交他们 -- 这是预提交
 * 当它收到checkpoint完成的通知时，它才正式提交事务，实现结果的真正写入
 * 这种方式真正实现了exactly-once，它需要一个提供事务支持的外部sink系统，Flink提供了TwoPhaseCommitSinkFunction接口


### 2.5 2PC对外部sink系统的要求
 * 外部sink系统必须提供事务支持，或者sink任务必须能够模拟外部系统上的事务
 * 在checkpoint的间隔期间里，必须能够开启一个事务并接受数据写入
 * 在收到checkpoint完成的通知之前，事务必须是"等待提交"的状态，在故障恢复的情况下，这可能需要一些时间，如果这个时候sink系统关闭事务(例如超时了)，那么未提交的数据就会丢失
 * sink任务必须能够在进程失败后恢复事务
 * 提交事务必须是幂等操作

| sink↓ \ source→ |    不重置    |                    可重置                    |
| :-------------: | :----------: | :------------------------------------------: |
|    任意(Any)    | At-most-once |                At-least-once                 |
|      幂等       | At-most-once | Exactly-once<br>(故障回复时会出现暂时不一致) |
|  预写日志(WAL)  | At-most-once |                At-least-once                 |
| 两阶段提交(2PC) | At-most-once |                 Exactly-once                 |

### 2.6 Flink+Kafka端到端状态一致性的保证
 * 内部 -- 利用checkpoint机制，把状态存盘，发生故障的时候可以恢复，保证内部的状态一致性
 * source -- kafka consumer作为source，可以将偏移量保存下来，如果后续任务出现了故障，恢复的时候可以由连接器重置偏移量，重新消费数据，保证一致性
 * sink -- kafka producer作为sink，才哟过两阶段提交sink，需要实现一个`TwoPhaseCommitSinkFunction`

### 2.7 Exactly-once两阶段提交步骤
 * 第一条数据来了之后，开启一个kafka的事务(transaction)，正常写入kafka分区日志但标记为未提交，这就是预提交
 * jobmanager触发checkpoint操作，barrier从source开始向下传递，遇到barrier的算子将状态存入状态后端，并通知jobmanager
 * sink连接器收到barrier，保存当前状态，存入checkpoint，通知jobmanager，并开启下一阶段的事务，用于提价下个检查点的数据
 * jobmanager收到所有任务的通知，发生确认信息，表示checkpoint完成
 * sink任务收到jobmanager的确认信息，正式提交这段时间的数据
 * 外部kafka关闭事务，提交的数据可以正常消费了

```scala
val env: StreamExecutionEnvironment = StreamExecutionEnvironment.getExecutionEnvironment
env.setParallelism(1)
env.enableCheckpointing(60000L) //打开检查点支持

val properties: Properties = new Properties()
properties.setProperty("bootstrap.servers", "localhost:9092")
properties.setProperty("group.id", "consumer-group")
properties.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer")
properties.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer")
properties.setProperty("auto.offset.reset", "latest")
val inputStream: DataStream[String] =
    env.addSource(new FlinkKafkaConsumer011[String]("sensor", new SimpleStringSchema(), properties))
val dataStream: DataStream[String] = inputStream
    .map(data => {
        val dataArr: Array[String] = data.split(",")
        SensorReading(dataArr(0).trim, dataArr(1).trim.toLong, dataArr(2).trim.toDouble).toString
    })
dataStream.addSink(new FlinkKafkaProducer011[String](
    "exactly-once test",
    new KeyedSerializationSchemaWrapper(new SimpleStringSchema()),
    properties,
    Semantic.EXACTLY_ONCE //默认状态一致性为AT_LEAST_ONCE
))
dataStream.print()
env.execute("exactly-once test")
/*
kafka consumer 配置isolation.level 改为read_committed，默认为read_uncommitted，
否则未提交(包括预提交)的消息会被消费走，同样无法实现状态一致性
*/
```

## 3.检查点

>**代码开启检查点并配置**

```scala
env.enableCheckpointing(60000L)
env.getCheckpointConfig.setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE)
env.getCheckpointConfig.setCheckpointTimeout(90000L)
env.getCheckpointConfig.setMaxConcurrentCheckpoints(2)
env.getCheckpointConfig.setMinPauseBetweenCheckpoints(10000L)
env.getCheckpointConfig.setFailOnCheckpointingErrors(false)
env.getCheckpointConfig.enableExternalizedCheckpoints(ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION)
```



# 十、Table API与SQL


# Flink CEP简介
