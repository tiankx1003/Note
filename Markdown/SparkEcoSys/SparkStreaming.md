实时流处理
微批处理
固定时间间隔的数据计算
秒级

# 一、概述
## 1.概念
Spark Streaming 是 Spark 核心 API 的扩展, 用于构建弹性, 高吞吐量, 容错的在线数据流的流式处理程序. 总之一句话: Spark Streaming 用于流式数据的处理
数据可以来源于多种数据源: Kafka, Flume, Kinesis, 或者 TCP 套接字. 接收到的数据可以使用 Spark 的负责元语来处理, 尤其是那些高阶函数像: map, reduce, join, 和window.
最终, 被处理的数据可以发布到 FS, 数据库或者在线dashboards.
另外Spark Streaming也能和MLlib（机器学习）以及Graphx完美融合.


## 2.特点
### 2.1 易用(Ease Of Use)
通过高阶函数构建应用

### 2.2 容错(Fault TOlerance)



### 2.3 易整合到Spark体系中(Spark Integration)
通过批处理和交互查询连接Streaming

### 2.4 缺点
Spark Streaming 是一种“微量批处理”架构, 和其他基于“一次处理一条记录”架构的系统相比, 它的延迟会相对高一些


# 二、WordCount
## 1.案例实现
```scala
//1. 创建StreamingContext
val conf = new SparkConf().setMaster("local[2]").setAppName("wordcount")
val ssc = new StreamingContext(conf, Seconds(5)) //传入时间间隔
//2. 核心数据集: DStream
val socketStream = ssc.socketTextStream("hadoop102", 9999)
//3. 对DStreaming各种操作
val wordCountDStream = socketStream
    .flatMap(_.split(" "))
    .map((_, 1))
    .reduceByKey(_ + _)
//4. 最终数据的处理: 打印
wordCountDStream.print(100) // TODO: 有问题!!!!
//5. 启动StreamingContext
ssc.start() //nc -lk 9999
//6. 阻止当前线程退出
ssc.awaitTermination() //等待ssc结束，主线程才结束
```

## 2.案例分析



# 三、DStream创建(数据源)
## 1.RDD队列


## 2.自定义数据源


## 3.Kafka数据源
<!-- TODO 理论知识 -->

