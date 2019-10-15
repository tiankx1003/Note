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



介绍Spark部署方式
Spark提交作业的参数
手绘Spark架构与作业提交流程(讲解各部分作用)
Spark中血统概念的理解
Spark的宽窄依赖
Spark如何划分stage，每个stage如何决定task个数
列举transformation算子并简述功能
列举action算子并简述功能
列举会引起Shuffle的算子并简述功能
两种Shuffle的工作流程
  包括未优化的HashShuffle、优化的HashShuffle、普通的SortShuffle与bypass的SortShuffle
reduceByKey和groupByKey的区别，那种更有优势
Repartition和Coalesce的关系和区别
Spark缓存机制和checkpoint机制
共享变量的原理和用途
在Spark操作数据库时如何减少连接次数
SparkSQL中RDD DF DS三者的区别和联系
SparkSQL中join操作和left join操作的区别
SparkStreaming消费Kafka的方式有那些，以及区别
SparkStreaming窗口函数的原理
手写WordCount的Spark代码实现
如何使用Spark实现TopN的获取(思路及伪代码)
调优前后性能的详细对比
append和overwrite的区别
coalesce和repartition的区别
cache缓存级别
释放缓存和缓存
Spark Shuffle默认并行度
kryo序列化
创建临时表和全局临时表
BroadCast Join
控制Spark reduce缓存 调优shuffle
注册UDF函数
Spark Streaming第一次运行不丢数据
Spark Streaming精准一次消费
Spark Streaming控制每秒消费数据的速度
Spark Streaming背压机制
Spark Streaming一个stage耗时
Spark Streaming优雅关闭
Spark Streaming默认分区个数
元数据管理(Atlas血缘系统)
数据质量监控(Griffin)