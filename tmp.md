<p align="right"><b><i>▼2019-8-2</i></b></p>

CentOS7安装mysql前卸载依赖**mariadb**

▼如果MySQL已经修改过编码方式不是latin1，hive连接mysql后自动创建metastore时会出错
**解决方法**:自己提前创建一个metastore并指定编码方式为latin1，

管理表和外部表**转换**时一定注意大小写

Hive**分区表**，把数据集按业务逻辑分割，增加查询效率
建表语句中指定分区字段

```mysql
create table dept_partition(
	deptno int, dname string, loc string
)
partitioned by (month string)
row format delimited fields terminated by '\t';

alter table dept_partition
add partition(month='201906') partition(month='201907');

# 删除多个分区用逗号隔开
alter table dept_partition
drop partition(month='201906'), partition(month='201907');

desc stu_partition;

# 二级分区
create table stu_partition2(
	name string, age int
)
partitioned by (month string, day string)
row format delimited fields terminated by '\t';

show partitions stu_partition2;
```

Hive分区表增删分区语法不同，增加分区用空格隔开多个的分区，**删除用逗号隔开**
分区字段不能与列名**重名**
数据上传到分区目录，让分区表和数据产生关联的方式

group by注意**分组字段**问题 *2019-8-2 15:37:45*

```mysql
select deptno, avg(sal) avg_sal
from emp
where job != "clerk"
group by deptno
having avg_sal > 2000;
```

sort by设置多个Reducer后把数据**随机**放入多个文件中

<p align="right"><b><i>▼2019-8-12</i></b></p>

**Kafka**
自定义拦截器的close()方法在Producer的close()方法中调用时调用
onSend()方法和onAcknowledgement()不在同一个线程，有共享数据注意线程安全
注意拦截器链返回null值的问题

flume-kafka.conf

```properties
# define
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# source
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F -c +0 /opt/module/datas/flume.log
a1.sources.r1.shell = /bin/bash -c

# sink
a1.sinks.k1.type = org.apache.flume.sink.kafka.KafkaSink
a1.sinks.k1.kafka.bootstrap.servers = hadoop101:9092,hadoop102:9092,hadoop103:9092
a1.sinks.k1.kafka.topic = first
a1.sinks.k1.kafka.flumeBatchSize = 20
# other configure
a1.sinks.k1.kafka.producer.acks = 1
a1.sinks.k1.kafka.producer.linger.ms = 1

# channel
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# bind
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
```

**需求**
多种日志分类放入不同的topic
event的header键值对中的键为topic

exactly once语义

<p align="right"><i><b>▼2019-8-13</b></i></p>

**NoSQL高扩展性**

传统关系型数据库，内容冗余(占用过多存储空间，修改数据不方便)，
为了减少冗余会对表进行规范化，将不同的数据放入不同的表，通过join查询(性能低)
多张表分区到不同的服务器节点，当join两台服务器上的表时会更慢

NoSQL，存储廉价，避免join把数据存放在一张表，虽然有冗余，但是性能高。
一张表易于分区。

**HBase数据模型**
和关系型数据库类似有行和列，到那时底层存储为kv，更像是一个多维
Name Space (命名空间)类似于关系型数据库的database概念
两个自带的命名空间(hbase,default,hbase存放的时HBase中内置的表，default表是用户默认使用的命名空间)
Table 类似与关系型数据库的表概念，不同的是定义表时只需要声明列族，不需要声明列名，后续插入数据时声明列名，这样能够轻松应付字段变更的场景
Cell row key , column family, column qualifier timestamp和value共同确定的键值对

> 逻辑结构
> 列族(column family)  若干个列的组合，相同列族的列会存在一起(相同的文件中)
> 列(column)  列名在建表时无需声明，在插入数据时声明列名，很强的列扩展性，适用于字段经常变更的场景
> 行键(Row key) HBase中的查询条件只能是Row key，Row key可以自行设计(HBase的灵魂)，Row key的设计需要考虑到后续的查询，Row key排序为字典顺序排序(查询效率高，有序则可以使用多种排序算法，如二分法查找)
> 分区(Region) 单表易于分区，并发处理提高速度
> Store Region可以再通过列族分割
> *不同的Region存在不同的节点，不同的Store存放在不同的文件中StroreFile(.hfile)*
> *无数据类型，存放的数据全是字节数组*

> 物理存储结构
> 一个store中的一行数据子底层为一张表，底层的一行数据对应store中一行中的一个单元
> 底层的一行数据可以看作一个多维kv，key为Row key，Column Family， Column Qualifier，(TimeStamp，Type)
> 多维key中的TimeStamp和Type不需要人为设置，
> HBase中所有的增删改在底层都是增的操作(追加写操作效率高)，
> 插入数据(put) 修改数据(put，新的时间节点直接覆盖旧的时间节点的内容) ，
> 删除(DeleteColumn，DeleteFamily，Delete，增加一条Type为删除的数据，查询时，查到delete标记则不返回)
> TimeStamp实现了一个字段内容有多个版本的功能
> Type有多种类型，DeleteColumn，DeleteFamily，Delete

**基本架构**
一个store可能有多个storefile，storefile存放在hdfs上，hdfs自身有冗余，所以storeFile不需要额外设置副本
一个Region Server内有若干个Region
Region Server部署在DataNode所在的节点，确保Region Server本地节点一定有一个StoreFile副本
当Region Server宕机时，Master(通过zk监听节点)将该Region Server的工作交个其他Region Server，暂时的数据非本地化
Master通过HA确保安全性

> RegionServer的作用
> Data:get，put，delete,即对数据的增删改查
> Region:splitRegion,compactRegion(切分压缩Region)

> Master的作用
> Table:create, delete, alter
> RegionServer:分配regions到每个RegionServer，监控每个RegionServer



**安装配置**

**DDL**

```sql
help
list
create 'student','info' -- 创建表
-- 描述表
describe 'student'
-- 增加版本数
alter 'student',{NAME=>'info',VERSIONS=>3}
-- 增加列族
alter 'student','msg'
-- 删除列族
alter 'student',{NAME => 'msg',METHOD => 'delete'}
-- 删除表
disable 'student'
enable 'student'
disable 'student'
drop 'student'
```

**DML**

```mysql
create 'student','info'
-- 增加数据
put 'student','1001','info:name','zs'
put 'student','1001','info:sex','male'
put 'student','1001','info:age','18'
put 'student','1002','info:name','ls'
put 'student','1002','info:sex','femal'
put 'student','1002','info:age','20'
-- 查数据
get 'student','1001' -- 查一行数据
get 'student','1001','info:name' -- 获取字段数据
scan 'student'
scan 'student',{STARTROW => '1002',STOPROW => '1002!'} -- 范围左闭右开1002!表示比1002大点的数
-- 删除数据
deleteall 'student','1001' -- 删除整行
delete 'student','1002','info:name' -- 删除字段
truncate 'student' -- 彻底清空数据

-- 多版本
alter 'student',{NAME => 'info',VERSIONS => 2}
put 'student','1001','info:name','Janna'
put 'student','1001','info:name','zs'
scan 'student' -- 返回最新数据
scan 'student',{VERSIONS => 2} -- 返回两个版本
put 'student','1001','info:name','wangwu'
scan 'student',{VERSIONS => 2} -- 返回最新两个版本
scan 'student',{VERSIONS => 10} -- 返回最新两个版本
scan 'student',{VERSIONS => 10,RAW => TRUE} -- 返回底层还没真正删除的数据(最终会删除)
delete 'student','1001','info:name'
scan 'student',{VERSIONS => 10}
scan 'student',{VERSIONS => 10,RAW => TRUE}
```

**详细架构**
RegionServer先把数据写到wal，再写入store中的MemStore(内存)，达到一定数量后在刷写到StoreFile，
WAL(write ahead log)预写日志，数据先行写到wal，wal和storefile都存放在hdfs上的文件
一个RegionServer中的所有Region中的Store公用一个WAL(日志为kv类型)，key为store位置，value为
BlockCache，读缓存，和MemStore(写缓存)相对应

每个RegionServer服务多个Region
每个RegionServer中有的多个Strore，一个WAL，一个BlockCache
每个Store对应一个列族，包含MemStore和StoreFile

**写流程**
访问zk获取元数据的表的位置信息，通过该信息请求元数据信息并获取meta(RegionServer信息)，并把meta放入缓存。
通过meta确定目标位置的RegionSever，并把数据写入到相应节点的wal
wal把数据写入到MemStore，向客户端发送ack
当MemStore中的数据达到阈值时刷写到StoreFile

**MemStore Flush**五种刷写时机
刷写以Region为单位，一个MemStore刷写时，所有MemStore都会flush
所以可能会有小文件刷写情况，为了避免小文件，我们设计Region时。。。
有一个独立的线程按照一定的时间间隔检查MemStore中内容的大小是否满足刷写条件，所以MemStore中内容可能超过阈值
WAL内的log文件滚动，在MemStore中的数据刷写完成后，可以删除，WAL中文件的数量达到阈值也会导致MemStore Flush

**读流程** 视频
HFile中的数据不是按照实际数据插入的顺序存放，

**StoreFile Compaction** 视频
RegionServer合并HFile，并删除标记为删除的数据和超过版本数的数据
Minor Compaction不会合并所有的HFile，选3-10个较小的相邻的HFile，合并成一个更大的HFile，并执行==**部分**==物理删除
小合并在遇到delete标记时并不能删除所有相关的数据，因为还有相关数据存放在别的HFile中，所以delete标记所在的数据也不能删除，必须留着提示客户端该数据被标记删除，防止读取并返回别的HFile中的数据
Major Compaction会合并所有的HFile并删除数据，并对整体HFile中的数据进行排序

**Region Split**
每个Table最初只有一个Region，随着数据不断写入，Region会自动分裂
分裂时机
某个Store下的所有StoreFile总大小超过阈值(0.94版本前后该阈值不同,为了利用分布式高并发的优势，新版本修改了阈值计算公式)
Region Split分裂后的Region在RegionServer中的具体存放与传输 视频
分裂最初Region若交给别的Region远程管理，发生Major Compaction时才会实现Region的本地化

操作表中数据在HDFS的具体体现 视频
增删数据，手动flush，查看数据(添加版本个数)，手动合并



LSM型数据库

<p align="right"><b><i>▼2019-8-14</i></b></p>

**HBase API**

官网查看API说明文档
创建连接(zk，RegionServer，Master)
Connection连接线程安全，可只创建一个对象线程共享
Table和Admin线程不安全，
不推荐缓存和池
Admin用于DDL操作 `Connection.getAdmin()`
Table用于get,put,delete,scan ``

添加依赖
见maven工程

**MapReduce**
从HBase读数据的InputFormat
往HBase写数据的OutputFormat
配置环境

hadoop-env.sh中添加`export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/opt/module/hbase/lib/*​`
官方hbase-mapreduce
自定义

<p align="right"><b><i>▼2019-8-16</i></b></p>

**谷粒微博**

▼表的设计

用户表user

| id   | name | gender | age  |
| ---- | ---- | ------ | ---- |
|      |      |        |      |

粉丝表fans

| id   | name | gender | age  |
| ---- | ---- | ------ | ---- |
|      |      |        |      |

明星表start

| id   | name | gender | age  |
| ---- | ---- | ------ | ---- |
|      |      |        |      |

中间表relation

fans|start
:-|:-
 aa |XX
 aa |YY
 bb |XX
 bb |YY

微博表weibo

id | content| time|user_id(foreign key)
:-|:-|:-|:-
| | | 

user和weibo为一对多关系，weibo表端添加外键来建立关系
fans和start为多对多关系，再建立一张中间表来建立关系

非关系型数据库的设计

weibo
rowKey|content
:-|:-
user_id_time| |

user
rowKey|data(time)
:-|:-
 aa:follow:bb | 
 aa:follow:cc | 
 bb:follow:cc | 
 cc:followedby:aa | 

inbox
rowKey| data(start) |
:-|:-|--
user_id| |



user_id_time为user_id和时间戳的拼接，user_id能保证所有相同user_id在一块，time保证了天然排序
weibo表通过用户名之间加连接符拼接成rowKey，连接符的不同表示关注与被关注
当有关注发生时插入两条数据(关注，被关注)
增加收件箱inbox表来增加查询速度，rowKey为user_id,列族为data，每个start为一个列，版本数来确定最新的几次微博内容
这种inbox设置有过大的冗余，通过牺牲查询速度减少冗余，内个版本的数据内存放为微博表user_id_time

weibo表方案二，rowKey为user_id，列族fans和star，每添加一个fans就在指定列族中添加一个列名，star同理

