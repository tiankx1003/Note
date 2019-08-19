# 1.Hadoop

## 1.1 Hadoop优势

**高可靠性**数据多副本
**高扩展性**集群间分配任务数据，方便扩展上千节点
**高效性**MapReduce思想下，Hadoop并行工作，
**高容错性**失败任务重新分配

## 1.2 Hadoop组成

>**Hadoop1.x**
MapReduce(计算+资源调度)
HDFS(数据存储)
Common(辅助工具)

>**Hadoop2.x**
MapReduce(计算)
Yarn(资源调度)
HDFS(数据存储)
Common(辅助工具)

1. **HDFS架构**
Hadoop Distributed File System
>**NameNode**
存储文件的**元数据**，如文件名，文件目录结构，文件属性(生成时间，副本书，文件权限)，以及每个文件的块列表和块的所在DataNode

>**DataNode**
在本地文件系统存储文件块数据，以及块数据和校验和

>**SecondaryNameNode**
用来监控HDFS状态的辅助后台程序，每隔一段时间获取HDFS原数据和快照

2. **Yarn架构描述**
>**ResourceManager**
处理客户端请求
监控NodeManager
启动或监控ApplicationMaster
资源的分配与调度

>**NodeManager**
管理单个节点上的资源
处理来自ResourceManager的命令
处理来自ApplicationMaster的命令

3. **MapReduce**
>**Map**
并行处理输入数据

>**Reduce**
对Map结果进行汇总

## 1.3 Hadoop生态体系
>**ZooKeeper**
针对大型分布式系统的可靠协调系统

>**Sqoop**
用于Hadoop、Hive与传统的数据库间进行数据传递，可以完成关系型数据库和HDFS之间数据的导入与导出

>**Flume**
高可用、高可靠、分布式的海量日志采集、聚合和传输的系统，Flume支持在日志系统中定制各类数据发送方，用于收集数据，同时Flume也能对数据进行简单处理，并写到该种定制的数据接收放

>**HBase**
分布式、面向列的开源数据库，适合与非结构化的数据存储

>**Hive**
基于Hadoop的数据仓库工具，可以讲结构化的数据文件映射成一张数据库表，并提供简单的SQL查询功能，可以讲SQL语句转换成MapReduce任务进行，

>**Oozie**
工作流管理调度系统

>**Azkaban**
工作流管理调度系统，具有更友好的web端交互界面用于监控与管理

>**Spark**
Spark是当前最流行的开源大数据内存计算框架。可以基于Hadoop上存储的大数据进行计算

>**Storm**
Storm用于“连续计算”，对数据流做连续查询，在计算时就将结果以流的形式输出给用户

>**R语言**
R是用于统计分析、绘图的语言和操作环境。R是属于GNU系统的一个自由、免费、源代码开放的软件，它是一个用于统计计算和统计制图的优秀工具

>**Mahout**
Apache Mahout是个可扩展的机器学习和数据挖掘库

## 1.4 推荐系统框架

# 2.HDFS

## 2.1 定义
Hadoop Distributed File System，是一个用于存储文件的文件系统
通过目录树来定位文件
是分布式的，由多个服务器联合实现功能，集群的服务器有各自的角色
适用于一次写入，多次读出的场景，不支持文件的修改

## 2.2 优缺点

>**优点**
高容错性
适合处理大数据
可够健在廉价机器上

>**缺点**
不适合低延时数据访问
无法高效的对大量小文件进行存储
不支持并发写入和文件随机修改

## 2.3 组成架构

### 2.3.1 NameNode
master
管理HDFS的名称空间
配置副本策略
管理数据块映射信息
处理客户端读写请求

### 2.3.2 DataNode
slave
执行NameNode下达的命令
存储实际的数据块
执行数据块的读写操作

### 2.3.3 SecondaryNameNode
不是NameNode的热备
当NameNode宕机后不能立即完成顶替
不住NameNode分担工作量，如定期合并Fsimage和Edits并推送给NameNode
紧急情况下可辅助回复NameNode

## 2.4 HDFS文件块大小
HDFS中文件分块(Block)存储，块的大小能够通过参数`dfs.blocksize`来规定
Hadoop2.x默认为128M,老版本为64M
>**文件块不能设置太小，也不能设置太大**
太小会增加寻址时间
太大会导致处理该数据块时间明显大于别的数据块
HDFS块的大小设置取决于**磁盘传输速率**

## 2.5 HDFS的Shell和Client操作

### 2.5.1 常用Shell命令
[^_^]:#(TODO 添加Shell命令)

### 2.5.2 常用API

[//]: # (TODO 添加常用API)


## 2.6 HDFS数据流

### 2.6.1 写流程

<!-- TODO 添加写流程 -->


网络拓扑--节点距离计算

机架感知



### 2.6.2 读流程

<!-- TODO 添加读流程 -->

## 2.7 NameNode & SecondaryNameNode

### 2.7.1 工作机制

### 2.7.2 Fsimage & Edits

### 2.7.3 CheckPoint

### 2.7.4 NameNode故障处理

### 2.7.5 集群安全模式

### 2.7.6 NameNode多目录


## 2.8 DataNode

# 3.MapReduce

## 3.1 概述

**MapReduce**是一个分布式运算程序的编程框架，使用户基于Hadoop数据分析应用的核心框架

### 3.1.1 优点
**易于编程**，简单的实现一些接口，就可以完成一个分布式程序
**良好的扩展性**，可以在计算资源不足时通过简单的增加及其扩展计算能力
**高容错**，一个节点宕机，可以把计算任务转移到另一个节点上运行
**适合海量数据的离线处理**，并发工作

### 3.1.2 缺点
**不擅长实时计算**
**不擅长流式计算**
**不是擅长DAG(有向图)计算**

### 3.1.3 核心思想
MapReduce编程模型只能包含一个Map阶段和一个Reduce阶段，如果业务逻辑复杂，只能多个MapReduce程序，串行运行。

### 3.1.4 进程
完成的MapReduce程序在分布式运行时有三类实例进程
**MrAppMaster**负责整个程序的过程调度和状态协调
**Map Task**负责Map阶段的整个数据处理流程
**Reduce Task**负责Reduce阶段的整个数据流程处理

### 3.1.5 WordCount源码

### 3.1.6 常用数据序列化类型
**Java类型**    **Hadoop Writable类型**
Boolean         BooleanWritable
Byte            ByteWritable
int             IntWritable
...             ...

### 3.1.7 编程规范

## 3.2 Hadoop序列化

### 3.3.1 概念

**序列化**就是把内存中的对象转换成字节序列(或其他数据传输协议)以便于存储到磁盘(持久化)和网络传输
**反序列化**就是将收到的字节序列(或其他数据传输协议)或者是磁盘的持久化数据，转换成内存中的对象

### 3.3.2 实现

自定义bean对象实现序列话接口(Writable)




