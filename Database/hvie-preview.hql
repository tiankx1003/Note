/*
    Hive基本操作
*/
show databases;
use default;
show tables;

create table student(id int, name string)
row format delimited fields terminated by '\t';

load data local inpath '/opt/module/datas/student.txt' 
into table student;

select * from student;
drop table student;

/*
    DDL数据定义
*/

-- 数据库定义
create databases db_hive;
create databases if not exists db_hive; -- 避免已经存在的问题
create databases db_hive2 location '/db_hive2.db'; -- 指定HDFS上存放的位置
-- 查询数据库
show databases like 'db_hive*'; -- 过滤显示查询的数据库
desc databases db_hive;
desc databases extended db_hive; -- 显示详细信息
use db_hive;

-- 修改数据库
alter databases db_hive set dbproperties('createtime'='20190803');
desc databases extended db_hive;

-- 删除数据库
drop databases db_hive2;
drop databases db_hive;
drop databases if exists db_hive;

-- 创建表
create table if exists student2(
    id int, name string
)
row format delimited fields terminated by '\t'
stored as textfile
location '/user/hive/warehouse/student2';

-- 根据查询结果创建表
create table if not exists student3 as
select id, name
from sutdent;

-- 根据已经存在的表的结构创建表
create table if exists student4 like student;
-- 查询表的类型
desc formatted student2;

-- 创建部门表
create external table if not exists default.dept(
    deptno int,
    dname string,
    loc int
)
row format delimited fields terminated by '\t';

-- 创建员工表
create external table if not exists default.emp(
    empno int,
    ename string,
    job string,
    mgr int,
    hiredate string,
    sal double,
    comm double,
    deptno int
)
row format delimited fields terminated by '\t';

show tables; -- 查看创建的表

-- 导入数据
load data local inpath '/opt/module/datas/dept.txt' 
into table default.dept;
load data local inpath '/opt/module/datas/emp.txt'
into table default.emp;

-- 查询结果
select * from emp;
select * from dept;
-- 查看表格式化数据
desc formatted dept;

-- 内部表和外部表的互相转换
-- 查看表的类型
desc formatted student2;
-- 修改内部表为外部表
alter table student2 tblproperties('EXTERNAL'='TRUE');
alter table student2 tblproperties('EXTERNAL'='FALSE');
/* 修改表的类型为固定写法，区分大小写! */

alter table student2 rename to stu; -- 重命名

-- 分区表


-- 修改表




drop table dept_partition; -- 删除表

/*
    DML数据操作
*/

-- 数据导入

-- load
craete table stu(
    id int,
    name string
)
row format delimited fields terminated by '\t';
load data local inpath '/opt/module/datas/student.txt'
into table stu_tab; -- 复制本地数据到Hive表

load data inpath '/user/tian/hive/student.txt'
into table stu_tab; -- 剪切hdfs中的数据到hive

load data local inpath '/opt/module/datas/student.txt'
overwrite into stu_tab;

-- insert
create table stu_tab2 like stu_tab; -- 复制表的结构
insert into table stu_tab2 
partition(month='201709')
values(1,'wangwu');

insert into table stu_tab2
partition(month='201708')
select id, name
from student
where month='201709';

insert overwrite table stu_tab2 
partition(month='201708')
select id, name
from student
where month='201709';

from stu_tab
insert overwrite table stu_tab
partition(month='201709')
select id, name
where month='201708'
insert overwrite table stu_tab
partition(month='201708')
select id, name
where month='201709'; -- 针对来自同一张表的数据的操作，多插入模式

-- as select
create table if not exists student3
as select id, name
from student;

-- location
create table if not exists student5(
    id int,
    name string
)
row format delimited fields terminated by '\t'
location '/user/hive/warehouse/student5';
dfs -put /opt/module/datas/students.txt /user/hive/warehouse/student5;
select * from student5;

-- import
/* 先export导出数据再将数据导入 */
export table default.student to '/user/hive/warehouse/export/student';
import table student2 partition(month='201709')
from '/user/hive/warehouse/export/student';

-- 数据导出

-- insert
-- 查询结果导出到本地，只能使用overwrite，不能使用into
insert overwrite local directory '/opt/module/datas/export/student'
select * from student;
-- 查询结果格式化后导出到本地
insert overwrite local directory '/opt/module/datas/export/student'
row format delimited fields terminated by '\t'
select *
from student;
-- 查询结果导出到hdfs上(语句不带local)
insert overwrite directory '/user/review/student2'
row format delimited fields terminated by '\t'
select * 
from student;

-- hadoop command
dfs -get /user/hive/warehouse/student/month=201709/000000_0
/opt/module/datas/export/student3.txt

-- hive shell
hive -e 'select * from student;' > /opt/module/datas/export/student.txt;

-- export 2 hdfs
export table default.student to '/user/hive/warehouse/export/student';

-- sqoop


-- Truncate
truncate table student; -- truncate只能删除管理表数据，不能删除外部表数据


/*
    DQL查询
*/

-- 基本查询
select * from emp;

select empno, ename 
from emp;

select e.deptno dn 
from emp e;

select count(*) cnt from emp;
select max(sal) max_sal from emp;
select min(sal) min_sal from emp;
select avg(sal) avg_sal from emp;
select sum(sal) sum_sal from emp;

select * 
from emp
limit 5; -- 限制返回行数

select * 
from emp
where sal>1000;

-- like & rlike
select * from emp where sal=5000;
select * from emp where sal between 5000 and 10000;
select * from emp where comm is null;
select * from emp where sal in (1500,5000);

select * from emp where sal like '2%';
select * from emp where sal like '_2%';
select * from emp where sal rlike '[2]'; -- 查找薪水中含有2的员工信息

-- group by
select t.deptno, avg(t.sal) avg_sal 
from emp t 
group by t.deptno;

select t.deptno, t.job, max(t.sal) max_sal
from emp t
group by t.deptno, t.job; -- 每个部门中每个岗位的最高薪水

-- haveing
select deptno, avg(sal) from emp group by deptno;
select deptno, avg(sal) avg_sal
from emp
group by deptno
having avg_sal>2000;

-- join
-- 等值join
select e.empno, e.ename, d.deptno, d.dname
from emp e
join dept d
on e.deptno = d.deptno;

-- 别名
select e.empno, e.ename, d.deptno
from emp e 
join dept d 
on e.deptno = d.deptno

-- 内连接，保留两表都存在且符合条件的内容
select e.empno, e.name, d.deptno
from emp e 
join dept d
on d.deptno = d.deptno;

-- 左外连接，左边表中符合where自居的所有记录将会返回
select e.empno, e.ename, d.deptno
from emp e
left join dept d
on e.deptno = d.deptno;

-- 右外连接，右边表中符合where条件的所有记录被返回
select e.empno, e.name, d.deptno
from emp e
right join dept d
on e.deptno = d.deptno;

-- 满外连接，返回表中符合where语句条件的所有记录，如果任一表的指定字段没有符合条件的值的话，那么就使用null替代
select e.empno, e.ename, d.deptno
from emp e
full join dept d
on e.deptno = d.deptno;

-- 多表连接
-- TODO

-- 连接谓词不支持or
select e.empno, e.name, d.deptno
from emp e
join dept d
on e.deptno = d.deptno or e.ename = d.ename; -- 错误示范

/*
    排序
*/

-- 全局排序(order by)

select *
from emp
order by sal;

select * 
from emp
order by sal desc;

select ename, sal*2 double_sal
from emp
order by double_sal;

select ename, deptno, sal
from emp
order by deptno, sal;

set mapreduce.job.reduces=3; -- 设置reduce个数
select *
from emp
sort by empno desc;

insert overwrite local directory '/opt/module/datas/sortby-result'
select * from emp sort by deptno desc; -- 将查询结果导入到文件中

-- 分区排序(Distribute by)
set mapreduce.job.reduces=3;
insert overwrite local directory '/opt/module/datas/distribute-result'
select * fro emp
distribute by deptno
sort by empno desc;

-- Cluster by,当distribute by和sort by字段相同时，可以用cluster by替代
select * 
from emp
cluster by deptno;
select *
from emp
distribute by deptno
sort by deptno;

/*
    分桶与抽样查询
*/
-- 建立分桶表
create table stu_buck(
    id int, name string
)
clustered by(id)
into 4 buckets
row format delimited fields terminated by '\t';
-- 导入数据
load data local inpath '/opt/module/datas/student.txt' into table stu_buck;

-- 建立分桶表，数据通过子查询的方式导入
create table stu(
    id int, name string
)
row format delimited fileds terminated by '\t';
load data local inpath '/opt/module/datas/student.txt' into table stu;
truncate table stu_buck;
select * from stu_buck;
insert into table stu_buck
select id, name from stu;
set hive.enforce.bucketing=true;
set mapreduce.job.reduces=-1;
insert into table stu_buck
select id, name from stu;
select * from stu_buck;

-- 分桶抽样查询
select * from stu_buck tablesample(buck 1 out of 4 on id);

/*
    其他常用函数
*/
-- 空字段赋值
select nvl(comm,-1) from emp; -- 如果comm为null，则用-1代替
select nvl(comm, mgr) from emp; -- comm为null时，使用领导id代替
select nvl(comm,nvl(mgr,ename)) from emp; -- 当comm为null时用mgr代替，若mgr也为null，使用ename代替

-- case when
create table emp_sex(
    name string,
    dept_id string,
    sex string
)
row format delimited fields terminated by '\t';
load data local inpath '/opt/module/datas/emp_sex.txt' into table emp_sex;

-- 




/*
    案例
*/

-- 统计视频观看数Top10

-- 统计视频类别热度Top10

-- 统计出视频观看数最高的20个视频的所属类别以及类别包含的Top20视频的个数

-- 统计视频观看数Top50所关联视频的所属类别Rank

-- 统计每个类别的视频热度Top10

-- 统计每个类别视频流量Top10

-- 统计上传视频最多的用户Top10以及他们上传的观看次数前20的视频