# 一、Spark内核概述
## 1.Spark核心组件
### 1.1 Driver
 * Spark驱动器节点，用于执行Spark任务中的main方法，负责实际代码的执行工作

Driver在Spark作业执行时主要负责
1. 将用户程序转化为作业(Job)
2. 在Executor之间调度任务(Task)
3. 跟踪Executor的执行情况
4. 通过UI展示查询运行情况

### 2.Executor
 * Spark Executor节点是负责在Spark作业中运行具体任务，任务彼此之间相互独立
 * Spark应用启动时，Executor节点被同时启动，并且始终伴随着整个Spark应用的生命周期而存在
 * 如果有Executor节点发生了故障或崩溃，Spark应用也可以继续执行，会将出错节点的任务调度到其他Executor节点继续运行

Executor有两个核心功能
1. 负责运行组成Spark应用的任务，并将结果返回给驱动器(Driver))
2. 他们通过自身功能的块管理器(Block Manager)为用户程序中要求缓存的RDD提供内存式存储，RDD是直接缓存在Executor进程内的，因此任务可以在运行时充分利用缓存，数据加速运算

## 2.Spark通用运行流程

<!-- TODO 配图 -->

不论Spark以何种模式进行部署，都是以如下核心步骤进行工作
1. 任务提交后，都会先启动Driver程序
2. 随后Driver向集群管理器注册应用程序
3. 之后集群管理器根据次此任务的配置文件分配到Executor并启动
4. 当Driver所需的资源全部满足后，Driver开始执行main函数，Spark查询为懒执行，当执行到Action算子时开始反向推算，根据宽依赖进行Stage的划分，随后每一个Stage对应一个Taskset，Taskset中有多个Task
5. 根据本地化原则，Task会被分发到指定的Executor去执行，在任务执行的过程中，Executor也会不断与Driver进行通信，拔高任务进行情况


# 二、Spark通讯架构

Hadoop的调度都是进程级别的
Spark的调度是线程级别的，所以效率比较高
Akka是进程间用于通讯的组件(Spark 0.x和Spark 1.x中使用，Spark 2.0后被移除)
Netty框架在Spark 1.3引入

Akka的Actor模型
Actor是节点间的通讯角色
Actor使用Mailbox(队列)进行通信
信息封装为样例类

Netty
Spark中的各个组件(Client/Master/Worker)都是EndPoint
每个EndPoint通过OutBox和InBox完成信息的收发
每个EndPoint有一个InBox和多个OutBox
TransportClient和TransportServer之间通许，底层仍旧是socket通信
Worker发送给Master的注册请求RegisterWorker是一个样例类
## 1.Spark通讯架构概述

## 2.Spark通讯架构解析


## 3.Spark集群启动

### 3.1 Master


### 3.2 Worker



<!-- TODO Spark部署模式 Yarn Cluster模式 手绘 -->

# 三、Spark部署模式

## 1.Yarn模式运行机制

### 1.1 Yarn Cluster模式


### 1.2 Yarn Client模式



## 2.Standalone模式运行机制


# 四、Spark任务调度机制