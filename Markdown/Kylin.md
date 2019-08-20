# 一、概述
## 1.定义
**Apache Kylin**是一个开源的分布式分析引擎，提供Hadoop/Spark之上的SQL查询接口及多维分析(OLAP)能力以支持超大规模数据，最初由eBay开发并贡献至开源社区。它能在亚秒内查询巨大的Hive表，在即席查询方面应用广泛。

## 2.前置知识

Kylin术语
Data Warehouse(数据仓库)
Business Intelligence(商业智能)
OLAP(online analytical processing)
$2^n-1$种角度
OLAP Cube
MOLAP基于多维数据集，一个多维数据集称为一个OLAP Cube
预计算每个OLAP Cube
通过降维获取不同角度
Cuboid

OLAP中所有的Cube在Kylin中并称为Cube

维度建模
星形模型
事实表中必须有可度量字段，事实表中每条数据对应一个实际的事件
维度表，用于描述事件，单个字段对应的事件
雪花模型
在星星模型的基础上，每个维度表再划分
Dimension(维度) & Measure(度量)
分析数据的角度
被分析的数据

数仓表的同步类型
增量同步
全量同步，针对修改无法使用增量同步

## 3.Kylin架构
![](img\kylin-struc.png)
**数据源**(离线--Hive 实时--Kafka)
**底层运算**使用Spark(比mr快)
>**REST Server**
REST Server是一套面向应用程序开发的入口点，旨在实现针对Kylin平台的应用开发工作。 此类应用程序可以提供查询、获取结果、触发cube构建任务、获取元数据以及获取用户权限等等。另外可以通过Restful接口实现SQL查询，Rest集成了多种接口用于处理不同的请求。

>**查询引擎(Query Engine)**
当cube准备就绪后，查询引擎就能够获取并解析用户查询。它随后会与系统中的其它组件进行交互，从而向用户返回对应的结果。

>**路由器(Routing)**
用于查询没有预计算的维度，在最初设计时曾考虑过将Kylin不能执行的查询引导去Hive中继续执行，但在实践后发现Hive与Kylin的速度差异过大，导致用户无法对查询的速度有一致的期望，很可能大多数查询几秒内就返回结果了，而有些查询则要等几分钟到几十分钟，因此体验非常糟糕。最后这个路由功能在发行版中默认关闭。

>**元数据管理工具(Metadata)**
Kylin是一款元数据驱动型应用程序。元数据管理工具是一大关键性组件，用于对保存在Kylin当中的所有元数据进行管理，其中包括最为重要的cube元数据。其它全部组件的正常运作都需以元数据管理工具为基础。 Kylin的元数据存储在hbase中。

>**任务引擎(Cube Build Engine)**
这套引擎的设计目的在于处理所有离线任务，其中包括shell脚本、Java API以及Map Reduce任务等等。任务引擎对Kylin当中的全部任务加以管理与协调，从而确保每一项任务都能得到切实执行并解决其间出现的故障。

## 4.特点
>**标准SQL接口**
即便Kylin不基于关系型数据库，仍具备标准的SQL结构

>**支持超大数据集**
Kylin对于大数据的支撑能力可能是目前所有技术中最为领先的。早在2015年eBay的生产环境中就能支持百亿记录的秒级查询，之后在移动的应用场景中又有了千亿记录秒级查询的案例

>**亚秒级响应**
Kylin拥有优异的查询相应速度，这点得益于预计算，很多复杂的计算，比如连接、聚合，在离线的预计算过程中就已经完成，这大大降低了查询时刻所需的计算量，提高了响应速度

>**可伸缩性和高吞吐率**
单节点Kylin可实现每秒70个查询，还可以搭建Kylin的集群

>**BI工具集成**
Kylin可以与现有的BI工具集成，具体包括如下内容。
ODBC：与Tableau、Excel、PowerBI等工具集成
JDBC：与Saiku、BIRT等Java工具集成
RestAPI：与JavaScript、Web网页集成
Kylin开发团队还贡献了**Zepplin**的插件，也可以使用Zepplin来访问Kylin服务

# 二、环境搭建
[**官网地址**http://kylin.apache.org/cn/](http://kylin.apache.org/cn/)
[**官方文档**http://kylin.apache.org/cn/docs/](http://kylin.apache.org/cn/docs/)
[**下载地址**http://kylin.apache.org/cn/download/](http://kylin.apache.org/cn/download/)
```bash
# 解压
tar -zxvf apache-kylin-2.5.1-bin-hbase1x.tar.gz -C /opt/module/
# 使用Kylin需要配置HADOOP_HOME,HIVE_HOME,HBASE_HOME，并添加PATH
# 先启动hdsf,yarn,historyserver,zk,hbase
start-dfs.sh # hadoop101
start-yarn.sh # hadoop102
mr-jobhistoryserver.sh start historyserver # hadoop101
start-zk # shell
start-hbase.sh
jpsall # 查看所有进程
# --------------------- hadoop101 ----------------
# 3360 JobHistoryServer
# 31425 HMaster
# 3282 NodeManager
# 3026 DataNode
# 53283 Jps
# 2886 NameNode
# 44007 RunJar
# 2728 QuorumPeerMain
# 31566 HRegionServer
# --------------------- hadoop102 ----------------
# 5040 HMaster
# 2864 ResourceManager
# 9729 Jps
# 2657 QuorumPeerMain
# 4946 HRegionServer
# 2979 NodeManager
# 2727 DataNode
# --------------------- hadoop103 ----------------
# 4688 HRegionServer
# 2900 NodeManager
# 9848 Jps
# 2636 QuorumPeerMain
# 2700 DataNode
# 2815 SecondaryNameNode
```
[**Web页面**http://hadoop101:7070/kylin/](http://hadoop101:7070/kylin/)

# 三、具体使用

## 1.数据准备
```sql
# 建表 user_info
create external table user_info(
id string,
user_name string,
gender string,
user_level string,
area string
)
partitioned by (dt string)
row format delimited fields terminated by "\t";

# payment_info
create external table payment_info(
id string,
user_id string,
payment_way string,
payment_amount double
)
partitioned by (dt string)
row format delimited fields terminated by "\t";

# 插入数据
load data local inpath "/opt/module/datas/user_0101.txt" overwrite into table user_info partition(dt='2019-01-01');
load data local inpath "/opt/module/datas/user_0102.txt" overwrite into table user_info partition(dt='2019-01-02');
load data local inpath "/opt/module/datas/user_0103.txt" overwrite into table user_info partition(dt='2019-01-03');

load data local inpath "/opt/module/datas/payment_0101.txt" overwrite into table payment_info partition(dt='2019-01-01');
load data local inpath "/opt/module/datas/payment_0102.txt" overwrite into table payment_info partition(dt='2019-01-02');
load data local inpath "/opt/module/datas/payment_0103.txt" overwrite into table payment_info partition(dt='2019-01-03');
```
## 2.项目创建
[**Web页面**http://hadoop101:7070/kylin/](http://hadoop101:7070/kylin/)
**用户名**:ADMIN
**密码**:KYLIN

## 3.创建Module
![](img/kylin/kylin-module01.png)
![](img/kylin/kylin-module02.png)
![](img/kylin/kylin-module03.png)
![](img/kylin/kylin-module04.png)
![](img/kylin/kylin-module05.png)
![](img/kylin/kylin-module06.png)
![](img/kylin/kylin-module07.png)
![](img/kylin/kylin-module08.png)
![](img/kylin/kylin-module09.png)
![](img/kylin/kylin-module10.png)
![](img/kylin/kylin-module11.png)
![](img/kylin/kylin-module12.png)
![](img/kylin/kylin-module13.png)
![](img/kylin/kylin-module14.png)
![](img/kylin/kylin-module15.png)
![](img/kylin/kylin-module16.png)

## 4.创建Cube
![](img/kylin/kylin-cube01.png)
![](img/kylin/kylin-cube02.png)
![](img/kylin/kylin-cube03.png)
![](img/kylin/kylin-cube04.png)
![](img/kylin/kylin-cube05.png)
![](img/kylin/kylin-cube06.png)
![](img/kylin/kylin-cube07.png)
![](img/kylin/kylin-cube08.png)
![](img/kylin/kylin-cube09.png)
![](img/kylin/kylin-cube10.png)
![](img/kylin/kylin-cube11.png)
![](img/kylin/kylin-cube12.png)
![](img/kylin/kylin-cube13.png)
![](img/kylin/kylin-cube14.png)

## 5.使用进阶

### 5.1 每日全量维度表
按照上述流程创建项目时会出现报错`USER_INFO Dup key found`
**报错原因**
module中的多维度表(user_info)为每日全量表，使用整张表作为维度表，必然会出现同一个user_id对应多条数据的问题
>**解决方案一**
在hive中创建维度表的临时表，该临时表中存放前一天的分区数据，在kylin中创建模型时选择该临时表作为维度表

>**解决方案二**
使用视图(view)实现方案一的效果
```sql
# 创建维度表视图(视图获取前一天分区的数据)，
create view user_info_view as select * from user_info where dt=date_add(current_date,-1);
# 本案例日期为确定值
create view user_info_view as select * from user_info where dt=2019-1-1;
# 创建视图后在DataSource中重新导入，并创建项目(module,cube)
# 查询数据
select u.user_level, sum(p.payment_amount)
from payment_info p
join user_info_view
on p.user_id = u.id
group by u.user_level;
```
### 5.1 编写脚本自动创建Cube
**build cube**
```sh
#! /bin/bash
cube_name=payment_view_cube
do_date=`date -d '-1 day' +%F`

#获取00:00时间戳，Kylin默认零时区，改为东八区
start_date_unix=`date -d "$do_date 08:00:00" +%s`
start_date=$(($start_date_unix*1000))

#获取24:00的时间戳
stop_date=$(($start_date+86400000))

curl -X PUT -H "Authorization: Basic QURNSU46S1lMSU4=" -H 'Content-Type: application/json' -d '{"startTime":'$start_date', "endTime":'$stop_date', "buildType":"BUILD"}' http://hadoop101:7070/kylin/api/cubes/$cube_name/build
```

# 四、Cube构建原理

HBase rowKey
Cuboid id + 维度值

Kylin根据任务复杂度和资源自动决定构建算法

# 五、Cube构建优化
**Cube构建优化**
尽可能减少Cuboid个数

**衍生维度原理**
通过衍生关系减少Cuboid个数，
不使用真正的维度构建，使用外键维度构建，
在查询后通过函数(衍生)关系计算结果，
当有多个结果时，再增加一次聚合，
即牺牲查询效率，增加构建效率
事实表中必须有字段(外键)通过函数关系确定维度表中的字段
这个函数关系称为衍生关系

**使用聚合组**
>**强制维度**
必须带有指定字段作为维度
A,B,C中最终确定了，A,AB,AC,ABC四个维度

>**联合维度**
必须把某些字段作为一个整体确定维度
A,B,C中把BC,作为整体，确定了
A,ABC,BC三个维度

>**层级维度**
A>B>C的层级关系，
维度中有低等级出现时，比它等级高的所有字段必须出现
确定维度为A,AB,ABC
如年，月，日字段
有价值的维度为年，年月，年月日

**Row Key优化**
>**被用作where过滤条件的维度放在前边**
HBase中的rowKey是按照字典顺序排列，
* 拖动web界面中拖动rowKey即可调整

>**基数大的维度放在基数小的维度前边**
根据Cuboid id确定基数大小，基数小的放在后面可以增加聚合度
因为HBase中Compaction

**并发粒度优化**
Kylin把任务转发到HBase，
在HBase中Region个数决定了并发度
通过调整`keylin.hbase.region.cut`的值决定并发

调整`kylin.hbase.region.count.min`实现预分区效果
`kylin.hbase.region.count.max`

# 六、BI工具集成

**JDBC**
```xml
<dependencies>
    <dependency>
        <groupId>org.apache.kylin</groupId>
        <artifactId>kylin-jdbc</artifactId>
        <version>2.5.1</version>
    </dependency>
</dependencies>
```
```java
package com.atguigu;

import java.sql.*;

public class TestKylin {

    public static void main(String[] args) throws Exception {

        //Kylin_JDBC 驱动
        String KYLIN_DRIVER = "org.apache.kylin.jdbc.Driver";
        //Kylin_URL，FirstProject替换为相互名
        String KYLIN_URL = "jdbc:kylin://hadoop101:7070/FirstProject";
        //Kylin的用户名
        String KYLIN_USER = "ADMIN";
        //Kylin的密码
        String KYLIN_PASSWD = "KYLIN";
        //添加驱动信息
        Class.forName(KYLIN_DRIVER);
        //获取连接
        Connection connection = DriverManager.getConnection(KYLIN_URL, KYLIN_USER, KYLIN_PASSWD);
        //预编译SQL
        PreparedStatement ps = connection.prepareStatement("SELECT sum(sal) FROM emp group by deptno");
        //执行查询
        ResultSet resultSet = ps.executeQuery();
        //遍历打印
        while (resultSet.next()) {
            System.out.println(resultSet.getInt(1));
        }
    }
}
```

**Zepplin**
```bash
tar -zxvf zeppelin-0.8.0-bin-all.tgz -C /opt/module/
mv zeppelin-0.8.0-bin-all/ zeppelin
bin/zeppelin-daemon.sh start
```
[Zepplin Web界面http://hadoop101:8080](http://hadoop101:8080)

