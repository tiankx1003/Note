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
 * RDD在Lineage依赖方面分为两种窄依赖(Narrow Dependencies)和宽依赖