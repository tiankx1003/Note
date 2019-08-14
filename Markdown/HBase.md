TODO

* [ ] -
* [ ] 读数据流程 *2019-8-13 19:17:01*
* [ ] StoreFile Compaction *2019-8-13 19:17:22*
* [ ] Region Split后Region在RegionServer中的具体存放与本地化 *2019-8-13 19:18:24*
* [ ] 操作表中数据在HDFS上的体现 *2019-8-13 19:19:00*

# 一、HBase简介

## 1.HBase定义

HBase是一种分布式、可扩展、支持海量数据存储的NoSQL数据库。

**NoSQL高扩展性**

传统关系型数据库，内容冗余(占用过多存储空间，修改数据不方便)，
为了减少冗余会对表进行规范化，将不同的数据放入不同的表，通过join查询(性能低)
多张表分区到不同的服务器节点，当join两台服务器上的表时会更慢

NoSQL，存储廉价，避免join把数据存放在一张表，虽然有冗余，但是性能高。
一张表易于分区。

## 2.HBase数据模型

逻辑上，HBase的数据模型同关系型数据库很类似，数据存储在一张表中，有行有列。但从HBase的底层物理存储结构（K-V）来看，HBase更像是一个multi-dimensional
map。

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

### 2.1 逻辑架构

![](img\hbase-logic-struc.png)



### 2.2 物理存储结构

![](img\hbase-physics-struc.png)



### 2.3 数据模型

> **Name Space**
> 命名空间，类似于关系型数据库的database概念，每个命名空间下有多个表。HBase两个自带的命名空间，分别是hbase和default，hbase中存放的是HBase内置的表，default表是用户默认使用的命名空间。

> **Table**
> 类似于关系型数据库的表概念。不同的是，HBase定义表时只需要声明列族即可，不需要声明具体的列。这意味着，往HBase写入数据时，字段可以动态、按需指定。因此，和关系型数据库相比，HBase能够轻松应对字段变更的场景。

> **Row**
> HBase表中的每行数据都由一个**RowKey**和多个**Column**（列）组成，数据是按照RowKey的字典顺序存储的，并且查询数据时只能根据RowKey进行检索，所以RowKey的设计十分重要。

> **Column**
> HBase中的每个列都由Column Family(列族)和Column Qualifier（列限定符）进行限定，例如info：name，info：age。建表时，只需指明列族，而列限定符无需预先定义。

> **Time Stamp**
> 用于标识数据的不同版本（version），每条数据写入时，系统会自动为其加上该字段，其值为写入HBase的时间。

> **Cell**
> 由{rowkey,column Family：column Qualifier, time Stamp} 唯一确定的单元。cell中的数据是没有类型的，全部是字节码形式存贮。



## 3.HBase基本架构

![](img\hbase-simple-struc.png)

### 架构角色

一个store可能有多个storefile，storefile存放在hdfs上，hdfs自身有冗余，所以storeFile不需要额外设置副本
一个Region Server内有若干个Region
Region Server部署在DataNode所在的节点，确保Region Server本地节点一定有一个StoreFile副本
当Region Server宕机时，Master(通过zk监听节点)将该Region Server的工作交个其他Region Server，暂时的数据非本地化,Master通过HA确保安全性

> **RegionServer**
> Data:get，put，delete,即对数据的增删改查
> Region:splitRegion,compactRegion(切分压缩Region)

> **Master**
> Table:create, delete, alter
> RegionServer:分配regions到每个RegionServer，监控每个RegionServer

> **Zookeeper**
> HBase通过zk完成master的高可用、RegionServer的监控、元数据的入口以及集群配置的维护等工作

> **HDFS**
> HDFS为HBase提供最终的底层数据存储服务，同时为HBase提供高可用的支持



# 二、基本操作

## 1.安装部署

```bash
# 启动zk hadoop
tar -zxvf hbase-1.3.1-bin.tar.gz -C /opt/module
vim hbase-env.sh
vim hbase-site.xml
vim regionservers
mv hbase-1.3.1/ hbase/
# 软链接hadoop配置文件到hbase,每个节点配置了hadoop环境变量可以省略这一步
ln -s /opt/module/hadoop-2.7.2/etc/hadoop/core-site.xml /opt/module/hbase/conf/core-site.xml
ln -s /opt/module/hadoop-2.7.2/etc/hadoop/hdfs-site.xml /opt/module/hbase/conf/hdfs-site.xml
xsync /opt/module/hbase/ # 分发配置
# 启停
hbase-daemon.sh start master
hbase-daemon.sh start regionserver
start-hbase.sh # 启动方法二
stop-hbase.sh
hbase shell # 启动交互
```

```properties
export JAVA_HOME=/opt/module/jdk1.8.0_144
export HBASE_MANAGES_ZK=false
```

```xml
<configuration>
	<property>     
		<name>hbase.rootdir</name>     
		<value>hdfs://hadoop101:9000/hbase</value>   
	</property>

	<property>   
		<name>hbase.cluster.distributed</name>
		<value>true</value>
	</property>

   <!-- 0.98后的新变动，之前版本没有.port,默认端口为60000 -->
	<property>
		<name>hbase.master.port</name>
		<value>16000</value>
	</property>

	<property>   
		<name>hbase.zookeeper.quorum</name>
	     <value>hadoop101,hadoop102,hadoop103</value>
	</property>

	<property>   
		<name>hbase.zookeeper.property.dataDir</name>
	     <value>/opt/module/zookeeper-3.4.10/zkData</value>
	</property>
</configuration>
```

```
hadoop101
hadoop102
hadoop103
```

[hbase页面](http://hadoop101:16010)

## 2.shell操作

### 2.1 DDL

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

### 2.2 DML

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
scan 'student',{VERSIONS => 10,RAW => TRUE} # 返回底层还没真正删除的数据(最终会删除)
delete 'student','1001','info:name'
scan 'student',{VERSIONS => 10}
scan 'student',{VERSIONS => 10,RAW => TRUE}
```

# 三、HBase进阶

## 1.RegionServer架构

![](img\hbase-struc.png)

**详细架构**
RegionServer先把数据写到wal，再写入store中的MemStore(内存)，达到一定数量后在刷写到StoreFile，
WAL(write ahead log)预写日志，数据先行写到wal，wal和storefile都存放在hdfs上的文件
一个RegionServer中的所有Region中的Store公用一个WAL(日志为kv类型)，key为store位置，value为
BlockCache，读缓存，和MemStore(写缓存)相对应

每个RegionServer服务多个Region
每个RegionServer中有的多个Strore，一个WAL，一个BlockCache
每个Store对应一个列族，包含MemStore和StoreFile

> **StoreFile**
> 保存实际数据的物理文件，StoreFile以Hfile的形式存储在HDFS上。每个Store会有一个或多个StoreFile（HFile），数据在每个StoreFile中都是有序的。

> **MemStore**
> 写缓存，由于HFile中的数据要求是有序的，所以数据是先存储在MemStore中，排好序后，等到达刷写时机才会刷写到HFile，每次刷写都会形成一个新的HFile。

> **WAL**
> 由于数据要经MemStore排序后才能刷写到HFile，但把数据保存在内存中会有很高的概率导致数据丢失，为了解决这个问题，数据会先写在一个叫做Write-Ahead logfile的文件中，然后再写入MemStore中。所以在系统出现故障的时候，数据可以通过这个日志文件重建。

> **BlockCache**
> 读缓存，每次查询出的数据会缓存在BlockCache中，方便下次查询。

## 2.写流程

![](img\hbase-write.png)

1. Client先访问zk，获取hbase:meta表位于哪个Region Server
2. 访问对应的Region Server，获取hbase:meta表，根据读请求的namespce:table/rowkey,查询出目标数据位于哪个Region Server中的哪个Region中，并将该table的region信息以及meta表的位置信息缓存在客户端的meta cache，便于下次访问
3. 与目标Region Server进行通讯
4. 将数据顺序写入(追加)到WAL
5. 将数据写入对应的MemStore，数据会在MemStore进行排序
6. 向客户端发送ack
7. 等达到MemStore的刷写时机后，将数据刷写到HFile

## 3.MemStore Flush

![](img\hbase-memstore-flush.png)

### MemStore刷写时机

1. 当某个MemStore的大小达到==$hbase.hregion.memstore.flush.size$(默认128M)==，其==所在的region的所有memstore都会刷写==，当MemStore的大小达到$hbase.hregion.memstore.flush.size * hbase.hregion.memstore.block.multiplier$ (默认为`128M * 4`)时，会==阻止继续==往该MemStore写数据
2. 当Region Server中MemStore的总大小达到==$java\_heapsize * hbase.reigonsrver.global.memstore.size * hbase.regionserver.global.memstore.size.lower.limit$==(默认为java_heapsize * 0.4 * 0.95)，Region会按照所有MemStore的大小顺序(由大到小)一次进行刷写，直到region server中所有memstore的总大小减小到上述阈值。
   当Region Server中MemStore的总大小达到==$java\_heapsize * hbase.regionserver.global.memstore.size$==(默认为java_heapsize * 0.4)时，会阻止继续往所有的MStore写数据
3. 到大自动刷写的时间，也会触发MemStore flush，自动刷新的时间间隔由该属性进行配==$hbase.regionserver.optionalcacheflushinterval$==(默认为1小时)
4. 当WAL文件数量超过==hbase.regionserver.max.logs==,region会按照时间顺序一次进行刷写，直到WAL文件数量减小到==hbase.regionserver.max.log==以下(该属性名已经被废弃，无序手动设置，最大值为31)。
5. 除了上述自动刷新时机，MemStore还可以==手动刷写==

## 4.读流程

### 4.1 整体流程

![](img\hbase-read.png)

### 4.2 Merge细节

![](img\hbase-merge.png)

### 4.3 读流程详述

HFile中的数据不是按照实际数据插入的顺序存放，…

1. Client先访问zk，获取hbase;meta表位于哪个Region Server
2. 访问对应的Region Server，获取hbase:meta表，根据读请求的namespace:table/rowkey查询出目标位于哪个Region Server中的哪个Region中，并将该table的region信息及meta表的位置信息缓存在客户端的meta cache，便于下次访问。
3. 与目标Region Server进行通讯
4. 分别在MemStore和StoreFile(Hfile)中查询目标数据，并将查询到的所有数据进行合并，此处所有数据是指同一条数据的不同版本(time stamp)或者不同的类型(put/delete)
5. 将查询到的新的数据块(Block，HFile数据存储单元，默认大小64kb)缓存到Block Cache
6. 将合并后的最终结果返回给客户端

## 5.StoreFile Compaction

由于memstore每次刷写都会生成一个新的HFile，且同一个字段的不同版本（timestamp）和不同类型（Put/Delete）有可能会分布在不同的HFile中，因此查询时需要遍历所有的HFile。为了减少HFile的个数，以及清理掉过期和删除的数据，会进行StoreFile Compaction。
Compaction分为两种，分别是==$Minor Compaction$==和==$Major Compaction$==。Minor Compaction会将临近的若干个较小的HFile合并成一个较大的HFile，并==清理掉部分过期和删除的数据==。Major Compaction会将一个Store下的所有的HFile合并成一个大HFile，并且==会清理掉所有过期和删除的数据==。

![](img\hbase-storefile-compaction.png)

RegionServer合并HFile，并删除标记为删除的数据和超过版本数的数据
Minor Compaction不会合并所有的HFile，选3-10个较小的相邻的HFile，合并成一个更大的HFile，并执行==**部分**==物理删除
小合并在遇到delete标记时并不能删除所有相关的数据，因为还有相关数据存放在别的HFile中，所以delete标记所在的数据也不能删除，必须留着提示客户端该数据被标记删除，防止读取并返回别的HFile中的数据
Major Compaction会合并所有的HFile并删除数据，并对整体HFile中的数据进行排序

## 6.Region Split

默认情况下，每个Table==最初只有一个Region==，随着数据的不断写入，Region会自动进行拆分，刚拆分时，两个子Region都位于当前的Region Server，但是出于负载均衡的考虑，HMaster有可能会将某个Region转移给其他的Region Server，分裂最初Region若交给别的Region远程管理，发生==Major Compaction==时才会实现Region的==本地化==。

**Region Split时机**
0.94版本之前，当一个Region的某个Store所有StoreFile的总大小超过==$hbase.hregion.max.filesize$==，该Region就会进行拆分。
0.94版本之后，为了充分发挥分布式高并发处理任务的优势，让Region在前期更容易拆分，当一个Region中的某个Store下所有的StoreFile的总大小超过==$Min(initialSize * R ^ 3 , hbase.hregion.max.filesize)$==，该Region就会进行拆分，其中initialSize默认为$2 * hbase.hregion.memstore.flush.size$,R为当前Region Server中属于该Table的个数。

> 具体切分策略为(假设每次切分的子Region都存放在当前RegionServer)，实际以该table在当前RegionServer中Region的数量决定)
> 第一次split: $1^3 * 256 = 256MB$
> 第二次split: $2^3 * 256 = 2048MB$
> 第三次split: $3^3 * 256 = 6912MB$
> 第四次split: $4^3 * 256 = 16384MB > 10GB$ 因此取较小的值10GB
> 其后的每次split的size都是10GB

![](img\hbase-region-split.png)

# 四、HBase API