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
wordCountDStream.print(100)
//5. 启动StreamingContext
ssc.start() //nc -lk 9999
//6. 阻止当前线程退出
ssc.awaitTermination() //等待ssc结束，主线程才结束
```
```bash
sudo yum install -y nc
nc -lk 9999
```

## 2.案例分析



# 三、DStream创建(数据源)
## 1.RDD队列
```scala
val conf = new SparkConf().setMaster("local[2]").setAppName("wordcount2")
val ssc = new StreamingContext(conf, Seconds(3))
val rddQueue = mutable.Queue[RDD[Int]]() //数据源为rdd队列
val resultDStream = ssc.queueStream(rddQueue, false).reduce(_ + _)
resultDStream.print
ssc.start()
while (true) {
    rddQueue.enqueue(ssc.sparkContext.parallelize(1 to 100))
    Thread.sleep(1000) //每秒处理一个
}
ssc.awaitTermination()
```

## 2.自定义数据源
 * 本质上就是自定义接收器

```scala
object CustomReceiver {
    def main(args: Array[String]): Unit = {
        val conf = new SparkConf().setMaster("local[2]").setAppName("wordcount")
        val ssc = new StreamingContext(conf, Seconds(4)) //传入时间间隔
        ssc.receiverStream(new MyReceiver("hadoop102", 9998))
            .flatMap(_.split(" ")).map((_, 1)).reduceByKey(_ + _).print(100)
        ssc.start()
        ssc.awaitTermination()
    }
}

/**
 * 自定义接收器从socket接受数据
 */
class MyReceiver(val host: String, val port: Int) extends Receiver[String](StorageLevel.MEMORY_ONLY) { //传入存储级别
    /**
     * 接收器启动时调用的方法
     * 启动子线程，循环不断的接收数据
     */
    override def onStart(): Unit = {
        new Thread() {
            override def run(): Unit = receiveData()
        }.start()
    }

    /**
     * 接收器停止时的回调方法
     */
    override def onStop(): Unit = ???

    /**
     * 封装接受数据的方法
     */
    def receiveData() = {
        try { //为了解决前面没数据报异常的问题
            //从socket接受数据
            val socket = new Socket(host, port)
            val reader = new BufferedReader(new InputStreamReader(socket.getInputStream, "utf-8")) //字节流转字符流
            var line = reader.readLine()
            while (line != null) {
                store(line)
                line = reader.readLine()
            }
            reader.close()
            socket.close()
        } catch {
            case e: Exception => e.printStackTrace
        } finally {
            //重启任务
            restart("restart............")
        }
    }
}
```

## 3.Kafka数据源

### 3.1
```scala
val conf = new SparkConf().setMaster("local[2]").setAppName("wordcount")
val ssc = new StreamingContext(conf, Seconds(4)) //传入时间间隔
//kafka参数声明
val brokers = "hadoop102:9092,hadoop103:9092,hadoop104:9092"
val topic = "first"
val group = "bigdata"
val kafkaParams =
    Map(ConsumerConfig.GROUP_ID_CONFIG -> group, ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG -> brokers)
// 使用泛型确定kv类型和kv解码器类型
KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](
    ssc, kafkaParams, Set(topic) //可以订阅多个topic
).print() //TODO 当前方法的缺点
ssc.start()
ssc.awaitTermination()
```

### 3.2
```scala
def main(args: Array[String]): Unit = {
    val ssc: StreamingContext = StreamingContext.getActiveOrCreate("./ck1", createSsc)
    ssc.start()
    ssc.awaitTermination()
}

def createSsc(): StreamingContext = {
    println("Flag") //只在第一次时执行
    val conf: SparkConf = new SparkConf().setMaster("local[2]").setAppName("wordcount")
    val ssc: StreamingContext = new StreamingContext(conf, Seconds(4))
    ssc.checkpoint(".ck1") //一般checkpoint存放在HDFS，但是又会带来小文件问题
    val brokers: String = "hadoop102:9092,hadoop103:9092,hadoop104:9092"
    val topic: String = "first"
    val group: String = "bigdata"
    val kafkaParams: Map[String, String] =
        Map(ConsumerConfig.GROUP_ID_CONFIG -> group, ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG -> brokers)
    KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](
        ssc, kafkaParams, Set(topic)).print() //TODO 没有打印输出会报错??????
    ssc
}
```


### 3.3
```scala
val brokers: String = "hadoop102:9092,hadoop103:9092,hadoop104:9092"
val topic: String = "first"
val group: String = "bigdata"
val kafkaParams: Map[String, String] =
    Map(ConsumerConfig.GROUP_ID_CONFIG -> group, ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG -> brokers)
//手动提交offsets，读取offsets需要使用
val kafkaCluster: KafkaCluster = new KafkaCluster(kafkaParams)

//读取offsets
def readOffsets(): Map[TopicAndPartition, Long] = { //泛型为分区和偏移量
    var resultMap: Map[TopicAndPartition, Long] = Map[TopicAndPartition, Long]()
    //获取到所有分区
    val topicAndPartitionEither: Either[Err, Set[TopicAndPartition]] = kafkaCluster.getPartitions(Set(topic))
    topicAndPartitionEither match {
        case Right(topicAndPartitionSet) => //分区存在
            //获取分区和偏移量
            val topicAndPartitionOffsetEither: Either[Err, Map[TopicAndPartition, Long]] =
                kafkaCluster.getConsumerOffsets(group, topicAndPartitionSet)
            if (topicAndPartitionOffsetEither.isRight) //表示曾经消费过，已经有offset
                resultMap ++= topicAndPartitionOffsetEither.right.get
            else //分区存在，但是没有map，表示第一次消费分区，把每个分区的偏移量置零
                topicAndPartitionSet.foreach(tap => resultMap += tap -> 0L)
        case _ =>
    }
    resultMap
}

def writeOffsets(sourceDStream: InputDStream[String]): Unit = {
    sourceDStream.foreachRDD(rdd => { //每个时间间隔都会遍历一次
        var map: Map[TopicAndPartition, Long] = Map[TopicAndPartition, Long]()
        //强转成HasOffsetRanges，包含本次消费的offset其实范围
        val hasOffsetRanges: HasOffsetRanges = rdd.asInstanceOf[HasOffsetRanges]
        val ranges: Array[OffsetRange] = hasOffsetRanges.offsetRanges
        ranges.foreach(rang => { //每个分区都会遍历一次
            val offset: Long = rang.untilOffset
            map += rang.topicAndPartition() -> offset
        })
        kafkaCluster.setConsumerOffsets(group, map)
    })
}

def main(args: Array[String]): Unit = { // TODO: 视频
    val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("HighKafka")
    val ssc: StreamingContext = new StreamingContext(conf, Seconds(3))
    val offsets: Map[TopicAndPartition, Long] = readOffsets()
    val sourceDStream: InputDStream[String] =
        KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder, String](
            ssc,
            kafkaParams,
            offsets,
            (mm: MessageAndMetadata[String, String]) => mm.message()
        )
    sourceDStream.flatMap(_.split(" ")).map((_, 1)).reduceByKey(_ + _).print(100)
    writeOffsets(sourceDStream)
    ssc.start()
    ssc.awaitTermination()
}
```


# 四、DStream转换

## 1.无状态转换
```scala
val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("TransformDemo")
val ssc: StreamingContext = new StreamingContext(conf, Seconds(3))
val socketStream: ReceiverInputDStream[String] = ssc.socketTextStream("hadoop102", 9999)
val resultDStream: DStream[(String, Int)] = socketStream.transform(rdd => {
    rdd.flatMap(_.split(" ")).map((_, 1)).reduceByKey(_ + _)
})
resultDStream.print
ssc.start()
ssc.awaitTermination()
```

## 2.有状态转换
```scala
val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("TransformDemo")
val ssc: StreamingContext = new StreamingContext(conf, Seconds(3))
ssc.checkpoint(".ck1")
//ssc.sparkContext.setCheckpointDir(".ck1") //效果同上
val socketStream: ReceiverInputDStream[String] = ssc.socketTextStream("hadoop102", 9999)
val resultDStream: DStream[(String, Int)] = socketStream
    .flatMap(_.split(" "))
    .map((_, 1))
    .updateStateByKey(
        (seq: Seq[Int], opt: Option[Int]) => Some(seq.sum + opt.getOrElse(0))
    )
resultDStream.print
ssc.start()
ssc.awaitTermination()
```


