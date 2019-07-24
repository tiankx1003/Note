# TODO-List

* [ ] **Job submit >> debug src**  ***视频3***
* [ ] **FileInputFormat** ***视频 4 5***
* [ ] **MapReduce测试 @ 集群**
* [ ] **NLineInputFormat实现类的理解**  ***视频***
* [ ] **KeyValueTextInputFormat & NLineInputFormat使用案例**
* [ ] **自定义FileInputFormat** ***视频11*** *2019-7-23 15:58:32*
* [ ] **自定义InputFormat调试** ***视频***
* [ ] **快速排序算法**  *2019-7-24 09:26:38*    
* [ ] **Partition实操**  *2019-7-24 11:43:01*
* [ ] **Combiner合并 视频**  *2019-7-24 14:49:10*
* [ ] **GroupingComparator分组 视频**  *2019-7-24 15:16:26*
* [ ] **Shuffle-src 视频**  *2019-7-24 15:50:36*
* [ ] **MapReduce工作流程图**  *2019-7-24 16:31:21*
* [ ] **InputFormat数据输入**  *2019-7-25 01:12:40*
* [ ] **切片与MapTask并发度决定机制**  *2019-7-25 01:13:13*



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
String|**Text**
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

>**Mapper**
将MapTask传给文本内容先转换成String
根据空格将这一行切分成单词
将单词输出成<K,V>

>**Reducer**
汇总key的个数
输出该key的总次数

>**Driver**
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

```
1. job.WaitForCompletion();提交job
2. waitForCompletion(true);调用submit
3. submit();
	3.1 ensureState(JobState.DEFINE);确认Job的状态
	3.2 setUseNewAPI();设置使用新的API
	3.3 connect();
		[1] 创建cluster对象，return new Cluster(getConfiguration());
		[2] initialize方法中创建cluster，判断是本地运行还是yarn运行
			最终获取不同的Runner，(LocalJobRunner or YarnRunner)
	3.4 ★ submitJobInternal();
		[1] checkSpecs(job);判断输出路径是否存在，如果存在抛出异常
		[2] JobSubmissionFiles.getStagingDir(cluster,conf);
			创建临时目录用于存放切片和job信息
		[3] submitClient.getNewJobID();生成一个jobID
		[4] copyAndConfigureFile();拷贝并配置文件
		[5] ★ writeSplits(job,submitJobDir);生成切片信息
			a. 默认使用的FileInputFormat是TextInputFormat
			b. input.getSplits(job);获取切片信息
				long minSize -- 
				long maxSize -- Long的最大值
				本地块BlockSize大小默认 -- 32M
				获取切片大小 -- 
				判断是否继续切片 -- 
		[6] writeConf(conf,jobFile);将所有xml配置信息写入job.xml
		[7] submitClient.submitJob(jobID,submitJobDir.toString());提交job，
		[8] jtFs.delete(submitJobDir,true);删除存放job和切片的临时目录
```

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
							<mainClass>com.tian.MapReduce.WordcountDriver</mainClass>
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
**打包前注释掉已经确定的路径**

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
package com.tian.FlowCount;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class FlowCountDriver {

	public static void main(String[] args) throws Exception {

		// 输入输出路径需要根据自己电脑上实际的输入输出路径设置
		args = new String[] { "d:/git/hadoop/input/phone_data.txt", 
				"d:/git/hadoop/output2" };

		// 1 获取配置信息，或者job对象实例
		Configuration configuration = new Configuration();
		Job job = Job.getInstance(configuration);

		// 6 指定本程序的jar包所在的本地路径
		job.setJarByClass(FlowCountDriver.class);

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

![数据输入](img/InputFormat-input.png)

### 1.1 切片与MapTask并行度决定机制

>**问题引出**
>MapTask的并行度决定Map阶段的并发度，进而影响整个进程的处理速度

> **MapTask并行度决定机制**
> **数据块：**Block是HDFS物理上把数据分成一块一块。
> **数据切片：**数据切片只是在逻辑上对输入进行分片，并不会在磁盘上将其切分成片进行存储。

![](img/split-maptask.png)

### 1.2 Job提交流程源码和切片源码详解

***视频03***



**Job提交流程源码解析**

```java
waitForCompletion()

submit();

// 1建立连接
	connect();	
		// 1）创建提交Job的代理
		new Cluster(getConfiguration());
			// （1）判断是本地yarn还是远程
			initialize(jobTrackAddr, conf); 

// 2 提交job
submitter.submitJobInternal(Job.this, cluster)
	// 1）创建给集群提交数据的Stag路径
	Path jobStagingArea = JobSubmissionFiles.getStagingDir(cluster, conf);

	// 2）获取jobid ，并创建Job路径
	JobID jobId = submitClient.getNewJobID();

	// 3）拷贝jar包到集群
copyAndConfigureFiles(job, submitJobDir);	
	rUploader.uploadFiles(job, jobSubmitDir);

// 4）计算切片，生成切片规划文件
writeSplits(job, submitJobDir);
		maps = writeNewSplits(job, jobSubmitDir);
		input.getSplits(job);

// 5）向Stag路径写XML配置文件
writeConf(conf, submitJobFile);
	conf.writeXml(out);

// 6）提交Job,返回提交状态
status = submitClient.submitJob(jobId, submitJobDir.toString(), job.getCredentials());
```



**FileInputFormat切片源码解析**



### 1.3 FileInputFormat切片机制

> **切片机制**
> 简单的按照文件的内容长度进行切片
> 切片太小，默认等于BlockSize
> 欺骗时不考虑数据集整体，而是逐个针对每一个文件单独切片

> **案例分析**
>
> 输入数据有两个文件
>
> > file1.txt – 320MB    
> > file2.txt – 10MB
>
> 经过FileInputFormat的切片机制运算后，形成的切片
>
> > file1.txt.split1 – 0~128MB
> > file1.txt.split2 – 128~256MB
> > file1.txt.split3 – 256~320MB
> > file2.txt.split1 – 0~10MB

**FileInputFormat切片大小的参数配置**

> **源码中计算切片大小的公式**
>
> ```java
> Math.max(minSize,Math.min(maxSize,blockSize));
> mapreduce.input.fileinputformat.split.minsize = 1;//默认值为1
> mapreduce.input.fileinputformat.split.maxsize = Long.MAXValue;//默认值Long.MAXValue	
> /* 因此，默认情况下，切片大小=blocksize */
> ```

> **切片大小设置**
> maxsize(切片最大值):参数如果调的必blockSize小，则会让切片变小，而且就等于配置的这个参数的值。
> minsize(切片最大值):参数调的比blockSize大，则可以让切片变得比blockSize还大。

> **获取切片信息API**
>
> ```java
> String name = inputSplit.getPath().getName();//获取切片的文件名称
> FileSplit inputSplit = (FileSplit) context.getInputSplit();//根据文件类型获取切片信息
> ```
>
> 

***视频04***

***视频05***


### 1.4 CombineTextInputFormat切片机制

框架默认的**TextInputFormat**切片机制是对任务按文件规划切片，<u>不管文件多小，都会是一个单独的切片</u>，都会交给一个MapTask，这样如果有<u>大量小文件</u>，就会产生<u>大量的MapTask</u>，处理效率极其低下。

**应用场景**
用于<u>小文件过多</u>的场景，可以将多个小文件从<u>逻辑上</u>规划到一个切片中，这样多个小文件交给<u>一个MapTask</u>处理。

**虚拟存储切片最大值设置**

```java
CombineTextInputFormat.setMaxInputSplitSize(job, 4194304);// 4m
```

***注意***：虚拟存储切片最大值设置最好根据实际的小文件大小情况来设置具体的值。

**切片机制**
生成切片过程包括：<u>虚拟存储</u>过程和<u>切片</u>过程二部分。

> **虚拟存储过程**
将输入目录下所有文件大小，依次和设置的setMaxInputSplitSize值比较，如果不大于设置的最大值，逻辑上划分一个块。如果输入文件大于设置的最大值且大于两倍，那么以最大值切割一块；当剩余数据大小超过设置的最大值且不大于最大值2倍，此时将文件均分成2个虚拟存储块（防止出现太小切片）。
例如setMaxInputSplitSize值为4M，输入文件大小为8.02M，则先逻辑上分成一个4M。剩余的大小为4.02M，如果按照4M逻辑划分，就会出现0.02M的小的虚拟存储文件，所以将剩余的4.02M文件切分成（2.01M和2.01M）两个文件。

>**切片过程**
判断虚拟存储的文件大小是否大于setMaxInputSplitSize值，大于等于则单独形成一个切片。
如果不大于则跟下一个虚拟存储文件进行合并，共同形成一个切片。
测试举例：有4个小文件大小分别为1.7M、5.1M、3.4M以及6.8M这四个小文件，则虚拟存储之后形成6个文件块，大小分别为：
1.7M，（2.55M、2.55M），3.4M以及（3.4M、3.4M）
最终会形成3个切片，大小分别为：
(1.7+2.55）M，（2.55+3.4）M，（3.4+3.4）M

[**合并小文件逻辑**](link/merge-tiny-file.docx)

### 1.5 CombineTextInputFormat案例实操

> **需求**将输入的大量小文件合并成一个切片统一处理
> 输入数据:准备4个小文件
> 期望:一个切片处理4个文件

> **实现过程**
> 不做任何处理，运行WordCount案例程序，控制台日志观察切片个数为4
>
> ```
> number of splits:4
> ```
>
> 在WordCountDriver中添加代码，运行程序并观察切片个数
>
> ```java
> // 如果不设置InputFormat，它默认用的是TextInputFormat.class
> job.setInputFormatClass(CombineTextInputFormat.class);
> 
> //虚拟存储切片最大值设置4m
> CombineTextInputFormat.setMaxInputSplitSize(job, 4194304);
> ```
>
> ```
> number of splits:3
> ```
>
> 在WordCountDriver中添加代码，运行程序并观察切片个数
>
> ```java
> // 如果不设置InputFormat，它默认用的是TextInputFormat.class
> job.setInputFormatClass(CombineTextInputFormat.class);
> 
> //虚拟存储切片最大值设置20m
> CombineTextInputFormat.setMaxInputSplitSize(job, 20971520);
> ```
>
> ```
> number of splits:1
> ```

### 1.6 FileInputFormat实现类

> **TextInputFormat**
> TextInputFormat是<u>默认</u>的FileInputFormat实现类。按行读取每天记录
> <u>Key</u>是存储该行整个文件中的起始字节偏移量，<u>LongWritable</u>
> <u>Value</u>是行的内容，不包括任何终止符(换行符和回车符)，<u>Text</u>

Value是行的内容，不包括任何终止符(换行符和回车符)，Text类型

> **KeyValueTextInputFormat**
> 每一行均为一条记录，分隔符为key , value，可以通过在驱动类中设置分隔符，默认分隔符为“\t”
> <u>不改变切片规则</u>
> <u>key</u>为分隔符前的内容，<u>Text</u>
> <u>value</u>为分隔符后的所有内容，<u>Text</u>

> **NLineInputFormat**
> map进程处理的<u>InputSplit不再按Block块划分</u>，而是按NlineInputFormat指定的行数N来划分
> 即输入文件的总行数/N=切片数，如果不整除，切片数=商+1
> <u>Key</u>和<u>Value</u>类型与<u>TextInputFormat</u>类型一致

***视频***

### 1.7 KeyValueTextInputFormat使用案例

>**需求**统计输入文件中每一行的第一个单词相同的行数
>输入数据
>```
>banzhang ni hao
>xihuan hadoop banzhang
>banzhang ni hao
>xihuan hadoop banzhang
>```
>期望结果数据
>```
>banzhang 2
>xihuan 2
>```

>**需求分析**
>Map
>```
>设置key和value<banzhang,1>
>写出
>```
>Reduce
>```
><banzhang,1>
><banzhang,1>
>汇总
>写出
>```
>Driver
>```java
>//设置切割符
>conf.set(KeyValueLineRecordReader.KEY_VALUE_SEPERATOR," ");
>//设置输入格式
>job.setInputFormatClass(KeyValueTextInputFormat.class);
>```

>**代码实现**
>编写Mapper类
>```java
>package com.atguigu.mapreduce.KeyValueTextInputFormat;
>import java.io.IOException;
>import org.apache.hadoop.io.LongWritable;
>import org.apache.hadoop.io.Text;
>import org.apache.hadoop.mapreduce.Mapper;
>
>public class KVTextMapper extends Mapper<Text, Text, Text, LongWritable>{
>	
>// 1 设置value
>   LongWritable v = new LongWritable(1);  
>    
>	@Override
>	protected void map(Text key, Text value, Context context)
>			throws IOException, InterruptedException {
>
>// banzhang ni hao
>        
>        // 2 写出
>        context.write(key, v);  
>	}
>}
>```
>编写Reducer类
>```java
>package com.atguigu.mapreduce.KeyValueTextInputFormat;
>import java.io.IOException;
>import org.apache.hadoop.io.LongWritable;
>import org.apache.hadoop.io.Text;
>import org.apache.hadoop.mapreduce.Reducer;
>
>public class KVTextReducer extends Reducer<Text, LongWritable, Text, LongWritable>{
>	
>    LongWritable v = new LongWritable();  
>    
>	@Override
>	protected void reduce(Text key, Iterable<LongWritable> values,	Context context) throws IOException, InterruptedException {
>		
>		 long sum = 0L;  
>
>		 // 1 汇总统计
>        for (LongWritable value : values) {  
>            sum += value.get();  
>        }
>         
>        v.set(sum);  
>         
>        // 2 输出
>        context.write(key, v);  
>	}
>}
>```
>编写Driver类
>```java
>package com.atguigu.mapreduce.keyvaleTextInputFormat;
>import java.io.IOException;
>import org.apache.hadoop.conf.Configuration;
>import org.apache.hadoop.fs.Path;
>import org.apache.hadoop.io.LongWritable;
>import org.apache.hadoop.io.Text;
>import org.apache.hadoop.mapreduce.Job;
>import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
>import org.apache.hadoop.mapreduce.lib.input.KeyValueLineRecordReader;
>import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat;
>import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
>
>public class KVTextDriver {
>
>	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
>		
>		Configuration conf = new Configuration();
>		// 设置切割符
>	conf.set(KeyValueLineRecordReader.KEY_VALUE_SEPERATOR, " ");
>		// 1 获取job对象
>		Job job = Job.getInstance(conf);
>		
>		// 2 设置jar包位置，关联mapper和reducer
>		job.setJarByClass(KVTextDriver.class);
>		job.setMapperClass(KVTextMapper.class);
>job.setReducerClass(KVTextReducer.class);
>				
>		// 3 设置map输出kv类型
>		job.setMapOutputKeyClass(Text.class);
>		job.setMapOutputValueClass(LongWritable.class);
>
>		// 4 设置最终输出kv类型
>		job.setOutputKeyClass(Text.class);
>job.setOutputValueClass(LongWritable.class);
>		
>		// 5 设置输入输出数据路径
>		FileInputFormat.setInputPaths(job, new Path(args[0]));
>		
>		// 设置输入格式
>	job.setInputFormatClass(KeyValueTextInputFormat.class);
>		
>		// 6 设置输出数据路径
>		FileOutputFormat.setOutputPath(job, new Path(args[1]));
>		
>		// 7 提交job
>		job.waitForCompletion(true);
>	}
>}
>```


### 1.8 NLineInputFormat使用案例

> **需求**对每个单词进行个数统计，要求根据每个输入文件的行数来规定输出多少个切片。此案例要求每三行放入一个切片中。
>
> **输入数据**
>
> ```
> banzhang ni hao
> xihuan hadoop banzhang
> banzhang ni hao
> xihuan hadoop banzhang
> banzhang ni hao
> xihuan hadoop banzhang
> banzhang ni hao
> xihuan hadoop banzhang
> banzhang ni hao
> xihuan hadoop banzhang banzhang ni hao
> xihuan hadoop banzhang
> ```
>
> **期望输出数据**
>
> ```
> Number of splits:4
> ```

> **需求分析**
> Map
>
> ```
> 获取一行
> 切割
> 循环写出
> ```
>
> Reduce
>
> ```
> 汇总
> 输出
> ```
>
> Dirver
>
> ```java
> //设置每个切片InputSplit中划分三条记录
> NLineInputFormat.setNumLinesPerSplit(job,3);
> ```

> **代码实现**
> 编写Mapper类
>
> ```java
> package com.atguigu.mapreduce.nline;
> import java.io.IOException;
> import org.apache.hadoop.io.LongWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Mapper;
> 
> public class NLineMapper extends Mapper<LongWritable, Text, Text, LongWritable>{
> 	
> 	private Text k = new Text();
> 	private LongWritable v = new LongWritable(1);
> 	
> 	@Override
> 	protected void map(LongWritable key, Text value, Context context)	throws IOException, InterruptedException {
> 		
> 		 // 1 获取一行
>         String line = value.toString();
>         
>         // 2 切割
>         String[] splited = line.split(" ");
>         
>         // 3 循环写出
>         for (int i = 0; i < splited.length; i++) {
>         	
>         	k.set(splited[i]);
>         	
>            context.write(k, v);
>         }
> 	}
> }
> ```
>
> 编写Reducer类
>
> ```java
> package com.atguigu.mapreduce.nline;
> import java.io.IOException;
> import org.apache.hadoop.io.LongWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Reducer;
> 
> public class NLineReducer extends Reducer<Text, LongWritable, Text, LongWritable>{
> 	
> 	LongWritable v = new LongWritable();
> 	
> 	@Override
> 	protected void reduce(Text key, Iterable<LongWritable> values,	Context context) throws IOException, InterruptedException {
> 		
>         long sum = 0l;
> 
>         // 1 汇总
>         for (LongWritable value : values) {
>             sum += value.get();
>         }  
>         
>         v.set(sum);
>         
>         // 2 输出
>         context.write(key, v);
> 	}
> }
> ```
>
> 编写Driver类
>
> ```java
> package com.atguigu.mapreduce.nline;
> import java.io.IOException;
> import java.net.URISyntaxException;
> import org.apache.hadoop.conf.Configuration;
> import org.apache.hadoop.fs.Path;
> import org.apache.hadoop.io.LongWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Job;
> import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
> import org.apache.hadoop.mapreduce.lib.input.NLineInputFormat;
> import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
> 
> public class NLineDriver {
> 	
> 	public static void main(String[] args) throws IOException, URISyntaxException, ClassNotFoundException, InterruptedException {
> 		
> // 输入输出路径需要根据自己电脑上实际的输入输出路径设置
> args = new String[] { "e:/input/inputword", "e:/output1" };
> 
> 		 // 1 获取job对象
> 		 Configuration configuration = new Configuration();
>         Job job = Job.getInstance(configuration);
>         
>         // 7设置每个切片InputSplit中划分三条记录
>         NLineInputFormat.setNumLinesPerSplit(job, 3);
>           
>         // 8使用NLineInputFormat处理记录数  
>         job.setInputFormatClass(NLineInputFormat.class);  
>           
>         // 2设置jar包位置，关联mapper和reducer
>         job.setJarByClass(NLineDriver.class);  
>         job.setMapperClass(NLineMapper.class);  
>         job.setReducerClass(NLineReducer.class);  
>         
>         // 3设置map输出kv类型
>         job.setMapOutputKeyClass(Text.class);  
>         job.setMapOutputValueClass(LongWritable.class);  
>         
>         // 4设置最终输出kv类型
>         job.setOutputKeyClass(Text.class);  
>         job.setOutputValueClass(LongWritable.class);  
>           
>         // 5设置输入输出数据路径
>         FileInputFormat.setInputPaths(job, new Path(args[0]));  
>         FileOutputFormat.setOutputPath(job, new Path(args[1]));  
>           
>         // 6提交job
>         job.waitForCompletion(true);  
> 	}
> }
> ```
>
> 

### 1.9 自定义InputFormat

在企业开发中，Hadoop框架自带的InputFormat类型不能满足所有应用场景，需要自定义InputFormat来解决问题

>**自定义InputFormat步骤**
>自定义类继承FileInputFormat
>重写RecordReader，实现一次读取一个完整文件
>在输出时使用SequenceFileOutPutFormat输出并合并文件

### 1.10 自定义InputFormat案例实操

***视频11***

无论HDFS还是MapReduce，在处理小文件时效率都非常低，但又难免面临处理大量小文件的场景，此时，就需要有相应解决方案。可以自定义InputFormat实现小文件的合并。

> **需求**
> 将多个小文件合并成一个SequenceFile文件（SequenceFile文件是Hadoop用来存储二进制形式的key-value对的文件格式），SequenceFile里面存储着多个文件，存储的形式为文件路径+名称为key，文件内容为value。
> 输入数据
>
> ```one.txt
> yongpeng weidong weinan
> sanfeng luozong xiaoming
> ```
> ```two.txt
> longlong fanfan
> mazong kailun yuhang yixin
> longlong fanfan
> mazong kailun yuhang yixin
> ```
> ```three.txt
> shuaige changmo zhenqiang 
> dongli lingu xuanxuan
> ```
>
> 期望输出
>
> ```
> //字节码文件
> ```

> **需求分析**
> 自定义类继承FileInputFormat
>
> ```
> 重写isSplitable()方法，返回false表示文件不可切割
> 重写creatRecordReader()，创建自定义RecordReader对象，并初始化
> ```
>
> 重写RecorderReader，实现一次读取一个完整的文件封装为KV
>
> ```
> 采用IO流一次读取一个文件输出到value中，因为设置了不可切片，最终把文件封装到了value中
> 获取文件路径信息+名称，并设置key
> ```
>
> 设置Driver
>
> ```java
> //设置输入的inputFormat
> job.setInputFormatClass(WholeFileInputFormat.class);
> //设置输出的outputFormat
> job.setOutputFormatClass(SequenceFileOutputFormat.class);
> ```

> **程序实现**
> 自定义InputFormat
>
> ```java
> package com.atguigu.mapreduce.inputformat;
> import java.io.IOException;
> import org.apache.hadoop.fs.Path;
> import org.apache.hadoop.io.BytesWritable;
> import org.apache.hadoop.io.NullWritable;
> import org.apache.hadoop.mapreduce.InputSplit;
> import org.apache.hadoop.mapreduce.JobContext;
> import org.apache.hadoop.mapreduce.RecordReader;
> import org.apache.hadoop.mapreduce.TaskAttemptContext;
> import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
> 
> // 定义类继承FileInputFormat
> public class WholeFileInputformat extends FileInputFormat<Text, BytesWritable>{
> 	
> 	@Override
> 	protected boolean isSplitable(JobContext context, Path filename) {
> 		return false;
> 	}
> 
> 	@Override
> 	public RecordReader<Text, BytesWritable> createRecordReader(InputSplit split, TaskAttemptContext context)	throws IOException, InterruptedException {
> 		
> 		WholeRecordReader recordReader = new WholeRecordReader();
> 		recordReader.initialize(split, context);
> 		
> 		return recordReader;
> 	}
> }
> 
> ```
>
> 自定义RecordReader类
>
> ```java
> package com.atguigu.mapreduce.inputformat;
> import java.io.IOException;
> import org.apache.hadoop.conf.Configuration;
> import org.apache.hadoop.fs.FSDataInputStream;
> import org.apache.hadoop.fs.FileSystem;
> import org.apache.hadoop.fs.Path;
> import org.apache.hadoop.io.BytesWritable;
> import org.apache.hadoop.io.IOUtils;
> import org.apache.hadoop.io.NullWritable;
> import org.apache.hadoop.mapreduce.InputSplit;
> import org.apache.hadoop.mapreduce.RecordReader;
> import org.apache.hadoop.mapreduce.TaskAttemptContext;
> import org.apache.hadoop.mapreduce.lib.input.FileSplit;
> 
> public class WholeRecordReader extends RecordReader<Text, BytesWritable>{
> 
> 	private Configuration configuration;
> 	private FileSplit split; //便于别的方法调用
> 	
> 	private boolean isProgress= true;
> 	private BytesWritable value = new BytesWritable();
> 	private Text k = new Text();
> 
> /**
>     * 初始化
>     * InputSplit split : 当前的切片对象 FileSplit
>     * TaskAttemptContext Context : 上下文对象，包含多种需要的信息
> */
> 	@Override
> 	public void initialize(InputSplit split, TaskAttemptContext context) throws IOException, InterruptedException {
> 		
> 		this.split = (FileSplit)split;
> 		configuration = context.getConfiguration();
> 	}
> /*
>     * key : 文件路径 + 文件名
>     * value : 文件中的内容
> *
> */
> 	@Override
> 	public boolean nextKeyValue() throws IOException, InterruptedException {
> 		
> 		if (isProgress) {
> 
> 			// 1 定义缓存区
> 			byte[] contents = new byte[(int)split.getLength()];
> 			
> 			FileSystem fs = null;
> 			FSDataInputStream fis = null;
> 			
>          try {
>              // 2 获取文件系统
>              Path path = split.getPath();
>              fs = path.getFileSystem(configuration);
>              fis = fs.open(path);
>              // 5 输出文件内容
>              value.set(contents, 0, contents.length);
>              // 6 获取文件路径及名称
>              String name = split.getPath().toString();
>              // 7 设置输出的key值
>              k.set(name);
> 
>          } catch (Exception e) {
> 
>          }finally {
>              IOUtils.closeStream(fis);
>          }
>              isProgress = false;
>              return true;
> 		}
> 		
> 		return false;
> 	}
> 
> 	@Override
> 	public Text getCurrentKey() throws IOException, InterruptedException {
> 		return k;
> 	}
> 
> 	@Override
> 	public BytesWritable getCurrentValue() throws IOException, InterruptedException {
> 		return value;
> 	}
> 
> 	@Override
> 	public float getProgress() throws IOException, InterruptedException {
> 		return 0;
> 	}
> 
> 	@Override
> 	public void close() throws IOException {
> 	}
> }
> ```
>
> 编写SequenceFileMapper类处理流程
>
> ```java
> package com.atguigu.mapreduce.inputformat;
> import java.io.IOException;
> import org.apache.hadoop.io.BytesWritable;
> import org.apache.hadoop.io.NullWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Mapper;
> import org.apache.hadoop.mapreduce.lib.input.FileSplit;
> 
> /**
> * key : 文件路径
> * value : 文件的内容
> */
> public class SequenceFileMapper extends Mapper<Text, BytesWritable, Text, BytesWritable>{
> 	
> 	@Override
> 	protected void map(Text key, BytesWritable value,			Context context)		throws IOException, InterruptedException {
> 
> 		context.write(key, value);
> 	}
> }
> ```
>
> 编写SequenceFileReducer类处理流程
>
> ```java
> package com.atguigu.mapreduce.inputformat;
> import java.io.IOException;
> import org.apache.hadoop.io.BytesWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Reducer;
> 
> public class SequenceFileReducer extends Reducer<Text, BytesWritable, Text, BytesWritable> {
> 
> 	@Override
> 	protected void reduce(Text key, Iterable<BytesWritable> values, Context context)		throws IOException, InterruptedException {
> 
> 		context.write(key, values.iterator().next());
>         //或者使用迭代
> 	}
> }
> ```
> 编写SequenceFileDriver类处理流程
>
> ```java
> package com.atguigu.mapreduce.inputformat;
> import java.io.IOException;
> import org.apache.hadoop.conf.Configuration;
> import org.apache.hadoop.fs.Path;
> import org.apache.hadoop.io.BytesWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Job;
> import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
> import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
> import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
> 
> public class SequenceFileDriver {
> 
> 	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
> 		
>         // 输入输出路径需要根据自己电脑上实际的输入输出路径设置
>         args = new String[] { "e:/input/inputinputformat", "e:/output1" };
>         // 1 获取job对象
>         Configuration conf = new Configuration();
>         Job job = Job.getInstance(conf);
>         // 2 设置jar包存储位置、关联自定义的mapper和reducer
>         job.setJarByClass(SequenceFileDriver.class);
>         job.setMapperClass(SequenceFileMapper.class);
>         job.setReducerClass(SequenceFileReducer.class);
>         // 7 设置输入的自定义inputFormat
>         job.setInputFormatClass(WholeFileInputformat.class);
>         // 8 设置输出的outputFormat
>         job.setOutputFormatClass(SequenceFileOutputFormat.class);
>         // 3 设置map输出端的kv类型
>         job.setMapOutputKeyClass(Text.class);
>         job.setMapOutputValueClass(BytesWritable.class);
>         // 4 设置最终输出端的kv类型
>         job.setOutputKeyClass(Text.class);
>         job.setOutputValueClass(BytesWritable.class);
>         // 5 设置输入输出路径
>         FileInputFormat.setInputPaths(job, new Path(args[0]));
>         FileOutputFormat.setOutputPath(job, new Path(args[1]));
>         // 6 提交job
>         boolean result = job.waitForCompletion(true);
>         System.exit(result ? 0 : 1);
> 	}
> }
> ```



**自定义InputFormat Debug**



## 2.MapReduce工作流程

![](img\MapReduce-workdetail-1.png)

map – 66.7%
sort – 33.3%
copy – 
sort –
reduce – 

mapper读取数据后通过context对象写数据到环形缓冲区
环形缓冲区中存储内容达到阈值80%后，
数据经过快排后从内存溢写到磁盘
磁盘中的文件经过归并排序后合并成一个文件
reducer合并后的单个文件

>kvindex


>bufindex



![](img\MapReduce-workdetail-2.png)





2．流程详解

上面的流程是整个MapReduce最全工作流程，但是Shuffle过程只是从第7步开始到第16步结束，具体Shuffle过程详解，如下：
1）MapTask收集我们的map()方法输出的kv对，放到内存缓冲区中
2）从内存缓冲区不断溢出本地磁盘文件，可能会溢出多个文件
3）多个溢出文件会被合并成大的溢出文件
4）在溢出过程及合并的过程中，都要调用Partitioner进行分区和针对key进行排序
5）ReduceTask根据自己的分区号，去各个MapTask机器上取相应的结果分区数据
6）ReduceTask会取到同一个分区的来自不同MapTask的结果文件，ReduceTask会将这些文件再进行合并（归并排序）
7）合并成大文件后，Shuffle的过程也就结束了，后面进入ReduceTask的逻辑运算过程（从文件中取出一个一个的键值对Group，调用用户自定义的reduce()方法）


3．注意
Shuffle中的缓冲区大小会影响到MapReduce程序的执行效率，原则上说，缓冲区越大，磁盘io的次数越少，执行速度就越快。
缓冲区的大小可以通过参数调整，参数：io.sort.mb默认100M。
4．源码解析流程

```java
context.write(k, NullWritable.get());
	output.write(key, value);
		collector.collect(key, value,partitioner.getPartition(key, value, partitions));
			HashPartitioner();
	collect()
		close()
			collect.flush()
				sortAndSpill()
					sort()   QuickSort
				mergeParts();
		
			collector.close();
```

## 3.Shuffle机制

### 3.1 Shuffle机制

![](img/shuffle.png)

### 3.2 Partition分区

>**问题引出**
要求将统计结果按照条件输出到不同文件中(分区)，如将统计结果按照手机归属地输出到不同文件中(分区)

>**默认Partition分区**
>
>```java
>public class CustomPartitioner extends Partitioner<Text, FlowBean> {
>	@Override
>	public int getPartition(Text key, FlowBean value, int numPartitions){
>		//控制分区代码逻辑
>		// ...
>		return partition;
>	}
>}
>```
>
>默认分区时根据key的hashCode对ReduceTask个数取模得到的，用户没法控制key存储到那个分区

>**自定义Partitioner步骤**
>自顶一个类继承Partitioner，重写getPartition()方法
>
>```java
>public class CustomPartitioner extends Partitioner<Text, FlowBean> {
> 	@Override
>	public int getPartition(Text key, FlowBean value, int numPartitions) {
>          // 控制分区代码逻辑
>    … …
>		return partition;
>	}
>}
>```
>
>在Job驱动中，设置自定义Partition
>
>```java
>job.setPartitionerClass(CustomPartition.class);
>```
>
>根据自定义Partition的逻辑设置相应数量的ReduceTask
>
>```java
>job.setNumReduceTasks(5);
>```

>**分区总结**
如果ReduceTask的数量 > getPartition结果数，则会多产生几个空的输出文件part-r000xx;
如果1 < ReduceTask < GetPartition接过书，则有一部分分区数据无处安放，会Exception;
若果ReduceTask的数量 = 1，则不管MapTask端输出多少个分区文件，最终结果都会交给一个ReduceTask，最终也只会产生一个结果文件part-r-00000;
分区号从零开始，逐一累加

>**案例分析**
>若自定义分区数为5
>
>```java
>job.setNumReduceTasks(1); //会正常运行，只不过会产生一个输出文件
>job.setNumReduceTasks(2); //会报错
>job.setNumReduceTasks(6); //大于5，程序会正常运行，产生空文件
>```
### 3.3 Partition分区案例实操

>**需求**
>将统计结果按照手机归属地不同省份输出到不同文件中
>**数据输入**
>
>```phone_data.txt
>1	13736230513	192.196.100.1	www.atguigu.com	2481	24681	200
>2	13846544121	192.196.100.2			264	0	200
>3 	13956435636	192.196.100.3			132	1512	200
>4 	13966251146	192.168.100.1			240	0	404
>5 	18271575951	192.168.100.2	www.atguigu.com	1527	2106	200
>6 	84188413	192.168.100.3	www.atguigu.com	4116	1432	200
>7 	13590439668	192.168.100.4			1116	954	200
>8 	15910133277	192.168.100.5	www.hao123.com	3156	2936	200
>9 	13729199489	192.168.100.6			240	0	200
>10 	13630577991	192.168.100.7	www.shouhu.com	6960	690	200
>11 	15043685818	192.168.100.8	www.baidu.com	3659	3538	200
>12 	15959002129	192.168.100.9	www.atguigu.com	1938	180	500
>13 	13560439638	192.168.100.10			918	4938	200
>14 	13470253144	192.168.100.11			180	180	200
>15 	13682846555	192.168.100.12	www.qq.com	1938	2910	200
>16 	13992314666	192.168.100.13	www.gaga.com	3008	3720	200
>17 	13509468723	192.168.100.14	www.qinghua.com	7335	110349	404
>18 	18390173782	192.168.100.15	www.sogou.com	9531	2412	200
>19 	13975057813	192.168.100.16	www.baidu.com	11058	48243	200
>20 	13768778790	192.168.100.17			120	120	200
>21 	13568436656	192.168.100.18	www.alibaba.com	2481	24681	200
>22 	13568436656	192.168.100.19			1116	954	200
>```
**期望输出**
手机号136、137、138、139开头都分别放到一个独立的4个文件中，其他开头的放到一个文件中。

>**需求分析**
>**增加一个ProvincePartition分区**
>
>```
>136		分区0
>137		分区1
>138		分区2
>139		分区3
>其他	分区4
>```

> **Driver驱动类**
>
> ```java
> //指定自定义数据分区
> job.setPartitionerClass(ProvincePartitioner.class);
> //同时指定象印数量的reduceTask
> job.setNumReduceTasks(5);
> ```
> ***ReduceTask数量设置只能为1或不小于分区个数***
> 当设置为1时所有结果写入到同一个文件part-r-00000
> 当等于分区数时，每个结果写到相应的文件中
> 当大于分区数时，结果写入到相应文件的中，多出相差个数的空文件
> 当设置为其他值时，运行报错。

>**在FlowCount案例中增加分区类**
>
>```java
>package com.atguigu.mapreduce.flowsum;
>import org.apache.hadoop.io.Text;
>import org.apache.hadoop.mapreduce.Partitioner;
>
>public class ProvincePartitioner extends Partitioner<Text, FlowBean> {
>
>	@Override
>	public int getPartition(Text key, FlowBean value, int numPartitions) {
>
>		// 1 获取电话号码的前三位
>		String preNum = key.toString().substring(0, 3);
>		
>		int partition = 4;
>		
>		// 2 判断是哪个省
>		if ("136".equals(preNum)) {
>			partition = 0;
>		}else if ("137".equals(preNum)) {
>			partition = 1;
>		}else if ("138".equals(preNum)) {
>			partition = 2;
>		}else if ("139".equals(preNum)) {
>			partition = 3;
>		}
>
>		return partition;
>	}
>}
>```

>**在驱动函数中增加自定义数据分区设置和ReduceTask设置**
>
>```java
>package com.atguigu.mapreduce.flowsum;
>import java.io.IOException;
>import org.apache.hadoop.conf.Configuration;
>import org.apache.hadoop.fs.Path;
>import org.apache.hadoop.io.Text;
>import org.apache.hadoop.mapreduce.Job;
>import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
>import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
>
>public class FlowsumDriver {
>
>	public static void main(String[] args) throws IllegalArgumentException, IOException, ClassNotFoundException, InterruptedException {
>
>		// 输入输出路径需要根据自己电脑上实际的输入输出路径设置
>		args = new String[]{"e:/output1","e:/output2"};
>
>		// 1 获取配置信息，或者job对象实例
>		Configuration configuration = new Configuration();
>		Job job = Job.getInstance(configuration);
>
>		// 2 指定本程序的jar包所在的本地路径
>		job.setJarByClass(FlowsumDriver.class);
>
>		// 3 指定本业务job要使用的mapper/Reducer业务类
>		job.setMapperClass(FlowCountMapper.class);
>		job.setReducerClass(FlowCountReducer.class);
>
>		// 4 指定mapper输出数据的kv类型
>		job.setMapOutputKeyClass(Text.class);
>		job.setMapOutputValueClass(FlowBean.class);
>
>		// 5 指定最终输出的数据的kv类型
>		job.setOutputKeyClass(Text.class);
>		job.setOutputValueClass(FlowBean.class);
>
>		// 8 指定自定义数据分区
>		job.setPartitionerClass(ProvincePartitioner.class);
>
>		// 9 同时指定相应数量的reduce task
>		job.setNumReduceTasks(5);
>		
>		// 6 指定job的输入原始文件所在目录
>		FileInputFormat.setInputPaths(job, new Path(args[0]));
>		FileOutputFormat.setOutputPath(job, new Path(args[1]));
>
>		// 7 将job中配置的相关参数，以及job所用的java类所在的jar包， 提交给yarn去运行
>		boolean result = job.waitForCompletion(true);
>		System.exit(result ? 0 : 1);
>	}
>}
>```
### 3.4 WritableComparable排序

**排序**是MapReduce框架中最重要的操作之一

MapTask和ReduceTask均会对数据按照key排序，该操作属于Hadoop的额默认行为，任何应用程序中的数据均会被排序，而不管逻辑上是否需要。

默认排序是按照字典顺序排序，且实现该排序的方法是快速排序

对于MapTask，它会将处理的结果暂时放到环形缓冲区中，当环形缓冲区使用率达到一定阈值后，再对缓冲区中的数据进行一次快速排序，并将这些有序数据溢写到磁盘上，而当数据处理完毕后，它会对磁盘上所有文件进行归并排序。

对于ReduceTask，它从每个MapTask上远程拷贝相应的数据文件，如果文件大小超过一定阈值，则溢写磁盘上，否则存储在内存中。如果磁盘上文件数目达到一定阈值，则进行一次归并排序以生成一个更大文件；如果内存中文件大小或者数目超过一定阈值，则进行一次合并后将数据溢写到磁盘上。当所有数据拷贝完毕后，ReduceTask统一对内存和磁盘上的所有数据进行一次归并排序。

>**排序分类**
**部分排序**
MapReduce根据输入记录的键对数据集排序，保证<u>输出的每个文件内部有序</u>
**全排序**
<u>最终输出结果只有一个文件，且文件内部有序</u>,实现方式是只设置一个ReduceTask。但该方法在处理大型文件时效率极低，因为一台及其处理所有文件，完全丧失了MapReduce所提供的并行架构。
**辅助排序**(GroupingComparator分组)
在Reduce端对key进行分组，应用于:在接收的key为bean对象时，向让一个或几个字段相同(全部字段比较不同)的key进行到同一个reduce方法时，可以采用分组排序。
**二次排序**
在自定义排序过程中，如果comparatorTo中的判断条件为两个即为二次排序。

>**自定义排序WritableComparable**
>**分析原理**
>bean对象作为key传输，需要实现WritableComparable接口重写compareTo方法，就可以实现排序
>```java
>package com.atguigu.mapreduce.flowsum;
>import java.io.IOException;
>import org.apache.hadoop.conf.Configuration;
>import org.apache.hadoop.fs.Path;
>import org.apache.hadoop.io.Text;
>import org.apache.hadoop.mapreduce.Job;
>import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
>import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
>
>public class FlowsumDriver {
>
>	public static void main(String[] args) throws IllegalArgumentException, IOException, ClassNotFoundException, InterruptedException {
>
>		// 输入输出路径需要根据自己电脑上实际的输入输出路径设置
>		args = new String[]{"e:/output1","e:/output2"};
>
>		// 1 获取配置信息，或者job对象实例
>		Configuration configuration = new Configuration();
>		Job job = Job.getInstance(configuration);
>
>		// 2 指定本程序的jar包所在的本地路径
>		job.setJarByClass(FlowsumDriver.class);
>
>		// 3 指定本业务job要使用的mapper/Reducer业务类
>		job.setMapperClass(FlowCountMapper.class);
>		job.setReducerClass(FlowCountReducer.class);
>
>		// 4 指定mapper输出数据的kv类型
>		job.setMapOutputKeyClass(Text.class);
>		job.setMapOutputValueClass(FlowBean.class);
>
>		// 5 指定最终输出的数据的kv类型
>		job.setOutputKeyClass(Text.class);
>		job.setOutputValueClass(FlowBean.class);
>
>		// 8 指定自定义数据分区
>		job.setPartitionerClass(ProvincePartitioner.class);
>
>		// 9 同时指定相应数量的reduce task
>		job.setNumReduceTasks(5);
>		
>		// 6 指定job的输入原始文件所在目录
>		FileInputFormat.setInputPaths(job, new Path(args[0]));
>		FileOutputFormat.setOutputPath(job, new Path(args[1]));
>
>		// 7 将job中配置的相关参数，以及job所用的java类所在的jar包， 提交给yarn去运行
>		boolean result = job.waitForCompletion(true);
>		System.exit(result ? 0 : 1);
>	}
>}
>```

### 3.5 WritableComparable排序案例实操(全排序)

> **需求**
> 根据案例FlowCount产生的结果再次对总流量进行排序
> **输入数据**
>
> ```
> 1	13736230513	192.196.100.1	www.atguigu.com	2481	24681	200
> 2	13846544121	192.196.100.2			264	0	200
> 3 	13956435636	192.196.100.3			132	1512	200
> 4 	13966251146	192.168.100.1			240	0	404
> 5 	18271575951	192.168.100.2	www.atguigu.com	1527	2106	200
> 6 	84188413	192.168.100.3	www.atguigu.com	4116	1432	200
> 7 	13590439668	192.168.100.4			1116	954	200
> 8 	15910133277	192.168.100.5	www.hao123.com	3156	2936	200
> 9 	13729199489	192.168.100.6			240	0	200
> 10 	13630577991	192.168.100.7	www.shouhu.com	6960	690	200
> 11 	15043685818	192.168.100.8	www.baidu.com	3659	3538	200
> 12 	15959002129	192.168.100.9	www.atguigu.com	1938	180	500
> 13 	13560439638	192.168.100.10			918	4938	200
> 14 	13470253144	192.168.100.11			180	180	200
> 15 	13682846555	192.168.100.12	www.qq.com	1938	2910	200
> 16 	13992314666	192.168.100.13	www.gaga.com	3008	3720	200
> 17 	13509468723	192.168.100.14	www.qinghua.com	7335	110349	404
> 18 	18390173782	192.168.100.15	www.sogou.com	9531	2412	200
> 19 	13975057813	192.168.100.16	www.baidu.com	11058	48243	200
> 20 	13768778790	192.168.100.17			120	120	200
> 21 	13568436656	192.168.100.18	www.alibaba.com	2481	24681	200
> 22 	13568436656	192.168.100.19			1116	954	200
> ```
> **第一次输出的结果**
>
> ```
> part-r-00000
> ```
>
> **期望输出数据**
>
> ```
> 13509468723	7335	110349	117684
> 13736230513	2481	24681	27162
> 13956435636	132		1512	1644
> 13846544121	264		0		264
> ... ...
> ```

> **需求分析**
> FlowBean实现WritableComparable重写compareTo方法
>
> ```java
> @Override
> publci int compareTo(FlowBean o) {
>     //倒序排列，按照总流量从大到小
>     return this.sumFlow > o.getSumFlow() ? -1 : 1;
> }
> ```
>
> Redecer类
>
> ```java
> //循环输出，避免总流量相同的情况
> for (Text text : values) {
>     context.write(text,key);
> }
> ```
>
> Mapper类
>
> ```java
> context.write(bean,手机号);
> ```

> **代码实现**
> FlowBean对象在需求1基础上增加了比较功能
>
> ```java
> package com.atguigu.mapreduce.sort;
> import java.io.DataInput;
> import java.io.DataOutput;
> import java.io.IOException;
> import org.apache.hadoop.io.WritableComparable;
> 
> public class FlowBean implements WritableComparable<FlowBean> {
> 
> 	private long upFlow;
> 	private long downFlow;
> 	private long sumFlow;
> 
> 	// 反序列化时，需要反射调用空参构造函数，所以必须有
> 	public FlowBean() {
> 		super();
> 	}
> 
> 	public FlowBean(long upFlow, long downFlow) {
> 		super();
> 		this.upFlow = upFlow;
> 		this.downFlow = downFlow;
> 		this.sumFlow = upFlow + downFlow;
> 	}
> 
> 	public void set(long upFlow, long downFlow) {
> 		this.upFlow = upFlow;
> 		this.downFlow = downFlow;
> 		this.sumFlow = upFlow + downFlow;
> 	}
> 	public long getSumFlow() {
> 		return sumFlow;
> 	}
> 
> 	public void setSumFlow(long sumFlow) {
> 		this.sumFlow = sumFlow;
> 	}	
> 
> 	public long getUpFlow() {
> 		return upFlow;
> 	}
> 
> 	public void setUpFlow(long upFlow) {
> 		this.upFlow = upFlow;
> 	}
> 
> 	public long getDownFlow() {
> 		return downFlow;
> 	}
> 
> 	public void setDownFlow(long downFlow) {
> 		this.downFlow = downFlow;
> 	}
> 
> 	/**
> 	 * 序列化方法
> 	 * @param out
> 	 * @throws IOException
> 	 */
> 	@Override
> 	public void write(DataOutput out) throws IOException {
> 		out.writeLong(upFlow);
> 		out.writeLong(downFlow);
> 		out.writeLong(sumFlow);
> 	}
> 
> 	/**
> 	 * 反序列化方法 注意反序列化的顺序和序列化的顺序完全一致
> 	 * @param in
> 	 * @throws IOException
> 	 */
> 	@Override
> 	public void readFields(DataInput in) throws IOException {
> 		upFlow = in.readLong();
> 		downFlow = in.readLong();
> 		sumFlow = in.readLong();
> 	}
> 
> 	@Override
> 	public String toString() {
> 		return upFlow + "\t" + downFlow + "\t" + sumFlow;
> 	}
> 
> 	@Override
> 	public int compareTo(FlowBean bean) {
> 		
> 		int result;
> 		
> 		// 按照总流量大小，倒序排列
> 		if (sumFlow > bean.getSumFlow()) {
> 			result = -1;
> 		}else if (sumFlow < bean.getSumFlow()) {
> 			result = 1;
> 		}else {
> 			result = 0;
> 		}
> 
> 		return result;
> 	}
> }
> ```
>
> 编写Mapper类
>
> ```java
> package com.atguigu.mapreduce.sort;
> import java.io.IOException;
> import org.apache.hadoop.io.LongWritable;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Mapper;
> 
> public class FlowCountSortMapper extends Mapper<LongWritable, Text, FlowBean, Text>{
> 
> 	FlowBean bean = new FlowBean();
> 	Text v = new Text();
> 
> 	@Override
> 	protected void map(LongWritable key, Text value, Context context)	throws IOException, InterruptedException {
> 
> 		// 1 获取一行
> 		String line = value.toString();
> 		
> 		// 2 截取
> 		String[] fields = line.split("\t");
> 		
> 		// 3 封装对象
> 		String phoneNbr = fields[0];
> 		long upFlow = Long.parseLong(fields[1]);
> 		long downFlow = Long.parseLong(fields[2]);
> 		
> 		bean.set(upFlow, downFlow);
> 		v.set(phoneNbr);
> 		
> 		// 4 输出
> 		context.write(bean, v);
> 	}
> }
> ```
>
> 编写Reducer类
>
> ```java
> package com.atguigu.mapreduce.sort;
> import java.io.IOException;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Reducer;
> 
> public class FlowCountSortReducer extends Reducer<FlowBean, Text, Text, FlowBean>{
> 
> 	@Override
> 	protected void reduce(FlowBean key, Iterable<Text> values, Context context)	throws IOException, InterruptedException {
> 		
> 		// 循环输出，避免总流量相同情况
> 		for (Text text : values) {
> 			context.write(text, key);
> 		}
> 	}
> }
> ```
>
> 编写Driver类
>
> ```java
> package com.atguigu.mapreduce.sort;
> import java.io.IOException;
> import org.apache.hadoop.conf.Configuration;
> import org.apache.hadoop.fs.Path;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Job;
> import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
> import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
> 
> public class FlowCountSortDriver {
> 
> 	public static void main(String[] args) throws ClassNotFoundException, IOException, InterruptedException {
> 
> 		// 输入输出路径需要根据自己电脑上实际的输入输出路径设置
> 		args = new String[]{"e:/output1","e:/output2"};
> 
> 		// 1 获取配置信息，或者job对象实例
> 		Configuration configuration = new Configuration();
> 		Job job = Job.getInstance(configuration);
> 
> 		// 2 指定本程序的jar包所在的本地路径
> 		job.setJarByClass(FlowCountSortDriver.class);
> 
> 		// 3 指定本业务job要使用的mapper/Reducer业务类
> 		job.setMapperClass(FlowCountSortMapper.class);
> 		job.setReducerClass(FlowCountSortReducer.class);
> 
> 		// 4 指定mapper输出数据的kv类型
> 		job.setMapOutputKeyClass(FlowBean.class);
> 		job.setMapOutputValueClass(Text.class);
> 
> 		// 5 指定最终输出的数据的kv类型
> 		job.setOutputKeyClass(Text.class);
> 		job.setOutputValueClass(FlowBean.class);
> 
> 		// 6 指定job的输入原始文件所在目录
> 		FileInputFormat.setInputPaths(job, new Path(args[0]));
> 		FileOutputFormat.setOutputPath(job, new Path(args[1]));
> 		
> 		// 7 将job中配置的相关参数，以及job所用的java类所在的jar包， 提交给yarn去运行
> 		boolean result = job.waitForCompletion(true);
> 		System.exit(result ? 0 : 1);
> 	}
> }
> ```

### 3.6 WritableComparable排序案例实操(区内排序)

> **需求**
> 要求每个省份手机号输出的文件中按照总流量内部排序

> **需求分析**
> 基于前一个需求，增加自定义分区类，分区按照省份手机号设置
> **输入数据**
>
> ```
> 13509468723	7335	110349	117684
> 13975057813	11058	48243	59301
> 13568436656	3597	25635	29232
> 13736230513	2481	24681	27162
> 18390173782	9531	2412	11943
> 13630577991	6960	690	7650
> 15043685818	3659	3538	7197
> 13992314666	3008	3720	6728
> 15910133277	3156	2936	6092
> 13560439638	918	4938	5856
> 84188413	4116	1432	5548
> 13682846555	1938	2910	4848
> 18271575951	1527	2106	3633
> 15959002129	1938	180	2118
> 13590439668	1116	954	2070
> 13956435636	132	1512	1644
> 13470253144	180	180	360
> 13846544121	264	0	264
> 13966251146	240	0	240
> 13768778790	120	120	240
> 13729199489	240	0	240
> ... ...
> ```
>
> **期望输出**
>
> ```part-r-00000
> 13630577991	6960	690	7650
> 13682846555	1938	2910	4848
> ```
> ```part-r-00001
> 13736230513	2481	24681	27162
> 13768778790	120	120	240
> 13729199489	240	0	240
> ```
> ```part-r-00002
> 13846544121	264	0	264
> ```
> ```part-r-00003
> 13975057813	11058	48243	59301
> 13992314666	3008	3720	6728
> 13956435636	132	1512	1644
> 13966251146	240	0	240
> ```
> ```part-r-00004
> 13509468723	7335	110349	117684
> 13568436656	3597	25635	29232
> 18390173782	9531	2412	11943
> 15043685818	3659	3538	7197
> 15910133277	3156	2936	6092
> ... ...
> ```

> **案例实操**
> 增加自定义分区类，因为kv颠倒，所以不能直接使用上一个案例中的分区类
>
> ```java
> package com.atguigu.mapreduce.sort;
> import org.apache.hadoop.io.Text;
> import org.apache.hadoop.mapreduce.Partitioner;
> 
> public class ProvincePartitioner extends Partitioner<FlowBean, Text> {
> 
> 	@Override
> 	public int getPartition(FlowBean key, Text value, int numPartitions) {
> 		
> 		// 1 获取手机号码前三位
> 		String preNum = value.toString().substring(0, 3);
> 		
> 		int partition = 4;
> 		
> 		// 2 根据手机号归属地设置分区
> 		if ("136".equals(preNum)) {
> 			partition = 0;
> 		}else if ("137".equals(preNum)) {
> 			partition = 1;
> 		}else if ("138".equals(preNum)) {
> 			partition = 2;
> 		}else if ("139".equals(preNum)) {
> 			partition = 3;
> 		}
> 
> 		return partition;
> 	}
> }
> ```
>
> 在驱动类中增加分区类
>
> ```java
> // 加载自定义分区类
> job.setPartitionerClass(ProvincePartitioner.class);
> 
> // 设置Reducetask个数
> job.setNumReduceTasks(5);
> ```

### 3.7 Combiner合并

1. Combiner是MR程序中Mapper和Reducer之外的一种组件

2. Combiner组件的父类是Reducer

3. Combiner和Reducer的区别在于运行的位置
   Combiner是在每一个MapTask所在的运行节点
   Reducer是接收全局所有Mapper的输出结果

4. Combiner的意义就是对每一个MapTask的输出进行局部汇总，以减小网络传输量

5. Combiner能够应用的前提是不能影响最终的业务逻辑，而且Combiner输出kv应该跟Reducer的输入kv类型要对应起来

   ```
   
   ```

   

6. 自定义Combiner实现步骤

   > 自定义一个Combiner继承Reducer，重写Reduce方法
   >
   > ```java
   > public class WordcountCombiner extends Reducer<Text, IntWritable, Text,IntWritable>{
   > 
   > 	@Override
   > 	protected void reduce(Text key, Iterable<IntWritable> values,Context context) throws IOException, InterruptedException {
   > 
   >         // 1 汇总操作
   > 		int count = 0;
   > 		for(IntWritable v :values){
   > 			count += v.get();
   > 		}
   > 
   >         // 2 写出
   > 		context.write(key, new IntWritable(count));
   > 	}
   > }
   > ```
   >
   > 在Job驱动类中设置
   >
   > ```java
   > job.setCombinerClass(WordcountCombiner.class);
   > ```



### 3.8 Combiner合并案例实操

1. 需求
   统计过程中对每一个MapTask的输出进行局部汇总，以减小网络传输量即采用Combiner功能

   > 数据输入
   >
   > ```
   > banzhang ni hao
   > xihuan hadoop banzhang
   > banzhang ni hao
   > xihuan hadoop banzhang
   > ```

   > 期望输出
   >
   > Combine输出数据多，输出时经过合并，输出数据降低

2. 需求分析

   > 方案一
   > 增加一个WordCountCombiner类继承Reducer
   > 在WordCountCombiner中统计单词汇总，将统计结果输出

   > 方案二
   > 将WordCountReducer作为Combiner在WordCountDriver驱动类中指定
   >
   > ```java
   > job.setCombinerClass(WordCountReducer.class);
   > ```

3. 实操--方案一

   > 增加一个WordCountCombiner类继承Reducer
   >
   > ```java
   > package com.atguigu.mr.combiner;
   > import java.io.IOException;
   > import org.apache.hadoop.io.IntWritable;
   > import org.apache.hadoop.io.Text;
   > import org.apache.hadoop.mapreduce.Reducer;
   > 
   > public class WordcountCombiner extends Reducer<Text, IntWritable, Text, IntWritable>{
   > 
   > IntWritable v = new IntWritable();
   > 
   > 	@Override
   > 	protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
   > 
   >         // 1 汇总
   > 		int sum = 0;
   > 
   > 		for(IntWritable value :values){
   > 			sum += value.get();
   > 		}
   > 
   > 		v.set(sum);
   > 
   > 		// 2 写出
   > 		context.write(key, v);
   > 	}
   > }
   > ```

   > 在WordCountDriver驱动类中指定Combiner
   >
   > ```java
   > // 指定需要使用combiner，以及用哪个类作为combiner的逻辑
   > job.setCombinerClass(WordcountCombiner.class)
   > ```

4. 实操--方案二

   > 将WordCountReducer作为Combiner在WordCountDriver驱动类中指定
   >
   > ```java
   > // 指定需要使用Combiner，以及用哪个类作为Combiner的逻辑
   > job.setCombinerClass(WordcountReducer.class);
   > 
   > ```
   >
   > 运行程序比较使用Combiner前后的区别

### 3.9 GroupingComparator分组(辅助排序)

对Reduce阶段的数据根据某一个或者几个字段进行分组。
分组排序步骤:

1. 自定义类继承WritableComparator

2. 重写compare()方法

   ```java
   @Override
   public int compare(WritableComparable a, WritableComparable b) {
   		// 比较的业务逻辑
   		return result;
   }
   ```

3. 创建一个构造将比较对象的类传给父类

   ```java
   protected OrderGroupingComparator() {
   		super(OrderBean.class, true);
   }
   ```

### 3.10 GroupingComparator分组案例实操



1. 需求
   有如下订单数据
   
   | 订单id  | 商品id | 成交金额 |
   | ------- | ------ | -------- |
   | 0000001 | Pdt_01 | 222.8    |
   | Pdt_02  | 33.8   |          |
   | 0000002 | Pdt_03 | 522.8    |
   | Pdt_04  | 122.4  |          |
   | Pdt_05  | 722.4  |          |
   | 0000003 | Pdt_06 | 232.8    |
   | Pdt_02  | 33.8   |          |
   
   求出每一个订单中最贵的商品
   
   > 输入数据
   >
   > ```
   > 0000001	Pdt_01	222.8
   > 0000002	Pdt_05	722.4
   > 0000001	Pdt_02	33.8
   > 0000003	Pdt_06	232.8
   > 0000003	Pdt_02	33.8
   > 0000002	Pdt_03	522.8
   > 0000002	Pdt_04	122.4
   > ```
   
   > 期望输出数据
   >
   > ```
   > 1	222.8
   > 2	722.4
   > 3	232.8
   > ```

2. 需求分析
   利用“订单id和成交金额”作为key，可以将Map阶段读取到的所有订单数据按照id升序排序，如果id相同再按照金额降序排序，发送到Reduce。

   在Reduce端利用groupingComparator将订单id相同的kv聚合成组，然后取第一个即是该订单中最贵商品，

   > **MapTask**
   > Map中处理的事情
   >
   > ```
   > 获取一行
   > 切割出每个字段
   > 一行封装成bean对象
   > ```
   >
   > 二次排序
   >
   > ```
   > 先根据订单id排序
   > 如果订单id相同再根据价格降序排序
   > ```

   > **ReduceTask**
   > 辅助排序
   >
   > ```
   > 对Map端拉取过得数据再次进行排序，
   > 只要订单id相同就认为是相同的key
   > ```
   >
   > Reduce方法只把一组key的每一个写出去
   >
   > ```
   > 第一次调用reduce方法
   > 0000001
   > 22.8	33.8
   > 第二次调用reduce方法
   > 0000002
   > 722.4	522.8
   > 		222.8
   > 第三次调用reduce方法
   > 0000003
   > 232.8	33.8
   > ```

3. 代码实现

   > 定义订单信息类OrderBean类
   >
   > ```java
   > package com.atguigu.mapreduce.order;
   > import java.io.DataInput;
   > import java.io.DataOutput;
   > import java.io.IOException;
   > import org.apache.hadoop.io.WritableComparable;
   > 
   > public class OrderBean implements WritableComparable<OrderBean> {
   > 
   > 	private int order_id; // 订单id号
   > 	private double price; // 价格
   > 
   > 	public OrderBean() {
   > 		super();
   > 	}
   > 
   > 	public OrderBean(int order_id, double price) {
   > 		super();
   > 		this.order_id = order_id;
   > 		this.price = price;
   > 	}
   > 
   > 	@Override
   > 	public void write(DataOutput out) throws IOException {
   > 		out.writeInt(order_id);
   > 		out.writeDouble(price);
   > 	}
   > 
   > 	@Override
   > 	public void readFields(DataInput in) throws IOException {
   > 		order_id = in.readInt();
   > 		price = in.readDouble();
   > 	}
   > 
   > 	@Override
   > 	public String toString() {
   > 		return order_id + "\t" + price;
   > 	}
   > 
   > 	public int getOrder_id() {
   > 		return order_id;
   > 	}
   > 
   > 	public void setOrder_id(int order_id) {
   > 		this.order_id = order_id;
   > 	}
   > 
   > 	public double getPrice() {
   > 		return price;
   > 	}
   > 
   > 	public void setPrice(double price) {
   > 		this.price = price;
   > 	}
   > 
   > 	// 二次排序
   > 	@Override
   > 	public int compareTo(OrderBean o) {
   > 
   > 		int result;
   > 
   > 		if (order_id > o.getOrder_id()) {
   > 			result = 1;
   > 		} else if (order_id < o.getOrder_id()) {
   > 			result = -1;
   > 		} else {
   > 			// 价格倒序排序
   > 			result = price > o.getPrice() ? -1 : 1;
   > 		}
   > 
   > 		return result;
   > 	}
   > }
   > ```

   > 编写OrderSortMapper类
   >
   > ```java
   > package com.atguigu.mapreduce.order;
   > import java.io.IOException;
   > import org.apache.hadoop.io.LongWritable;
   > import org.apache.hadoop.io.NullWritable;
   > import org.apache.hadoop.io.Text;
   > import org.apache.hadoop.mapreduce.Mapper;
   > 
   > public class OrderMapper extends Mapper<LongWritable, Text, OrderBean, NullWritable> {
   > 
   > 	OrderBean k = new OrderBean();
   > 	
   > 	@Override
   > 	protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
   > 		
   > 		// 1 获取一行
   > 		String line = value.toString();
   > 		
   > 		// 2 截取
   > 		String[] fields = line.split("\t");
   > 		
   > 		// 3 封装对象
   > 		k.setOrder_id(Integer.parseInt(fields[0]));
   > 		k.setPrice(Double.parseDouble(fields[2]));
   > 		
   > 		// 4 写出
   > 		context.write(k, NullWritable.get());
   > 	}
   > }
   > ```

   > 编写OrderSortGroupingComparator类
   >
   > ```java
   > package com.atguigu.mapreduce.order;
   > import org.apache.hadoop.io.WritableComparable;
   > import org.apache.hadoop.io.WritableComparator;
   > 
   > public class OrderGroupingComparator extends WritableComparator {
   > 
   > 	protected OrderGroupingComparator() {
   >         //
   > 		super(OrderBean.class, true);
   > 	}
   > 
   > 	@Override
   > 	public int compare(WritableComparable a, WritableComparable b) {
   > 
   > 		OrderBean aBean = (OrderBean) a;
   > 		OrderBean bBean = (OrderBean) b;
   > 
   > 		int result;
   > 		if (aBean.getOrder_id() > bBean.getOrder_id()) {
   > 			result = 1;
   > 		} else if (aBean.getOrder_id() < bBean.getOrder_id()) {
   > 			result = -1;
   > 		} else {
   > 			result = 0;
   > 		}
   > 
   > 		return result;
   > 	}
   > }
> ```
   
   > 编写OrderSortReducer类
   >
   > ```java
   > package com.atguigu.mapreduce.order;
   > import java.io.IOException;
   > import org.apache.hadoop.io.NullWritable;
   > import org.apache.hadoop.mapreduce.Reducer;
   > 
   > public class OrderReducer extends Reducer<OrderBean, NullWritable, OrderBean, NullWritable> {
   > 
   > 	@Override
   > 	protected void reduce(OrderBean key, Iterable<NullWritable> values, Context context)		throws IOException, InterruptedException {
   > 		
   >      //没有迭代则会自动过滤重复数据，如果想要处理所有数据可使用foreach迭代
   > 		context.write(key, NullWritable.get());
   > 	}
   > }
   > ```
   
   > 编写OrderSortDriver类
   >
   > ```java
   > package com.atguigu.mapreduce.order;
   > import java.io.IOException;
   > import org.apache.hadoop.conf.Configuration;
   > import org.apache.hadoop.fs.Path;
   > import org.apache.hadoop.io.NullWritable;
   > import org.apache.hadoop.mapreduce.Job;
   > import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
   > import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
   > 
   > public class OrderDriver {
   > 
   > 	public static void main(String[] args) throws Exception, IOException {
   > 
   > // 输入输出路径需要根据自己电脑上实际的输入输出路径设置
   > 		args  = new String[]{"e:/input/inputorder" , "e:/output1"};
   > 
   > 		// 1 获取配置信息
   > 		Configuration conf = new Configuration();
   > 		Job job = Job.getInstance(conf);
   > 
   > 		// 2 设置jar包加载路径
   > 		job.setJarByClass(OrderDriver.class);
   > 
   > 		// 3 加载map/reduce类
   > 		job.setMapperClass(OrderMapper.class);
   > 		job.setReducerClass(OrderReducer.class);
   > 
   > 		// 4 设置map输出数据key和value类型
   > 		job.setMapOutputKeyClass(OrderBean.class);
   > 		job.setMapOutputValueClass(NullWritable.class);
   > 
   > 		// 5 设置最终输出数据的key和value类型
   > 		job.setOutputKeyClass(OrderBean.class);
   > 		job.setOutputValueClass(NullWritable.class);
   > 
   > 		// 6 设置输入数据和输出数据路径
   > 		FileInputFormat.setInputPaths(job, new Path(args[0]));
   > 		FileOutputFormat.setOutputPath(job, new Path(args[1]));
   > 
   > 		// 8 设置reduce端的分组
   > 	job.setGroupingComparatorClass(OrderGroupingComparator.class);
   > 
   > 		// 7 提交
   > 		boolean result = job.waitForCompletion(true);
   > 		System.exit(result ? 0 : 1);
   > 	}
   > }
   > ```

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
