# 一、Spark内核概述
## 1.Spark核心组件
### 1.1 Driver
 * Spark驱动器节点，用于执行Spark任务中的main方法，负责实际代码的执行工作

Driver在Spark作业执行时主要负责
1. 将用户程序转化为作业(Job)
2. 在Executor之间调度任务(Task)
3. 跟踪Executor的执行情况
4. 通过UI展示查询运行情况

### 1.2 Executor
 * Spark Executor节点是负责在Spark作业中运行具体任务，任务彼此之间相互独立
 * Spark应用启动时，Executor节点被同时启动，并且始终伴随着整个Spark应用的生命周期而存在
 * 如果有Executor节点发生了故障或崩溃，Spark应用也可以继续执行，会将出错节点的任务调度到其他Executor节点继续运行

Executor有两个核心功能
1. 负责运行组成Spark应用的任务，并将结果返回给驱动器(Driver))
2. 他们通过自身功能的块管理器(Block Manager)为用户程序中要求缓存的RDD提供内存式存储，RDD是直接缓存在Executor进程内的，因此任务可以在运行时充分利用缓存，数据加速运算

## 2.Spark通用运行流程

<!-- TODO spark-run-process.png -->

不论Spark以何种模式进行部署，都是以如下核心步骤进行工作
1. 任务提交后，都会先启动Driver程序
2. 随后Driver向集群管理器注册应用程序
3. 之后集群管理器根据次此任务的配置文件分配到Executor并启动
4. 当Driver所需的资源全部满足后，Driver开始执行main函数，Spark查询为懒执行，当执行到Action算子时开始反向推算，根据宽依赖进行Stage的划分，随后每一个Stage对应一个Taskset，Taskset中有多个Task
5. 根据本地化原则，Task会被分发到指定的Executor去执行，在任务执行的过程中，Executor也会不断与Driver进行通信，拔高任务进行情况


 * Hadoop的调度都是进程级别的
 * Spark的调度是线程级别的，所以效率比较高

# 二、Spark通讯架构

*信息封装为样例类*
*Spark中的各个组件(Client/Master/Worker)都是EndPoint*

## 1.Spark通讯架构概述

>**Spark通信框架的发展**
Spark早期版本中采用Akka作为内部通信部件
Spark1.3中引入Netty通信框架，为了解决Shuffle的大数据问题使用
Spark1.6中Akka和Netty可以配置使用。Netty完全实现了Akka在Spark中的功能
Spark2系列中，Spark抛弃Akka，使用Netty

Spark2.x版本使用Netty通讯框架作为内部通讯部件，Spark基于Netty新的RPC框架借鉴了Akka中的设计，它是基于Actor模型

<!-- spark-actor-system.png -->

Spark通讯框架中各个组件(Client/Master/Worker)可以认为是一个个独立的实体，各个实体之间通过消息来进行通信。

<!-- spark-manage-system.png -->

Endpoint(Client/Master/Worker)有1个InBox和N个OutBox(N>=1，N取决于当前Endpoint与多少其他的Endpoint进行通信，一个与其通讯的其他Endpoint对应一个OutBox)，Endpoint接收到的消息写入到InBox，发送出去的消息写入OutBox并被发送到其他Endpoint的InBox中。


## 2.Spark通讯架构解析

<!-- spark-communication-ache.png -->

>**RpcEndpoint** RPC端点
RPC(Remote Process Call远程过程调用)，Spark针对每个节点(Client/Master/Worker)都称之为一个Rpc端点，且都实现RpcEndpoint接口，内部根据不同端点的需求，设计不同的消息和不同的业务处理，如果需要发送(询问)则调用Dispatcher

>**RpcEnv** RPC上下文环境
每个RPC端点运行时依赖的上下文环境成为RpcEnv

>**Dispatcher** 消息分发器
消息分发器负责将RPC端点需要发送的消息或者从远程RPC接收的消息分发至对应的指令收件箱或发件箱。如果指令接收方是自己则存入收件箱，如果指令接收方不是自己，则放入发件箱。

>**Inbox** 指令消息收件箱
一个本地RpcEndpoint对应一个收件箱，Dispatcher在每次向Inbox存入消息时，都将对应EndpointData加入内部ReceiverQueue中，另外Dispatcher创建时会启动一个单独线程轮询ReceiverQueue，进行收件箱消息消费

>**RpcEndpointRef**
RpcEndpointRef是对远程RpcEndpoint的一个引用，当我们需要向一个具体的RpcEndpoint发送消息时，一般我们需要获取到该RpcEndpoint的引用，然后通过该引用发送消息

>**OutBox** 指令消息收件箱
对于当前RpcEndpoint来说，一个目标RpcEndpoint对应一个收件箱，如果向多个目标RpcEndpoint发送消息，则有多个OutBox，当消息放入OutBox后，紧接着通过TransportClient将消息发送出去。消息放入发件箱以及发送过程是在同一个线程中进行

>**RpcAddress**
表示远程的RpcEndpointRef的地址，Host + Port

>**TransportClient**
Netty通信服务端，一个RpcEndpoint对应一个TransportServer，接收远程消息后调用Dispatcher分发消息至对应收发件箱

<!-- spark-transport-view.png -->

## 3.Spark集群启动
<!-- spark-cluster-startup.png -->
<!-- Master & Worker src -->

1. start-all.sh,执行`java -cp Master`和`java -cp Worker`
2. Master启动时首先创建要给RpcEnv对象，负责管理所有通讯逻辑
3. Master通过RpcEnv对应创建一个Endpoint，Master就是一个Endpoint，Worker可以与其进行通信
4. Worker启动时也创建一个RpcEnv对象
5. Worker通过RpcEnv对象创建一个Endpoint
6. WorkerRpcEnv对象建立到Master的连接，获取到一个RpcEndpointRef对象，通过对象可以与Master通信
7. Worker向Master注册，注册内容包括主机名、端口、CPU Core数量、内存数量
8. Master接收到Worker的注册，将注册信息维护在内存中的Table中，其中还包括一个到Worker的RpcEndpointRef对象引用
9. Master回复Worker已经收到注册，告知Worker已经注册成功
10. Worker端收到成功注册响应后，开始周期性向Master发送心跳

### 3.1 Master
<!-- src -->

### 3.2 Worker
<!-- src -->

# 三、Spark部署模式
Spark支持3种Cluster Manager，分别为
1. Standalone独立模式，Spark原生的简单集群管理器，自带完整的服务，可单独部署到一个集群中，无需依赖任何其他资源管理系统，使用Standalone可以方便地搭建一个集群
2. Hadoop Yarn，统一的资源管理机制，在上面可以运行多套计算框架，如MR，Storm，根据Driver在集群中的位置不同，分为Yarn Client和Yarn Cluster
3. Apache Mesos，一个强大的分布式资源管理框架，允许多种不同的框架部署在其上，包括Yarn
   
实际上，除了上述这些通用的集群管理器外，Spark内部也提供了方便用户测试和学习的集群部署模式，但是在实际生产环境中应用最广泛的还是Hadoop Yarn模式。

## 1.Yarn模式运行机制

### 1.1 Yarn Cluster模式
<!-- spark-yarn-cluster.png -->
<!-- src -->
![](img/spark-yarn-cluster.png)
1. 执行脚本提交任务，实际是启动一个SparkSubmit的JVM进程
2. SparkSubmit类中的main方法反射调用Client的main方法
3. Client创建Yarn客户端，然后Yarn发送执行指令`bin/java ApplicationMaster`
4. Yarn框架收到指令后会在指定的NM中启动ApplicationMaster
5. ApplicationMaster启动Driver线程，执行用户的作业
6. AM向RM注册，申请资源
7. 获取资源后AM向NM发送指令，`bin/java CoarseGrainedExecutorBackend`
8. ExecutorBackend进程会接受消息，启动计算对象Executor并跟Driver通信，注册已经启动的Executor
9. Driver分配任务并监控任务的执行

 * *SparkSubmit、ApplicationMaster和CoarseGrainedExecutorBacken是独立的进程，Client和Driver是独立的线程，Executor是一个对象*

### 1.2 Yarn Client模式
<!-- spark-yarn-client.png -->
<!-- src -->

1. 执行脚本提交任务，实际是启动一个SparkSubmit的JVM进程
2. SparkSubmit类中的main方法反射调用用户代码的main方法
3. 启动Driver进程，执行用户的作业，并创建ScheculeBackend
4. YarnClientScheduleBackend向RM发送指令，`bin/java ExecutorLauncher`
5. Yarn框架收到指令后会在指定的NM中启动ExecutorLauncher(实际还是调用ApplicationMaster的main方法，是为了用户在使用jps命令时能欧明确所执行的是哪个进程)
```scala
object ExecutorLauncher {
    def main (args: Array[String]): Unit = {
        ApplicationMaster.main(args)
    }
}
```
6. AM向RM注册，申请资源
7. 获取资源后AM向NM发送指令，`bin/java CoarseGrainedExecutorBacked`
8. ExecutorBackend进程会接收消息，启动计算对象Executor并跟Driver通信，注册已经启动的Executor
9. Driver分配任务并监控任务的执行

 * SparkSubmit、ExecutorLauncher和CoarseGrainedExecutorBackend是独立的进程，Client和Driver是独立的线程，Executor是一个对象

## 2.Standalone模式运行机制

Standalone集群有连个重要组成部分，分别是
1. Master(RM)，是一个进程，祖尧负责资源的调度和分配，并进行集群的监控等职责
2. Worker(NM)，是一个进程，一个Worker运行在集群中的一台服务器上，主要有两个职责，一个是用自己的内存存储RDD的某个或某些partition，另一个是启动其他进程和线程(Executor)，对RDD上的partition进行并行的处理和计算

### 2.1 Standalone Cluster模式
<!-- spark-standalone-cluster.png -->

在Standalone Cluster模式下，任务提交后，**Master会找到一个Worker启动Driver**，Driver启动后向Master注册应用程序，Master根据submit脚本的资源需求找到内部资源至少可以启动一个Executor的所有Worker，然后在这些Worker之间分配Executor，Worker上的Executor启动后会向Driver反向注册，所有的Executor注册完成后，Driver开始执行main函数，之后执行到Action算子时，开始划分Stage，每个Stage生成对应的taskSet，之后将Task分发到各个Executor上执行

### 2.2 Standalone Client模式
<!-- spark-standalone-client.png -->

在Standalone Client模式下，**Driver在任务提交的本地机器上运行**，Driver启动后向Master注册应用程序，Master根据submit脚本的资源需求找到内部资源至少可以启动的Executor的所有Worker，然后这些Worker之间分配Executor，Worker上的Executor启动后会向Driver反向注册，所有的Executor注册完成后，Driver开始执行main函数，之后执行到Action算子时，开始划分Stage，每个Stage生成对应的TaskSet，之后将Task分发到各个Executor上执行。


# 四、Spark任务调度机制

Driver的工作流程主要是初始化SparkContext对象，准备运行所需的上下文，然后一方面保持与ApplicationMaster的RPC连接，通过ApplicationMaster申请资源，另一方面根据用户业务逻辑开始调度任务，将任务下发到已有的空闲Executor上
当ResourceManager向ApplicationMaster返回Container资源时，ApplicationMaster就尝试在对应的Container上启动进程，Executor进程起来后，会向Driver反向注册，注册成功后保持与Driver的心跳，同时等待Driver分发任务，当分发的任务执行完毕后，将任务状态上报给Driver。

## 1.Spark任务调度概述

当Driver启动后，Driver则会根据用户程序逻辑准备任务，并根据Executor资源情况逐步分发任务。
Spark任务调度的相关**概念**
**Job**是以Action方法为界，遇到一个Action方法则触发一个Job
**Stage**是Job的子集，以RDD宽依赖(即Shuffle)为界，遇到Shuffle做一次划分
**Task**是Stage的子集，以并行度(分区数)来衡量，分区数是多少，则有多少个task

Spark任务调度总体来说分两路进行，一路是Stage级的调度，一路是Task级的调度，总体调度流程如下所示

<!-- spark-job-schedule.png -->

SparkRDD通过其Transaction操作，形成了RDD血缘关系图，级DAG，最后通过Action调用，触发Job并调度执行，DAGSchedule负责Stage级的调度，主要将job切分成若干Stages，并将每个Stage打包成TaskSet交给TaskSchedule调度。TaskSchedule负责Task级的调度，将DAGSchedule给过来的TaskSet按照指定的调度策略分发到Executor上执行，调度过程中SchedulerBackend负责提供可用资源，其中ScheduleBackend有多种实现，分别对接不同的资源管理系统。

<!-- spark-job-commit-task-split.png -->

Driver初始化SparkContext过程中，会分别初始化DAGSchedule、TaskScheduler、SchedulerBackend以及HeartbeatReceiver，并启动SchedulerBackend以及HeartbeatReceiver。SchedulerBackend通过ApplicationMaster申请资源，并不断从TaskSchedule中拿到合适的Task分发到Executor执行，HeartbeatReceiver负责接收Executor的心跳消息，监控Executor的存活状况，并通知到TaskScheduler

## 2.Spark Stage级调度

Spark的任务调度是从DAG切割开始，主要是由DAGScheduler来完成，当遇到一个Action操作后就会触发一个Job的计算，并交给DAGScheduler来提交

<!-- spark-job-commit-ref-stack.png -->

1. Job由最最终的RDD和Action方法封装而成
2. SparkContext将job交给Stages，具体划分策略是，由最终的RDD不断通过依赖回溯判断父依赖是否是宽依赖，即以shuffle为界，划分Stage，窄依赖的RDD之间被划分到同一个Stage中，可以进行pipeline式的计算，划分的Stage有两类，一类叫做ResultStage，为DAG最下游的Stage，由Action方法决定，另一类叫做ShuffleMapStage，为下游Stage准备数据，下面看一个简单的例子WordCount

<!-- spark-stage-wordcount.png -->

Job由saveTextFile触发，该Job由RDD-3和saveAsTextFile方法组成，根据RDD之间的依赖关系从RDD-3开始回溯搜索，直到没有依赖的RDD-0，在回溯搜索过程中，RDD-3依赖RDD-2，并且是宽依赖，所以在RDD-2和RDD-3之间划分Stage，RDD-3被划到最后一个Stage，即ResultStage中，RDD-2依赖RDD-1，RDD-1依赖RDD-0，这些依赖都是摘以来，所以将RDD-0、RDD-1和RDD-2划分到同一个Stage，即ShuffleMapStage中，实际执行的时候，数据会一气呵成地执行RDD-0到RDD-2的转化，其本质是一个深度优先搜索算法。
一个Stage是否被提交，需要判断他的父Stage是否执行，只有在父Stage执行完毕才能提交当前Stage，如果一个Stage没有父Stage，那么该Stage开始提交，Stage提交时会将Task信息(分区信息以及方法等)序列化并打包成TaskSet交给TaskScheduler，一个Partition对应一个Task，另一方面TaskScheduler会监控Stage的运行状态，只有Executor丢失或者Task由于Fetch失败才需要冲洗提交失败的Stage以调度运行失败的任务，其他类型的Task失败会在TaskScheduler的调度过程中重试
相对来说，DAGScheduler做的事情比较简单，仅仅是在Stage层面划分DAG，提交Stage并监控相关状态信息，TaskScheduler则相对较为复杂。

## 3.Spark Task级调度

### 3.1 调度策略


### 3.2 本地化调度


### 3.2 失败重试与黑名单机制



# 五、Spark Shuffle解析
## 1.Shuffle的核心要点

### ShuffleMapStage与ResultStage


## 2.HashShuffle解析

### 2.1 未优化的HashShuffle

### 2.2 优化后的HashShuffle


## 3.SortShuffle解析

### 3.1 普通SortShuffle

### 3.2 bypass SortShuffle




