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



![](img\MapReduce-workdetail-2.png)

## 3.Shuffle机制





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



* [ ] **MapReduce Job submit >> debug src**  ***视频3***
* [ ] **MapReduce >> FileInputFormat** ***视频 4 5***
* [ ] **MapReduce测试 @ 集群**
* [ ] **MapReduce >> NLineInputFormat实现类的理解**  ***视频***
* [ ] **MapReduce >> KeyValueTextInputFormat & NLineInputFormat使用案例**
* [ ] **MapReduce >> 自定义FileInputFormat** ***视频11*** *2019-7-23 15:58:32*
* [ ] **自定义InputFormat调试** ***视频***