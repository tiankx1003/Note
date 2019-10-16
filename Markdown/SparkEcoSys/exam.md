# Scala
### 1.元组
```scala
//元组的创建
val tuple1 = (1,2,3,"aaa") //四维元祖
val value1 = tuple1._1 //第一个元素
//元祖的遍历
for(i <- tuple1.productIterator){
    print(i)
}
tuple1.productIterator.foreach(i => println(i))
tuple1.productIterator.foreach(print(_))
```

### 2.隐式转换
<!-- TODO 自定义隐式类 -->

### 3.函数式编程的理解
Scala中函数的地位:一等公民
Scala的匿名函数(函数字面量)
Scala中的高阶函数(传入或返回函数)
Scala中的闭包(调用外部值)
Scala中的柯里化
Scala中的部分应用函数

### 4.样例类
```scala
case class Person(name: String, age: Int)
//spark中的应用场景
ds = df.as[Person]
```

### 5.柯里化
函数编程中，单个参量列表中含有多个参量，转化为多个参量列表分别包含单个参量
柯里化是面向函数思想的必然产生结果
```scala
```
<!-- TODO 示例 -->

### 6.闭包
一个函数把外部的那些不属于自己的对象也包含(闭合)进来
```scala
def minus(x: Int) = (y: Int) => x - y
val f1 = minus(10)
val f2 = minus(10)
println(f1(3) + f2(3))
```

### 7.Some、None、Option的使用
<!-- TODO 具体使用 -->


# Spark

### 1.简述Spark的部署方式
 * local模式，运行在一台机器上，通常用于测试环境
 * Standalone模式，构建一个基于Master+Slaves的资源调度集群，Spark任务提交给Master运行，是Spark滋生的一个调度系统
 * Yarn模式，Spark客户端直接连接Yarn，不要额外构建Spark集群，有yarn-client和yarn-cluster两种模式，主要区别在于，Driver程序运行的节点不同
 * Mesos模式，在国内很少有使用

### 2.平时使用那种方式提交Spark任务，javaEE界面还是脚本
 * 我们企业使用脚本的方式提交Spark任务

### 3.Spark作业提交参数(重点)
`executor-cores` 每个executor使用的内核数，默认为1，官方建议为2~5个，我们企业使用4个
`num-executors` 启动executor的数量，默认为2
`executor-memory` executor内存大小，默认1G
`driver-cores` driver使用内核数，默认为1
`driver-memory` dirver内存大小，默认512M

```bash
# 任务提交样式
spark-submit \
--master local[5] \
--driver-cores 2 \
--executor-cores 4 \
--num-executors 10 \
--executor-memory 8g \
--class PackageName.ClassName XXX.jar \
--name "Spark Job Name" \
InputPaht \
OutputPaht
```

### 4.简述Spark的架构与作业提交流程(画图讲解，注明各部分的作用，重点)
<!-- TODO 手绘 + 讲解 -->

### 5.Spark中RDD血统概念的理解(笔试重点)
 * RDD在Lineage依赖方面分为两种窄依赖(Narrow Dependencies)和宽依赖(Wide Dependencies)用来解决数据容错时的高效性以及划分任务时起到重要作用

### 6.简述SPark的宽窄依赖，以及Spark如何划分stage，每个stage有根据什么决定task个数
 * stage，根据RDD之间的依赖关系的不同将job划分成不同的Stage，遇到宽依赖则划分一个Stage
 * Task，Stage是一个TaskSet，将Stage根据分区数划分成一个个的Task

### 7.请列举Spark的transformation算子(不少于8个)，并简述功能
 * `map(func)` 返回要给新的RDD，该RDD由每一个输入元素经过func函数转换后组成
 * `mapPartitions(func)` 类似于map，但独立地在RDD的每一个分片上运行，因此在类型为T的RDD上运行时，func的函数u类型必须是`Iterator[T] => Iterator[U]`，假设有N个元素，有M个分区，那么map的函数将被调用N次，而mapPartitions被调用M次，一个函数一次处理所有分区
 * `reduceByKey(func, [numTask])` 在一个(K, V)的RDD上调用，返回一个(K, V)的RDD，使用reduce函数，将相同key的值聚合到一起，reduce任务的个数可以通过第二个可选的参数来设置
 * `aggregateByKey(zeroValue:U,[partition:Partitioner])(seqOp:(U,V)=>U,combOp:(U,U)=>U)` 在kv对的RDD中，按key将value进行分组合并，合并时，将每个value和初始值作为seq函数的参数，进行计算，返回的结果作为一个新的kv对，然后再将结果按照key进行合并，最后将每个分组的value传递给combine函数进行计算(先将前两个value进行计算)，将返回结果和下一个value传给combine函数，以此类推)，将key与计算结果作为一个新的kv输出。
 * `combineByKey(createCombiner:V=>C, mergeValue:(C,V)=>C,mergeCombiners:(C,C)=>C)` 对相同K，把V合并成一个集合
   * `createCombiner:CombinerByKey()` 会遍历分区中的所有元素，因此每个元素的键要么还没有遇到过，要么和之前的某个元素的键相同，如果是一个新的元素，`combineByKey()`会使用`createCombiner()`的函数来创建那个键对应的累加器的初始值
   * `mergeValue` 如果这是一个在处理当前分区之前已经遇到的键，他会使用mergeValue()方法将该键的累加器对应的当前值与这个新的值进行合并
   * mergeCombiners 由于每个分区都是独立处理的，因此对于同一个键可以有多个累加器，如果有两个后者更多的分区都有对应的同一个键的累加器，就需要使用用户提供的mergeCombiners()方法将哥哥分区的结果进行合并
   <!-- 介绍自己熟悉的算子 -->

### 8.列举Spark的action算子(不少于6个)，并简述功能(重点)
 * reduce
 * collect
 * first
 * aggregate
 * countByKey
 * foreach
 * saveAsTextFile
<!-- TODO 简述功能 -->

### 9.列举会引起Shuffle过程的Spark算子并简述功能
 * reduceByKey
 * groupByKey
 * ...ByKey
<!-- TODO 简述功能 -->

### 10.简述Spark的两种核心Shuffle(HashShuffle和SortShuffle)的工作流程(包括未优化HashShuffle、优化的HashShuffle、普通的SortShuffle与bypass的SortShuffle)(绘图，重点)

<!-- TODO 绘图，描述 -->

### 11.Spark算子中reduceByKey和groupByKey的区别，哪一个更有优势
 * reduceByKey 按照key进行聚合，在shuffle之前有预聚合操作返回结果为`RDD[k,v]`
 * groupByKey 按照key进行分组，直接shuffle
 * 在不影响业务逻辑的前提下，reduceByKey更具有优势

### 12.Repartition和Coalesce的关系和区别
 * 关系，两者都用来改变RDD的分区数，repartition底层调用的是`coalesce(numPartitions,shuffle=true)`
 * 区别，repartition一定会发生shuffle，coalesce根据传入的参数决定是否shuffle
 * 一般情况下，在增大partition数时使用repartition，减小partition数时使用coalesce

### 13.简述Spark中的缓存机制(cache和persist)与checkpoint机制，并指出两者的区别和联系
 * 都是用来做RDD的持久化
 * cache缓存，不会截断血缘关系，使用计算过程中的计算缓存
 * checkpoint磁盘，阶段血缘关系，在ck之前没有任何任务提交才会生效，ck过程会额外提交一次任务

### 14.简述Spark中共享变量(广播变量和累加器)的基本原理和用途
 * 累加器(accumulator)是spark中提供的一种分布式的变量机制，其原理类似于mapreduce，即分布式的改变，然后聚合这些改变
 * 累加器主要用于累加计数性质，广播变量主要用于高效的分发较大的对象
 * Spark中在做map或者filter时，executor都会用到driver中的变量，而每个节点上操作这些变量不会真正改变driver中的值
 * 累加器和广播变量主要用于结果聚合和广播这两种通信模式

### 15.当Spark需要和数据库进行交互时，如何减少连接次数
 * 使用foreachPartition算子代替foreach，每个分区获取一次连接

### 16.简述RDD、DataFrame和DataSet三者的区别和联系
**RDD**
 * 优点，编译时类型安全，编译时就能检查处类型错误，面向对象的编程风格，直接通过类点名的方式来操作数据
 * 缺点，序列化和反序列化的性能开销，无论是集群间的通信，还是IO操作都需要对对象的结构和数据进行序列化和反序列化GC的性能开销，频繁的创建和销毁对象势必会增加GC
**DataFrame**
 * DF引入了Schema和off-heap
 * schema,每一行的数据，结构都是一样的，这个结构存储在schema中，Spark通过schema就能够读懂数据，因此在通信和IO时就只需要序列化和反序列化数据，而结构的部分就可以省略了
**DataSet**
 * DS结合了RDD和DF的优点，并带来一个新的概念Encoder
 * 当序列化数据时，Encoder产生字节码与off-heap进行交互，能够达到按需访问数据的效果，而不用反序列化整个对象，Spark还没有提供自定义Encoder的API，但是未来会加入
**三者之间的转换**
<!-- TODO 绘图 -->

### 17.SparkSQL中join操作和left join操作区别
* join和sql中的inner join操作类似，只返回前面的集合和后面的集合匹配成功的
* leftjoin类似于SQL中的左外关联left outer join，返回结果以第一个RDD为主，关联不上的记录为空
* 部分场景下可以使用left semi join替代left join
* 因为left semi join是in(keySet)的关系，遇到右表重复记录，左表会跳过，性能更高，而left join则会一直遍历，但是left semi join中最后select的结果中只许出现左表中的列名，因为右表只有join key参与关联计算了

### 18.SparkStreaming有哪几种方式消费kafka中的数据，他们之间的区别是什么
 * 基于Receiver的方式

 * 基于Direct的方式

 * 对比
<!-- TODO 消费Kafka的方式 -->

### 19.简述SparkStreaming窗口函数的原理(重点)
 窗口函数就是在原来定义的SparkStreaming计算批次大小的基础上再次进行封装，每次计算多个批次的数据，同时还需要传递一个滑动步长的参数，用来设置当次计算任务完成之后下一次从什么地方开始计算
<!-- TODO 绘图表示窗口长度和滑动步长 -->

### 20.手写Wordcount的Spark代码
```scala
val conf:SparkConf=new SparkConf().setMaster("local[*]").setAppName("WordCount")
val sc=new SparkContext(conf)
sc.textFile("/input")
  .flatMap(_.split"\\W+")
  .map((_,1))
  .reduceByKey(_+_)
  .saveAsTextFile("/output")
sc.stop()
```

### 21.如何使用Spark实现TopN的获取(描述思路或使用伪代码)
**方法1**
 * 按照key对数据进行聚合(groupByKey)
 * 将value转换为数组，利用scala的sortBy或者sortWith进行排序(mapValues)数据量太小，，会OOM

**方法2**
 * 取出所有的key
 * 对key进行迭代，每次取出一个key利用spark的排序算子进行排序

**方法3**
 * 自定义分区器，按照key进行分区，使不用的key进入到不同的分区
 * 对每个分区运用spark的排序算子进行排序

### 22.京东，调优之前和调优之后性能的详细对比(例如调整map个数，map个数之前多少，之后多少，有什么提升)
若是有几百个文件，会有几百个map出现，读取之后进行join操作，会非常的慢，这个时候我们可以进行coalesce操作，
比如240个map，我们合成60个map，也就是窄依赖，这样再shuffle，过程产生额文件会大大减少，提高join的时间性能

### 23.append和overwrite的区别
append在原有分区上进行追加，overwrite在原有的分区上进行全量刷新

### 24.coalesce和repartition的区别
coalesce和repartition都用于改变分区，coalesce用于缩小分区而且不会进行shuffle，repartition用于增大分区(提供并行度)会进行shuffle，在spark中减少文件个数会使用coalesce来减少分区来到这个目的，但是如果数据量过大，分区数会出现OOM所以coalesce缩小分区个数也需合理

### 25.cache缓存级别
DF的Cache采用MEMORY_AND_DISK这和RDD默认方式不一样RDD cache默认使用MEMORY_ONLY

### 26.释放缓存和缓存
 * 缓存 `dataFrame.cache`  `sparkSession.catelog.cacheTable("tableName")`
 * 释放缓存 `dataFrame.unpersist`  `sparkSession.catalog.uncacheTable("tableName")`

### 27.Spark Shuffle默认并行度
 * 参数`spark.sql.shuffle.partitions`决定
 * 默认并行度为200

### 28.kryo序列化
 * kryo序列化比java序列化更快更紧凑，但spark默认的序列化是java序列化并不是spark序列化，因为spark并不支持所有序列化类型，而且每次使用都必须进行注册
 * 注册只针对于RDD
 * 在DF和DS中自动实现了kryo序列化

### 29.创建临时表和全局临时表
 * `DataFrame.createTempView()`创建临时表
 * `DataFrame.createGlobalTempView()` `DataFrame.createOrReplaceTempView()`创建全局临时表

### 30.BroadCast join广播join
 * 原理，先将小表数据查询出来聚合到driver端，再广播到各个executor端，使表与表jion时进行本地join，避免进行网络传输产生shuffle
 * 使用场景，大表join小表，只能广播小表

### 31.控制Spark reduce缓存，调优shuffle
 * `spark.reducer.maxSizeInFilght` 该参数为reduce task能够来去多少数据量的一个参数默认48M，当集群资源足够时，增大此参数可减少reduce拉去数据量的次数，从而达到优化shuffle的效果，一般调大为96MB，资源够大时可以继续增大
 * `spark.shuffle.file.buffer` 此参数为每个shuffle文件输出流的内容缓冲区大小，增大该参数可以减少shuffle文件时进行磁盘搜索和系统调用的次数，默认参数为32k一般增大为64k

### 32.注册UDF函数
```scala
SparkSession.udf.register
```

### 33.Spark Streaming第一次运行不丢失数据
kafka参数`auto.offset.reset`参数设置成earliest从最初偏移量开始消费数据

### 34.Spark Streaming精准消费一次
 * 手动维护偏移量
 * 处理完业务数据后，在进行提交偏移量操作
 * 极端情况下，如果提交偏移量时断网或者停电到这Spark程序二次启动重复消费问题，所以在涉及金额和精准计算的场景会使用事务保证精准消费一次

### 35.Spark Streaming控制每秒消费数据的速度
通过`spark.streaming.kafka.maxRatePerPartition`参数来设置Spark Streaming从Kafka分区每秒拉取的条数

### 36.Spark Streaming背压机制
`spark.streaming.backpressure.enable`设置为`true`，开启背压机制后Spark Streaming会根据延迟动态去kafka消费数据，上限由`spark.streaming.kafka.maxRatePerPartition`参数控制
两个一般配合使用

### 37.Spark Streaming一个stage耗时
Spark Streaming stage耗时由最慢的task决定，所以数据倾斜时某个task运行慢会导致整个Spark Streaming运行非常慢

### 38.Spark Streaming优雅关闭
`spark.streaming.stopGracefullyOnShutdown`参数设置成true，Spark会在JVM关闭时正常不关闭StreamingContext，而不是立马不关闭
Kill命令， `yarn application -kill aplicationid`

### 39.Spark Streaming默认分区个数
Spark Streaming默认分区个数与所对接的Kafka topic分区个数一致，Spark Streaming里一般不会使用repartition算子增大分区，因为repartition会进行shuffle增加耗时

### 40.元数据管理(Atlas血缘系统)
https://www.cnblogs.com/mantoudev/p/9986408.html

### 41.数据质量监控(Griffin)
https://blog.csdn.net/An342647823/article/details/86543432


<!-- TODO yarn cluster流程图 -->