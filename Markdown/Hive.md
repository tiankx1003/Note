# TODO
* [ ] -
* [ ] 小表、大表join *2019-8-5 11:49:07*
* [ ] *hive中文字符编码问题  *2019-8-5 11:49:29*
* [ ] hive自定义函数java函数命名限制 *2019-8-5 09:20:24*
* [ ] hive常用函数(日期，字符串，集合) *2019-8-3 16:54:19*
* [ ] Maven工程文件在eclipse中打jar包 *2019-8-3 16:54:25*
* [ ] 列转行  视频09*2019-8-3 11:38:10*
* [ ] Distributed By分区个数和reducer个数的设置 *2019-8-2 16:44:49*
* [ ] sort by 多个Reducer 数据随机存入多个文件 *2019-8-2 16:33:34*
* [ ] 多表连接和笛卡尔积 *2019-8-2 16:01:35*
* [ ] 分组字段问题 *2019-8-2 15:34:02*
* [ ] import数据到指定hive表 *2019-8-2 14:22:49*
* [ ] 数据上传到分区目录，让分区表和数据产生关联的方式 *2019-8-2 10:26:29*
* [ ] Hive分区表实操 *2019-8-2 09:35:11*
* [ ] hive cli窗口查看本地文件系统 *2019-8-2 09:12:01*
* [ ] hive cli窗口查看hdfs文件系统 *2019-8-2 09:11:02*
* [x] **配置Hive元数据到MySQL数据库** *2019-7-31 11:20:13*
* [ ] MySQL用户配置与远程登录连接 *2019-7-31 10:49:18*
* [x] MySQL密码文件 *2019-7-31 10:44:47*
* [x] 卸载旧MySQL *2019-7-31 10:42:25*
* [x] 本地文件导入Hive案例 *2019-7-31 10:40:43*


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

![Hive架构原理](E:\Git\Note\Markdown\img\hive-stru.png)

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

![Hive运行机制](E:\Git\Note\Markdown\img\hive-run.png)

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
# 1．Hive安装及配置
# （1）把apache-hive-1.2.1-bin.tar.gz上传到linux的/opt/software目录下
# （2）解压apache-hive-1.2.1-bin.tar.gz到/opt/module/目录下面
tar -zxvf apache-hive-1.2.1-bin.tar.gz -C /opt/module/
# （3）修改apache-hive-1.2.1-bin.tar.gz的名称为hive
mv apache-hive-1.2.1-bin/ hive
# （4）修改/opt/module/hive/conf目录下的hive-env.sh.template名称为hive-env.sh
mv hive-env.sh.template hive-env.sh
	# （5）配置hive-env.sh文件
	# （a）配置HADOOP_HOME路径
# export HADOOP_HOME=/opt/module/hadoop-2.7.2
# 	（b）配置HIVE_CONF_DIR路径
# export HIVE_CONF_DIR=/opt/module/hive/conf
# 2．Hadoop集群配置
# （1）必须启动hdfs和yarn
sbin/start-dfs.sh
sbin/start-yarn.sh
# （2）在HDFS上创建/tmp和/user/hive/warehouse两个目录并修改他们的同组权限可写
bin/hadoop fs -mkdir /tmp
bin/hadoop fs -mkdir -p /user/hive/warehouse

bin/hadoop fs -chmod g+w /tmp
bin/hadoop fs -chmod g+w /user/hive/warehouse
```

```mysql
# 3．Hive基本操作
# （1）启动hive
# bin/hive
# （2）查看数据库
show databases;
# （3）打开默认数据库
use default;
# （4）显示default数据库中的表
show tables;
# （5）创建一张表
create table student(id int, name string);
# （6）显示数据库中有几张表
show tables;
# （7）查看表的结构
desc student;
# （8）向表中插入数据
insert into student values(1000,"ss");
# （9）查询表中数据
select * from student;
# （10）退出hive
quit;
```

## 3.本地文件导入Hive案例

> **需求**
> 将本地/opt/module/datas/student.txt这个目录下的数据导入到hive的student(id int, name string)表中。

> **数据准备**
> 在/opt/module/datas这个目录下准备数据
> （1）在/opt/module/目录下创建datas
> mkdir datas
> （2）在/opt/module/datas/目录下创建student.txt文件并添加数据
> touch student.txt
> vi student.txt
> 1001	zhangshan
> 1002	lishi
> 1003	zhaoliu
> 注意以tab键间隔。

> Hive实际操作
>
> ```mysql
> # （1）启动hive
> bin/hive
> # （2）显示数据库
> show databases;
> # （3）使用default数据库
> use default;
> # （4）显示default数据库中的表
> show tables;
> # （5）删除已创建的student表
> drop table student;
> （6）创建student表, 并声明文件分隔符’\t’
> create table student(id int, name string) ROW FORMAT DELIMITED FIELDS TERMINATED
>  BY '\t';
> # （7）加载/opt/module/datas/student.txt 文件到student数据库表中。
> load data local inpath '/opt/module/datas/student.txt' into table student;
> # （8）Hive查询结果
> select * from student;
> # OK
> # 1001	zhangshan
> # 1002	lishi
> # 1003	zhaoliu
> # Time taken: 0.266 seconds, Fetched: 3 row(s)
> ```

>**遇到的问题**
>再打开一个客户端窗口启动hive，会产生java.sql.SQLException异常。
>
>```
>Exception in thread "main" java.lang.RuntimeException: java.lang.RuntimeException:
> Unable to instantiate
> org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient
>        at org.apache.hadoop.hive.ql.session.SessionState.start(SessionState.java:522)
>        at org.apache.hadoop.hive.cli.CliDriver.run(CliDriver.java:677)
>        at org.apache.hadoop.hive.cli.CliDriver.main(CliDriver.java:621)
>        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
>        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
>        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
>        at java.lang.reflect.Method.invoke(Method.java:606)
>        at org.apache.hadoop.util.RunJar.run(RunJar.java:221)
>        at org.apache.hadoop.util.RunJar.main(RunJar.java:136)
>Caused by: java.lang.RuntimeException: Unable to instantiate org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient
>        at org.apache.hadoop.hive.metastore.MetaStoreUtils.newInstance(MetaStoreUtils.java:1523)
>        at org.apache.hadoop.hive.metastore.RetryingMetaStoreClient.<init>(RetryingMetaStoreClient.java:86)
>        at org.apache.hadoop.hive.metastore.RetryingMetaStoreClient.getProxy(RetryingMetaStoreClient.java:132)
>        at org.apache.hadoop.hive.metastore.RetryingMetaStoreClient.getProxy(RetryingMetaStoreClient.java:104)
>        at org.apache.hadoop.hive.ql.metadata.Hive.createMetaStoreClient(Hive.java:3005)
>        at org.apache.hadoop.hive.ql.metadata.Hive.getMSC(Hive.java:3024)
>        at org.apache.hadoop.hive.ql.session.SessionState.start(SessionState.java:503)
>... 8 more
>```
> **原因**是，Metastore默认存储在自带的derby数据库中，推荐使用MySQL存储Metastore;

## 4.安装配置MySQL

```bash
## 查看
rpm -qa|grep -i mysql
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
rpm -ivh MySQL-client-5.6.24-1.el6.x86_64.rpm
# 连接MySQL
mysql -uroot -pOEXaQuS8IWkG19Xs
```

```mysql
# 修改密码
SET PASSWORD=PASSWORD('root');
## MySQL在user表中主机配置
show databases;
use mysql;
show tables;
desc user;
select User, Host, Password from user;
# 修改user表，把Host表内容修改为%
update user set host='%' where host='localhost'
# 删除root中的其他账户
delete from user where Host='hadoop102';
delete from user where Host='127.0.0.1';
delete from user where Host='::1';
# 刷新
flush privileges;
\q;
```

## 5.Hive元数据配置到MySQL

### 5.1 拷贝驱动
```bash
tar -zxvf mysql-connector-java-5.1.27.tar.gz
cp mysql-connector-java-5.1.27-bin.jar /opt/module/hive/lib/
```

### 5.2 配置Metastore到MySQL

/opt/module/hive/conf目录下创建一个hive-site.xml
```bash
touch hive-site.xml
vi hive-site.xml
```

根据官方文档配置参数
[官方文档参数](https://cwiki.apache.org/confluence/display/Hive/AdminManual+MetastoreAdmin)
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop101:3306/metastore?createDatabaseIfNotExist=true</value>
        <description>JDBC connect string for a JDBC metastore</description>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
        <description>Driver class name for a JDBC metastore</description>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
        <description>username to use against metastore database</description>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>root</value>
        <description>password to use against metastore database</description>
    </property>
</configuration>
```
配置完毕后，如果启动hive异常，可以重新启动虚拟机。（重启后，别忘了启动hadoop集群）

### 5.3 多窗口启动Hive测试

```bash
# 先启动MySQL并查看几个数据库
 mysql -uroot -proot
```

```mysql
show databases;
```
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
```
```bash
# 在多个窗口中启动hive，查看数据库
hive
```
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| metastore          |
| mysql              |
| performance_schema |
| test               |
+--------------------+
```


## 6.HiveJDBC访问

**启动hiveserver2服务**
```bash
bin/hiveserver2
```
**启动beeline**
```bash
bin/beeline
# Beeline version 1.2.1 by Apache Hive
# beeline>
```
**连接hiveserver2**
```
beeline> !connect jdbc:hive2://hadoop101:10000（回车）
Connecting to jdbc:hive2://hadoop102:10000
Enter username for jdbc:hive2://hadoop102:10000: tian（回车）
Enter password for jdbc:hive2://hadoop102:10000: （直接回车）
Connected to: Apache Hive (version 1.2.1)
Driver: Hive JDBC (version 1.2.1)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://hadoop102:10000> show databases;
+----------------+--+
| database_name  |
+----------------+--+
| default        |
| hive_db2       |
+----------------+--+
```


## 7.Hive常用交互命令

```bash
bin/hive -help
# usage: hive
#  -d,--define <key=value>          Variable subsitution to apply to hive
#                                   commands. e.g. -d A=B or --define A=B
#     --database <databasename>     Specify the database to use
#  -e <quoted-query-string>         SQL from command line
#  -f <filename>                    SQL from files
#  -H,--help                        Print help information
#     --hiveconf <property=value>   Use value for given property
#     --hivevar <key=value>         Variable subsitution to apply to hive
#                                   commands. e.g. --hivevar A=B
#  -i <filename>                    Initialization SQL file
#  -S,--silent                      Silent mode in interactive shell
#  -v,--verbose                     Verbose mode (echo executed SQL to the console)
```
```bash
# 1．“-e”不进入hive的交互窗口执行sql语句
bin/hive -e "select id from student;"
# 2．“-f”执行脚本中sql语句
	# （1）在/opt/module/datas目录下创建hivef.sql文件
touch hivef.sql
		# 文件中写入正确的sql语句
		# select *from student;
	# （2）执行文件中的sql语句
bin/hive -f /opt/module/datas/hivef.sql
    # （3）执行文件中的sql语句并将结果写入文件中
bin/hive -f /opt/module/datas/hivef.sql  > /opt/module/datas/hive_result.txt
```

## 8.Hive其他命令操作

1．退出hive窗口：
```
hive(default)>exit;
hive(default)>quit;
```
在新版的hive中没区别了，在以前的版本是有的：
exit:先隐性提交数据，再退出；
quit:不提交数据，退出；

2．在hive cli命令窗口中如何查看hdfs文件系统

```
hive(default)>dfs -ls /;
```

3．在hive cli命令窗口中如何查看本地文件系统
```
hive(default)>! ls /opt/module/datas;
```
4．查看在hive中输入的所有历史命令
```bash 
# （1）进入到当前用户的根目录/root或/home/tian
# （2）查看. hivehistory文件
cat .hivehistory
```

## 9.Hive常用属性配置

### 9.1 Hive数据仓库位置配置

1）Default数据仓库的最原始位置是在hdfs上的：/user/hive/warehouse路径下。
	2）在仓库目录下，没有对默认的数据库default创建文件夹。如果某张表属于default数据库，直接在数据仓库目录下创建一个文件夹。
	3）修改default数据仓库原始位置（将hive-default.xml.template如下配置信息拷贝到hive-site.xml文件中）。
```xml
<property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/user/hive/warehouse</value>
    <description>location of default database for the warehouse</description>
</property>
```
配置同组用户有执行权限
```bash
bin/hdfs dfs -chmod g+w /user/hive/warehouse
```

### 9.2 查询后信息显示配置

1）在hive-site.xml文件中添加如下配置信息，就可以实现显示当前数据库，以及查询表的头信息配置。
```xml
<property>
<name>hive.cli.print.header</name>
<value>true</value>
</property>

<property>
<name>hive.cli.print.current.db</name>
<value>true</value>
</property>
```
2）重新启动hive，对比配置前后差异。



### 9.3 Hive运行日志信息配置

1．Hive的log默认存放在/tmp/tian/hive.log目录下（当前用户名下）
2．修改hive的log存放日志到/opt/module/hive/logs
```bash
# （1）修改/opt/module/hive/conf/hive-log4j.properties.template文件名称为hive-log4j.properties
pwd
# /opt/module/hive/conf
mv hive-log4j.properties.template hive-log4j.properties
# （2）在hive-log4j.properties文件中修改log存放位置
# hive.log.dir=/opt/module/hive/logs
```

### 9.4 参数配置方式

1．查看当前所有的配置信息
```mysql
set;
```
2．参数的配置三种方式
（1）配置文件方式
默认配置文件：hive-default.xml 
用户自定义配置文件：hive-site.xml
注意：用户自定义配置会覆盖默认配置。另外，Hive也会读入Hadoop的配置，因为Hive是作为Hadoop的客户端启动的，Hive的配置会覆盖Hadoop的配置。配置文件的设定对本机启动的所有Hive进程都有效。
（2）命令行参数方式
启动Hive时，可以在命令行添加-hiveconf param=value来设定参数。
例如：
```bash
bin/hive -hiveconf mapred.reduce.tasks=10;
```
注意：仅对本次hive启动有效
查看参数设置：
```mysql
hive (default)> set mapred.reduce.tasks;
```
（3）参数声明方式
可以在HQL中使用SET关键字设定参数
例如：
hive (default)> set mapred.reduce.tasks=100;
注意：仅对本次hive启动有效。
查看参数设置
hive (default)> set mapred.reduce.tasks;
上述三种设定方式的优先级依次递增。即配置文件<命令行参数<参数声明。注意某些系统级的参数，例如log4j相关的设定，必须用前两种方式设定，因为那些参数的读取在会话建立以前已经完成了。


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

对于Hive的String类型相当于数据库的varchar类型，该类型是一个可变的字符串，不过它不能声明其中最多能存储多少个字符，理论上它可以存储2GB的字符数。

## 2.集合数据类型

| 数据类型 | 描述                                                                                                                                                                              | 语法示例 |
| :------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------- |
| STRUCT   | 和c语言中的struct类似，都可以通过“点”符号访问元素内容。例如，如果某个列的数据类型是STRUCT{first STRING, last STRING},那么第1个元素可以通过字段.first来引用。                      | struct() |
| MAP      | MAP是一组键-值对元组集合，使用数组表示法可以访问数据。例如，如果某个列的数据类型是MAP，其中键->值对是’first’->’John’和’last’->’Doe’，那么可以通过字段名[‘last’]获取最后一个元素   | map()    |
| ARRAY    | 数组是一组具有相同类型和名称的变量的集合。这些变量称为数组的元素，每个数组元素都有一个编号，编号从零开始。例如，数组值为[‘John’, ‘Doe’]，那么第2个元素可以通过数组名[1]进行引用。 | Array()  |

Hive有三种复杂数据类型ARRAY、MAP 和 STRUCT。ARRAY和MAP与Java中的Array和Map类似，而STRUCT与C语言中的Struct类似，它封装了一个命名字段集合，复杂数据类型允许任意层次的嵌套。


**案例实操**

1）	假设某表有如下一行，我们用JSON格式来表示其数据结构。在Hive下访问的格式为
```json
{
    "name": "songsong",
    "friends": ["bingbing" , "lili"] ,       //列表Array, 
    "children": {                      //键值Map,
        "xiao song": 18 ,
        "xiaoxiao song": 19
    }
    "address": {                      //结构Struct,
        "street": "hui long guan" ,
        "city": "beijing" 
    }
}
```
2）基于上述数据结构，我们在Hive里创建对应的表，并导入数据。 
创建本地测试文件test.txt
```
songsong,bingbing_lili,xiao song:18_xiaoxiao song:19,hui long guan_beijing
yangyang,caicai_susu,xiao yang:18_xiaoxiao yang:19,chao yang_beijing
```
注意：MAP，STRUCT和ARRAY里的元素间关系都可以用同一个字符表示，这里用“_”。

3）Hive上创建测试表test
```mysql
create table test(
name string,
friends array<string>,
children map<string, int>,
address struct<street:string, city:string>
)
row format delimited fields terminated by ','
collection items terminated by '_'
map keys terminated by ':'
lines terminated by '\n';
```
字段解释：
row format delimited fields terminated by ','  -- 列分隔符
collection items terminated by '_'  	--MAP STRUCT 和 ARRAY 的分隔符(数据分割符号)
map keys terminated by ':'				-- MAP中的key与value的分隔符
lines terminated by '\n';					-- 行分隔符

4）导入文本数据到测试表
```mysql
load data local inpath ‘/opt/module/datas/test.txt’into table test
```

5）访问三种集合列里的数据，以下分别是ARRAY，MAP，STRUCT的访问方式
```mysql
select friends[1],children['xiao song'],address.city from test
where name="songsong";
# OK
# _c0     _c1     city
# lili    18      beijing
# Time taken: 0.076 seconds, Fetched: 1 row(s)
```

## 3.类型转化

Hive的原子数据类型是可以进行隐式转换的，类似于Java的类型转换，例如某表达式使用INT类型，TINYINT会自动转换为INT类型，但是Hive不会进行反向转化，例如，某表达式使用TINYINT类型，INT不会自动转换为TINYINT类型，它会返回错误，除非使用CAST操作。
1．隐式类型转换规则如下
（1）任何整数类型都可以隐式地转换为一个范围更广的类型，如TINYINT可以转换成INT，INT可以转换成BIGINT。
（2）所有整数类型、FLOAT和STRING类型都可以隐式地转换成DOUBLE。
（3）TINYINT、SMALLINT、INT都可以转换为FLOAT。
（4）BOOLEAN类型不可以转换为任何其它的类型。
2．可以使用CAST操作显示进行数据类型转换
例如CAST('1' AS INT)将把字符串'1' 转换成整数1；如果强制类型转换失败，如执行CAST('X' AS INT)，表达式返回空值 NULL。

# 四、DDL数据定义

## 1.数据库定义

1）创建一个数据库，数据库在HDFS上的默认存储路径是/user/hive/warehouse/*.db。
```mysql
hive (default)> create database db_hive;
```
2）避免要创建的数据库已经存在错误，增加if not exists判断。（标准写法）
```mysql
hive (default)> create database db_hive;
/* FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. Database db_hive already exists */
hive (default)> create database if not exists db_hive;
```
3）创建一个数据库，指定数据库在HDFS上存放的位置
```mysql
hive (default)> create database db_hive2 location '/db_hive2.db';
```

## 2.查询数据库

```mysql
# 显示数据库
hive> show databases;
# 过滤显示查询的数据库
hive> show databases like 'db_hive*';
# OK
# db_hive
# db_hive_1
# 显示数据库信息
hive> desc database db_hive;
# OK
# db_hive		hdfs://hadoop102:9000/user/hive/warehouse/db_hive.db	atguiguUSER	
# 显示数据库详细信息，extended
hive> desc database extended db_hive;
# OK
# db_hive		hdfs://hadoop102:9000/user/hive/warehouse/db_hive.db	atguiguUSER	
# 切换当前数据库
hive (default)> use db_hive;
# 切换当前数据库
hive (default)> use db_hive;
```

## 3.修改数据库

用户可以使用ALTER DATABASE命令为某个数据库的DBPROPERTIES设置键-值对属性值，来描述这个数据库的属性信息。数据库的其他元数据信息都是不可更改的，包括数据库名和数据库所在的目录位置。
```mysql
hive (default)> alter database db_hive set dbproperties('createtime'='20170830');
# 在hive中查看修改结果
hive> desc database extended db_hive;
# db_name comment location        owner_name      owner_type      parameters
# db_hive         hdfs://hadoop102:8020/user/hive/warehouse/db_hive.db    atguigu USER    {createtime=20170830}
```

## 4.删除数据库

```mysql
# 1．删除空数据库
hive>drop database db_hive2;
# 2．如果删除的数据库不存在，最好采用 if exists判断数据库是否存在
hive> drop database db_hive;
# FAILED: SemanticException [Error 10072]: Database does not exist: db_hive
hive> drop database if exists db_hive2;
# 3．如果数据库不为空，可以采用cascade命令，强制删除
hive> drop database db_hive;
# FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. InvalidOperationException(message:Database db_hive is not empty. One or more tables exist.)
hive> drop database db_hive cascade;
```

## 5.创建表

**建表语法**

```mysql
CREATE [EXTERNAL] TABLE [IF NOT EXISTS] table_name 
[(col_name data_type [COMMENT col_comment], ...)] 
[COMMENT table_comment] 
[PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)] 
[CLUSTERED BY (col_name, col_name, ...) 
[SORTED BY (col_name [ASC|DESC], ...)] INTO num_buckets BUCKETS] 
[ROW FORMAT row_format] 
[STORED AS file_format] 
[LOCATION hdfs_path]
```
>**字段说明**
（1）CREATE TABLE 创建一个指定名字的表。如果相同名字的表已经存在，则抛出异常；用户可以用 IF NOT EXISTS 选项来忽略这个异常。
（2）EXTERNAL关键字可以让用户创建一个外部表，在建表的同时指定一个指向实际数据的路径（LOCATION），Hive创建内部表时，会将数据移动到数据仓库指向的路径；若创建外部表，仅记录数据所在的路径，不对数据的位置做任何改变。在删除表的时候，内部表的元数据和数据会被一起删除，而外部表只删除元数据，不删除数据。
（3）COMMENT：为表和列添加注释。
（4）PARTITIONED BY创建分区表
（5）CLUSTERED BY创建分桶表
（6）SORTED BY不常用
（7）ROW FORMAT 
DELIMITED [FIELDS TERMINATED BY char] [COLLECTION ITEMS TERMINATED BY char]
        [MAP KEYS TERMINATED BY char] [LINES TERMINATED BY char] 
   | SERDE serde_name [WITH SERDEPROPERTIES (property_name=property_value, property_name=property_value, ...)]
用户在建表的时候可以自定义SerDe或者使用自带的SerDe。如果没有指定ROW FORMAT 或者ROW FORMAT DELIMITED，将会使用自带的SerDe。在建表的时候，用户还需要为表指定列，用户在指定表的列的同时也会指定自定义的SerDe，Hive通过SerDe确定表的具体的列的数据。
SerDe是Serialize/Deserilize的简称，目的是用于序列化和反序列化。
（8）STORED AS指定存储文件类型
常用的存储文件类型：SEQUENCEFILE（二进制序列文件）、TEXTFILE（文本）、RCFILE（列式存储格式文件）
如果文件数据是纯文本，可以使用STORED AS TEXTFILE。如果数据需要压缩，使用 STORED AS SEQUENCEFILE。
（9）LOCATION ：指定表在HDFS上的存储位置。
（10）LIKE允许用户复制现有的表结构，但是不复制数据。

### 5.1 管理表

**理论**
默认创建的表都是所谓的管理表，有时也被称为内部表。因为这种表，Hive会（或多或少地）控制着数据的生命周期。Hive默认情况下会将这些表的数据存储在由配置项hive.metastore.warehouse.dir(例如，/user/hive/warehouse)所定义的目录的子目录下。	
<u>当我们删除一个管理表时，Hive也会删除这个表中数据。</u>管理表不适合和其他工具共享数据。


**实操**
```mysql
# （1）普通创建表
create table if not exists student2(
id int, name string
)
row format delimited fields terminated by '\t'
stored as textfile
location '/user/hive/warehouse/student2';
# （2）根据查询结果创建表（查询的结果会添加到新创建的表中）
create table if not exists student3 as select id, name from student;
# （3）根据已经存在的表结构创建表
create table if not exists student4 like student;
# （4）查询表的类型
hive (default)> desc formatted student2;
# Table Type:             MANAGED_TABLE  
```

### 5.2 外部表

**理论**
因为表是外部表，所以Hive并非认为其完全拥有这份数据。
删除该表并不会删除掉这份数据，不过描述表的元数据信息会被删除掉。


**管理表和外部表使用场景**
每天将收集到的网站日志定期流入HDFS文本文件。在外部表（原始日志表）的基础上做大量的统计分析，用到的中间表、结果表使用内部表存储，数据通过SELECT+INSERT进入内部表。

**案例实操**
分别创建部门和员工外部表，并向表中导入数据
**原始数据**

```
10	ACCOUNTING	1700
20	RESEARCH	1800
30	SALES	1900
40	OPERATIONS	1700
```

```emp.txt
7369	SMITH	CLERK	7902	1980-12-17	800.00		20
7499	ALLEN	SALESMAN	7698	1981-2-20	1600.00	300.00	30
7521	WARD	SALESMAN	7698	1981-2-22	1250.00	500.00	30
7566	JONES	MANAGER	7839	1981-4-2	2975.00		20
7654	MARTIN	SALESMAN	7698	1981-9-28	1250.00	1400.00	30
7698	BLAKE	MANAGER	7839	1981-5-1	2850.00		30
7782	CLARK	MANAGER	7839	1981-6-9	2450.00		10
7788	SCOTT	ANALYST	7566	1987-4-19	3000.00		20
7839	KING	PRESIDENT		1981-11-17	5000.00		10
7844	TURNER	SALESMAN	7698	1981-9-8	1500.00	0.00	30
7876	ADAMS	CLERK	7788	1987-5-23	1100.00		20
7900	JAMES	CLERK	7698	1981-12-3	950.00		30
7902	FORD	ANALYST	7566	1981-12-3	3000.00		20
7934	MILLER	CLERK	7782	1982-1-23	1300.00		10
```

**建表语句**
```mysql
# （1）创建部门表
create external table if not exists default.dept(
deptno int,
dname string,
loc int
)
row format delimited fields terminated by '\t';
# （2）创建员工表
create external table if not exists default.emp(
empno int,
ename string,
job string,
mgr int,
hiredate string, 
sal double, 
comm double,
deptno int)
row format delimited fields terminated by '\t';
# （3）查看创建的表
hive (default)> show tables;
# OK
# tab_name
# dept
# emp
# （4）向外部表中导入数据
# 导入数据
hive (default)> load data local inpath '/opt/module/datas/dept.txt' into table default.dept;
hive (default)> load data local inpath '/opt/module/datas/emp.txt' into table default.emp;
# 查询结果
hive (default)> select * from emp;
hive (default)> select * from dept;
# （5）查看表格式化数据
hive (default)> desc formatted dept;
# Table Type:             EXTERNAL_TABLE
```


### 5.3 管理表和外部表的互相转换

```mysql
# （1）查询表的类型
hive (default)> desc formatted student2;
# Table Type:             MANAGED_TABLE
# （2）修改内部表student2为外部表
alter table student2 set tblproperties('EXTERNAL'='TRUE');
# （3）查询表的类型
hive (default)> desc formatted student2;
# Table Type:             EXTERNAL_TABLE
# （4）修改外部表student2为内部表
alter table student2 set tblproperties('EXTERNAL'='FALSE');
# （5）查询表的类型
hive (default)> desc formatted student2;
# Table Type:             MANAGED_TABLE
```
**注意：('EXTERNAL'='TRUE')和('EXTERNAL'='FALSE')为固定写法，区分大小写！**



## 6.分区表

分区表实际上就是对应一个HDFS文件系统上的独立的文件夹，该文件夹下是该分区所有的数据文件。Hive中的分区就是分目录，把一个大的数据集根据业务需要分割成小的数据集。在查询时通过WHERE子句中的表达式选择查询所需要的指定的分区，这样的查询效率会提高很多。

### 6.1 分区表基本操作


### 6.2 分区表注意事项


## 7.修改表

### 7.1 重命名表

```mysql
alter table table_name rename to new_table_name;
```



### 7.2 增加、修改和删除表分区

*见分区表部分*

### 7.3 增加、修改、替换列信息

```mysql
alter table table_name add columns (col_name data_type); -- 默认位置在所有列后，(partition列前)
alter table table_name replace columns (col_name data_type); -- 替换所有列
alter table table_name change column col_old_name col_new_name column_type;

alter table stu_tab add columns (gender string, add string);
alter table stu_tab replace columns (phone string, email string);
alter table stu_tab change column email mail string;
```

替换列是用指定的列替换**所有的列**

## 8.删除表

```mysql
drop table dept_partition;
```



# 五、DML数据操作

## 1.数据导入

### 1.1 向表中装载数据(load)

**语法**

```mysql
hive> load data [local] inpath '/opt/module/datas/student.txt' overwrite | into table student [partition (partcol1=val1,…)];
/*
（1）load data:表示加载数据
（2）local:表示从本地加载数据到hive表；否则从HDFS加载数据到hive表
（3）inpath:表示加载数据的路径
（4）overwrite:表示覆盖表中已有数据，否则表示追加
（5）into table:表示加载到哪张表
（6）student:表示具体的表
（7）partition:表示上传到指定分区
*/
```

**实操**

```mysql
create table stu(id int, name string)
row format delimited fields terminated by "\t";

load data local inpath '/opt/module/datas/student.txt' into table stu_tab; -- 复制本地数据到hive
dfs -put /opt/module/datas/students.txt /user/tian/hive;
load data inpath '/user/tian/hive/student.txt' into table stu_tab; -- 剪切hdfs中的数据到hive
load data local inpath '/opt/module/datas/student.txt' overwrite into stu_tab;
```

### 1.2 通过查询语句向表中插入数据(Insert)

```mysql
create tabe stu_tab2 like stu_tab; -- 按结构复制表，不复制数据
insert into table stu_tab2 partition(month('201709')
values(1,'wangwu');
insert into table stu_tab2 partition(month='201708')
select id, name from student where month='201709';
insert overwrite table stu_tab2 partition(month='201708')
select id, name from student where month='201709'; -- 使用ovewrite后不能带into

## 多插入模式 

from stu_tab
insert overwrite table stu_tab partition(month='201908')
select id, name where month='201808'
insert overwrite table stu_tab partition(month='201801')
select id, name where month='201801'; -- 针对来自同一张表的数据的操作
```

### 1.3 查询语句中创建表并加载数据(As Select)

```mysql
create table if not exists student3
as select id, name from student;
```

### 1.4 创建表时通过Location指定加载数据路径

```mysql
create table if not exists student5(
	id int, name string
)
row format delimited fields terminated by '\t'
locationt '/user/hive/warehouse/student5';

dfs -put /opt/module/datas/studnets.txt /user/hive/warehouse/student5;

select * from student5;
```

### 1.5 Import数据到指定Hive表中

```mysql
## 先用export导出数据，再将数据导入
import table student2 partition(month='201909')
from '/user/hive/warehouse/export/student';
```

## 2.数据导出

### 2.1 Insert导出

```mysql
# 将查询的结果导出到本地 只能使用overwrite 不能使用into
insert overwrite local directory '/opt/module/datas/export/student'
select * from student;

# 将查询的结果格式化导出到本地
insert overwrite local directory '/opt/module/datas/export/student'
row format delimited fields terminated by '\t'
select * from student;

# 将查询的结果导出到hdfs上(没有local)
insert overwrite directory '/user/tian/student2'
row farmat delimited fields terminated by '\t'
select * from student;
```

### 2.2 hadoop命令导出到本地

```mysql
dfs -get /user/hive/warehouse/student/month=201909/000000_0 /opt/module/datas/export/student3.txt
```

### 2.3 Hive Shell命令导出

```mysql
hive -e 'select * from student;' > /opt/module/datas/export/student.txt;
```

### 2.4 Export导出到hdfs上

```mysql
export table default.student to 'user/hive/warehouse/export/student';
-- 然后才能import数据到指定hive表
```

### 2.5 Sqoop导出

*见后续课程*

## 3.清除表中的数据(Truncate)

```mysql
# Truncate只能删除管理表，不能删除外部表中数据
truncate table student;
```

# 六、查询

[官方文档](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Select)

**基本语法**

```mysql
[WITH CommonTableExpression (, CommonTableExpression)*]    (Note: Only available
 starting with Hive 0.13.0)
SELECT [ALL | DISTINCT] select_expr, select_expr, ...
  FROM table_reference
  [WHERE where_condition]
  [GROUP BY col_list]
  [ORDER BY col_list]
  [CLUSTER BY col_list
    | [DISTRIBUTE BY col_list] [SORT BY col_list]
  ]
 [LIMIT number]
```

> **说明**
> order by	全局排序
> sort by		区内排序
> distribute by 分区规则
> cluster by 当sort by和distribute by的字段相同时，可以用cluster by

## 1.基本查询(Select…from)

### 1.1 全表和特定列查询

```mysql
# 全表查询
select * from emp;
# 选择特定列查询
select empno, ename, from emp;
```

> **注意**
> sql语言大小写不敏感
> sql可以写在一行或多行
> 关键字不成能被缩写也不能分行
> 各字句一般要分行写
> 使用缩进提高语句的可读性

### 1.2 列别名

```mysql
select ename as name, deptno dn from emp;
```

### 1.3 算术运算符

| 运算符 | 描述           |
| ------ | :------------- |
| A+B    | A和B   相加    |
| A-B    | A减去B         |
| A*B    | A和B   相乘    |
| A/B    | A除以B         |
| A%B    | A对B取余       |
| A&B    | A和B按位取与   |
| A\|B   | A和B按位取或   |
| A^B    | A和B按位取异或 |
| ~A     | A按位取反      |

```mysql
select sal +1 from emp;
```

### 1.4 常用函数

```mysql
select count(*) cnt from emp;
select max(sal) max_sal from emp;
select min(sal) min_sal from emp;
select sum(sal) sum_sal from emp;
select avg(sal) avg_sal from emp;
```

### 1.5 limit语句

```mysql
select * from emp limit 5; -- 用于限制返回的行数
```

## 2.where语句

```mysql
select * from emp where sal>1000;
```

### 2.1 比较运算符(between / in / is null)

以下运算符同样可以用于join…on和having语句中

| 操作符                  | 支持的数据类型 | 描述                                                         |
| ----------------------- | -------------- | ------------------------------------------------------------ |
| A=B                     | 基本数据类型   | 如果A等于B则返回TRUE，反之返回FALSE                          |
| A<=>B                   | 基本数据类型   | 如果A和B都为NULL，则返回TRUE，其他的和等号（=）操作符的结果一致，如果任一为NULL则结果为NULL |
| A<>B, A!=B              | 基本数据类型   | A或者B为NULL则返回NULL；如果A不等于B，则返回TRUE，反之返回FALSE |
| A<B                     | 基本数据类型   | A或者B为NULL，则返回NULL；如果A小于B，则返回TRUE，反之返回FALSE |
| A<=B                    | 基本数据类型   | A或者B为NULL，则返回NULL；如果A小于等于B，则返回TRUE，反之返回FALSE |
| A>B                     | 基本数据类型   | A或者B为NULL，则返回NULL；如果A大于B，则返回TRUE，反之返回FALSE |
| A>=B                    | 基本数据类型   | A或者B为NULL，则返回NULL；如果A大于等于B，则返回TRUE，反之返回FALSE |
| A [NOT] BETWEEN B AND C | 基本数据类型   | 如果A，B或者C任一为NULL，则结果为NULL。如果A的值大于等于B而且小于或等于C，则结果为TRUE，反之为FALSE。如果使用NOT关键字则可达到相反的效果。 |
| A IS NULL               | 所有数据类型   | 如果A等于NULL，则返回TRUE，反之返回FALSE                     |
| A IS NOT NULL           | 所有数据类型   | 如果A不等于NULL，则返回TRUE，反之返回FALSE                   |
| IN(数值1, 数值2)        | 所有数据类型   | 使用 IN运算显示列表中的值                                    |
| A [NOT] LIKE B          | STRING 类型    | B是一个SQL下的简单正则表达式，如果A与其匹配的话，则返回TRUE；反之返回FALSE。B的表达式说明如下：‘x%’表示A必须以字母‘x’开头，‘%x’表示A必须以字母’x’结尾，而‘%x%’表示A包含有字母’x’,可以位于开头，结尾或者字符串中间。如果使用NOT关键字则可达到相反的效果。 |
| A RLIKE B, A REGEXP B   | STRING 类型    | B是一个正则表达式，如果A与其匹配，则返回TRUE；反之返回FALSE。匹配使用的是JDK中的正则表达式接口实现的，因为正则也依据其中的规则。例如，正则表达式必须和整个字符串A相匹配，而不是只需与其字符串匹配。 |

```mysql
select * from emp where sal = 5000;
select * from emp where sal between 5000 and 10000;
select * from emp where comm is null;
select * from emp where sal in (1500, 5000);
```

### 2.2 like和rlike

```mysql
-- 使用like运算符选择类似的值
-- 选择条件可以包含字符或数字
-- 	%代表零个或多个字符(任意个字符)
-- 	_代表一个字符
-- rlike是hive中对该功能的扩展，可以通过java正则表达式来指定匹配条件

select * from emp where sal like '2%';
select * from emp where sal like '_2%';
select * from emp where sal rlike '[2]'; -- 查找薪水中含有2的员工信息
```

### 2.3 逻辑运算符(and / or / not)

| 操作符 | 含义   |
| ------ | ------ |
| AND    | 逻辑并 |
| OR     | 逻辑或 |
| NOT    | 逻辑否 |

```mysql
select * from emp where sal > 1000 and depno = 30;
select * from emp where sal > 1000 or depno = 30;
select * from emp where deptno not in (30, 20);
```

## 3.分组

### 3.1 group by语句

```mysql
/* group by语句通常会和聚合函数一起使用，按照一个或者多个队列记过进行分组，然后对每个组执行聚合操作。 */
-- 计算emp表每个部门的平均工资
select t.deptno, avg(t.sal) avg_sal from emp t group by t.deptno;
-- 计算emp每个部门中每个岗位的最高薪水
select t.deptno t.deptno, t.job, max(t.sal) max_sal
from emp t
group by t.deptno, t.job;
```

### 3.2 having语句

> **having和where不同点**
> where针对表中的列发挥作用，查询数据，having针对查询结果中的列发挥作用，筛选数据
> where后面不能写分组函数，而having后面可以使用分组函数
> having只用于group by分组统计语句

```mysql
-- 每个部门的平均薪水
select deptno, avg(sal) from emp group bu deptno;
-- 每个部门的平均薪水大于2000的部门
```

## 4.join语句

### 4.1 等值join

```mysql
/* hive通常支持的sql join语句，但是只支持等值连接，不支持非等值连接 */

-- 根据员工表和部门表中的部门编号相等，查询员工编号、员工名称和部门名称
select e.empno, e.ename, d.deptno, d.dname
from emp e
join dept d 
on e.deptno = d.deptno;
```

### 4.2 表的别名

```mysql
select e.empno, e.ename, d.deptno
from emp e
join dept d 
on e.deptno = d.deptno;
```

### 4.3 内连接

```mysql
# 只进行连接的两个表中都存在与连接条件相匹配的数据才会保留下来
select e.empno, e.name, d.deptno
from emp e
join dept d 
on d.deptno = d.deptno;
```

### 4.4 左外连接

```mysql
# join操作符左边表中符合where字句的所有记录将会被返回
select e.empno, e.ename, d.deptno
from emp e
left join dept d 
on e.deptno = d.deptno;
```

### 4.5 右外连接

```mysql
# join操作符右边表中符合where字句的u偶有记录将会被返回
select e.empno, e.name, d.deptno
from emp e
right join dept d 
on e.deptno = d.deptno;
```

### 4.6 满外连接

```mysql
# 返回所有表中符合where语句条件的所有记录，如果任一表的指定字段咩有符合条件的值的话，那么就使用null替代
select e.empno, e.ename, d.deptno
from emp e
full join dept d
on e.deptno = d.deptno;
```

### 4.7 多表连接



### 4.8 笛卡尔积



### 4.9 连接谓词中不支持or

```mysql
select e.empno, e.ename, d.deptno
from emp e
join dept d 
on e.deptno = d.deptno or e.ename = d.ename; -- 错误示范
```

## 5.排序

### 5.1 全局排序(order by)

Order By: 全局排序，一个Reducer

```mysql
/*
order by:全局排序，一个reducer
ASC(ascend):升序(默认)
DESC(descend):降序
order by在select语句的结尾
*/

-- 查询员工信息按工资升序排列
select * 
from emp 
order by sal;
-- 查询员工信息按工资降序排列
select *
from emp
order by sal desc;
```

### 5.2  按照别名排序

```mysql
-- 按照与员工薪水的二倍排序
select ename, sal*2 double_sal
from emp
order by double_sal;
```

### 5.3 多个列排序

```mysql
-- 按照部门和工资升序排序
select ename, deptno, sal
from emp 
order by deptno, sal;
```

### 5.4 每个MapReduce内部排序(sort by)

Sort by:每个Reducer内部排序，对全局结果集来说不是排序

```mysql
-- 设置reduce个数
set mapreduce.job.reduces=3;
-- 查看设置的reduce个数
set mapreduce.job.reduces;
-- 根据部门编号降序查看员工信息
select *
from emp
sort by empno desc;
-- 将查询结果导入到文件中(按照部门编号降序排序)
insert overwrite local directory '/opt/module/datas/sortby-result' 
select * from emp sort by deptno desc;
```

### 5.5 分区排序(Distributed By)

Distribute by:类似MR中partition，进行分区，结合sort by使用
注意，hive要求distribute by语句要写在sort by语句之前
只有分派对个reduce进行处理时才能看出distribute by的效果
**分区个数和reducer个数**的确定与最终文件的个数和文件的内容

```mysql
-- 先按照部门编号排序，再按照员工编号降序排序
set mapreduce.job.reduces=3; # 个数的确定★ 
insert overwrite loacl directory '/opt/module/datas/distribute-result'
select * from emp
distribute by deptno
sort by empno desc;
```

### 5.6 Cluster By

当distribute by 和 sort by字段相同时，可以使用cluster by
cluster by除了具有distribute by的功能外还兼具了sort by的功能。但是排序是升序，不能设置规则

```mysql
select * 
from emp 
cluster by depto;
select * 
from emp 
distribute by deptno 
sort by deptno; -- 和第一条语句相同
# 按照部门编号分区，不一定是固定死的数值，可以是20和30号部门分到一个分区里面去。
```

## 6.分桶及抽样查询

### 6.1 分桶表数据存储

分区针对数据的存储路径，分桶针对数据文件
分区提供一个隔离数据和优化查询的便利方式，并非所有的数据集都可以形成合理的分区，特别是之前所提到过的要确定合适的划分大小。
分桶是将数据集分解成更容易管理的若干部分另一个技术。

1. 先创建分桶表，通过直接导入数据文件的方式

   数据准备

   ```
   1001	ss1
   1002	ss2
   1003	ss3
   1004	ss4
   1005	ss5
   1006	ss6
   1007	ss7
   1008	ss8
   1009	ss9
   1010	ss10
   1011	ss11
   1012	ss12
   1013	ss13
   1014	ss14
   1015	ss15
   1016	ss16
   ```

   ```mysql
   -- 创建分桶表
   create table stu_buck(id int, name string)
   clustered by(id)
   into 4 buckets
   row format delimited fields terminated by '\t';
   -- 查看表结构
   desc formatted stu_buck;
   -- 导入数据到分桶表中
   load data local inpath 'opt/module/datas/student.txt' into table stu_buck;
   # web界面查看分桶表中是否分成四个桶 --并没有
   ```

2. 创建分桶表是，数据通过子查询的方式导入

   ```mysql
   -- 先建一个普通的stu表
   create table stu(id int, name string)
   row format delimited fields terminated by '\t';
   -- 导入数据
   load data local inpath '/opt/module/datas/student.txt' into table stu;
   -- 清空stu_buck表中数据
   truncate table stu_buck;
   select * from stu_buck;
   -- 导入数据到分桶表，通过子查询的方式
   insert into table stu_buck
   select id, name from stu;
   # web端查看还是只有一个桶
   -- 设置属性
   set hive.enforce.bucketing=true;
   set mapreduce.job.reduces=-1;
   insert into table stu_buck
   select id, name from stu;
   # 再次查看发现数据已经分桶
   -- 查询分桶中的数据
   select * from stu_buck;
   ```

### 6.2 分桶抽样查询

```mysql
select * from stu_buck tablesample(bucket 1 out of 4 on id);
```

> **TABLESAMPLE(BUCKET x OUT OF y)** 
> y必须是table总bucket数的倍数或者因子
> hive根据y的大小，决定抽样的比例，抽取bucket个数为z/y，z为bucket总数。
> x表示从哪个bucket开始抽取，如果需要多个分区，以后的分区号为当前分区号加上y。
> x必须小于y，因为x+(z/y-1)≤z否则
> FAILED: SemanticException [Error 10061]: Numerator should not be
> bigger than denominator in sample clause for table stu_buck

## 7.其他常用查询函数

### 7.1 空字段赋值

> **函数说明**
> NVL:给值为null的数据赋值，他的格式是NVL(string 1, replace_with)，他的功能是如果string1为null，则nvl则nvl函数返回replace_with的值，否则返回string 1的值，如果两个参数为null，则返回null

```mysql
-- 如果comm为null，则用-1代替
select nvl(comm,-1) from emp;
-- 如果员工的comm为null，则用领导id代替
select nvl(comm，mgr) from emp;
-- 如果员工的comm为空显示他的领导id，如果领导id也是空，显示他的名字
select nvl(comm, nvl(mgr,ename)) from emp;
```

### 7.2 case when

1. 数据准备

   | name | dept_id | sex  |
   | ---- | ------- | ---- |
   | 悟空 | A       | 男   |
   | 大海 | A       | 男   |
   | 宋宋 | B       | 男   |
   | 凤姐 | A       | 女   |
   | 婷姐 | B       | 女   |
   | 婷婷 | B       | 女   |

2. 需求
   求出不同部门男女各多少人，结果如下:

   ```
   A     2       1
   B     1       2
   ```

   

3. 创建本地emp_sex.txt，导入数据

   ```bash
   vim emp_sex.txt # 将表中的数据写入到文件中
   ```

   ```
   悟空	A	男
   大海	A	男
   宋宋	B	男
   凤姐	A	女
   婷姐	B	女
   婷婷	B	女
   ```

4. 创建hive表并导入数据

   ```mysql
   create table emp_sex(
   	name string,
       dept_id string,
       sex string)
   row format delimited fields terminated by '\t';
   load data local inpath '/opt/module/datas/emp_sex.txt' into table emp_sex;
   ```

5. 按需求查询数据

   ```mysql
   select 
   	dept_id,
   	sum(case sex when '男' then 1 else 0 end) male_count,
   	sum(case sex when '女' then 1 else 0 end) female_count
   from
   	emp_sex
   group bu
   	dept_id;
   ```

### 7.3 行转列

> **函数说明**
> **concat(string A/col, string B/col, …)** 返回输入字符串连接后的结果，支持任意个输入字符串
> **concat ws(separator, str1, str2,…)** 它是一个特殊形式的concat()，第一个参数剩余参数间的分隔符，分隔符可以是字符串，如果分隔符时null，返回值也将是null，这个函数会跳过分隔符参数后的任何null和空字符串，分隔符将被加到被连接的字符串之间
> **collect_set(col)**函数只接受基本数据类型，他的主要作用是将某个字段的值进行去重汇总，产生array类型字段

> **数据准备**

| name   | constellation | blood_type |
| ------ | ------------- | ---------- |
| 孙悟空 | 白羊座        | A          |
| 大海   | 射手座        | A          |
| 宋宋   | 白羊座        | B          |
| 猪八戒 | 白羊          | A          |
| 凤姐   | 射手座        | A          |

>**需求**
>把星座和血型一样的人归类到一起，输出结果如下
>
>```
>射手座,A            大海|凤姐
>白羊座,A            孙悟空|猪八戒
>白羊座,B            宋宋
>```

> **创建本地文件constellation.txt,并导入数据**
>
> ```bash
> vim constellation.txt # 把上述表中的数据写入到文件中
> ```
>
> ```
> 孙悟空	白羊座	A
> 大海	     射手座	A
> 宋宋	     白羊座	B
> 猪八戒    白羊座	A
> 凤姐	     射手座	A
> ```

> **创建hive表并导入数据**
>
> ```mysql
> create table person_info(
> name string,
> constellation string,
> blood_type string)
> row format delimited fields terminated by "\t";
> load data local inpath "/opt/module/constellation.txt" into table person_info;
> ```

> **按需求查询数据**
>
> ```mysql
> select
> 	t1.base,
> 	concat ws('|', conllect_set(t1.name)) name
> from 
> 	(select
>     	name,
>     	concat(constellation, ",", blood_type) base
>     from
>     	person_info) t1
> group by
> 	t1.base;
> ```

### 7.4 列转行

> **函数说明**
> **EXPLODE(col)**将hive一列中复杂的array或者map结构拆分成多行
> **LATERVL VIEW**
> 	用法:LATERVAL VIEW udtf(expression) tableAlias AS columnAlias
> 	解释:用于和split，explode等UDTF一起使用，它能够将一列数据拆分成多行数据，在此基础上对查分后的数据惊醒聚合。

> **数据准备**

| movie           | category                 |
| --------------- | ------------------------ |
| 《疑犯追踪》    | 悬疑,动作,科幻,剧情      |
| 《Lie   to me》 | 悬疑,警匪,动作,心理,剧情 |
| 《战狼2》       | 战争,动作,灾难           |

> **创建本地文件movie.txt导入数据**
>
> ```bash
> vim movie.txt # 将上述表中的数据写入到文件中
> ```
>
> ```
> 《疑犯追踪》	悬疑,动作,科幻,剧情
> 《Lie to me》	悬疑,警匪,动作,心理,剧情
> 《战狼2》	战争,动作,灾难
> ```

> **创建hive表并导入数据**
>
> ```mysql
> create table movie info(
> 	movie string,
> 	category array<string>)
> row format delimited fields terminated by "\t"
> collection items terminated by ",";
> load data local inpath "/opt/module/datas/movie.txt" into table movie_info;
> ```

> **按需求查询数据**
>
> ```mysql
> select
> 	movie,
> 	catagory_name
> from
> 	movie_info lateral view explode(category) table_tmp as category_name;
> ```

### 7.5 窗口函数

> **函数说明**
> **OVER()**：指定分析函数工作的数据窗口大小，这个数据窗口大小可能会随着行的变而变化
> **CURRENT ROW**：当前行
> **n PRECEDING**：往前n行数据
> **n FOLLOWING**：往后n行数据
> **UNBOUNDED**：起点，UNBOUNDED PRECEDING 表示从前面的起点， UNBOUNDED FOLLOWING表示到后面的终点
> **LAG(col,n)**：往前第n行数据
> **LEAD(col,n)**：往后第n行数据
> **NTILE(n)**：把有序分区中的行分发到指定数据的组中，各个组有编号，编号从1开始，对于每一行，NTILE返回此行所属的组的编号。注意：n必须为int类型。

> **数据准备** name, orderdate, cost
>
> ```
> jack,2017-01-01,10
> tony,2017-01-02,15
> jack,2017-02-03,23
> tony,2017-01-04,29
> jack,2017-01-05,46
> jack,2017-04-06,42
> tony,2017-01-07,50
> jack,2017-01-08,55
> mart,2017-04-08,62
> mart,2017-04-09,68
> neil,2017-05-10,12
> mart,2017-04-11,75
> neil,2017-06-12,80
> mart,2017-04-13,94
> ```

> **需求**
> （1）查询在2017年4月份购买过的顾客及总人数
> （2）查询顾客的购买明细及月购买总额
> （3）上述的场景,要将cost按照日期进行累加
> （4）查询顾客上次的购买时间
> （5）查询前20%时间的订单信息

> **创建本地文件business.txt导入数据**
>
> ```bash
> vim business.txt # 写入数据到文件
> ```

> **创建hive表并导入数据**
>
> ```mysql
> create table business(
> name string,
> orderdate string,
> cost int)
> row format delimited fields terminated by ',';
> load data local inpath "/opt/module/datas/business.txt" into table business;
> ```

> **按需求查询数据**
>
> ```mysql
> -- 查询在2017年4月购买过的顾客及总人数
> select name, count(*) over() -- 使用over()后，count窗口个数
> from business
> where substring(orderdate,1,7) = '2017-04'
> group by name; -- group by后窗口个数为分成的组数，
> 
> -- 查询顾客的购买明细及月购买总额
> select name, orderdate, cost, sum(cost)
> over(partition by month(orderdate))
> from business;
> 
> -- 上述场景，将cost按照日期进行累加
> select name, orderdate, cost
> sum(cost) over() as sample1, -- 所有行累加
> sum(cost) over(partition by name) as sample2, -- 按name分组，组内数据相加
> sum(cost) over(partition by name order by orderdate) as sample3, -- 按name分组，组内数据累加
> sum(cost) over(partition by name order by orderdate rows between UNBOUNDED PRECEDING and current row) as sample4, -- 和sample3一样，由七点到当前行的聚合
> sum(cost) over(partition by name order by orderdate rows between 1 PRECEDING and current row) as sample5, -- 当前行和前面一行做聚合
> sum(cost) over(partition by name order by orderdate rows between 1 PRECEDING AND 1 FOLLOWING) as sample6, -- 当前行和前边一行及后面一行
> sum(cost) over(partition by name order by orderdate rows between current row and UNBOUNDED FOLLOWING) as sample7 -- 当前行及后面所有行
> from business;
> 
> -- 查看顾客上次购买时间
> select name, orderdate, cost,
> lag(orderdate, 1, '1900-01-01') over(partition by name order by orderdate) as time1,
> lag(orderdate, 2) over (partition by name order by orderdate) as time2
> from business;
> -- 查询前20%时间的订单信息
> select * from  (
> 	select name, orderdate, cost ntile(5) over(order by orderdate) sorted
> 	from business) t
> where sorted = 1;
> ```

### 7.6 Rank

> **函数说明**
> RANK() 排序相同时会重复，总数不会变
> DENSE_RANK() 排序相同时会重复，总数会减少
> ROW_NUMBER() 会根据顺序计算

> **数据准备**

| name   | subject | score |
| ------ | ------- | ----- |
| 孙悟空 | 语文    | 87    |
| 孙悟空 | 数学    | 95    |
| 孙悟空 | 英语    | 68    |
| 大海   | 语文    | 94    |
| 大海   | 数学    | 56    |
| 大海   | 英语    | 84    |
| 宋宋   | 语文    | 64    |
| 宋宋   | 数学    | 86    |
| 宋宋   | 英语    | 84    |
| 婷婷   | 语文    | 65    |
| 婷婷   | 数学    | 85    |
| 婷婷   | 英语    | 78    |

> **需求**
> 计算每门学科成绩排名

> **创建本地文件movie.txt，导入数据**
>
> ```bash
> vim score.txt
> ```

> **创建hive表并导入数据**
>
> ```mysql
> create table score(
> name string,
> subject string,
> score int)
> row format delimited fields terminated by "\t";
> load data local inpath '/opt/module/datas/score.txt' into table score;
> ```

> **按需求查询数据**
>
> ```mysql
> select name, subject, score,
> rank() over(partition by subject order by score desc) rp,
> dense rank() over(partition by subject order by score desc) drp,
> row number() over(partition by subject order by score desc) rmp
> from score;
> ```

> **输出结果**
>
> ```
> name    subject score   rp      drp     rmp
> 孙悟空  数学    95      1       1       1
> 宋宋    数学    86      2       2       2
> 婷婷    数学    85      3       3       3
> 大海    数学    56      4       4       4
> 宋宋    英语    84      1       1       1
> 大海    英语    84      1       1       2
> 婷婷    英语    78      3       2       3
> 孙悟空  英语    68      4       3       4
> 大海    语文    94      1       1       1
> 孙悟空  语文    87      2       2       2
> 婷婷    语文    65      3       3       3
> 宋宋    语文    64      4       4       4
> ```



# 七、函数

## 1.系统内置函数

```mysql
-- 查询系统自带的函数
show functions;
-- 显示自带的函数的用法
desc function upper;
-- 详细显示自带的函数的用法
desc function extended upper;
```

## 2.自定义函数

hive自带了一些函数，但是数量有限，当内置函数无法满足业务需求时，可以使用用户自定义函数

> **(UDF:user-defined function)分类**
> UDF(User-Defined-Function) 一进一出
> UDAF(User-Defined Aggregation Function) 聚集函数，多进一出，类似count/max/min
> UDTF(User-Defined Table-Generating Function) 一进一出，如lateral view explore

[官方文档地址](https://cwiki.apache.org/confluence/display/Hive/HivePlugins)

> **编程步骤**
> 继承org.apache.hadoop.hive.ql.UDF
> 需要实现evaluate函数;evaluate函数支持重载
> 在hive的命令行窗口创建函数
>
> ```mysql
> # 添加jar
> add jar linux_jar_path
> -- 创建function
> create [temporary] function [dbname.]function_name AS class_name;
> ```
>
> 在hive命令行窗口删除函数
>
> ```mysql
> Drop [temporary] function [if exists] [dbname.]function_name;
> ```

> **注意事项**
> UDF必须要有返回类型，可以返回null，但是返回类型不能为void

## 3.自定义UDF函数

**创建Maven工程Hive**

**导入依赖**

```xml
<dependencies>
		<!-- https://mvnrepository.com/artifact/org.apache.hive/hive-exec -->
		<dependency>
			<groupId>org.apache.hive</groupId>
			<artifactId>hive-exec</artifactId>
			<version>1.2.1</version>
		</dependency>
</dependencies>
```

 **创建一个类**

```java
package com.tian.hive;
import org.apache.hadoop.hive.ql.exec.UDF;

public class Lower extends UDF {

	public String evaluate (final String s) {
		
		if (s == null) {
			return null;
		}
		
		return s.toLowerCase();
	}
}
```

**打成jar包上传到服务器/opt/module/jars/udf.jar**

```mysql
-- 将jar包添加到hive的classpath
add jar /opt/module/datas/udf.jar
-- 创建临时函数与开发好的java class关联
create temporary function mylower as "com.tian.hive.lower";
-- 在hql中使用自定义的函数strip
select ename, mylower(ename) lowername from emp;
```

## 4.常用函数

### 4.1 日期





### 4.2 字符串





### 4.3 集合



# 八、压缩和存储

## 1.Hadoop源码编译支持Snappy压缩



## 2.Hadoop压缩配置

**MR支持的压缩编码**

| 压缩格式 | 工具  | 算法    | 文件扩展名 | 是否可切分 |
| -------- | ----- | ------- | ---------- | ---------- |
| DEFAULT  | 无    | DEFAULT | .deflate   | 否         |
| Gzip     | gzip  | DEFAULT | .gz        | 否         |
| bzip2    | bzip2 | bzip2   | .bz2       | 是         |
| LZO      | lzop  | LZO     | .lzo       | 是         |
| Snappy   | 无    | Snappy  | .snappy    | 否         |

**Hadoop引入的编码/解码器**

| 压缩格式 | 对应的编码/解码器                          |
| -------- | ------------------------------------------ |
| DEFLATE  | org.apache.hadoop.io.compress.DefaultCodec |
| gzip     | org.apache.hadoop.io.compress.GzipCodec    |
| bzip2    | org.apache.hadoop.io.compress.BZip2Codec   |
| LZO      | com.hadoop.compression.lzo.LzopCodec       |
| Snappy   | org.apache.hadoop.io.compress.SnappyCodec  |

**压缩性能比较**

| 压缩算法 | 原始文件大小 | 压缩文件大小 | 压缩速度 | 解压速度 |
| -------- | ------------ | ------------ | -------- | -------- |
| gzip     | 8.3GB        | 1.8GB        | 17.5MB/s | 58MB/s   |
| bzip2    | 8.3GB        | 1.1GB        | 2.4MB/s  | 9.5MB/s  |
| LZO      | 8.3GB        | 2.9GB        | 49.3MB/s | 74.6MB/s |

[snappy官方描述](http://google.github.io/snappy/)

> On a single core of a Core i7 processor in 64-bit mode, Snappy compresses at about 250 MB/sec or more and decompresses at about 500 MB/sec or more.

**压缩参数设置**

| 参数                                                 | 默认值                                                       | 阶段        | 建议                                         |
| ---------------------------------------------------- | ------------------------------------------------------------ | ----------- | -------------------------------------------- |
| io.compression.codecs      （在core-site.xml中配置） | org.apache.hadoop.io.compress.DefaultCodec,   org.apache.hadoop.io.compress.GzipCodec,   org.apache.hadoop.io.compress.BZip2Codec,   org.apache.hadoop.io.compress.Lz4Codec | 输入压缩    | Hadoop使用文件扩展名判断是否支持某种编解码器 |
| mapreduce.map.output.compress                        | false                                                        | mapper输出  | 这个参数设为true启用压缩                     |
| mapreduce.map.output.compress.codec                  | org.apache.hadoop.io.compress.DefaultCodec                   | mapper输出  | 使用LZO、LZ4或snappy编解码器在此阶段压缩数据 |
| mapreduce.output.fileoutputformat.compress           | false                                                        | reducer输出 | 这个参数设为true启用压缩                     |
| mapreduce.output.fileoutputformat.compress.codec     | org.apache.hadoop.io.compress.   DefaultCodec                | reducer输出 | 使用标准工具或者编解码器，如gzip和bzip2      |
| mapreduce.output.fileoutputformat.compress.type      | RECORD                                                       | reducer输出 | SequenceFile输出使用的压缩类型：NONE和BLOCK  |

3.开启Map输出阶段压缩

开启map输出阶段压缩可以减少job中map和reduce task间数据传输量
**实操**

```mysql
-- 临时设置只对当前窗口有效，更改配置文件才能永久有效

-- 开启hive中间传输数据压缩功能
set hive.exec.compress.intermediate=true;
-- 开启mapreduce中map输出压缩功能
set mapreduce.map.output.compress=true;
-- 设置mapreduce中map输出数据的压缩方式
set maprduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec;
-- 执行查询语句
select count(ename) name from emp;
```



## 4.开启Map输出阶段压缩

当hive将输出写入到表中时，输出内容同样可以进行压缩。属性hive.exec.compress.output控制着这个功能。用户可能需要保持默认设置文件中的默认值false，这样默认的输出就是非压缩的纯文本文件了，用户可以通过在查询语句或执行脚本中设置这个true，来开启输出结果压缩功能。	

**实操**

```mysql
-- 开启hive最终输出数据压缩功能
set hive.exec.compress.output=true;
-- 开启mapreduce最终输出数据压缩
set mapreduce.output.fileoutputformat.compress=true;
-- 设置mapreduce最终数据输出压缩方式
set mapreduce.output.fileoutputformat.compress.codes=org.apache.hadoop.io.compress.SanppyCodec;
-- 设置mapreduce最终数据输出压缩为块压缩
set mapreduce.output.fileoutputformat.compress.type=BLOCK;
-- 测试一下输出结果是否是压缩文件
insert overwrite local directory
 '/opt/module/datas/distribute-result' 
 select * 
 from emp 
 distribute by deptno 
 sort by empno desc;
```

## 5.文件存储格式

Hive支持的存储数的格式主要有：**TEXTFILE** 、**SEQUENCEFILE**、**ORC**、**PARQUET**。

### 5.1 列式存储和行式存储

![行式存储和列式存储](E:\Git\Note\Markdown\img\col-row.png)

**行式存储的特点**
查询满足条件的一整行数据的时候，列存储则需要去每个聚集的字段找到对应的每个列的值，行存储只需要找到其中一个值，其余的值都在相邻地方，所以此时行存储查询的速度更快。
**列式存储的特点**
因为每个字段的数据聚集存储，在查询只需要少数几个字段的时候，能大大减少读取的数据量；每个字段的数据类型一定是相同的，列式存储可以针对性的设计更好的设计压缩算

**TEXTFILE**和**SEQUENCEFILE**的存储格式都是基于行存储的；
**ORC**和**PARQUET**是基于列式存储的。

### 5.2 TextFile格式

默认格式，数据不做压缩，磁盘开销大，数据解析开销大。可结合Gzip、Bzip2使用，但使用Gzip这种方式，hive不会对数据进行切分，从而无法对数据进行并行操作。



### 5.3 Orc格式

Orc (Optimized Row Columnar)是Hive 0.11版里引入的新的存储格式。

每个Orc文件由1个或多个stripe组成，每个stripe250MB大小，这个Stripe实际相当于RowGroup概念，不过大小由4MB->250MB，这样应该能提升顺序读的吞吐率。每个Stripe里有三部分组成，分别是Index Data，Row Data，Stripe Footer。

![](E:\Git\Note\Markdown\img\orc-format.png)

> **Index Data**
> 一个轻量级的index，默认是每隔1W行做一个索引。
> 这里做的索引应该只是记录某行的各字段在Row Data中的offset。

> **Row Data**
> 存的是具体的数据，先取部分行，然后对这些行按列进行存储。
> 对每个列进行了编码，分成多个Stream来存储。

> **Stripe Footer**
> 存的是各个Stream的类型，长度等信息。
> 每个文件有一个File Footer，这里面存的是每个Stripe的行数，每个Column的数据类型信息等；
> 每个文件的尾部是一个PostScript，这里面记录了整个文件的压缩类型以及FileFooter的长度信息等。
> 在读取文件时，会seek到文件尾部读PostScript，从里面解析到File Footer长度，再读FileFooter，从里面解析到各个Stripe信息，再读各个Stripe，即从后往前读。

### 5.4 Parquet格式

Parquet是面向分析型业务的列式存储格式，由Twitter和Cloudera合作开发，2015年5月从Apache的孵化器里毕业成为Apache顶级项目。Parquet文件是以二进制方式存储的，所以是不可以直接读取的，文件中包括该文件的数据和元数据，因此Parquet格式文件是自解析的。通常情况下，在存储Parquet数据的时候会按照Block大小设置行组的大小，由于一般情况下每一个Mapper任务处理数据的最小单位是一个Block，这样可以把每一个行组由一个Mapper任务处理，增大任务执行并行度。

![](E:\Git\Note\Markdown\img\paquet-format.png)

上图展示了一个Parquet文件的内容，一个文件中可以存储多个行组，文件的首位都是该文件的Magic Code，用于校验它是否是一个Parquet文件，Footer length记录了文件元数据的大小，通过该值和文件长度可以计算出元数据的偏移量，文件的元数据中包括每一个行组的元数据信息和该文件存储数据的Schema信息。除了文件中每一个行组的元数据，每一页的开始都会存储该页的元数据，在Parquet中，有三种类型的页：数据页、字典页和索引页。数据页用于存储当前行组中该列的值，字典页存储该列值的编码字典，每一个列块中最多包含一个字典页，索引页用来存储当前行组下该列的索引，目前Parquet中还不支持索引页。

### 5.5 主流文件存储格式对比试验

从存储文件的压缩比和查询速度两个角度对比。

**测试数据**

```powershell
scp ./log.data tian@hadoop201:/opt/module/datas/log.data # 拷贝数据到服务器
```

**TextFile**

```mysql
-- 创建表，存储数据格式为TEXTFILE
create table log_text (
track_time string,
url string,
session_id string,
referer string,
ip string,
end_user_id string,
city_id string
)
row format delimited fields terminated by '\t'
stored as textfile ;
-- 向表中加载数据
load data local inpath '/opt/module/datas/log.data' into table log_text ;
-- 查看表中数据大小
hive (default)> dfs -du -h /user/hive/warehouse/log_text;
# 18.1 M  /user/hive/warehouse/log_text/log.data
```

**ORC**

```mysql
-- 创建表，存储数据格式为orc
create table log_orc(
track_time string,
url string,
session_id string,
referer string,
ip string,
end_user_id string,
city_id string
)
row format delimited fields terminated by '\t'
stored as orc;
-- 向表中加载数据
insert into table log_orc select * from log_text;
-- 查看表中数据大小
dfs -du -h /user/hive/warehouse/log_orc/;
# 2.8 M  /user/hive/warehouse/log_orc/000000_0
```

**Parquet**

```mysql
-- 创建表，存储数据格式为parquet
create table log_parquet(
track_time string,
url string,
session_id string,
referer string,
ip string,
end_user_id string,
city_id string
)
row format delimited fields terminated by '\t'
stored as parquet ;	
-- 向表中加载数据
insert into table log_parquet select * from log_text ;
-- 查看表中数据大小
dfs -du -h /user/hive/warehouse/log_parquet/ ;
# 13.1 M  /user/hive/warehouse/log_parquet/000000_0
```

**查询速度测试**

```mysql
select count(*) from log_text;
# _c0
# 100000
# Time taken: 21.54 seconds, Fetched: 1 row(s)
# Time taken: 21.08 seconds, Fetched: 1 row(s)
# Time taken: 19.298 seconds, Fetched: 1 row(s)
select count(*) from log_orc;
# _c0
# 100000
# Time taken: 20.867 seconds, Fetched: 1 row(s)
# Time taken: 22.667 seconds, Fetched: 1 row(s)
# Time taken: 18.36 seconds, Fetched: 1 row(s)
select count(*) from log_parquet;
# _c0
# 100000
# Time taken: 22.922 seconds, Fetched: 1 row(s)
# Time taken: 21.074 seconds, Fetched: 1 row(s)
# Time taken: 18.384 seconds, Fetched: 1 row(s)
```

> **总结**
> **压缩比** ORC>Parquet>textFile
> **速度** 查询速度相近



## 6.存储和压缩结合

### 6.1 修改Hadoop集群具有Snappy压缩方式

```bash
# 解压编译喊得支持snappy压缩的hadoop-2.7.2.tar.gz包并找到lib/native中的动态链接库并拷贝到当前使用的hadoop的native路径下，分发配置，重启集群和hive
# 查看hadoop checknative命令使用
hadoop checknative [-a|-h]  check native hadoop and compression libraries availability
# 查看hadoop支持的压缩方式
hadoop checknative
```

### 6.2 测试压缩方式压缩

[官网地址](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+ORC)

**ORC存储方式的压缩**

| Key                      | Default    | Notes                                                        |
| ------------------------ | ---------- | ------------------------------------------------------------ |
| orc.compress             | ZLIB       | high level compression (one of NONE, ZLIB,   SNAPPY)         |
| orc.compress.size        | 262,144    | number of bytes in each compression chunk                    |
| orc.stripe.size          | 67,108,864 | number of bytes in each stripe                               |
| orc.row.index.stride     | 10,000     | number of rows between index entries (must be   >= 1000)     |
| orc.create.index         | true       | whether to create row indexes                                |
| orc.bloom.filter.columns | ""         | comma separated list of column names for which   bloom filter should be created |
| orc.bloom.filter.fpp     | 0.05       | false positive probability for bloom filter (must   >0.0 and <1.0) |

**创建非压缩的ORC存储方式**

```mysql
-- 建表
create table log_orc_none(
track_time string,
url string,
session_id string,
referer string,
ip string,
end_user_id string,
city_id string
)
row format delimited fields terminated by '\t'
stored as orc tblproperties ("orc.compress"="NONE");
-- 插入数据
insert into table log_orc_none select * from log_text ;
-- 查看数据
dfs -du -h /user/hive/warehouse/log_orc_none/ ;
# 7.7 M  /user/hive/warehouse/log_orc_none/000000_0
```



**创建Snappy压缩的ORC存储方式**

```mysql
-- 建表
create table log_orc_snappy(
track_time string,
url string,
session_id string,
referer string,
ip string,
end_user_id string,
city_id string
)
row format delimited fields terminated by '\t'
stored as orc tblproperties ("orc.compress"="SNAPPY");
-- 插入数据
insert into table log_orc_snappy select * from log_text ;
-- 查看数据
dfs -du -h /user/hive/warehouse/log_orc_snappy/ ;
# 3.8 M  /user/hive/warehouse/log_orc_snappy/000000_0
```

orc存储文件默认采用ZLIB压缩。比snappy压缩的小。

在实际的项目开发当中，hive表的数据存储格式一般选择：orc或parquet。压缩方式一般选择snappy，lzo。

# 九、企业调优

## 1.Fetch抓取

Fetch抓取是指，Hive中对某些情况的查询可以不必使用MapReduce计算。例如：SELECT * FROM employees;在这种情况下，Hive可以简单地读取employee对应的存储目录下的文件，然后输出查询结果到控制台。

在hive-default.xml.template文件中hive.fetch.task.conversion默认是more，老版本hive默认是minimal，该属性修改为more以后，在全局查找、字段查找、limit查找等都不走mapreduce。

```xml
<property>
    <name>hive.fetch.task.conversion</name>
    <value>more</value>
    <description>
      Expects one of [none, minimal, more].
      Some select queries can be converted to single FETCH task minimizing latency.
      Currently the query should be single sourced not having any subquery and should not have
      any aggregations or distincts (which incurs RS), lateral views and joins.
      0. none : disable hive.fetch.task.conversion
      1. minimal : SELECT STAR, FILTER on partition columns, LIMIT only
      2. more  : SELECT, FILTER, LIMIT only (support TABLESAMPLE and virtual columns)
    </description>
</property>
```

**实操**

```mysql
-- 把hive.fetch.task.conversion设置成none，然后执行查询语句，都会执行mapreduce程序。
set hive.fetch.task.conversion=none;
select * from emp;
select ename from emp;
select ename from emp limit 3;
-- 把hive.fetch.task.conversion设置成more，然后执行查询语句，如下查询方式都不会执行mapreduce程序。
set hive.fetch.task.conversion=more;
select * from emp;
select ename from emp;
select ename from emp limit 3;
```



## 2.本地模式

大多数的Hadoop Job是需要Hadoop提供的完整的可扩展性来处理大数据集的。不过，有时Hive的输入数据量是非常小的。在这种情况下，为查询触发执行任务消耗的时间可能会比实际job的执行时间要多的多。对于大多数这种情况，Hive可以通过本地模式在单台机器上处理所有的任务。对于小数据集，执行时间可以明显被缩短。

用户可以通过设置hive.exec.mode.local.auto的值为true，来让Hive在适当的时候自动启动这个优化。

```mysql
set hive.exec.mode.local.auto=true;  -- 开启本地mr
-- 设置local mr的最大输入数据量，当输入数据量小于这个值时采用local  mr的方式，默认为134217728，即128M
set hive.exec.mode.local.auto.inputbytes.max=50000000;
-- 设置local mr的最大输入文件个数，当输入文件个数小于这个值时采用local mr的方式，默认为4
set hive.exec.mode.local.auto.input.files.max=10;
```

**实操**

```mysql
-- 开启本地模式，并执行查询语句
set hive.exec.mode.local.auto=true; 
select * from emp cluster by deptno;
# Time taken: 1.328 seconds, Fetched: 14 row(s)
-- 关闭本地模式，并执行查询语句
set hive.exec.mode.local.auto=false; 
select * from emp cluster by deptno;
# Time taken: 20.09 seconds, Fetched: 14 row(s)
```

## 3.表的优化

### 3.1 小表、大表join

将key相对分散，并且数据量小的表放在join的左边，这样可以有效减少内存溢出错误发生的几率；再进一步，可以使用map join让小的维度表（1000条以下的记录条数）先进内存。在map端完成reduce。

**实际测试发现**：新版的hive已经对小表JOIN大表和大表JOIN小表进行了优化。小表放在左边和右边已经没有明显区别。

**实操**

```mysql
# 需求: 测大表join小表和小表join大表的效率

-- 建大表、小表和join后表的语句
create table bigtable(id bigint, time bigint, uid string, keyword string, url_rank int, click_num int, click_url string) row format delimited fields terminated by '\t'; -- 创建大表
create table smalltable(id bigint, time bigint, uid string, keyword string, url_rank int, click_num int, click_url string) row format delimited fields terminated by '\t'; -- 创建小表
create table jointable(id bigint, time bigint, uid string, keyword string, url_rank int, click_num int, click_url string) row format delimited fields terminated by '\t'; -- 创建join后表的语句

-- 分别向大表和小表中导入数据
load data local inpath '/opt/module/datas/bigtable' into table bigtable;
load data local inpath '/opt/module/datas/smalltable' into table smalltable;

-- 关闭mapjoin功能(默认时打开的)
set hive.auto.convert.join=false;

-- 执行小表join大表语句
insert overwrite table jointable
select b.id, b.time, b.uid, b.keyword, b.url_rank, b.click_num, b.click_url
from smalltable s
left join bigtable  b
on b.id = s.id;
# Time taken: 35.921 seconds
# No rows affected (44.456 seconds)
-- 执行小表join大表语句
insert overwrite table jointable
select b.id, b.time, b.uid, b.keyword, b.url_rank, b.click_num, b.click_url
from bigtable  b
left join smalltable  s
on s.id = b.id;
# Time taken: 34.196 seconds
# No rows affected (26.287 seconds)
```



### 3.2 大表join大表

**空key过滤**

有时join超时是因为某些key对应的数据太多，而相同key对应的数据都会发送到相同的reducer上，从而导致内存不够。此时我们应该仔细分析这些异常的key，很多情况下，这些key对应的数据是异常数据，我们需要在SQL语句中进行过滤。例如key对应的字段为空，

**实操**

```xml
<!-- 配置历史服务器mapred-site.xml -->
<property>
    <name>mapreduce.jobhistory.address</name>
    <value>hadoop102:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop102:19888</value>
</property>
```

```bash
mr-history-daemon.sh start historyserver # 启动历史服务器
```

[查看jobhistory](http://hadoop101:19888/jobhistory)

```mysql
# 创建原始表
create table ori(id bigint, time bigint, uid string, keyword string, url_rank int, click_num int, click_url string) row format delimited fields terminated by '\t';
# 创建空id表
create table nullidtable(id bigint, time bigint, uid string, keyword string, url_rank int, click_num int, click_url string) row format delimited fields terminated by '\t';
# 创建join后表的语句
create table jointable(id bigint, time bigint, uid string, keyword string, url_rank int, click_num int, click_url string) row format delimited fields terminated by '\t';
# 分别加载原始数据和空id数据到对应表中
load data local inpath '/opt/module/datas/ori' into table ori;
load data local inpath '/opt/module/datas/nullid' into table nullidtable;
# 测试不过滤空id
insert overwrite table jointable 
select n.* from nullidtable n left join ori o on n.id = o.id;
# Time taken: 42.038 seconds
# Time taken: 37.284 seconds
# 测试过滤空id
# Time taken: 31.725 seconds
# Time taken: 28.876 seconds
```

**空key转换**

有时虽然某个key为空对应的数据很多，但是相应的数据不是异常数据，必须要包含在join的结果中，此时我们可以表a中key为空的字段赋一个随机的值，使得数据随机均匀地分不到不同的reducer上。

**实操**

不随机分布null值

```mysql
# 设置5个reduce个数
set mapreduce.job.reduce=5
-- join两张表
insert overwirte table jointable
select n.* from nullidable
n left join ori b on n.id=b.id;
```

结果如图，发生了数据倾斜

![](E:\Git\Note\Markdown\img\null-key.png)

### 3.3 MapJoin

如果不指定MapJoin或者不符合MapJoin的条件，那么Hive解析器会将Join操作转换成Common Join，即：在Reduce阶段完成join。容易发生数据倾斜。可以用MapJoin把小表全部加载到内存在map端进行join，避免reducer处理。

```mysql
# 开启MapJoin参数设置
-- 设置自动设置Mapjoin
set hive.auto.convert.join=true; -- 默认为true
-- 大表小表的阈值设置(默认25M以下认为是小表)
set hive.mapjoin.smalltable.filesize=25000000;
```

![MapJoin工作机制](E:\Git\Note\Markdown\img\mapjoin-work.png)

**实操**

```mysql
-- 开启Mapjoin功能
set hive.auto.convert.join=true; -- 默认为true
-- 执行小表join大表语句
insert overwrite table jointable
select b.id, b.time, b.uid, b.keyword, b.url_rank, b.click_num, b.click_url
from smalltable s
join bigtable  b
on s.id = b.id;
# Time taken: 24.594 seconds
-- 执行大表join小表语句
insert overwrite table jointable
select b.id, b.time, b.uid, b.keyword, b.url_rank, b.click_num, b.click_url
from bigtable  b
join smalltable  s
on s.id = b.id;
# Time taken: 24.315 seconds
```

### 3.4 Group By

默认情况下，Map阶段同一个Key数据分发给一个reduce，当一个key数据过大时就倾斜了。并不是所有的聚合操作都需要在Reduce端完成，很多聚合操作都可以先在Map端进行部分聚合，之后在Reduce端得出最终结果。

> **开启Map端集合参数设置**
>
> ```mysql
> -- 是否在Map端进行聚合，默认为true
> hive.map.aggr=true
> -- 在Mapdaunt进行聚合操作的条目数目
> hive.groupby.mapaggr.checkinterval=100000
> -- 在数据倾斜的时候进行负载均衡(默认时false)
> hive.groupby.skewindata=true
> ```

**当选项设定为 true，生成的查询计划会有两个MR Job。**第一个MR Job中，Map的输出结果会随机分布到Reduce中，每个Reduce做部分聚合操作，并输出结果，这样处理的结果是**相同的Group By Key有可能被分发到不同的Reduce中**，从而达到负载均衡的目的；第二个MR Job再根据预处理的数据结果按照Group By Key分布到Reduce中（这个过程可以保证相同的Group By Key被分布到同一个Reduce中），最后完成最终的聚合操作。

### 3.5 Count(Distinct)去重统计

数据量小的时候无所谓，数据量大的情况下，由于COUNT DISTINCT操作需要用一个Reduce Task来完成，这一个Reduce需要处理的数据量太大，就会导致整个Job很难完成，一般COUNT DISTINCT使用先GROUP BY再COUNT的方式替换

**实操**

```mysql
-- 创建一张大表
create table bigtable(id bigint, time bigint, uid string, keyword
string, url_rank int, click_num int, click_url string) row format delimited
fields terminated by '\t';
-- 加载数据
load data local inpath '/opt/module/datas/bigtable/' into table bigtable;
-- 设置5个reduce个数
set mapreduce.job.reduces=5
-- 执行去重id查询
select count(distinct id) from bigtable;
# Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 7.12 sec   HDFS Read: 120741990 HDFS Write: 7 SUCCESS
# Total MapReduce CPU Time Spent: 7 seconds 120 msec
# OK
# c0
# 100001
# Time taken: 23.607 seconds, Fetched: 1 row(s)
-- 采用group by去重id
select count(id) from (select id from bigtable group by id) a;
# Stage-Stage-1: Map: 1  Reduce: 5   Cumulative CPU: 17.53 sec   HDFS Read: 120752703 HDFS Write: 580 SUCCESS
# Stage-Stage-2: Map: 1  Reduce: 1   Cumulative CPU: 4.29 sec   HDFS Read: 9409 HDFS Write: 7 SUCCESS
# Total MapReduce CPU Time Spent: 21 seconds 820 msec
# OK
# _c0
# 100001
# Time taken: 50.795 seconds, Fetched: 1 row(s)
```

**虽然会多用一个Job来完成，但在数据量大的情况下，这个绝对是值得的。**

### 3.6 笛卡尔积

尽量避免笛卡尔积，join的时候不加on条件，或者无效的on条件，Hive只能使用1个reducer来完成笛卡尔积。

### 3.7 行列过滤

**列处理**：在SELECT中，只拿需要的列，如果有，尽量使用分区过滤，少用SELECT *。

**行处理**：在分区剪裁中，当使用外关联时，如果将副表的过滤条件写在Where后面，那么就会先全表关联，之后再过滤，

**实操**

```mysql
-- 测试先关联两张表，再用where条件过滤
select o.id from bigtable b
join ori o on o.id = b.id
where o.id <= 10;
# Time taken: 34.406 seconds, Fetched: 100 row(s)
-- 通过子查询后，在关联表
select b.id from bigtable b
join (select id from ori where id <= 10 ) o on b.id = o.id;
# Time taken: 30.058 seconds, Fetched: 100 row(s)
```

### 3.8 动态分区调整

关系型数据库中，对分区表Insert数据时候，数据库自动会根据分区字段的值，将数据插入到相应的分区中，Hive中也提供了类似的机制，即动态分区(Dynamic Partition)，只不过，使用Hive的动态分区，需要进行相应的配置。

> **开启动态分区参数设置**
>
> ```mysql
> -- 开启动态分区功能(默认为true，开启)
> hive.exec.dynamic.patition=true
> -- 设置为非严格模式(动态分区模式，默认strict，表示必须指定至少一个分区为静态分区，nonstrict模式表示允许所有的分区字段都可以使用动态分区)
> hive.exec.max.dynamic.partition=nonstrict
> -- 在所有执行MR的节点上，最大一共可以创建多个动态分区
> hive.exec.max.dynamic.partition=1000
> -- 在每个执行MR的节点上，最大可以创建多个动态分区。该函数需要根据实际的数据来设定，
> hive.exec.max.dynamic.partition.pernode=100
> -- 整个MR job中，最大可以创建多个HDFS文件
> hive.exce.max.created.files=100000
> -- 当有空分区生成时，是否抛出异常，一般不需要设置
> hive.error.on.empty.partition=false
> ```

**实操**

```mysql
# 需求：将ori中的数据按照时间(如：20111230000008)，插入到目标表ori_partitioned_target的相应分区中。
-- （1）创建分区表
create table ori_partitioned(id bigint, time bigint, uid string, keyword string,
 url_rank int, click_num int, click_url string) 
partitioned by (p_time bigint) 
row format delimited fields terminated by '\t';
-- （2）加载数据到分区表中
hive (default)> load data local inpath '/home/atguigu/ds1' into table
 ori_partitioned partition(p_time='20111230000010') ;
hive (default)> load data local inpath '/home/atguigu/ds2' into table ori_partitioned partition(p_time='20111230000011') ;
-- （3）创建目标分区表
create table ori_partitioned_target(id bigint, time bigint, uid string,
 keyword string, url_rank int, click_num int, click_url string) PARTITIONED BY (p_time STRING) row format delimited fields terminated by '\t';
-- （4）设置动态分区
set hive.exec.dynamic.partition = true;
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.max.dynamic.partitions = 1000;
set hive.exec.max.dynamic.partitions.pernode = 100;
set hive.exec.max.created.files = 100000;
set hive.error.on.empty.partition = false;

insert overwrite table ori_partitioned_target partition (p_time) 
select id, time, uid, keyword, url_rank, click_num, click_url, p_time from ori_partitioned;
-- （5）查看目标分区表的分区情况
show partitions ori_partitioned_target;
```

### 3.9 分桶

*详见第六章第6节*

### 3.10 分区

*详见第四章第6节*

## 4.数据倾斜

### 4.1 合理设置Map数

> 通常情况下，作业会通过input的目录产生一个或者多个map任务
> 主要取决于input的文件总个数，input的文件大小，集群设置的文件块大小

> map数不是越多越好
> 如果一个任务有多个小文件(远远小于块大小127m)，则每个小文件也会被当作一个块，用一个map任务来完成，而一个map任务启动和初始化的时间远远大于逻辑处理的时间，就会造成很大的资源浪费。而且，同时执行的map数时受限的。这时需要**减少map**数。

> 不是保证每个map处理接近128m的文件块就没问题了，因为一个文件中也可能有大量的记录，如果map处理逻辑复杂，用一个map任务去做，肯定也比较耗时。这种情况需要**增加map数**来解决。

### 4.2 小文件进行合并

在map执行前合并小文件，减少map数：CombineHiveInputFormat具有对小文件进行合并的功能（系统默认的格式）。HiveInputFormat没有对小文件合并功能。

```mysql
set hive.input.format= org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
```

### 4.3 复杂文件增加Map数



### 4.4 合理设置Reduce数

> **调整reduce个数方法一**
>
> ```mysql
> -- （1）每个Reduce处理的数据量默认是256MB
> hive.exec.reducers.bytes.per.reducer=256000000
> -- （2）每个任务最大的reduce数，默认为1009
> hive.exec.reducers.max=1009
> -- （3）计算reducer数的公式
> # N=min(参数2，总输入数据量/参数1)
> ```

> **调整reduce个数方法二**
>
> ```mysql
> -- 在hadoop的mapred-default.xml文件中修改设置每个job的Reduce个数
> set mapreduce.job.reduces = 15;
> ```

> **reduce个数并不是越多越好**
> 1）过多的启动和初始化reduce也会消耗时间和资源；
> 2）另外，有多少个reduce，就会有多少个输出文件，如果生成了很多个小文件，那么如果这些小文件作为下一个任务的输入，则也会出现小文件过多的问题；
>2）另外，有多少个reduce，就会有多少个输出文件，如果生成了很多个小文件，那么如果这些小文件作为下一个任务的输入，则也会出现小文件过多的问题；
>在设置reduce个数的时候也需要考虑这两个原则：处理大数据量利用合适的reduce数；使单个reduce任务处理数据量大小要合适；





## 5.并行执行

Hive会将一个查询转化成一个或者多个阶段。这样的阶段可以是MapReduce阶段、抽样阶段、合并阶段、limit阶段。或者Hive执行过程中可能需要的其他阶段。默认情况下，Hive一次只会执行一个阶段。不过，某个特定的job可能包含众多的阶段，而这些阶段可能并非完全互相依赖的，也就是说有些阶段是可以并行执行的，这样可能使得整个job的执行时间缩短。不过，如果有更多的阶段可以并行执行，那么job可能就越快完成。

通过设置参数hive.exec.parallel值为true，就可以开启并发执行。不过，在共享集群中，需要注意下，如果job中并行阶段增多，那么集群利用率就会增加。

```mysql
set hive.exec.parallel=true;             -- 打开任务并行执行
set hive.exec.parallel.thread.number=16;  -- 同一个sql允许最大并行度，默认为8。
```

当然，得是在系统资源比较空闲的时候才有优势，否则，没资源，并行也起不来。

## 6.严格模式

Hive提供了一个严格模式，可以防止用户执行那些可能意想不到的不好的影响的查询。

通过设置属性hive.mapred.mode值为默认是非严格模式nonstrict 。开启严格模式需要修改hive.mapred.mode值为strict，开启严格模式可以禁止3种类型的查询。

```xml
<property>
    <name>hive.mapred.mode</name>
    <value>strict</value>
    <description>
        The mode in which the Hive operations are being performed. 
        In strict mode, some risky queries are not allowed to run. They include:
        Cartesian Product.
        No partition being picked up for a query.
        Comparing bigints and strings.
        Comparing bigints and doubles.
        Orderby without limit.
	</description>
</property>
```

1)       对于分区表，除非where语句中含有分区字段过滤条件来限制范围，否则不允许执行。换句话说，就是用户不允许扫描所有分区。进行这个限制的原因是，通常分区表都拥有非常大的数据集，而且数据增加迅速。没有进行分区限制的查询可能会消耗令人不可接受的巨大资源来处理这个表。

2)       对于使用了order by语句的查询，要求必须使用limit语句。因为order by为了执行排序过程会将所有的结果数据分发到同一个Reducer中进行处理，强制要求用户增加这个LIMIT语句可以防止Reducer额外执行很长一段时间。

3)       限制笛卡尔积的查询。对关系型数据库非常了解的用户可能期望在执行JOIN查询的时候不使用ON语句而是使用where语句，这样关系数据库的执行优化器就可以高效地将WHERE语句转化成那个ON语句。不幸的是，Hive并不会执行这种优化，因此，如果表足够大，那么这个查询就会出现不可控的情况。

## 7.JVM重用

JVM重用是Hadoop调优参数的内容，其对Hive的性能具有非常大的影响，特别是对于很难避免小文件的场景或task特别多的场景，这类场景大多数执行时间都很短。

Hadoop的默认配置通常是使用派生JVM来执行map和Reduce任务的。这时JVM的启动过程可能会造成相当大的开销，尤其是执行的job包含有成百上千task任务的情况。JVM重用可以使得JVM实例在同一个job中重新使用N次。N的值可以在Hadoop的mapred-site.xml文件中进行配置。通常在10-20之间，具体多少需要根据具体业务场景测试得出。

```xml
<property>
    <name>mapreduce.job.jvm.numtasks</name>
    <value>10</value>
    <description>
        How many tasks to run per jvm. If set to -1, there is no limit. 
    </description>
</property>
```

这个功能的缺点是，开启JVM重用将一直占用使用到的task插槽，以便进行重用，直到任务完成后才能释放。如果某个“不平衡的”job中有某几个reduce task执行的时间要比其他Reduce task消耗的时间多的多的话，那么保留的插槽就会一直空闲着却无法被其他的job使用，直到所有的task都结束了才会释放。



## 8.推测实行

在分布式集群环境下，因为程序Bug（包括Hadoop本身的bug），负载不均衡或者资源分布不均等原因，会造成同一个作业的多个任务之间运行速度不一致，有些任务的运行速度可能明显慢于其他任务（比如一个作业的某个任务进度只有50%，而其他所有任务已经运行完毕），则这些任务会拖慢作业的整体执行进度。为了避免这种情况发生，Hadoop采用了推测执行（Speculative Execution）机制，它根据一定的法则推测出“拖后腿”的任务，并为这样的任务启动一个备份任务，让该任务与原始任务同时处理同一份数据，并最终选用最先成功运行完成任务的计算结果作为最终结果。

设置开启推测执行参数：Hadoop的mapred-site.xml文件中进行配置

```xml
<property>
    <name>mapreduce.map.speculative</name>
    <value>true</value>
    <description>
        If true, then multiple instances of some map tasks 
        may be executed in parallel.
    </description>
</property>

<property>
    <name>mapreduce.reduce.speculative</name>
    <value>true</value>
    <description>
        If true, then multiple instances of some reduce tasks 
        may be executed in parallel.
    </description>
</property>
```
不过hive本身也提供了配置项来控制reduce-side的推测执行：
```xml
<property>
    <name>hive.mapred.reduce.tasks.speculative.execution</name>
    <value>true</value>
    <description>
    	Whether speculative execution for reducers should be turned on. 
    </description>
</property>
```
关于调优这些推测执行变量，还很难给一个具体的建议。如果用户对于运行时的偏差非常敏感的话，那么可以将这些功能关闭掉。如果用户因为输入数据量很大而需要执行长时间的map或者Reduce task的话，那么启动推测执行造成的浪费是非常巨大大。



## 9.压缩

*详见第八章*



## 10.执行计划(Explain)

**语法**

`EXPLAIN [EXTENDED | DEPENDENCY | AUTHORIZATION] query`

**实操**

```mysql
-- （1）查看下面这条语句的执行计划
hive (default)> explain select * from emp;
hive (default)> explain select deptno, avg(sal) avg_sal from emp group by deptno;
-- （2）查看详细执行计划
hive (default)> explain extended select * from emp;
hive (default)> explain extended select deptno, avg(sal) avg_sal from emp group by deptno;
```


# 十、Hive实战



# 常见错误及解决方案

1）SecureCRT 7.3出现乱码或者删除不掉数据，免安装版的SecureCRT 卸载或者用虚拟机直接操作或者换安装版的SecureCRT 

2）连接不上mysql数据库

​       （1）导错驱动包，应该把mysql-connector-java-5.1.27-bin.jar导入/opt/module/hive/lib的不是这个包。错把mysql-connector-java-5.1.27.tar.gz导入hive/lib包下。

​       （2）修改user表中的主机名称没有都修改为%，而是修改为localhost

3）hive默认的输入格式处理是CombineHiveInputFormat，会对小文件进行合并。

hive (default)> set hive.input.format;

hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat

可以采用HiveInputFormat就会根据分区数输出相应的文件。

hive (default)> set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;

4）不能执行mapreduce程序

​       可能是hadoop的yarn没开启。

5）启动mysql服务时，报MySQL server PID file could not be found! 异常。

​       在/var/lock/subsys/mysql路径下创建hadoop102.pid，并在文件中添加内容：4396

6）报service mysql status MySQL is not running, but lock file (/var/lock/subsys/mysql[失败])异常。

​       解决方案：在/var/lib/mysql 目录下创建： -rw-rw----. 1 mysql mysql        5 12月 22 16:41 hadoop102.pid 文件，并修改权限为 777。

7）JVM堆内存溢出

描述：java.lang.OutOfMemoryError: Java heap space

解决：在yarn-site.xml中加入如下代码

```xml
<property>
	<name>yarn.scheduler.maximum-allocation-mb</name>
	<value>2048</value>
</property>
<property>
  	<name>yarn.scheduler.minimum-allocation-mb</name>
  	<value>2048</value>
</property>
<property>
	<name>yarn.nodemanager.vmem-pmem-ratio</name>
	<value>2.1</value>
</property>
<property>
	<name>mapred.child.java.opts</name>
	<value>-Xmx1024m</value>
</property>
```