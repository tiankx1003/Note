# TODO
* [ ] -
* [ ] 
* [ ] **配置Hive元数据到MySQL数据库** *2019-7-31 11:20:13*
* [ ] MySQL用户配置与远程登录连接 *2019-7-31 10:49:18*
* [ ] MySQL密码文件 *2019-7-31 10:44:47*
* [ ] 卸载旧MySQL *2019-7-31 10:42:25*
* [ ] 本地文件导入Hive案例 *2019-7-31 10:40:43*


# 一、入门

## 1.概念

Hive：由Facebook开源用于解决海量结构化日志的数据统计。
基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张表，并提供类SQL查询功能
本质：将HQL转化成MapReduce程序

## 2.优缺点

>**优点**
操作接口采用类SQL语法，提供快速开发的能力(简单、容易上手)
避免去写MapReduce，较少开发人员的学习成本
Hive的执行延迟比较高，因此Hive常用于数据分析，对实时性要求不高的场合
Hive优势在于处理大数据，对于小数据没有优势，因为Hive的执行延迟比较高
Hive支持用户自定义函数，用户可以根据自己的需求来实现自己的函数

>**缺点**
Hive的HQL的表达能力有限
    迭代式算法无法表达
    数据挖掘方面不擅长
Hive的效率比较低
    Hive**自动生成**的MapReduce作业，通常情况下不够**智能化**
    Hive调优困难，粒度很粗

## 3.架构原理

![Hive架构原理]()

1．用户接口：Client
CLI（hive shell）、JDBC/ODBC(java访问hive)、WEBUI（浏览器访问hive）
2．元数据：Metastore
元数据包括：表名、表所属的数据库（默认是default）、表的拥有者、列/分区字段、表的类型（是否是外部表）、表的数据所在目录等；
默认存储在自带的derby数据库中，推荐使用MySQL存储Metastore
3．Hadoop
使用HDFS进行存储，使用MapReduce进行计算。
4．驱动器：Driver
（1）解析器（SQL Parser）：将SQL字符串转换成抽象语法树AST，这一步一般都用第三方工具库完成，比如antlr；对AST进行语法分析，比如表是否存在、字段是否存在、SQL语义是否有误。
（2）编译器（Physical Plan）：将AST编译生成逻辑执行计划。
（3）优化器（Query Optimizer）：对逻辑执行计划进行优化。
（4）执行器（Execution）：把逻辑执行计划转换成可以运行的物理计划。对于Hive来说，就是MR/Spark。

![Hive运行机制]()

Hive通过给用户提供的一系列交互接口，接收到用户的指令(SQL)，使用自己的Driver，结合元数据(MetaStore)，将这些指令翻译成MapReduce，提交到Hadoop中执行，最后，将执行返回的结果输出到用户交互接口。

## 4.Hive和数据库比较

由于 Hive 采用了类似SQL 的查询语言 HQL(Hive Query Language)，因此很容易将 Hive 理解为数据库。其实从结构上来看，Hive 和数据库除了拥有类似的查询语言，再无类似之处。本文将从多个方面来阐述 Hive 和数据库的差异。数据库可以用在 Online 的应用中，但是Hive 是为数据仓库而设计的，清楚这一点，有助于从应用角度理解 Hive 的特性。

### 4.1 查询语言

由于SQL被广泛的应用在数据仓库中，因此，专门针对Hive的特性设计了类SQL的查询语言HQL。熟悉SQL开发的开发者可以很方便的使用Hive进行开发。

### 4.2 数据存储位置

Hive 是建立在 Hadoop 之上的，所有 Hive 的数据都是存储在 HDFS 中的。而数据库则可以将数据保存在块设备或者本地文件系统中。

### 4.3 数据更新

由于Hive是针对数据仓库应用设计的，而数据仓库的内容是读多写少的。因此，Hive中不建议对数据的改写，所有的数据都是在加载的时候确定好的。而数据库中的数据通常是需要经常进行修改的，因此可以使用 INSERT INTO …  VALUES 添加数据，使用 UPDATE … SET修改数据。

### 4.4 索引

Hive在加载数据的过程中不会对数据进行任何处理，甚至不会对数据进行扫描，因此也没有对数据中的某些Key建立索引。Hive要访问数据中满足条件的特定值时，需要暴力扫描整个数据，因此访问延迟较高。由于 MapReduce 的引入， Hive 可以并行访问数据，因此即使没有索引，对于大数据量的访问，Hive 仍然可以体现出优势。数据库中，通常会针对一个或者几个列建立索引，因此对于少量的特定条件的数据的访问，数据库可以有很高的效率，较低的延迟。由于数据的访问延迟较高，决定了 Hive 不适合在线数据查询。

### 4.5 执行

Hive中大多数查询的执行是通过 Hadoop 提供的 MapReduce 来实现的。而数据库通常有自己的执行引擎。

### 4.6 执行延迟

Hive 在查询数据的时候，由于没有索引，需要扫描整个表，因此延迟较高。另外一个导致 Hive 执行延迟高的因素是 MapReduce框架。由于MapReduce 本身具有较高的延迟，因此在利用MapReduce 执行Hive查询时，也会有较高的延迟。相对的，数据库的执行延迟较低。当然，这个低是有条件的，即数据规模较小，当数据规模大到超过数据库的处理能力的时候，Hive的并行计算显然能体现出优势。

### 4.7 可扩展性

由于Hive是建立在Hadoop之上的，因此Hive的可扩展性是和Hadoop的可扩展性是一致的（世界上最大的Hadoop 集群在 Yahoo!，2009年的规模在4000 台节点左右）。而数据库由于 ACID 语义的严格限制，扩展行非常有限。目前最先进的并行数据库 Oracle 在理论上的扩展能力也只有100台左右。

### 4.8 数据规模

由于Hive建立在集群上并可以利用MapReduce进行并行计算，因此可以支持很大规模的数据；对应的，数据库可以支持的数据规模较小。

# 二、安装

## 1.安装地址

[Hive官网地址](http://hive.apache.org/)
[文档查看地址](https://cwiki.apache.org/confluence/display/Hive/GettingStarted)
[下载地址](http://archive.apache.org/dist/hive/)
[github地址](https://github.com/apache/hive)

## 2.安装部署

```bash
1．Hive安装及配置
（1）把apache-hive-1.2.1-bin.tar.gz上传到linux的/opt/software目录下
（2）解压apache-hive-1.2.1-bin.tar.gz到/opt/module/目录下面
[atguigu@hadoop102 software]$ tar -zxvf apache-hive-1.2.1-bin.tar.gz -C /opt/module/
（3）修改apache-hive-1.2.1-bin.tar.gz的名称为hive
[atguigu@hadoop102 module]$ mv apache-hive-1.2.1-bin/ hive
（4）修改/opt/module/hive/conf目录下的hive-env.sh.template名称为hive-env.sh
[atguigu@hadoop102 conf]$ mv hive-env.sh.template hive-env.sh
	（5）配置hive-env.sh文件
	（a）配置HADOOP_HOME路径
export HADOOP_HOME=/opt/module/hadoop-2.7.2
	（b）配置HIVE_CONF_DIR路径
export HIVE_CONF_DIR=/opt/module/hive/conf
2．Hadoop集群配置
（1）必须启动hdfs和yarn
sbin/start-dfs.sh
[atguigu@hadoop103 hadoop-2.7.2]$ sbin/start-yarn.sh
（2）在HDFS上创建/tmp和/user/hive/warehouse两个目录并修改他们的同组权限可写
bin/hadoop fs -mkdir /tmp
bin/hadoop fs -mkdir -p /user/hive/warehouse

bin/hadoop fs -chmod g+w /tmp
bin/hadoop fs -chmod g+w /user/hive/warehouse
3．Hive基本操作
（1）启动hive
[atguigu@hadoop102 hive]$ bin/hive
（2）查看数据库
hive> show databases;
（3）打开默认数据库
hive> use default;
（4）显示default数据库中的表
hive> show tables;
（5）创建一张表
hive> create table student(id int, name string);
（6）显示数据库中有几张表
hive> show tables;
（7）查看表的结构
hive> desc student;
（8）向表中插入数据
hive> insert into student values(1000,"ss");
（9）查询表中数据
hive> select * from student;
（10）退出hive
hive> quit;
```

## 3.本地文件导入Hive案例

需求
将本地/opt/module/datas/student.txt这个目录下的数据导入到hive的student(id int, name string)表中。
1．数据准备
在/opt/module/datas这个目录下准备数据
（1）在/opt/module/目录下创建datas
[atguigu@hadoop102 module]$ mkdir datas
（2）在/opt/module/datas/目录下创建student.txt文件并添加数据
[atguigu@hadoop102 datas]$ touch student.txt
[atguigu@hadoop102 datas]$ vi student.txt
1001	zhangshan
1002	lishi
1003	zhaoliu
注意以tab键间隔。
2．Hive实际操作
（1）启动hive
[atguigu@hadoop102 hive]$ bin/hive
（2）显示数据库
hive> show databases;
（3）使用default数据库
hive> use default;
（4）显示default数据库中的表
hive> show tables;
（5）删除已创建的student表
hive> drop table student;
（6）创建student表, 并声明文件分隔符’\t’
hive> create table student(id int, name string) ROW FORMAT DELIMITED FIELDS TERMINATED
 BY '\t';
（7）加载/opt/module/datas/student.txt 文件到student数据库表中。
hive> load data local inpath '/opt/module/datas/student.txt' into table student;
（8）Hive查询结果
hive> select * from student;
OK
1001	zhangshan
1002	lishi
1003	zhaoliu
Time taken: 0.266 seconds, Fetched: 3 row(s)
3．遇到的问题
再打开一个客户端窗口启动hive，会产生java.sql.SQLException异常。
Exception in thread "main" java.lang.RuntimeException: java.lang.RuntimeException:
 Unable to instantiate
 org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient
        at org.apache.hadoop.hive.ql.session.SessionState.start(SessionState.java:522)
        at org.apache.hadoop.hive.cli.CliDriver.run(CliDriver.java:677)
        at org.apache.hadoop.hive.cli.CliDriver.main(CliDriver.java:621)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:606)
        at org.apache.hadoop.util.RunJar.run(RunJar.java:221)
        at org.apache.hadoop.util.RunJar.main(RunJar.java:136)
Caused by: java.lang.RuntimeException: Unable to instantiate org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient
        at org.apache.hadoop.hive.metastore.MetaStoreUtils.newInstance(MetaStoreUtils.java:1523)
        at org.apache.hadoop.hive.metastore.RetryingMetaStoreClient.<init>(RetryingMetaStoreClient.java:86)
        at org.apache.hadoop.hive.metastore.RetryingMetaStoreClient.getProxy(RetryingMetaStoreClient.java:132)
        at org.apache.hadoop.hive.metastore.RetryingMetaStoreClient.getProxy(RetryingMetaStoreClient.java:104)
        at org.apache.hadoop.hive.ql.metadata.Hive.createMetaStoreClient(Hive.java:3005)
        at org.apache.hadoop.hive.ql.metadata.Hive.getMSC(Hive.java:3024)
        at org.apache.hadoop.hive.ql.session.SessionState.start(SessionState.java:503)
... 8 more
原因是，Metastore默认存储在自带的derby数据库中，推荐使用MySQL存储Metastore;

## 4.安装配置MySQL

```bash
## 查看
rpm -qa|grep mysql
#mysql-libs-5.1.73-7.el6.x86_64



## 卸载
rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64

## 安装MySQL server
rpm -ivh MySQL-server-5.6.24-1.el6.x86_64.rpm
# 查看随机产生的密码
cat /root/.mysql_secret
#OEXaQuS8IWkG19Xs
#查看MySQL状态
service mysql status
#启动MySQL
service mysql start

## 安装MySQL client

## MySQL在user表中主机配置

```

```sql
## MySQL在user表中主机配置



```

## 5.Hive元数据配置到MySQL

## 6.HiveJDBC访问

## 7.Hive常用交互命令

## 8.Hive其他命令操作

## 9.Hive常用属性配置


# 三、数据类型

## 1.基本数据类型

| Hive数据类型 | Java数据类型 | 长度                                                 | 例子                                 |
| :----------: | :----------: | :--------------------------------------------------- | :----------------------------------- |
|   TINYINT    |     byte     | 1byte有符号整数                                      | 20                                   |
|   SMALINT    |    short     | 2byte有符号整数                                      | 20                                   |
|     INT      |     int      | 4byte有符号整数                                      | 20                                   |
|    BIGINT    |     long     | 8byte有符号整数                                      | 20                                   |
|   BOOLEAN    |   boolean    | 布尔类型，true或者false                              | TRUE  FALSE                          |
|    FLOAT     |    float     | 单精度浮点数                                         | 3.14159                              |
|    DOUBLE    |    double    | 双精度浮点数                                         | 3.14159                              |
|    STRING    |    string    | 字符系列。可以指定字符集。可以使用单引号或者双引号。 | ‘now is the time’ “for all good men” |
|  TIMESTAMP   |              | 时间类型                                             |                                      |
|    BINARY    |              | 字节数组                                             |                                      |


# 四、DDL数据定义


# 五、DML数据操作



# 六、查询


# 七、函数


# 八、压缩和存储


# 九、企业调优


# 十、Hive实战


# 常见错误及解决方案