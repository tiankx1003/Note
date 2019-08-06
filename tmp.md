<p align="right">2019-8-2</p>

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



