定义
开源分布式分析引擎，提供Hadoop/Spark之上的SQL查询接口及多维分析(OLAP)能力以支持超大规模数据，能在亚秒内查询巨大的Hive表，在即席查询方面广泛应用。

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
在Kylin中对每个OLAP概念中的Cube称为Cuboid
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

架构
