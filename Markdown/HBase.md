TODO

* [ ] -
* [ ] **布隆过滤器** *2019-8-18 16:48:34*
* [ ] **集成Hive** *2019-8-18 16:48:19*
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
put 'student','1003','info:name','ww'
put 'student','1003','info:sex','femal'
put 'student','1003','info:age','22'
-- 查数据
get 'student','1001' -- 查一行数据
get 'student','1001','info:name' -- 获取字段数据
scan 'student'
scan 'student',{STARTROW => '1002',STOPROW => '1002!'} -- 范围左闭右开1002!表示比1002大点的数
-- 删除数据
deleteall 'student','1001' -- 删除整行
delete 'student','1002','info:name' -- 删除字段
truncate 'student' -- 彻底清空数据
drop_namespace 'weibo' # 删除命名空间

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
## 1.环境准备
```xml
    <dependencies>
        <dependency>
            <groupId>org.apache.hbase</groupId>
            <artifactId>hbase-server</artifactId>
            <version>1.3.1</version>
        </dependency>

        <dependency>
            <groupId>org.apache.hbase</groupId>
            <artifactId>hbase-client</artifactId>
            <version>1.3.1</version>
        </dependency>
    </dependencies>
```

## 2.HBase API
```java
package com.tian.hbase.api;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.*;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.filter.CompareFilter;
import org.apache.hadoop.hbase.filter.FilterList;
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.util.Bytes;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

//TODO 创建命名空间

/**
 * HBase工具类，封装静态方法
 *
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 9:00
 */
public class HBaseUtil {
    private static Connection connection = null;

    /*
    静态代码块获取连接
     */
    static {
        try {
            Configuration conf = HBaseConfiguration.create();
            //只需获取zk信息，就可以获取Region信息
            conf.set("hbase.zookeeper.quorum", "hadoop101,hadoop102,hadoop102");
            conf.set("hbase.zookeeper.property.clientPort", "2181"); //添加端口号配置
            connection = ConnectionFactory.createConnection(conf); //赋值
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 创建表
     *
     * @param tableName 表名
     * @param families  列族
     * @throws IOException
     */
    public static void createTable(String tableName, String... families) throws IOException {
        Admin admin = connection.getAdmin();
        //判断表是否已经存在
        if (admin.tableExists(TableName.valueOf(tableName))) {
            System.err.println("table " + tableName + " was already exists!");
            admin.close();
            return;
        }
        HTableDescriptor tableDesc = new HTableDescriptor(TableName.valueOf(tableName));
        //多个列族，循环调用
        for (String family : families) {
            HColumnDescriptor familyDesc = new HColumnDescriptor(family);//列族描述
            tableDesc.addFamily(familyDesc);
        }
        admin.createTable(tableDesc);
        //放回admin
        admin.close();
    }

    /**
     * 修改表最大版本数
     *
     * @param tableName 表名
     * @param family    列族名
     * @throws IOException none
     */
    public static void modifyTable(String tableName, String family) throws IOException {
        Admin admin = connection.getAdmin();
        //判断表是否不存在
        if (!admin.tableExists(TableName.valueOf(tableName))) {
            System.err.println("table " + tableName + " does not exists!");
            admin.close();
            return;
        }
        HColumnDescriptor familyDesc = new HColumnDescriptor(family);
        familyDesc.setMaxVersions(3); //设置最大版本数
        admin.modifyColumn(TableName.valueOf(tableName), familyDesc);
        admin.close();
    }

    /**
     * 删除表
     *
     * @param tableName
     */
    public static void dropTable(String tableName) throws IOException {
        Admin admin = connection.getAdmin();
        //判断表是否不存在
        if (!admin.tableExists(TableName.valueOf(tableName))) {
            System.err.println("table " + tableName + " does not exists!");
            admin.close();
            return;
        }
        admin.disableTable(TableName.valueOf(tableName)); //删除之前先disable
        admin.deleteTable(TableName.valueOf(tableName));
        admin.close();
    }

    /**
     * 打印所有表
     *
     * @throws IOException
     */
    public static void listTables() throws IOException {
        Admin admin = connection.getAdmin();
        TableName[] tableNames = admin.listTableNames();
        System.out.println("---------------- Tables ----------------");
        for (TableName tableName : tableNames) {
            System.out.println(tableName.getNameAsString());
        }
        System.out.println("----------------  done  ----------------");
    }

    /**
     * 打印表的详细信息
     *
     * @param tableName
     * @throws IOException
     */
    @Deprecated
    public static void descTable(String tableName) throws IOException {
        Admin admin = connection.getAdmin();
        //判断表是否不存在
        if (!admin.tableExists(TableName.valueOf(tableName))) {
            System.err.println("table " + tableName + " does not exists!");
            admin.close();
            return;
        }
        HTableDescriptor tableDescriptor = admin.getTableDescriptor(TableName.valueOf(tableName));
        Map<ImmutableBytesWritable, ImmutableBytesWritable> values = tableDescriptor.getValues();
        Set<Map.Entry<ImmutableBytesWritable, ImmutableBytesWritable>> entries = values.entrySet();
        for (Map.Entry<ImmutableBytesWritable, ImmutableBytesWritable> entry : entries) {
            ImmutableBytesWritable value = entry.getValue();
            System.out.println(value.toString());
        }
    }

    /**
     * 添加数据
     *
     * @param tableName
     * @param rowKey
     * @param family
     * @param column
     * @param value
     * @throws IOException
     */
    public static void putCell(String tableName, String rowKey, String family, String column, String value)
            throws IOException {
        Table table = connection.getTable(TableName.valueOf(tableName));
        Put put = new Put(Bytes.toBytes(rowKey));
        //为put对象绑定一行数据对应的信息
        put.addColumn(Bytes.toBytes(family), Bytes.toBytes(column), Bytes.toBytes(value));
        table.put(put);
        table.close();
    }

    /**
     * 查看一行的数据
     *
     * @param tableName
     * @param rowKey
     * @throws IOException
     */
    public static void getRow(String tableName, String rowKey) throws IOException {
        Table table = connection.getTable(TableName.valueOf(tableName));
        Get get = new Get(Bytes.toBytes(rowKey));
//        get.addColumn(); 获取某一列
//        get.setMaxVersions(3); 设置返回最大版本数
        Result result = table.get(get);
        Cell[] cells = result.rawCells();
        for (Cell cell : cells) {
            /*
            下面连个方法的返回值相同,并不能返回需要的内容
             */
            byte[] valueArray = cell.getValueArray();
            byte[] familyArray = cell.getFamilyArray();
            System.out.println(valueArray == familyArray); //验证返回值相同
            byte[] valueBytes = CellUtil.cloneValue(cell);//获取value对应的字节数组
            byte[] columnBytes = CellUtil.cloneQualifier(cell);//获取列名对应的字节数组
            System.out.println(Bytes.toString(columnBytes) + "-" + Bytes.toString(valueBytes));
        }
        table.close();
    }

    /**
     * 按范围获取指定行数据
     *
     * @param tableName
     * @param startRow
     * @param stopRow
     * @throws IOException
     */
    public static void getRowsByRowRange(String tableName, String startRow, String stopRow) throws IOException {
        Table table = connection.getTable(TableName.valueOf(tableName));
        Scan scan = new Scan(Bytes.toBytes(startRow), Bytes.toBytes(stopRow));
        ResultScanner scanner = table.getScanner(scan); //是一个连接，需要关闭，内容为结果集
        for (Result result : scanner) {
            Cell[] cells = result.rawCells();
            for (Cell cell : cells) {
                byte[] rowBytes = CellUtil.cloneRow(cell);
                byte[] valueBytes = CellUtil.cloneValue(cell);//获取value对应的字节数组
                byte[] columnBytes = CellUtil.cloneQualifier(cell);//获取列名对应的字节数组
                System.out.println(Bytes.toString(rowBytes) + "-"
                        + Bytes.toString(columnBytes) + "-"
                        + Bytes.toString(valueBytes));
            }
        }
        scanner.close(); //scanner需要关闭
        table.close();
    }

    /**
     * 通过过滤器查询指定行数据
     *
     * @param tableName
     * @param family
     * @param column
     * @param value
     * @throws IOException
     */
    public static void getRowByColumn(String tableName, String family, String column, String value)
            throws IOException {
        Table table = connection.getTable(TableName.valueOf(tableName));
        Scan scan = new Scan();
        SingleColumnValueFilter filter = new SingleColumnValueFilter(Bytes.toBytes(family),
                Bytes.toBytes(column),
                CompareFilter.CompareOp.EQUAL,
                Bytes.toBytes(value));
        SingleColumnValueFilter filter1 = new SingleColumnValueFilter(Bytes.toBytes(family),
                Bytes.toBytes(column),
                CompareFilter.CompareOp.EQUAL,
                Bytes.toBytes(value));
        filter.setFilterIfMissing(true); //如果没有该过滤条件则，直接过滤
        FilterList filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL);//连个过滤器为与的逻辑关系
        filterList.addFilter(filter);
        filterList.addFilter(filter1);
//        scan.setFilter(filter);
        scan.setFilter(filterList); //多过滤器时传入过滤器集合
        ResultScanner scanner = table.getScanner(scan);
        for (Result result : scanner) {
            Cell[] cells = result.rawCells();
            for (Cell cell : cells) {
                byte[] rowBytes = CellUtil.cloneRow(cell);
                byte[] valueBytes = CellUtil.cloneValue(cell);//获取value对应的字节数组
                byte[] columnBytes = CellUtil.cloneQualifier(cell);//获取列名对应的字节数组
                System.out.println(Bytes.toString(rowBytes) + "-"
                        + Bytes.toString(columnBytes) + "-"
                        + Bytes.toString(valueBytes));
            }
        }
        scanner.close();
        table.close();
    }

    /**
     * 删除一行
     *
     * @param tableName
     * @param rowKey
     * @throws IOException
     */
    public static void deleteRow(String tableName, String rowKey) throws IOException {
        Table table = connection.getTable(TableName.valueOf(tableName));
        Delete delete = new Delete(Bytes.toBytes(rowKey));
        table.delete(delete);
        table.close();
    }

    /**
     * 删除列(最新版本，所有版本)
     * 删除列中指定时间戳的版本
     * 删除最新版本，生成的时间戳和最新版本数据的时间戳一致
     * 删除时指定时间戳就可以删除时间戳对应的指定版本
     *
     * @param tableName
     * @param rowKey
     * @throws IOException
     */
    public static void delete(String tableName, String rowKey,String family,String column) throws IOException {
        Table table = connection.getTable(TableName.valueOf(tableName));
        Delete delete = new Delete(Bytes.toBytes(rowKey));
        delete.addColumn(Bytes.toBytes(family),Bytes.toBytes(column)); //
        delete.addColumn(Bytes.toBytes(family),Bytes.toBytes(column),
                new Long(100000)); //删除时指定时间戳就可以删除时间戳对应的指定版本
//        delete.addColumns(Bytes.toBytes(family),Bytes.toBytes(column));//删除所有版本
        table.delete(delete);
        table.close();
    }

    /**
     * main方法测试工具类方法
     *
     * @param args
     */
    public static void main(String[] args) throws IOException {
//        createTable("class", "info");
//        modifyTable("class","info");
//        dropTable("class");
//        listTables();
//        descTable("class"); //TODO 待补充
//        putCell("class", "1001", "info", "name", "0508");
//        getRow("class","1001");
//        getRowsByRowRange("student","1001","1004");
//        getRowByColumn("student", "info", "name", "zs");
        deleteRow("student", "1001");
    }
}
```

## 3.MapReduce
### 3.1 HBase-MapReduce官方案例


### 3.2 自定义HBase-MapReduce1
**Mapper**
```java
package com.tian.hbase.mr;


import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableMapper;
import org.apache.hadoop.hbase.util.Bytes;

import java.io.IOException;

/**
 * 从HBase读取数据
 * ImmutableBytesWritable实现了WritableComparable接口
 * Put没有实现上述接口，HBase为我们提供了Put的序列化器，TODO 源码
 *
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 15:29
 */
public class ReadMapper extends TableMapper<ImmutableBytesWritable, Put> {
    /**
     * 读取特定的列
     * @param key rowKey
     * @param value Result对象
     * @param context
     * @throws IOException
     * @throws InterruptedException
     */
    @Override
    protected void map(ImmutableBytesWritable key, Result value, Context context) throws IOException, InterruptedException {
        Put put = new Put(key.get());
        Cell[] cells = value.rawCells();
        for (Cell cell : cells) {
            if ("name".equals(Bytes.toString(CellUtil.cloneQualifier(cell))))
//                put.addColumn();
                put.add(cell);
        }
        context.write(key,put);
    }
}
```
**Reducer**
```java
package com.tian.hbase.mr;

import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableReducer;
import org.apache.hadoop.io.NullWritable;

import java.io.IOException;

/**
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 15:30
 */
public class WriteReducer extends TableReducer<ImmutableBytesWritable, Put, NullWritable> {
    /**
     * 归并相同的rowKey后直接写出
     *
     * @param key
     * @param values
     * @param context
     * @throws IOException
     * @throws InterruptedException
     */
    @Override
    protected void reduce(ImmutableBytesWritable key, Iterable<Put> values, Context context) throws IOException, InterruptedException {
        for (Put value : values) {
            context.write(NullWritable.get(), value);
        }
    }
}
```
**Driver**
```java
package com.tian.hbase.mr;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.HRegionPartitioner;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.mapreduce.Job;

import java.io.IOException;

/**
 * 将fruit表中的一部分数据，通过MR迁入到fruit_mr表中
 * TODO 结果验证
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 15:30
 */
public class Driver {
    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        Configuration conf = HBaseConfiguration.create();
        conf.set("hadoop.zookeeper.quorum",
                "hadoop101,hadoop102,hadoop103");
        Job job = Job.getInstance(conf);
        job.setJarByClass(Driver.class);
        /*
        使用HBase工具类初始化
         */
        Scan scan = new Scan();
        TableMapReduceUtil.initTableMapperJob("fruit",scan,ReadMapper.class,
                ImmutableBytesWritable.class,
                Put.class,job);
        job.setNumReduceTasks(100);
        TableMapReduceUtil.initTableReducerJob("fruit_mr",WriteReducer.class,
                job, HRegionPartitioner.class); //TODO 源码
        job.waitForCompletion(true);
    }
}
```
### 3.3 自定义HBase-MapReduce2
**Mapper**
```java
package com.tian.hbase.mr2;

import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

/**
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 16:29
 */
public class ReadMapper extends Mapper<Long, Text, ImmutableBytesWritable, Put> {
    @Override
    protected void map(Long key, Text value, Context context) throws IOException, InterruptedException {
        String line = value.toString();
        String[] split = line.split("\t");//split方法传入的参量是一个正则表达式
        if (split.length<3)
            return;
        Put put = new Put(Bytes.toBytes(split[0])); //split[0]即rowKey
        put.addColumn(Bytes.toBytes("info"),Bytes.toBytes("name"),Bytes.toBytes(split[1]));
        put.addColumn(Bytes.toBytes("info"),Bytes.toBytes("color"),Bytes.toBytes(split[2]));
        context.write(new ImmutableBytesWritable(Bytes.toBytes(split[0])),put);
    }
}
```
**Reducer**
```java
package com.tian.hbase.mr2;

import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableReducer;
import org.apache.hadoop.io.NullWritable;

import java.io.IOException;

/**
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 16:37
 */
public class WriteReducer extends TableReducer<ImmutableBytesWritable,Put,NullWritable> {
    @Override
    protected void reduce(ImmutableBytesWritable key, Iterable<Put> values, Context context)
            throws IOException, InterruptedException {
        for (Put value : values) {
            context.write(NullWritable.get(),value);
        }
    }
}
```
**Driver**
```java
package com.tian.hbase.mr2;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.mapreduce.Job;

import java.io.IOException;

/**
 * @author JARVIS
 * @version 1.0
 * 2019/8/14 16:38
 */
public class Driver {
    public static void main(String[] args) throws IOException, ClassNotFoundException,
            InterruptedException {
        Configuration conf = HBaseConfiguration.create();
        conf.set("hadoop.zookeeper.quorum",
                "hadoop101,hadoop102,hadoop103");
        Job job = Job.getInstance(conf);
        job.setJarByClass(com.tian.hbase.mr.Driver.class);
        job.setMapperClass(ReadMapper.class);
        job.setMapOutputKeyClass(ImmutableBytesWritable.class);
        job.setMapOutputValueClass(Put.class);
        TableMapReduceUtil.initTableReducerJob("fruit_mr",
                WriteReducer.class,job);
        job.setNumReduceTasks(1);
        boolean isSuccess = job.waitForCompletion(true);
//        if (!isSuccess)
//            throw new IOException("Job running with error");
//        return isSuccess ? 0:1;
    }
}
```

## 4.集成Hive

### 4.1 HBase与Hive对比

#### Hive

> **数据仓库**
> Hive的本质其实就相当于将HDFS中已经存储的文件在MySql中做了一个双射关系，以方便使用HQL去管理查询

> **用于数据分析、数据清洗**
> Hive适用于历险的数据分析和清洗，延迟较高

> **基于HDFS、MapReduce**
> Hive存储的数据依旧在DataNode上，编写的HQL语句终将是转换为MapReduce代码执行

#### HBase

> **数据库**
> 是一种面向列存储的非关系型数据库

> **用于存储结构化和非结构化的数据**
> 适用于单表非关系型数据的存储，不适合做关联查询，类似join等操作

> **基于HDFS**
> 数据持久化存储的体现形式时Hfile，存放在DataNode中，被RegionServer以Region的形式进行管理

> **延迟较低，介入的在线业务使用**
> 面对大量的企业数据，HBase可以单线单表大量数据的存储，同时提供了高效的数据访问速度。

### 4.2 HBase与Hive集成使用

#### 环境准备

为解决兼容性问题，使用源码替换依赖重新编译**hive-hbase-handler-1.2.2.jar**
```bash
# 添加软链接
ln -s $HBASE_HOME/lib/hbase-common-1.3.1.jar  $HIVE_HOME/lib/hbase-common-1.3.1.jar
ln -s $HBASE_HOME/lib/hbase-server-1.3.1.jar $HIVE_HOME/lib/hbase-server-1.3.1.jar
ln -s $HBASE_HOME/lib/hbase-client-1.3.1.jar $HIVE_HOME/lib/hbase-client-1.3.1.jar
ln -s $HBASE_HOME/lib/hbase-protocol-1.3.1.jar $HIVE_HOME/lib/hbase-protocol-1.3.1.jar
ln -s $HBASE_HOME/lib/hbase-it-1.3.1.jar $HIVE_HOME/lib/hbase-it-1.3.1.jar
ln -s $HBASE_HOME/lib/htrace-core-3.1.0-incubating.jar $HIVE_HOME/lib/htrace-core-3.1.0-incubating.jar
ln -s $HBASE_HOME/lib/hbase-hadoop2-compat-1.3.1.jar $HIVE_HOME/lib/hbase-hadoop2-compat-1.3.1.jar
ln -s $HBASE_HOME/lib/hbase-hadoop-compat-1.3.1.jar $HIVE_HOME/lib/hbase-hadoop-compat-1.3.1.jar
```

```xml
<!-- hive-site.xml -->
<property>
    <name>hive.zookeeper.quorum</name>
    <value>hadoop101,hadoop102,hadoop103</value>
    <description>
        The list of ZooKeeper servers to talk to. This is only needed for read/write locks.
    </description>
</property>
<property>
    <name>hive.zookeeper.client.port</name>
    <value>2181</value>
    <description>
        The port of ZooKeeper servers to talk to. This is only needed for read/write locks.
    </description>
</property>
```

#### 案例一

```mysql
# 案例一 需求 建立Hive表，关联HBase表，插入数据到Hive表的同时能够影响HBase表
# 建表
CREATE TABLE hive_hbase_emp_table(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,info:ename,info:job,info:mgr,info:hiredate,info:sal,info:comm,info:deptno")
TBLPROPERTIES ("hbase.table.name" = "hbase_emp_table");

# 创建临时中间表
CREATE TABLE emp(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int)
row format delimited fields terminated by '\t';

# 向中间表load数据
load data local inpath '/home/admin/softwares/data/emp.txt' into table emp;

# 通过insert将中间表中的数据导入到Hive关联的HBase表中
insert into table hive_hbase_emp_table select * from emp;
```

#### 案例二

```mysql
# 案例二 需求 在HBase中已经存储了某一张表hbase_emp_table，然后在Hive中创建一个外部表来关联HBase中的hbase_emp_table这张表，使之可以借助Hive来分析HBase这张表中的数据。
# Hive中创建外部表
CREATE EXTERNAL TABLE relevance_hbase_emp(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int)
STORED BY 
'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = 
":key,info:ename,info:job,info:mgr,info:hiredate,info:sal,info:comm,info:deptno") 
TBLPROPERTIES ("hbase.table.name" = "hbase_emp_table");

# 关联后使用hive函数进行分析操作
select * from relevance_hbase_emp;
```

# 五、HBase优化

## 1.高可用

在HBase中Hmaster负责监控RegionServer的生命周期，均衡RegionServer的负载，如果Hmaster挂掉了，那么整个HBase集群将陷入不健康的状态，并且此时的工作状态并不会维持太久。所以HBase支持对Hmaster的高可用配置。

```bash
# 关闭集群后进行配置
stop-hbase.sh
cd $HBASE_HOME
echo hadoop102 > conf/backup-master
xsync $HBASE_HOME/conf/
# 测试，kill hadoop101的master后，hadoop102成为master，重启hadoop101，master仍为hadoop102
# ha可以配置多个
# 若是在hadoop102起hbase，ha节点也是hadoop102，则ha不生效
```

查看页面[http://hadooo101:16010](http://hadoop101:16010)

## 2.预分区

每一个region维护着startRow与endRowKey，如果加入的数据符合某个region维护的rowKey范围，则该数据交给这个region维护。那么依照这个原则，我们可以将数据所要投放的分区提前大致的规划好，以提高HBase性能。

```mysql
# 手动设置预分区
# 四个分区键把负无穷到正无穷分成五个区
create 'staff1','info','partition1',SPLITS => ['1000','2000','3000','4000']

# 指定分区个数和分区语法生成预分区，生成16进制序列预分区
# rowKey设置好预分区规则要协调使用
create 'staff2','info','partition2',{NUMREGIONS => 15, SPLITALGO => 'HexStringSplit'}

# 按照文件中设置的规则预分区
# HBase会自动对分区键进行排序
# aaaa
# bbbb
# cccc
# dddd
create 'staff3','partition3',SPLITS_FILE => 'splits.txt'
```

```java
// 使用API创建预分区
//自定义算法，产生一系列Hash散列值存储在二维数组中
byte[][] splitKeys = 某个散列值函数
//创建HBaseAdmin实例
HBaseAdmin hAdmin = new HBaseAdmin(HBaseConfiguration.create());
//创建HTableDescriptor实例
HTableDescriptor tableDesc = new HTableDescriptor(tableName);
//通过HTableDescriptor实例和散列值二维数组创建带有预分区的HBase表
hAdmin.createTable(tableDesc, splitKeys);
```

```java
Admin admin = connection.getAdmin();
HTableDescriptor tableDesc = new HTableDescriptor(TableName.valueOf("test"));
tableDesc.addFamily(new HColumnDescriptor("info"));
byte[][] splitKeys = new byte[3][];
splitKeys[0] = Bytes.toBytes("aaa");
splitKeys[1] = Bytes.toBytes("bbb");
splitKeys[2] = Bytes.toBytes("ccc");
admin.createTable(tableDesc,splitKeys);
admin.close();
```

## 3.RowKey设计 *视频*

一条数据的唯一标识就是rowkey，那么这条数据存储于哪个分区，取决于rowkey处于哪个一个预分区的区间内，设计rowkey的主要目的
，就是让数据均匀的分布于所有的region中，在一定程度上防止数据倾斜。接下来我们就谈一谈rowkey常用的设计方案。
rowKey的设计最先考虑是要满足**业务需求**,RowKey的设计和预分区协调进行

> **生成随机数、hash、散列值**
>
> ```
> 原本rowKey为1001的，SHA1后变成：dd01903921ea24941c26a48f2cec24e0bb0e8cc7
> 原本rowKey为3001的，SHA1后变成：49042c54de64a1e9bf0b33e00245660ef92dc7bd
> 原本rowKey为5001的，SHA1后变成：7b61dec07e02c188790670af43e717f0f46e8913
> ```
>
> 在做此操作之前，一般我们会选择从数据集中抽取样本，来决定什么样的rowKey来Hash后作为每个分区的临界值。
> 解决Region热点问题(大批的数据写到一个Region)，在rowKey前加指定字符段的hash值前缀，对Region数取余得到位置。这样既能保证相同的字符段对应的RowKey在一块，有解决了热点问题，查询时，先计算hash值
> 不能设计单调递增的rowKey，以防发生热点问题。

> **字符串反转**
>
> ```
> 20170524000001转成10000042507102
> 20170524000002转成20000042507102
> ```
>
> 因为字符串的后端变化频率更高，反转可以一定程度上散列逐步put进来的数据

> **字符串拼接**
>
> ```
> 20170524000001_a12e
> 20170524000001_93i7
> ```

## 4.内存优化

HBase操作过程中需要大量的内存开销，毕竟Table是可以缓存在内存中的，一般会分配整个可用内存的70%给HBase的Java堆。但是不建议分配非常大的堆内存，因为GC过程持续太久会导致RegionServer处于长期不可用状态，一般==**16~48G**===内存就可以了，如果因为框架占用内存过高导致系统内存不足，框架一样会被系统服务拖死。

## 5.基础优化

**1.允许在HDFS的文件中追加内容**
hdfs-site.xml、hbase-site.xml
属性：dfs.support.append
解释：开启HDFS追加同步，可以优秀的配合HBase的数据同步和持久化。默认值为true。
**2.优化DataNode允许的最大文件打开数**
hdfs-site.xml
属性：dfs.datanode.max.transfer.threads
解释：HBase一般都会同一时间操作大量的文件，根据集群的数量和规模以及数据动作，设置为4096或者更高。默认值：4096
**3.优化延迟高的数据操作的等待时间**
hdfs-site.xml
属性：dfs.image.transfer.timeout
解释：如果对于某一次数据操作来讲，延迟非常高，socket需要等待更长的时间，建议把该值设置为更大的值（默认60000毫秒），以确保socket不会被timeout掉。
**4.优化数据的写入效率**
mapred-site.xml
属性：
mapreduce.map.output.compress
mapreduce.map.output.compress.codec
解释：开启这两个数据可以大大提高文件的写入效率，减少写入时间。第一个属性值修改为true，第二个属性值修改为：org.apache.hadoop.io.compress.GzipCodec或者其他压缩方式。
**5.设置RPC监听数量**
hbase-site.xml
属性：hbase.regionserver.handler.count
解释：默认值为30，用于指定RPC监听的数量，可以根据客户端的请求数进行调整，读写请求较多时，增加此值。
**6.优化HStore文件大小**
hbase-site.xml
属性：hbase.hregion.max.filesize
解释：默认值10737418240（10GB），如果需要运行HBase的MR任务，可以减小此值，因为一个region对应一个map任务，如果单个region过大，会导致map任务执行时间过长。该值的意思就是，如果HFile的大小达到这个数值，则这个region会被切分为两个Hfile。
**7.优化HBase客户端缓存**
hbase-site.xml
属性：hbase.client.write.buffer
解释：用于指定HBase客户端缓存，增大该值可以减少RPC调用次数，但是会消耗更多内存，反之则反之。一般我们需要设定一定的缓存大小，以达到减少RPC次数的目的。
**8.指定scan.next扫描HBase所获取的行数**
hbase-site.xml
属性：hbase.client.scanner.caching
解释：用于指定scan.next方法获取的默认行数，值越大，消耗内存越大。
**9.flush、compact、split机制**
当MemStore达到阈值，将Memstore中的数据Flush进Storefile；compact机制则是把flush出来的小文件合并成大的Storefile文件。split则是当Region达到阈值，会把过大的Region一分为二。
涉及属性：
即：128M就是Memstore的默认阈值
hbase.hregion.memstore.flush.size：134217728
即：这个参数的作用是当单个HRegion内所有的Memstore大小总和超过指定值时，flush该HRegion的所有memstore。RegionServer的flush是通过将请求添加一个队列，模拟生产消费模型来异步处理的。那这里就有一个问题，当队列来不及消费，产生大量积压请求时，可能会导致内存陡增，最坏的情况是触发OOM。
hbase.regionserver.global.memstore.upperLimit：0.4
hbase.regionserver.global.memstore.lowerLimit：0.38
即：当MemStore使用内存总量达到HBase.regionserver.global.memstore.upperLimit指定值时，将会有多个MemStores flush到文件中，MemStore flush 顺序是按照大小降序执行的，直到刷新到MemStore使用内存略小于lowerLimit

```
HBase recommend property

hbase.hregion.max.filesize
默认值10737418240（10GB），如果需要运行HBase的MR任务，可以减小此值，因为一个region对应一个map任务，如果单个region过大，会导致map任务执行时间过长。该值的意思就是，如果HFile的大小达到这个数值，则这个region会被切分为两个Hfile。

hbase.regionserver.handler.count
regionserver开启的客户端访问监听器的线程数，默认值30

zookeeper.session.timeout
默认值3分钟，可设为1分钟

hbase.hregion.majorcompaction
设成0，可关闭自动majorcompaction

hfile.block.cache.size
默认0.4，读请求比较多的情况下，可适当调大

hbase.regionserver.global.memstore.size
默认0.4，写请求较多的情况下，可适当调大

hbase.client.write.buffer
客户端的写缓存，默认值2M

hbase.client.scanner.caching
客户端的读缓存，默认1行(MR任务，若map段逻辑复杂，该值需设置较小，反之较大)

hbase.regionserver.region.split.policy=org.apache.hadoop.hbase.regionserver.DisabledRegionSplitPolicy
关闭自动region_split
```





# 六、HBase实战

## 1.需求

1) 微博内容的浏览，数据库表设计
2) 用户社交体现：关注用户，取关用户
3) 拉取关注的人的微博内容

## 2.需求分析

1) 创建命名空间以及表名的定义
2) 创建微博内容表
3) 创建用户关系表
3) 创建用户关系表
4) 创建用户微博内容接收邮件表
5) 发布微博内容
6) 添加关注用户
7) 移除（取关）用户
8) 获取关注的人的微博内容
9) 测试

## 3.表格设计

![](img\hbase-guli-table.png)

## 4.代码实现

```java
package constant;

public class Names {

    public static final String NAMESPACE_WEIBO = "weibo";

    public static final String TABLE_WEIBO = "weibo:weibo";
    public static final String TABLE_RELATION = "weibo:relation";
    public static final String TABLE_INBOX = "weibo:inbox";

    public static final String WEIBO_FAMILY_DATA = "data";
    public static final String RELATION_FAMILY_DATA = "data";
    public static final String INBOX_FAMILY_DATA = "data";

    public static final String WEIBO_COLUMN_CONTENT = "content";
    public static final String RELATION_COLUMN_TIME = "time";

    public static final Integer INBOX_VERSIONS = 3;

}
```

```java
package dao;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.*;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class WeiboDao {

    public static Connection connection = null;

    static {

        try {
            Configuration conf = HBaseConfiguration.create();
            conf.set("hbase.zookeeper.quorum", "hadoop102,hadoop103,hadoop104");
            connection = ConnectionFactory.createConnection(conf);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void createNameSpace(String namespace) throws IOException {

        Admin admin = connection.getAdmin();

        try {
            admin.getNamespaceDescriptor(namespace);
        } catch (NamespaceNotFoundException e) {
            NamespaceDescriptor namespaceDesc = NamespaceDescriptor.create(namespace).build();

            admin.createNamespace(namespaceDesc);
        } finally {
            admin.close();
        }


    }

    public void createTable(String tableName, String... families) throws IOException {
        createTable(tableName, 1, families);
    }

    public void createTable(String tableName, Integer versions, String... families) throws IOException {


        Admin admin = connection.getAdmin();

        if (admin.tableExists(TableName.valueOf(tableName))) {
            System.err.println("table " + tableName + " already exists");
            admin.close();
            return;
        }

        HTableDescriptor tableDesc = new HTableDescriptor(TableName.valueOf(tableName));

        for (String family : families) {
            HColumnDescriptor familyDesc = new HColumnDescriptor(family);
            familyDesc.setMaxVersions(versions);
            tableDesc.addFamily(familyDesc);
        }
        admin.createTable(tableDesc);

        admin.close();
    }

    public void putCell(String tableName, String rowKey, String family, String column, String value) throws IOException {

        Table table = connection.getTable(TableName.valueOf(tableName));

        Put put = new Put(Bytes.toBytes(rowKey));
        put.addColumn(Bytes.toBytes(family), Bytes.toBytes(column), Bytes.toBytes(value));

        table.put(put);

        table.close();
    }

    public List<String> getRowKeysByPrefix(String tableName, String prefix) throws IOException {

        List<String> rowKeys = new ArrayList<>();

        Table table = connection.getTable(TableName.valueOf(tableName));

        Scan scan = new Scan();

        scan.setRowPrefixFilter(Bytes.toBytes(prefix));

        ResultScanner scanner = table.getScanner(scan);

        for (Result result : scanner) {
            byte[] row = result.getRow();
            rowKeys.add(Bytes.toString(row));
        }

        scanner.close();
        table.close();

        return rowKeys;
    }

    public void putCells(String tableName, List<String> rowKeys, String family, String column, String value) throws IOException {

        if (rowKeys.size() == 0) return;
        Table table = connection.getTable(TableName.valueOf(tableName));
        List<Put> puts = new ArrayList<>();

        for (String rowKey : rowKeys) {
            Put put = new Put(Bytes.toBytes(rowKey));
            put.addColumn(Bytes.toBytes(family), Bytes.toBytes(column), Bytes.toBytes(value));
            puts.add(put);
        }

        table.put(puts);

        table.close();
    }

    public List<String> getRowKeysByRange(String tableName, String startRow, String stopRow) throws IOException {

        List<String> rowKeys = new ArrayList<>();
        Table table = connection.getTable(TableName.valueOf(tableName));

        Scan scan = new Scan(Bytes.toBytes(startRow), Bytes.toBytes(stopRow));
        ResultScanner scanner = table.getScanner(scan);

        for (Result result : scanner) {
            byte[] row = result.getRow();
            rowKeys.add(Bytes.toString(row));
        }

        scanner.close();
        table.close();

        return rowKeys;
    }

    public void deleteRow(String tableName, String rowKey) throws IOException {

        Table table = connection.getTable(TableName.valueOf(tableName));
        Delete delete = new Delete(Bytes.toBytes(rowKey));
        table.delete(delete);
        table.close();
    }

    public void deleteColumn(String tableName, String rowKey, String family, String column) throws IOException {

        Table table = connection.getTable(TableName.valueOf(tableName));

        Delete delete = new Delete(Bytes.toBytes(rowKey));
        delete.addColumns(Bytes.toBytes(family), Bytes.toBytes(column));
        table.delete(delete);

        table.close();
    }

    public List<String> getCellsByPrefix(String tableName, String prefix, String family, String column) throws IOException {

        List<String> list = new ArrayList<>();

        Table table = connection.getTable(TableName.valueOf(tableName));
        Scan scan = new Scan();
        scan.addColumn(Bytes.toBytes(family), Bytes.toBytes(column));
        scan.setRowPrefixFilter(Bytes.toBytes(prefix));
        ResultScanner scanner = table.getScanner(scan);
        for (Result result : scanner) {
            Cell[] cells = result.rawCells();
            list.add(Bytes.toString(CellUtil.cloneValue(cells[0])));
        }

        scanner.close();
        table.close();

        return list;
    }

    public List<String> getRow(String tableName, String rowKey) throws IOException {

        List<String> list = new ArrayList<>();

        Table table = connection.getTable(TableName.valueOf(tableName));

        Get get = new Get(Bytes.toBytes(rowKey));
        get.setMaxVersions();
        Result result = table.get(get);
        Cell[] cells = result.rawCells();

        for (Cell cell : cells) {
            list.add(Bytes.toString(CellUtil.cloneValue(cell)));
        }

        table.close();
        return list;
    }

    public List<String> getCellsByRowKeys(String tableName, List<String> rowKeys, String family, String column) throws IOException {

        Table table = connection.getTable(TableName.valueOf(tableName));

        List<Get> gets = new ArrayList<>();
        List<String> weibos = new ArrayList<>();

        for (String rowKey : rowKeys) {
            Get get = new Get(Bytes.toBytes(rowKey));
            get.addColumn(Bytes.toBytes(family), Bytes.toBytes(column));
            gets.add(get);
        }

        Result[] results = table.get(gets);

        for (Result result : results) {
            Cell[] cells = result.rawCells();
            weibos.add(Bytes.toString(CellUtil.cloneValue(cells[0])));
        }
        return weibos;
    }
}
```

```java
package service;

import constant.Names;
import dao.WeiboDao;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class WeiboService {

    private WeiboDao dao = new WeiboDao();

    public void init() throws IOException {

        //1) 创建命名空间以及表名的定义
        dao.createNameSpace(Names.NAMESPACE_WEIBO);

        //2) 创建微博内容表
        dao.createTable(Names.TABLE_WEIBO, Names.WEIBO_FAMILY_DATA);

        //3) 创建用户关系表
        dao.createTable(Names.TABLE_RELATION, Names.RELATION_FAMILY_DATA);

        //4) 创建用户微博内容接收邮件表
        dao.createTable(Names.TABLE_INBOX, Names.INBOX_VERSIONS, Names.INBOX_FAMILY_DATA);
    }

    public void publish(String star, String content) throws IOException {

        //1.在weibo表中插入一条数据
        String rowKey = star + "_" + System.currentTimeMillis();
        dao.putCell(Names.TABLE_WEIBO, rowKey, Names.WEIBO_FAMILY_DATA, Names.WEIBO_COLUMN_CONTENT, content);

        //2.查找star的所有fansId
        String prefix = star + ":followedby:";
        List<String> list = dao.getRowKeysByPrefix(Names.TABLE_RELATION, prefix);

        if (list.size() <= 0) return;

        List<String> fansIds = new ArrayList<>();

        for (String row : list) {
            String[] split = row.split(":");
            fansIds.add(split[2]);
        }

        //3.将weiboID插入到所有fans的inbox中
        dao.putCells(Names.TABLE_INBOX, fansIds, Names.INBOX_FAMILY_DATA, star, rowKey);

    }

    public void follow(String fans, String star) throws IOException {

        //1.往relation表中插入两条数据
        String rowKey1 = fans + ":follow:" + star;
        String rowKey2 = star + ":followedby:" + fans;
        String time = System.currentTimeMillis() + "";
        dao.putCell(Names.TABLE_RELATION, rowKey1, Names.RELATION_FAMILY_DATA, Names.RELATION_COLUMN_TIME, time);
        dao.putCell(Names.TABLE_RELATION, rowKey2, Names.RELATION_FAMILY_DATA, Names.RELATION_COLUMN_TIME, time);

        //2.从weibo表中获取star的近期weiboID
        String startRow = star + "_";
        //azhas_1561651351651
        String stopRow = star + "_|";
        List<String> list = dao.getRowKeysByRange(Names.TABLE_WEIBO, startRow, stopRow);
        if (list.size() <= 0) {
            return;
        }

        int fromIndex = list.size() >= 3 ? list.size() - Names.INBOX_VERSIONS : 0;
        List<String> recentWeiboIds = list.subList(fromIndex, list.size());

        //3.将star的近期weiboId插入到fans的inbox
        for (String recentWeiboId : recentWeiboIds) {
            dao.putCell(Names.TABLE_INBOX, fans, Names.INBOX_FAMILY_DATA, star, recentWeiboId);
        }
    }

    public void unFollow(String fans, String star) throws IOException {

        //1.删除relation表中的两条数据
        String rowKey1 = fans + ":follow:" + star;
        String rowKey2 = star + ":followedby:" + fans;
        dao.deleteRow(Names.TABLE_RELATION, rowKey1);
        dao.deleteRow(Names.TABLE_RELATION, rowKey2);

        //2.删除inbox中fans行的star列
        dao.deleteColumn(Names.TABLE_INBOX, fans, Names.INBOX_FAMILY_DATA, star);
    }

    public List<String> getCellsByPrefix(String tableName, String prefix, String family, String column) throws IOException {
        return dao.getCellsByPrefix(tableName, prefix, family, column);
    }

    public List<String> getAllRecentWeibos(String fans) throws IOException {


        //1.从inbox表中获取fans的所有star的近期weiboId
        List<String> list = dao.getRow(Names.TABLE_INBOX, fans);

        if (list.size() <= 0) return new ArrayList<>();

        //2.从weibo表中获取相应的weibo内容
        return dao.getCellsByRowKeys(Names.TABLE_WEIBO, list, Names.WEIBO_FAMILY_DATA, Names.WEIBO_COLUMN_CONTENT);
    }
}
```

```java
package controller;

import constant.Names;
import service.WeiboService;

import java.io.IOException;
import java.util.List;

public class WeiboController {

    private WeiboService service = new WeiboService();

    public void init() throws IOException {
        service.init();
    }


    //5) 发布微博内容
    public void publish(String star, String content) throws IOException {
        service.publish(star, content);
    }

    //6) 添加关注用户
    public void follow(String fans, String star) throws IOException {
        service.follow(fans, star);
    }

    //7) 移除（取关）用户
    public void unFollow(String fans, String star) throws IOException {
        service.unFollow(fans, star);
    }

    //8) 获取关注的人的微博内容
    //8.1 获取某个star的所有weibo
    public List<String> getWeibosByStarId(String star) throws IOException {
        return service.getCellsByPrefix(Names.TABLE_WEIBO, star, Names.WEIBO_FAMILY_DATA, Names.WEIBO_COLUMN_CONTENT);
    }

    //8.2 获取某个fans的所有star的近期weibo
    public List<String> getAllRecentWeibos(String fans) throws IOException {

        return service.getAllRecentWeibos(fans);
    }

}
```

```java
import controller.WeiboController;

import java.io.IOException;
import java.util.List;

public class WeiboAPP {

    private static WeiboController controller = new WeiboController();

    public static void main(String[] args) throws IOException {

//        controller.init();

//        controller.follow("1001","1002");
//        controller.follow("1001","1003");
//        controller.follow("1001","1004");

//        controller.unFollow("1001","1004");

//        controller.publish("1002", "happy 10.1");
//        controller.publish("1002", "happy 10.2");
//        controller.publish("1002", "happy 10.3");
//        controller.publish("1002", "happy 10.4");
//        controller.publish("1002", "happy 10.5");
//        controller.publish("1002", "happy 10.6");
//        controller.publish("1002", "happy 10.7");

//        List<String> weibos = controller.getWeibosByStarId("1002");
//        if (weibos.size() >= 1) {
//            for (String weibo : weibos) {
//                System.out.println("weibo = " + weibo);
//            }
//        }

        controller.publish("1003","unHappy 10.1");
        controller.publish("1003","unHappy 10.2");
        controller.publish("1003","unHappy 10.3");
        controller.publish("1003","unHappy 10.4");
        controller.publish("1003","unHappy 10.5");

        List<String> weibos = controller.getAllRecentWeibos("1001");

        if (weibos.size() >= 1){
            for (String weibo : weibos) {
                System.out.println("weibo = " + weibo);
            }
        }
    }
}
```

# 七、扩展

## 1.HBase在商业项目中的能力

每天：
1) 消息量：发送和接收的消息数超过60亿
2) 将近1000亿条数据的读写
3) 高峰期每秒150万左右操作
4) 整体读取数据占有约55%，写入占有45%
5) 超过2PB的数据，涉及冗余共6PB数据
6) 数据每月大概增长300千兆字节。

## 2.布隆过滤器

**Bloom Filter**是一种空间效率很高的随机数据结构，它利用位数组很简洁地表示一个集合，并能判断一个元素是否属于这个集合。Bloom Filter的这种高效是有一定代价的：==在判断一个元素是否属于某个集合时，有可能会把不属于这个集合的元素误认为属于这个集合（false positive）==。因此，==Bloom Filter不适合那些“零错误”的应用场合。而在能容忍低错误率的应用场合下，Bloom Filter通过极少的错误换取了存储空间的极大节省。==
布隆过滤器的好处在于快速，省空间，但是有一定的误识别率，常见的补救办法是在建立一个小的白名单，存储那些可能个别误判的邮件地址。

**布隆过滤器算法内容**
[http://blog.csdn.net/jiaomeng/article/details/1495500](http://blog.csdn.net/jiaomeng/article/details/1495500)

## 3.HBase2.0新特性

**最新文档**
[http://hbase.apache.org/book.html#ttl](http://hbase.apache.org/book.html#ttl)

**官方发布主页**
[http://mail-archives.apache.org/mod_mbox/www-](http://mail-archives.apache.org/mod_mbox/www-)
[announce/201706.mbox/<CADcMMgFzmX0xYYso-UAYbU7V8z-](announce/201706.mbox/<CADcMMgFzmX0xYYso-UAYbU7V8z-)
[Obk1J4pxzbGkRzbP5Hps+iA@mail.gmail.com](Obk1J4pxzbGkRzbP5Hps+iA@mail.gmail.com)

[==*详细内容变动*==]([https://issues.apache.org/jira/secure/ReleaseNote.jspa?version=12340859&styleName=&projectId=12310753&Create=Create&atl_token=A5KQ-2QAV-T4JA-FDED%7Ce6f233490acdf4785b697d4b457f7adb0a72b69f%7Clout](https://issues.apache.org/jira/secure/ReleaseNote.jspa?version=12340859&styleName=&projectId=12310753&Create=Create&atl_token=A5KQ-2QAV-T4JA-FDED|e6f233490acdf4785b697d4b457f7adb0a72b69f|lout))