# 一、MapReduce概述

## 1.定义

**MapReduce**是一个分布式运算程序的编程框架，使用户开发“基于Hadoop的数据分析应用”的核心框架。

**MapReduce**核心功能是将**用户编写的业务逻辑代码**和**自带默认组件**整合成一个完整的**分布式运算程序**，并运算在一个Hadoop集群上。


## 2.优缺点

### 2.1 优点

**易于编程**
简单的实现一些接口，就可以完成一个分布式程序。

**良好的扩展性**
可以在计算资源不足时通过简单的增加及其来扩展计算能力

**高容错性**
如果一个节点宕机，可以把计算任务转移到另一个节点上运行，不至于任务运行失败

**适合PB级以上海量数据的离线处理**
可以实现上千台服务器集群并发工作，提供数据处理能力。

### 2.2 缺点

**不擅长实时计算**
MapReduce无法像MySQL一样，在毫秒或秒级内返回结果

**不擅长流式计算**
流式计算的输入数据是动态的，而MapReduce的**输入数据集是静态的**，不能动态变化。这是因为MapReduce自身的设计特点决定了数据源必须的静态的。

**不擅长DAG(有向图)计算**
多个应用程序存在依赖关系，后一个应用程序的输入为前一个的输出。在这种情况下，MapReduce并不是不能做，而是使用后每个MapReduce作业的输出结果都会写入多磁盘，会造成大量的磁盘IO，导致性能非常的低下。

## 3.核心思想

![](img/MapReduce-core.png)

>1）分布式的运算程序往往需要分成至少2个阶段。
2）第一个阶段的MapTask并发实例，完全并行运行，互不相干。
3）第二个阶段的ReduceTask并发实例互不相干，但是他们的数据依赖于上一个阶段的所有MapTask并发实例的输出。
4）MapReduce编程模型只能包含一个Map阶段和一个Reduce阶段，如果用户的业务逻辑非常复杂，那就只能多个MapReduce程序，串行运行。

**若干问题细节**
MapTask如何工作
ReduceTask如何工作
MapTask如何控制分区排序
MapTask和ReduceTask之间如何衔接

**总结**：分析WordCount数据流走向深入理解MapReduce核心思想。


## 4.进程

>完整的MapReduce程序在分布式运行时有三类**实例进程**
**MrAppMaster**负责整个程序的过程调度及状态协调
**MapTask**负责Map阶段的整个数据处理流程
**ReduceTask**负责Reduce阶段的整个数据流程处理


## 5.官方WordCount源码

采用反编译工具反编译源码，发现WordCount案例有Map类、Reduce类和驱动类。且数据类型是Hadoop自身封装的序列化类型。

```java
//driver


```

```java
//mapper

```

```java
//reducer

```

## 6.常用数据序列化类型

Java类型|Hadoop Writable类型
:-:|:-:
Boolean|BooleanWritable
Byte|ByteWritable
Int|IntWritable
Float|FloatWritabl
Long|LongWritabl
Double|DoubleWritabl
String|TextWritabl
Map|MapWritabl
Array|ArrayWritabl

## 7.Mapreduce编程规范

>**Mapper**
用户自定义的Mapper要继承自己的父类
Mapper的输入数据是KV对的形式(KV的类型可自定义)
Mapper的业务逻辑写在map()方法中
Mapper的输出数据时KV的形式(KV的类型可自定义)
map()方法(MapTask进程)对每一个<K,V>调用一次

>**Reducer**
用户自定义的Reduce要继承自己的父类
Reduce的输入数据类型对应Mapper的输出数据类型，也是KV
Reduce的业务逻辑写在reduce()方法中
ReduceTask进程对每一组相同k的<K,V>**组**调用一次reduce()方法

>**Driver**
相当于YARN集群的客户端，用于提交我们整个程序到YARN集群
和封装MapReduce程序相关运行参数的job对象

## 8.WordCount案例实操

### 8.1 需求

在给定的文本文件中统计输出每一个单词出现的总次数
**输入数据**
```
hello
hello world
MapReduce
Zookeeper Mapper
hello Hello World
tian
```
**期望输出数据**
```
hello   2
Hello   1
Mapper  1
MapReduce   1
tian    1
world   1
World   1
```

### 8.2 需求分析

>输入数据

>输出数据

>Mapper
将MapTask传给文本内容先转换成String
根据空格将这一行切分成单词
将单词输出成<K,V>

>Reducer
汇总key的个数
输出该key的总次数

>Driver
获取配置信息，获取job对象实例
指定本程序的jar包所在的本地路径
关联Mapper/Reducer业务类
指定Mapper输出数据的kv类型
指定最终输出的数据的kv类型
指定job的输入原始文件所在的目录
指定job的输出结果所在目录
提交作业

### 8.3 环境准备

创建Maven工程

在pom.xml中添加依赖
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

src/main/resources目录下新建log4j.properties
```propeerties
log4j.rootLogger=INFO, stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d %p [%c] - %m%n
log4j.appender.logfile=org.apache.log4j.FileAppender
log4j.appender.logfile.File=target/spring.log
log4j.appender.logfile.layout=org.apache.log4j.PatternLayout
log4j.appender.logfile.layout.ConversionPattern=%d %p [%c] - %m%n
```

### 8.4 编写程序
Mapper
```java
package com.atguigu.mapreduce;
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class WordcountMapper extends Mapper<LongWritable, Text, Text, IntWritable>{
	
	Text k = new Text();
	IntWritable v = new IntWritable(1);
	
	@Override
	protected void map(LongWritable key, Text value, Context context)	throws IOException, InterruptedException {
		
		// 1 获取一行
		String line = value.toString();
		
		// 2 切割
		String[] words = line.split(" ");
		
		// 3 输出
		for (String word : words) {
			
			k.set(word);
			context.write(k, v);
		}
	}
}
```

Reducer
```java
package com.atguigu.mapreduce.wordcount;
import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class WordcountReducer extends Reducer<Text, IntWritable, Text, IntWritable>{
    int sum;
    IntWritable v = new IntWritable();

	@Override
	protected void reduce(Text key, Iterable<IntWritable> values,Context context) throws IOException, InterruptedException {
		
		// 1 累加求和
		sum = 0;
		for (IntWritable count : values) {
			sum += count.get();
		}
		
		// 2 输出
       v.set(sum);
		context.write(key,v);
	}
}
```

Driver驱动类
```java
package com.atguigu.mapreduce.wordcount;
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordcountDriver {

	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {

		// 1 获取配置信息以及封装任务
		Configuration configuration = new Configuration();
		Job job = Job.getInstance(configuration);

		// 2 设置jar加载路径
		job.setJarByClass(WordcountDriver.class);

		// 3 设置map和reduce类
		job.setMapperClass(WordcountMapper.class);
		job.setReducerClass(WordcountReducer.class);

		// 4 设置map输出
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(IntWritable.class);

		// 5 设置最终输出kv类型
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);
		
		// 6 设置输入和输出路径
		FileInputFormat.setInputPaths(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		// 7 提交
		boolean result = job.waitForCompletion(true);

		System.exit(result ? 0 : 1);
	}
}
```

### 8.5 本地测试

在本地操作系统配置Hadoop环境
在编译器上运行程序
***debug视频***

### 8.6 集群测试

用maven打jar包，需要添加的打包插件依赖

```xml
<build>
		<plugins>
			<plugin>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>2.3.2</version>
				<configuration>
					<source>1.8</source>
					<target>1.8</target>
				</configuration>
			</plugin>
			<plugin>
				<artifactId>maven-assembly-plugin </artifactId>
				<configuration>
					<descriptorRefs>
						<descriptorRef>jar-with-dependencies</descriptorRef>
					</descriptorRefs>
					<archive>
						<manifest>
                        <!-- 需要修改 -->
							<mainClass>com.tian.mr.WordcountDriver</mainClass>
						</manifest>
					</archive>
				</configuration>
				<executions>
					<execution>
						<id>make-assembly</id>
						<phase>package</phase>
						<goals>
							<goal>single</goal>
						</goals>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
```
右键项目 -> maven -> update project

将程序打成jar包，然后拷贝到Hadoop集群中
步骤: 右键 -> Run as -> maven install
等待编译完成就会在项目的target文件夹中生成jar包，如果看不到，在项目上右键 -> Refresh 即可看到。修改不带依赖的jar包名称为 wc.jar 并拷贝该jar到Hadoop集群。

启动Hadoop集群


执行WordCount程序
```bash
hadoop jar  wc.jar
 com.tian.wordcount.WordcountDriver /user/tian/input /user/tian/output
```

# 二、Hadoop序列化

## 1.序列化概述

### 1.1 序列化概念
**序列化**就是把内存中的对象转换成字节序列(或其他数据传输协议)以便于存储到磁盘(持久化)和网络传输

**反序列化**就是将收到的字节序列(或其他数据传输协议)或者是磁盘的持久化数据，转换成内存中的对象

### 1.2 为什么序列化

使用序列化可以将内存中的对象存储到磁盘，还可以在远程计算机传输

### 1.3 为什么不用Java的序列化

Java序列化是一个重量级序列化框架(Serializable)，一个对象被序列化后，会附带很多额外的信息(各种校验信息，Header,继承体系等)，不便于网络中高效传输，所以Hadoop自己开发了一套序列化机制(Writable)。

>**Hadoop序列化特点**
**紧凑**高效使用内存空间
**快速**对俄数据的额外开销小
**可扩展**可随着通信协议的升级而升级
**互操作**支持多语言的交互


## 2.自定义bean对象实现序列化接口(Writable)

**实现bean对象序列化步骤**

必须实现Writable接口
反序列化时，需要反射调用空参构造器，所以必须使用空参构造
```java
public FlowBean() {
    super();
}
```
重写序列化方法
```java
@Override
public void write(DataOutput out) throws IOException {
	out.writeLong(upFlow);
	out.writeLong(downFlow);
	out.writeLong(sumFlow);
}
```
重写反序列化方法
```java
@Override
public void readFields(DataInput in) throws IOException {
	upFlow = in.readLong();
	downFlow = in.readLong();
	sumFlow = in.readLong();
}
```
注意反序列化的顺序和序列化的顺序完全一致
把结果显示在文件中，需要重写toString()，用"\t"分开，方便后续使用
如果需要将自定义的bean放在key中传输，则还需要实现Comparable接口，因为MapReduce框中的Shuffle过程要求对key必须能排序，详见排序案例
```java
@Override
public int compareTo(FlowBean o) {
	// 倒序排列，从大到小
	return this.sumFlow > o.getSumFlow() ? -1 : 1;
}

```
## 3.序列化案例实操

### 3.1 需求

统计每一个手机号耗费的总上行流量、下行流量、总流量
输入数据 phone_data.txt
```txt
1	13736230513	192.196.100.1	www.atguigu.com	2481	24681	200
2	13846544121	192.196.100.2			264	0	200
3 	13956435636	192.196.100.3			132	1512	200
4 	13966251146	192.168.100.1			240	0	404
5 	18271575951	192.168.100.2	www.atguigu.com	1527	2106	200
6 	84188413	192.168.100.3	www.atguigu.com	4116	1432	200
7 	13590439668	192.168.100.4			1116	954	200
8 	15910133277	192.168.100.5	www.hao123.com	3156	2936	200
9 	13729199489	192.168.100.6			240	0	200
10 	13630577991	192.168.100.7	www.shouhu.com	6960	690	200
11 	15043685818	192.168.100.8	www.baidu.com	3659	3538	200
12 	15959002129	192.168.100.9	www.atguigu.com	1938	180	500
13 	13560439638	192.168.100.10			918	4938	200
14 	13470253144	192.168.100.11			180	180	200
15 	13682846555	192.168.100.12	www.qq.com	1938	2910	200
16 	13992314666	192.168.100.13	www.gaga.com	3008	3720	200
17 	13509468723	192.168.100.14	www.qinghua.com	7335	110349	404
18 	18390173782	192.168.100.15	www.sogou.com	9531	2412	200
19 	13975057813	192.168.100.16	www.baidu.com	11058	48243	200
20 	13768778790	192.168.100.17			120	120	200
21 	13568436656	192.168.100.18	www.alibaba.com	2481	24681	200
22 	13568436656	192.168.100.19			1116	954	200
```
输入数据格式
```
7 	13560436666	120.196.100.99		1116		 954			200
id	手机号码		网络ip			上行流量  下行流量     网络状态码
```
期望输出格式
```
13560436666 		1116		      954 			2070
手机号码		    上行流量        下行流量		总流量
```

### 3.2 需求分析



### 3.3 编写MapReduce程序

**编写流量统计的Bean对象**
```java
package com.atguigu.mapreduce.flowsum;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import org.apache.hadoop.io.Writable;

// 1 实现writable接口
public class FlowBean implements Writable{

	private long upFlow;
	private long downFlow;
	private long sumFlow;
	
	//2  反序列化时，需要反射调用空参构造函数，所以必须有
	public FlowBean() {
		super();
	}

	public FlowBean(long upFlow, long downFlow) {
		super();
		this.upFlow = upFlow;
		this.downFlow = downFlow;
		this.sumFlow = upFlow + downFlow;
	}
	
	//3  写序列化方法
	@Override
	public void write(DataOutput out) throws IOException {
		out.writeLong(upFlow);
		out.writeLong(downFlow);
		out.writeLong(sumFlow);
	}
	
	//4 反序列化方法
	//5 反序列化方法读顺序必须和写序列化方法的写顺序必须一致
	@Override
	public void readFields(DataInput in) throws IOException {
		this.upFlow  = in.readLong();
		this.downFlow = in.readLong();
		this.sumFlow = in.readLong();
	}

	// 6 编写toString方法，方便后续打印到文本
	@Override
	public String toString() {
		return upFlow + "\t" + downFlow + "\t" + sumFlow;
	}

	public long getUpFlow() {
		return upFlow;
	}

	public void setUpFlow(long upFlow) {
		this.upFlow = upFlow;
	}

	public long getDownFlow() {
		return downFlow;
	}

	public void setDownFlow(long downFlow) {
		this.downFlow = downFlow;
	}

	public long getSumFlow() {
		return sumFlow;
	}

	public void setSumFlow(long sumFlow) {
		this.sumFlow = sumFlow;
	}
}
```
**编写Mapper类**
```java
package com.atguigu.mapreduce.flowsum;
import java.io.IOException;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class FlowCountMapper extends Mapper<LongWritable, Text, Text, FlowBean>{
	
	FlowBean v = new FlowBean();
	Text k = new Text();
	
	@Override
	protected void map(LongWritable key, Text value, Context context)	throws IOException, InterruptedException {
		
		// 1 获取一行
		String line = value.toString();
		
		// 2 切割字段
		String[] fields = line.split("\t");
		
		// 3 封装对象
		// 取出手机号码
		String phoneNum = fields[1];

		// 取出上行流量和下行流量
		long upFlow = Long.parseLong(fields[fields.length - 3]);
		long downFlow = Long.parseLong(fields[fields.length - 2]);

		k.set(phoneNum);
		v.set(downFlow, upFlow);
		
		// 4 写出
		context.write(k, v);
	}
}
```
**编写Reducer类**
```java
package com.atguigu.mapreduce.flowsum;
import java.io.IOException;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class FlowCountReducer extends Reducer<Text, FlowBean, Text, FlowBean> {

	@Override
	protected void reduce(Text key, Iterable<FlowBean> values, Context context)throws IOException, InterruptedException {

		long sum_upFlow = 0;
		long sum_downFlow = 0;

		// 1 遍历所用bean，将其中的上行流量，下行流量分别累加
		for (FlowBean flowBean : values) {
			sum_upFlow += flowBean.getUpFlow();
			sum_downFlow += flowBean.getDownFlow();
		}

		// 2 封装对象
		FlowBean resultBean = new FlowBean(sum_upFlow, sum_downFlow);
		
		// 3 写出
		context.write(key, resultBean);
	}
}
```

**编写Driver驱动类**
```java
package com.atguigu.mapreduce.flowsum;
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class FlowsumDriver {

	public static void main(String[] args) throws IllegalArgumentException, IOException, ClassNotFoundException, InterruptedException {
		
// 输入输出路径需要根据自己电脑上实际的输入输出路径设置
args = new String[] { "e:/input/inputflow", "e:/output1" };

		// 1 获取配置信息，或者job对象实例
		Configuration configuration = new Configuration();
		Job job = Job.getInstance(configuration);

		// 6 指定本程序的jar包所在的本地路径
		job.setJarByClass(FlowsumDriver.class);

		// 2 指定本业务job要使用的mapper/Reducer业务类
		job.setMapperClass(FlowCountMapper.class);
		job.setReducerClass(FlowCountReducer.class);

		// 3 指定mapper输出数据的kv类型
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(FlowBean.class);

		// 4 指定最终输出的数据的kv类型
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(FlowBean.class);
		
		// 5 指定job的输入原始文件所在目录
		FileInputFormat.setInputPaths(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		// 7 将job中配置的相关参数，以及job所用的java类所在的jar包， 提交给yarn去运行
		boolean result = job.waitForCompletion(true);
		System.exit(result ? 0 : 1);
	}
}
```

***视频***

# 三、MapReduce框架原理

## 1.InputFormat数据输入

### 1.1 切片与MapTask并行度决定机制

### 1.2 Job提交流程源码和切片源码详解

### 1.3 FileInputFormat切片机制

### 1.4 CombineTextInputFormat切片机制

### 1.5 CombineTextInputFormat案例实操

### 1.6 FileInputFormat实现类

### 1.7 KeyValueTextInputFormat使用案例

### 1.8 NLineInputFormat使用案例

### 1.9 自定义InputFormat

### 1.10 自定义InputFormat案例实操

### 2.MapReduce工作流程

### 3.Shuffle机制

### 3.1 Shuffle机制

### 3.2 Partition分区

### 3.3 Partition分区案例实操

### 3.4 WritableComparable排序

### 3.5 WritableComparable排序案例实操(全排序)

### 3.6 WritableComparable排序案例实操(区内排序)

### 3.7 Combiner合并

### 3.8 Combiner合并案例实操

### 3.9 GroupingComparator分组(辅助排序)

### 3.10 GroupingComparator分组案例实操

## 4.MapTask工作机制

## 5.ReduceTask工作机制

## 6.OutputFormat数据输出

### 6.1 OutputFormat接口实现类

### 6.2 自定义OutputFormat

### 6.3 自定义OutputFormat案例实操



## 7.Join多种应用

## 7.1 Reduce Join

## 7.2 Reduce Join案例实操

## 7.3 Map Join

## 7.4 Map Join案例实操

## 8.计数器应用

## 9.数据清洗(ETL)

### 9.1 数据清晰案例实操-简单解析版

### 9.2 数据清洗案例实操-复杂解析版

## 10.MapReduce开发总结

# 四、Hadoop数据压缩

## 1.概述

## 2.MR支持的压缩编码

## 3.压缩方式选择

### 3.1 Gzip压缩

### 3.2 Bzip2压缩

### 3.3 Lzo压缩

### 3.4 Snappy压缩



## 4.压缩位置选择

## 5.压缩参数配置

## 6.压缩实操案例

### 6.1 数据流的压缩和解压缩

### 6.2 Map输出端采用压缩

### 6.3 Reduce输出端采用压缩

# 五、Yarn资源调度

## 1.基本架构

## 2.工作机制

## 3.作业提交全过程

## 4.资源调度器

## 5.容量调度器多队列提交案例

### 5.1 需求

### 5.2 配置多队列的容量调度器

### 5.3 向Hive队列提交任务

## 6.任务的推测执行

# 六、Hadoop企业执行

## 1.MapReduce跑的慢的原因

## 2.MapReduce优化方法

### 2.1 数据输入

### 2.2 Map阶段

### 2.3 Reduce阶段

### 2.4 I/O传输

### 2.5 数据倾斜问题

### 2.6 常用的调优参数

## 3.HDFS小文件优化

### 3.1 HDFS小文件弊端

### 3.2 HDFS小文件解决方案

# 七、MapReduce扩展案例

## 1.倒排索引案例(多job串联)

## 2.TopN案例

## 3.找博客共同好友案例

# 八、常见错误及解决方案

