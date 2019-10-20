
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

### 2.2 从文件读取数据

### 2.3 以kafka消息队列的数据作为来源

### 2.4 自定义source
```scala


## 3.Transform

## 4.Sink


# 六、Flink中的Window

## 1.
