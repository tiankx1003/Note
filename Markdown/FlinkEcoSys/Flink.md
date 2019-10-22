
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

## 4.Sink


# 六、Flink中的Window

## 1.TimeWindow
 * TimeWindow是将指定时间范围内的所有数据组成一个window，一次对一个window里面的所有数据进行计算

### 1.1 滚动窗口
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

## 4.其他可选API



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
//从调用时刻开始给env创建额每一个stream追加时间特征
env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime)
```

## 3.Watermark
### 3.1 基本概念

### 3.2 Watermark引入

### 3.3 EventTime在window中的使用

# 八、ProcessFunction API(底层API)


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

#### 状态后端State Backends
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

## 2.状态一致性
当在分布式系统中引入状态时，自然也引入了一致性问题。一致性实际上是"正确性级别"的另一种说法，也就是说在成功处理故障并恢复之后得到的结果，与没有发生任何故障时得到的结果相比，前者到底有多正确。

### 2.1 一致性级别
**at-most-once** 这其实是没有正确性保障的委婉说法--故障发生后，计数结果可能丢失，童谣的还有个udp
**at-least-once** 这表示计数结果可能大于正确值，当绝对不会小于正确值。也就是说，计数程序在发生故障后可能多算，但绝不会少算
**exactly-once** 系统保证在发色和功能故障后得到的计数结果与正确值一致



### 2.2 端到端(end-to-end)状态一致性




# 十、Table API与SQL


# Flink CEP简介
