# 通用范式

## **pom.xml添加依赖**

```xml
<dependencies>
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-core</artifactId>
        <version>2.8.2</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-common</artifactId>
        <version>2.7.2</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-client</artifactId>
        <version>2.7.2</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-hdfs</artifactId>
        <version>2.7.2</version>
    </dependency>
</dependencies>
```

**添加log4j.properties**

```properties
log4j.rootLogger=INFO, stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.sstdout.layout.ConversionPattern=%d %p [%c] - %m%n
log4j.appender.logfile=org.apache.log4j.FileAppender
log4j.appender.logfile.File=target/spring.log
log4j.appender.logfile.layout=org.apache.log4j.PatternLayout
log4j.appender.logfile.layout.ConversionPattern=%d %p [%c] - %m%n
```

**编程规范**
Mapper继承类重写map方法
Reducer继承类重写Reduce方法
Driver类关联、设置输出类型、输入输出路径

# 案例

## WordCount





## Hadoop序列化


在pojo中实现Writable接口并重写序列化反序列化

```java
//反序列化时需要反射调用空参构造器，必须包含空参构造器
public FlowBean() {
    super();
}
//重写序列化和反序列化方法时注意顺序必须一致
@Override
public void write(DataOutput out) throws IOException {
	out.writeLong(upFlow);
	out.writeLong(downFlow);
	out.writeLong(sumFlow);
}
@Override
public void readFields(DataInput in) throws IOException {
	upFlow = in.readLong();
	downFlow = in.readLong();
	sumFlow = in.readLong();
}
//自定义bean需要放在key中传输时需要实现Comparable接口
//因为shuffle过程要求必须排序
@Override
public int compareTo(FlowBean o) {
	return this.sumFlow > o.getSumFlow() ? -1 : 1;
}
```


## KeyValueTextInputFormat

设置分隔符后，分隔符前为key，分隔符后为value，二者均为Text类的对象

```java
/* Mapper */
//按照业务逻辑设置key value
LongWritable v = new LongWritable(1);  
context.write(key, v);

/* Reducer */
//按照业务逻辑进行合并或累加等操作
long sum = 0L;
for (LongWritable value : values) {  
    sum += value.get();  
}
v.set(sum);
context.write(key,v);

/* Driver */
//设置切割符
conf.set(KeyValueLineRecordReader.KEY_VALUE_SEPERATOR," ");
//设置输入格式
job.setInputFormatClass(KeyValueTextInputFormat.class);
```



## NLineInputFormat

key value类型和TextInputFormat类型一致
改变了切片规则
map进程处理的InputSplit不再按Block块来划分，根据指定的行数

```java
/* Mapper */
//设置key value
private Text k = new Text();
private LongWritable v = new LongWritable(1); //恒1
k.set(splited[i]); //迭代一行切割后的每个字符串
context.write(k, v);

/* Reducer */
//统计汇总
long sum = 0l;
for (LongWritable value : values) {
    sum += value.get();
} 
v.set(sum);
context.write(key,v);

/* Driver */
//设置每个切片InputSplit中划分三条记录
NLineInputFormat.setNumLinesPerSplit(job,3);
```



## CombineTextInputFormat

通过设置虚拟切片最大值的方式，改变切片规则，解决小文件问题

```java
/* Mapper 和 Reducer不做改动，和WordCount案例一致 */

/* WordCountDriver */
// 如果不设置InputFormat，它默认用的是TextInputFormat.class
job.setInputFormatClass(CombineTextInputFormat.class);
//虚拟存储切片最大值设置4m
CombineTextInputFormat.setMaxInputSplitSize(job, 4194304);
/* 查看日志输出
 * number of splits:3
 */
```



## 自定义InputFormat

在企业开发中，Hadoop框架自带的InputFormat类型不能满足所有应用场景，需要自定义InputFormat来解决问题

```java
/* 自定义InputFormat的子类 */
//重写isSplitable方法
//重写RecordReader实现一次读取一整个文件

/* 自定义RecordReader子类 */
//重写方法

/* Mapper */
context.write(key，value); //直接写出

/* Reducer */
context.write(key, values.iterator().next()); //获取并写出一个
//或使用迭代

/* Driver */
//设置输入的inputFormat
job.setInputFormatClass(WholeFileInputFormat.class);
//设置输出的outputFormat
job.setOutputFormatClass(SequenceFileOutputFormat.class);
```



## Partition

把统计结果输出到不同文件(分区)中

```java
/* 自定义Partitioner子类 */
//重写getPartition方法
int partition = 4;
if ("136".equals(preNum)) partition = 0;
else if ("137".equals(preNum)) partition = 1;
else if ("138".equals(preNum)) partition = 2;
else if ("139".equals(preNum)) partition = 3;
return partition;

/* Mapper 和 Reducer 业务逻辑不需要改动 */

/* Driver */
//指定自定义数据分区
job.setPartitionerClass(ProvincePartitioner.class);
//同时指定象印数量的reduceTask
job.setNumReduceTasks(5);

//若partition是5
job.setNumReduceTasks(1); //会正常运行，只不过会产生一个输出文件
job.setNumReduceTasks(2); //会报错
job.setNumReduceTasks(6); //大于5，程序会正常运行，产生空文件
```



## WritableComparable

**排序**是MapReduce框架中最重要的操作之一
可以根据自己的需求自定义排序规则



**全排序**

```java
/* pojo类实现WritableComparable接口 */
//重写compareTo方法
publci int compareTo(FlowBean o) {
 	return this.sumFlow > o.getSumFlow() ? -1 : 1;
}

/* Mapper */
//context.write(bean,手机号);
bean.set(upFlow, downFlow);
v.set(phoneNbr);
context.write(bean, v);

/* Reducer */
//循环输出，避免总流量相同的情况
for (Text text : values) {
 	context.write(text,key);
}

/* Driver没改动 */
```

**区内排序**

```java
/* 自定义Partitioner子类 */
//根据规则返回分区号
return partition;

/* Mapper 和 Reducer 无业务逻辑变更 */
/* Driver */
// 加载自定义分区类
job.setPartitionerClass(ProvincePartitioner.class);
// 设置Reducetask个数
job.setNumReduceTasks(5);
```



## Combiner

在MapTask过程中使用Reducer子类Combiner对MapTask输出进行局部汇总，见减小网络传输
Combiner不能影响最终业务的逻辑，且输出的kv和Reducer输入kv一致

```java
/* Combiner类继承Reducer */
//重写Reducer方法，业务逻辑和Reducer子类一致

/* Mapper和Reducer业务逻辑不变 */

/* Driver */
//方法一
job.setCombinerClass(WordcountCombiner.class);
//方法二
job.setCombinerClass(WordCountReducer.class);
//这里Combiner 和 Reducer业务逻辑一致
```



## GroupingComparator

对Reduce阶段的数据根据某一个或者几个字段进行分组。

```java
/* pojo继承WritableComparator */
//根据业务逻辑重写compare
//空参构造器将类传给父类
protected OrderGroupingComparator() {
    super(OrderBean.class, true);
}

/* WritableComparator子类 */
//根据排序规则重写compare方法

/* 根据业务逻辑编写 Mapper 和 Reducer */

/* Driver */
//设置reduce端的分组
job.setGroupingComparatorClass(OrderGroupingComparator.class);
```



# 源码





## WordCount



## JobCommit



## Split 



## MapReduce





## Shuffle


