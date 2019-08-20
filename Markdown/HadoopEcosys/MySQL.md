# MySQL核心
### 一 DQL
#### 1.基础查询
```sql
select * from emps;
select e_id , e_name salary from emps;
select 常量; #字符型和日期型常量使用单引号，数值型不需要
select 函数名(实参列表);
select e_id i , e_name name , e.salary sal from emps e; #别名
select distinct e_name from emps; #去重
select salary + bonus from emps; #加法运算
select concat(str1,str2,str3); #拼接字符
-- 判断某字段或表达式是否为null，如果为null 返回指定的值，否则返回原本的值
select ifnull(commission_pct,0) from emps;
-- 功能：判断某字段或表达式是否为null，如果是，则返回1，否则返回0
select isnull(e_name) from emps;
```
#### 2.条件查询
种类|运算符
:-:|-
**简单条件运算符** |> < = <> != >= <=  <=>安全等于
**逻辑运算符** |and or not
**模糊查询** |like 通配符 %任意多个字符 _任意单个字符 <br> between and 范围查询<br> in <br> is null/is not null:用于判断null

```sql
select e_id ,e_name ,salary
from emps
where salary > 10000;
select e_id ,e_name ,salary
from emps
where salary between 10000 and 15000;
select e_id ,e_name ,salary
from emps
where e_name like "%a%";
```
#### 3.排序查询
asc ：升序，如果不写默认升序
desc：降序
排序列表 支持 单个字段、多个字段、函数、表达式、别名
order by的位置一般放在查询语句的最后（除limit语句之外）
```sql
select e_id ,e_name ,salary
from emps
where e_id between 11 and 20
order by salary desc;
```
#### 4.常见函数
##### 4.1 函数概述
**功能：**类似于Java中的方法
**好处：**提高重用性和隐藏实现细节
**调用：**select 函数名(实参列表)
##### 4.2单行函数
字符函数| -
:-:|:-:
concat|连接
substr|截取字符串
upper|变大写
lower|变小写
replace|替换
length|获取字节长度
trim|去除前后空格
lpad|左填充
rpad|右填充
instr|获取字串第一次出现的索引

数学函数|-
:-:|:-:
ceil|向上取整
round|四舍五入
mod|取模
floor|向下取整
truncate|截断
rand|获取随机数

日期函数|-
:-:|:-:
now|返回当前日期+时间
year|返回年
month|返回月
day|返回日
date_format|将日期转成字符
curdate|返回当前日期
str_to_date|将字符转成日期
curtime|返回当前时间
hour|小时
minute|分钟
second|秒
datediff|返回两个日期相差的天数
monthname|以英文形式返回月

其他函数|-
:-:|:-:
version|当前数据库服务器的版本
database|当前打开的数据库
user|当前用户
password|返回该字符的密码形式
md5|返回该字符的md5加密形式

**流程控制函数**
①if(条件表达式，表达式1，表达式2)：如果条件表达式成立，返回表达式1，否则返回表达式2
②case情况1
case 变量或表达式或字段
when 常量1 then 值1
when 常量2 then 值2
...
else 值n
end

③case情况2
case 
when 条件1 then 值1
when 条件2 then 值2
...
else 值n
end

##### 4.3分组函数

函数|描述
:-:|:-:
max| 最大值
min| 最小值
sum| 和
avg| 平均值
count| 计算个数

①**语法**
select max(字段) from 表名;
②支持的**类型**
sum和avg一般用于处理数值型
max、min、count可以处理任何数据类型

③以上分组函数都**忽略null**
④都可以搭配**distinct**使用，实现去重的统计
select sum(distinct 字段) from 表;
⑤**count**函数
`count(字段)`：统计该字段非空值的个数
`count(*)`:统计结果集的行数
案例：查询每个部门的员工个数
1 xx    10
2 dd    20
3 mm    20
4 aa    40
5 hh    40
`count(1)`:统计结果集的行数
**效率**上：
MyISAM存储引擎，`count(*)`最高
InnoDB存储引擎，`count(*)`和`count(1)`效率>`count(字段)`
⑥ 和分组函数一同查询的字段，要求是group **by后出现的字段**
#### 5.分组函数
```sql
select 分组函数,分组后的字段
from 表
where 筛选条件
group by 分组的字段
having 分组后的筛选
order by 排序列表
```
筛选时机|使用关键字|筛选的表|位置
:-:|:-:|:-:|:-:
分组前筛选|where|原始表|group by的前面
分组后筛选|having|分组后的结果|group by的后面
#### 6.连接查询
##### 6.1 sql92语法
```sql
-- 等值连接
/*
	① 一般为表起别名
	②多表的顺序可以调换
	③n表连接至少需要n-1个连接条件
	④等值连接的结果是多表的交集部分
*/
select 查询列表
from 表1 别名,表2 别名
where 表1.key = 表2.key
and 筛选条件
group by 分组字段
having 分组后的筛选
order by 排序字段;

-- 非等值连接
select 查询列表
from 表1 别名,表2 别名
where 非等值的连接条件
and 筛选条件
group by 分组字段
having 分组后的筛选
order by 排序字段

-- 自连接
select 查询列表
from 表 别名1,表 别名2
where 等值的连接条件
and 筛选条件
group by 分组字段
having 分组后的筛选
order by 排序字段
```

##### 6.2 sql99语法
```sql
-- 内连接
/*
分类：
    等值连接
    非等值连接
    自连接
特点：
    ①表的顺序可以调换
    ②内连接的结果=多表的交集
    ③n表连接至少需要n-1个连接条件
*/
select 查询列表
from 表1 别名
inner join 表2 别名 on 连接条件
where 筛选条件
group by 分组列表
having 分组后的筛选
order by 排序列表
limit 子句;

-- 外连接
/*
特点：
    ①查询的结果=主表中所有的行，如果从表和它匹配的将显示匹配行，如果从表没有匹配的则显示null
    ②left join 左边的就是主表，right join 右边的就是主表
    full join 两边都是主表
    ③一般用于查询除了交集部分的剩余的不匹配的行
*/
select 查询列表
from 表1 别名
#left|right|full outer join 表2 别名 on 连接条件
left join 表2 别名 on 连接条件
where 筛选条件
group by 分组列表
having 分组后的筛选
order by 排序列表
limit 子句;

-- 交叉连接
/*
    类似于笛卡尔乘积
*/
select 查询列表
from 表1 别名
cross join 表2 别名;
```
#### 7.子查询
**嵌套**在其他语句内部的select语句称为子查询或内查询，
外面的语句可以是insert、update、delete、select等，一般select作为外面语句较多
外面如果为select语句，则此语句称为**外查询或主查询**

按出现**位置**查询
出现位置 | 种类
:-: | -
select后面|仅仅支持标量子查询
from后面|表子查询
where或having后面|标量子查询<br>列子查询<br>行子查询
exists后面|标量子查询<br>列子查询<br>行子查询<br>表子查询
按**结果集**的行列分类
分类|结果集
:-:|-
标量子查询（单行子查询）| 结果集为一行一列
列子查询（多行子查询）| 结果集为多行一列
行子查询| 结果集为多行多列
表子查询| 结果集为多行多列
```sql
/*
where或having后面
1、标量子查询
案例：查询最低工资的员工姓名和工资
*/
-- ①最低工资
select min(salary) from employees

-- ②查询员工的姓名和工资，要求工资=①
select last_name,salary
from employees
where salary=(
	select min(salary) from employees
);
/*
2、列子查询
案例：查询所有是领导的员工姓名
*/
-- ①查询所有员工的 manager_id
select manager_id
from employees

-- ②查询姓名，employee_id属于①列表的一个
select last_name
from employees
where employee_id in(
	select manager_id
	from employees
);
```
#### 8.分页查询
**应用场景**
当要查询的条目数太多，一页显示不全
```sql
select 查询列表
from 表
limit 【offset，】size;.
/*
注意：
offset代表的是起始的条目索引，默认从0卡死
size代表的是显示的条目数

假如要显示的页数为page，每一页条目数为size
*/
select 查询列表
from 表
limit (page-1)*size,size;
```
#### 9.联合查询
**union** 合并、联合，将多次查询结果合并成一个结果
```sql
select * from emps
union
select * from adds
union all
select * from dept;
/*
意义：
    1、将一条比较复杂的查询语句拆分成多条语句
    2、适用于查询多个表的时候，查询的列基本是一致
特点：
    1、要求多条查询语句的查询列数必须一致
    2、要求多条查询语句的查询的各列类型、顺序最好一致
    3、union 去重，union all包含重复项
*/
```
#### 10.查询总结
```sql
-- sql 执行顺序
select 查询列表    ⑦
from 表1 别名       ①
连接类型 join 表2   ②
on 连接条件         ③
where 筛选          ④
group by 分组列表   ⑤
having 筛选         ⑥
order by排序列表    ⑧
limit 起始条目索引，条目数;  ⑨
```
### 二 DML
#### 1.插入
```sql
-- 方式一
insert into emps(e_id,e_name,salary)
values(01,'jack',10000);
-- 一次插入多行
insert into emps(e_id,..) values(值,...),(值,...),...;
-- 支持子查询
insert into emps2
select * from emps;
/*
特点：
1、要求值的类型和字段的类型要一致或兼容
2、字段的个数和顺序不一定与原始表中的字段个数和顺序一致
但必须保证值和字段一一对应
3、假如表中有可以为null的字段，注意可以通过以下两种方式插入null值
①字段和值都省略
②字段写上，值使用null
4、字段和值的个数必须一致
5、字段名可以省略，默认所有列
*/

-- 方式二
insert into emps set e_id=01,e_name='jack',salary=10000;
```
#### 2.修改
```sql
-- 修改单表的记录
update emps set e_id=01,e_name='tom' where salary > 10000;

-- 修改多表的记录
update emps e
right join emps2 e2
on 连接条件
set e.e_id=01,e.e_name='tom'
where 筛选条件;
```
#### 3.删除
```sql
-- 删除单表记录
delete from emps
where 筛选条件
limit 条目数;

-- 级联删除
delete e1 ,e2
from emps1 e1
inner join emps2 e2
on 连接条件
where 筛选条件;

truncate table emps;

/*
两种方式的区别【面试题】★
    1.truncate删除后，如果再插入，标识列从1开始
        delete删除后，如果再插入，标识列从断点开始
    2.delete可以添加筛选条件
        truncate不可以添加筛选条件
    3.truncate效率较高
    4.truncate没有返回值
    delete可以返回受影响的行数
    5.truncate不可以回滚
        delete可以回滚
*/
```
### 三 DDL
#### 1.库的管理
```sql
-- 创建库
create database if not exists 库名 character set 字符集名;
-- 修改库
alter database 库名 character set 字符集名;
-- 删除库
drop database if exists 库名;
```
#### 2.表的管理
```sql
-- 创建表
create table if not exists 表名 (
    字段名 字段类型 约束,
    字段名 字段类型 约束,
    ...
);

-- 修改表
#添加列
alter table 表名 add column 列名 类型 first|alter 字段名;
#修改列的类型或约束
alter table 表名 modify column 列名 新类型 新约束;
#修改列名
alter table 表名 change column 旧列名 新列名 类型;
#删除列
alter table 表名 drop column 列名;
#修改表名
alter table 表名 rename to 新表名;

-- 删除表
drop table if exists 表名;

-- 复制表
#复制表的结构
create table 表名 like 旧表;
#复制表的结构+数据
create table 表名
select 查询列表 from 旧表 
where 筛选条件;
```
#### 3.数据类型
##### 3.1数值型
类型|描述
:-:|-
整型|tinyint<br>smallint<br>mediuint<br>int/integer<br>bigint
浮点型|定点数 decimal(M,D)<br>浮点数 float(M,D) double(M,D)
##### 3.2字符型
char、varchar、binary、varbinary、enum、set、text、blob
**char**：固定长度的字符，写法为char(M)，最大长度不能超过M，其中M可以省略，默认为1
**varchar**：可变长度的字符，写法为varchar(M)，最大长度不能超过M，其中M不可以省略
##### 3.3日期型
类型|描述
:-:|-
year|年
date|日期
time|时间
datetime|日期+时间
timestamp|日期+时间

**timestamp**更容易受时区、语法模式、版本的影响，更能反映当前时区的真实时间
#### 4.约束
##### 4.1常见约束
约束|描述
:-:|-
NOT NULL|非空，该字段的值必填
UNIQUE|唯一，该字段的值不可重复
DEFAULT|默认，该字段的值不用手动插入有默认值
CHECK|检查，mysql不支持
PRIMARY KEY|主键，该字段的值不可重复并且非空  unique+not null
FOREIGN KEY|外键，该字段的值引用了另外的表的字段

**主键和唯一**
区别|相同点
-|-
①一个表至多有一个主键但可以有多个唯一<br>②主键不允许为空，唯一可以为空|都具有唯一性<br>都支持组合键，但是不推荐
**外键**
1、用于限制两个表的关系，从表的字段值引用了主表的某字段值
2、外键列和主表的被引用列要求类型一致，意义一样，名称无要求
3、主表的被引用列要求是一个key（一般就是主键）
4、插入数据，先插入主表
```sql
/*
    删除数据，先删除从表
*/
#级联删除
ALTER TABLE stuinfo ADD 
CONSTRAINT fk_stu_major 
FOREIGN KEY(majorid) 
REFERENCES major(id) 
ON DELETE CASCADE;
#级联置空
ALTER TABLE stuinfo ADD 
CONSTRAINT fk_stu_major 
FOREIGN KEY(majorid) 
REFERENCES major(id) 
ON DELETE SET NULL;
```
##### 4.2创建表时添加约束
```sql
create table 表名(
	字段名 字段类型 not null,#非空
	字段名 字段类型 primary key,#主键
	字段名 字段类型 unique,#唯一
	字段名 字段类型 default 值,#默认
	constraint 约束名 foreign key(字段名) references 主表（被引用列）
);
```
约束类型|支持类型|可以起约束名
:-:|:-:|:-:
列级约束|除了外键|不可以
表级约束|除了非空和默认|可以，但对主键无效
列级约束可以在一个字段上追加多个，中间用空格隔开，没有顺序要求
##### 4.3修改表时添加或删除约束
```sql
-- 非空
#添加非空
alter table 表名 modify column 字段名 字段类型 not null;
#删除非空
alter table 表名 modify column 字段名 字段类型 ;
-- 默认
#添加默认
alter table 表名 modify column 字段名 字段类型 default 值;
#删除默认
alter table 表名 modify column 字段名 字段类型 ;
-- 主键
#添加主键
alter table 表名 add【 constraint 约束名】 primary key(字段名);
#删除主键
alter table 表名 drop primary key;
-- 唯一
#添加唯一
alter table 表名 add【 constraint 约束名】 unique(字段名);
#删除唯一
alter table 表名 drop index 索引名;
-- 外键
#添加外键
alter table 表名 add【 constraint 约束名】 foreign key(字段名) references 主表（被引用列）;
#删除外键
alter table 表名 drop foreign key 约束名;
```

##### 4.4自增长列

```sql
/*
特点：
    1、不用手动插入值，可以自动提供序列值，默认从1开始，步长为1
        auto_increment_increment
        如果要更改起始值：手动插入值
        如果要更改步长：更改系统变量
        set auto_increment_increment=值;
    2、一个表至多有一个自增长列
    3、自增长列只能支持数值型
    4、自增长列必须为一个key
*/
-- 创建表时添加自增长列
create table 表(
	字段名 字段类型 约束 auto_increment
);
-- 修改表时设置自增长列
alter table 表 modify column 字段名 字段类型 约束 auto_increment;
-- 删除自增长列
alter table 表 modify column 字段名 字段类型 约束;
```
### 四 TCL
####事务
**事务**：一条或多条sql语句组成一个执行单位，一组sql语句要么都执行要么都不执行
**特点**
**A 原子性**：一个事务是不可再分割的整体，要么都执行要么都不执行
**C 一致性**：一个事务可以使数据从一个一致状态切换到另外一个一致的状态
**I 隔离性**：一个事务不受其他事务的干扰，多个事务互相隔离的
**D 持久性**：一个事务一旦提交了，则永久的持久化到本地
**步骤**

```sql
-- ①开启事务
set autocommit = 0;
start transaction;#可以省略
-- ②编写一组逻辑sql语句
#注意：sql语句支持的是insert update delete
#设置回滚点
savepoint 回滚点名;

--③结束事务
#提交
commit;
#回滚
rollback;
#回滚到指定地方
rollback to 回滚点名;
```
并发事务
多个事务同时操作同一数据库的相同数据就会发生并发事务；
脏读：一个事务读取了其他事务还没有提交的数据，读到的时其他事务更新的数据；
不可重复读：一个事务多次读取，结果不一样
幻读：一个事务读取了其他事务还没有提交的数据，只是读到的是其他事务插入的数据
通过设置隔离级别来解决并发问题

隔离级别|脏读|不可重复读|幻读
:-:|:-:|:-:|:-:
read uncommitted读未提交|×|×|×
read committed读已提交|√|×|×


### 五 其他
#### 1.视图
本身是一个虚拟表，它的数据来自于表，通过执行时动态生成。

```sql
/*
好处
    1、简化sql语句
    2、提高了sql的重用性
    3、保护基表的数据，提高了安全性
*/
-- 创建
create view 视图名
as 
查询语句;
-- 修改
create or replace view 视图名
as
查询语句;
alter view 视图名
as
查询语句;
-- 删除
drop view 视图1，视图2,...;
-- 查看
desc 视图名;
show create view 视图名;
```
使用|关键字
:-:|:-:
插入|insert
修改|update
删除|delete
查看|select
**注意**视图一般用于查询的，而不是更新的，所以具备下列特点的视图不允许更新
①包含分组函数、group by、distinct、having、union、
②join
③常量视图
④where后的子查询用到了from中的表
⑤用到了不可更新的视图
对比|关键字|物理空间占用|使用
:-:|:-:|:-:|:-:
视图|view|占用较小，只保存sql逻辑|一般用于查询
表|table|保存实际的数据|增删改查
#### 2.变量
##### 2.1系统变量
```sql
-- ①查看系统变量
show global|session variables like ''; 
#如果没有显式声明global还是session，则默认是session
-- ②查看指定的系统变量的值
select @@global|session.变量名; 
#如果没有显式声明global还是session，则默认是session
-- ③为系统变量赋值
set global|session  变量名=值; 
#如果没有显式声明global还是session，则默认是session
set @@global.变量名=值;
set @@变量名=值；
```
**全局变量**：服务器层面上的，必须拥有super权限才能为系统变量赋值，作用域为整个服务器，也就是针对于所有连接（会话）有效
**会话变量**：服务器为每一个连接的客户端都提供了系统变量，作用域为当前的连接（会话）
##### 2.2自定义变量
**用户变量**
**作用域**：针对当前连接(会话)生效
**位置**：begin and里面，也可以放在外面
```sql
-- ①声明并赋值：
set @变量名=值;或
set @变量名:=值;或
select @变量名:=值;

-- ②更新值
set @变量名=值;或
set @变量名:=值;或
select @变量名:=值;
select xx into @变量名 from 表;

-- ③使用
select @变量名;
```
**局部变量**
**作用域**：仅仅在定义它的begin and 中生效
**位置**：只能放在begin and中，而且只能放在第一句
```sql
-- ①声明
declare 变量名 类型 【default 值】;
-- ②赋值或更新
set 变量名=值;或
set 变量名:=值;或
select @变量名:=值;
select xx into 变量名 from 表;
-- ③使用
select 变量名;
```
#### 3.存储过程和函数
##### 3.1概述
类似于java中的方法，将一组完成特定功能的逻辑语句包装起来，对外暴露名字
**好处**
提高重用性
sql语句简单
减少了和数据库服务器连接的次数，提高了效率
##### 3.2存储过程
```sql
-- 创建
create procedure 存储过程名(参数模式 参数名 参数类型)
begin
		存储过程体
end
/*
注意：
    1.参数模式：in、out、inout，其中in可以省略
    2.存储过程体的每一条sql语句都需要用分号结尾
*/

-- 调用
call 存储过程名(实参列表)
#调用in模式的参数
call sp1('值');
#调用out模式的参数
set @name; call sp1(@name);select @name;
#调用inout模式的参数
set @name=值; call sp1(@name); select @name;
-- 查看
show create procedure 存储过程名;
-- 删除
drop procedure 存储过程名;
```
##### 3.3函数
```sql
-- 创建
create function 函数名(参数名 参数类型) returns  返回类型
begin
	函数体
end
/*
注意：函数体中肯定需要有return语句
*/
-- 调用
select 函数名(实参列表);
-- 查看
show create function 函数名;
-- 删除
drop function 函数名；
```
#### 4.流程控制结构
**顺序结构**：程序从上往下依次执行
**分支结构**：程序按条件进行选择执行，从两条或多条路径中选择一条执行
**循环结构**：程序满足一定条件下，重复执行一组语句
##### 分支结构
```sql
-- if函数
/*
功能：实现简单双分支
位置：可以作为表达式放在任何位置
*/
if(条件,值1,值2)

-- case结构
/*
功能：实现多分枝
位置：
    可以放在任何位置，
    如果放在begin end 外面，作为表达式结合着其他语句使用
    如果放在begin end 里面，一般作为独立的语句使用
*/
case 表达式或字段
when 值1 then 语句1;
when 值2 then 语句2；
..
else 语句n;
end [case];

case 
when 条件1 then 语句1;
when 条件2 then 语句2；
..
else 语句n;
end [case];

-- if结构
/*
功能：实现分支
位置：只能发在begin and中
*/
if 条件1 then 语句1;
elseif 条件2 then 语句2;
...
else 语句n;
end if;
```
##### 循环结构
**loop** 一般用于实现简单的死循环
**while** 先判断后执行
**repeat** 先执行后判断，无条件至少执行一次
只能放在begin and中
都能实现循环结构
都可以省略名称，但如果循环中添加循环控制语句(leaver或iterate)则必须添加名称
```sql
-- while
循环名 while 循环条件 do
		循环体
end while 循环名;

-- loop
循环名 loop
		循环体
end loop 循环名;

-- repeat
循环名 repeat
		循环体
until 结束条件 
end repeat 循环名;
```
**循环控制语句**
关键字|描述
:-:|-
leave|类似于break，用于跳出所在的循环
iterate|类似于continue，用于结束本次循环，继续下一次

# MySQL高级

### 一、MySQL高级知识体系

数据库内部结构和原理 
数据库建模优化 
数据库索引建立 
SQL语句优化 
SQL编程(自定义函数、存储过程、触发器、定时任务) 
mysql服务器的安装配置

### 二、Linux安装MySQL
```bash
rpm -qa|grep mysql #查看当前mysql的安装情况
rpm -e --nodeps mysql-libs #卸载之前的mysql
mv MySQL-client-5.5.54-1.linux2.6.x86_64.rpm MySQL-server-5.5.54-1.linux2.6.x86_64.rpm /opte #拷贝到指定目录
rpm -ivh MySQL-client-5.5.54-1.linux2.6.x86_64.rpm #在包所在的目录中安装
rpm -ivh MySQL-server-5.5.54-1.linux2.6.x86_64.rpm
mysqladmin --version #查看mysql版本
rpm -qa|grep MySQL #查看mysql是否安装完成
mysqladmin -u root password #设置密码,需要先启动服务
```


### 三、安装目录

参数 | 路径 | 解释 | 备注
:-: | :-: | :-: |:-:
|  --datadir   |         /var/lib/mysql/         |  mysql数据库文件的存放路径   |                            |
|  --basedir   |            /usr/bin             |         相关命令目录         | mysqladmin mysqldump等命令 |
| --plugin-dir |     /usr/lib64/mysql/plugin     |      mysql插件存放路径       |                            |
| --log-error  | /var/lib/mysql/jack.tian.err |      mysql错误日志路径       |                            |
|  --pid-file  | /var/lib/mysql/jack.tian.pid |         进程pid文件          |                            |
|   --socket   |    /var/lib/mysql/mysql.sock    | 本地连接时用的unix套接字文件 |                            |
|              |        /usr/share/mysql         |         配置文件目录         |    mysql脚本及配置文件     |
|              |        /etc/init.d/mysql        |       服务启停相关脚本       |                            |

### 四、安装后的配置
#### 1.服务项相关操作
```bash
service mysql status #查看服务状态
service mysql start #启动服务
service mysql stop #停止服务
service mysql restart #重启服务
ps -ef|grep mysql #查看进程
chkconfig --list|grep mysql #查看自动状态
ntsysv #取消自启动
```
重复启动服务后会报错，需要杀死进程
```bash
kill mysqld
```

#### 2.修改字符集
```sql
show create table mytable; #查看表的字符集
show create database mydb; #查看库的字符集
show variables like '%char%'; #查看所有和char有关的字串
```

```bash
cp /usr/share/mysql/my-huge.cnf /etc/my.cnf
vim /etc/my.cnf
```
```
[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
[mysqld]
character-set-server=utf8
```

#### 3.设置大小写不敏感
属性设置|描述
-|-
| 0        | 大小写敏感                                                                                          |
| 1        | 大小写不敏感。创建的表，数据库都是以小写形式存放在磁盘上，对于sql语句都是转换为小写对表和DB进行查找 |
| 2        | 创建的表和DB依据语句上格式存放，凡是查找都是转换为小写进行                                          |
```sql
show variables like '%lower_case_table_names%';
```
```
[mysqld]
lower_case_table_names = 1
```

#### 4.sql_mode
属性设置|描述
-|-
| ONLY_FULL_GROUP_BY    | 对于GROUP BY聚合操作，如果在SELECT中的列，没有在GROUP BY中出现，那么这个SQL是不合法的，因为列不在GROUP BY从句中                       |
| NO_AUTO_VALUE_ON_ZERO | 该值影响自增长列的插入。默认设置下，插入0或NULL代表生成下一个自增长值。如果用户 希望插入的值为0，而该列又是自增长的，那么这个选项就有 |
```
sql_mode=ONLY_FULL_GROUP_BY
```

#### 5.用户创建与授权
```sql
#查看用户和权限的相关信息
select host,user,password,select_priv,insert_priv,drop_priv from mysql.user;
create user test identified by 'test'; #新建用户
grant all privileges on *.* to test@'%' identified by 'test'; #授予外部登录权限
grant all privileges on *.* to test@localhost identified by 'test'; #授予本机登录权限
#mysql -h tian01 -P 3306 -u test -p test
```

### 五、MySQL逻辑架构
连接层
服务层
引擎层
存储层

#### 2. show profile
```sql
show variables  like '%profiling%'; #查看profile是否开启
set profiling=1; #开启profile
select * from mytable;
show prifiles; #显示刚才这条sql语句执行了哪些内容
show profile cpu,block io for query 8;
```

#### 3.sql的执行顺序

```sql
-- 手写的顺序
SELECT DISTINCT
    <select_list>
FROM
    <left_table> <join_type>
JOIN <right_table> ON <join_condition>
WHERE
    <where_condition>
HAVING
    <having_condition>
ORDER BY
    <order_by_condition>
LIMIT <limit_number>
```
```sql
-- 执行顺序
FROM <left_table>
ON <join_condition>
<join_type> JOIN <right_table>
WHERE <where_condition>
GROUP BY <group_by_condition>
HAVING <having_condition>
SELECT 
DISTINCT <select_list>
ORDER BY <order_by_condition>
LIMIT <limit_number>
```
#### 4.数据库引擎对比

对比项 | MyISAM | InnoDB
:-: | :-: | :-:
外键 | 不支持 | 支持
事务 | 不支持 | 支持
行表锁 | 表锁，即使操作一条记录也会锁住整个表，不适合高并发的操作 | 行锁,操作时只锁某一行，不对其它行有影响， 适合高并发的操作
缓存 | 只缓存索引，不缓存真实数据 | 不仅缓存索引还要缓存真实数据，对内存要求较高，而且内存大小对性能有决定性的影响
关注点 | 读性能 | 并发写、事务、资源
默认安装 | Y | Y
默认使用 | N | Y
自带系统表使用 | Y | N

```sql
show engines; #查看所有的数据库引擎
show variables like '%storage_engine%'; #查看默认的数据库引擎
```

### 六、主从复制的配置★

```bash
mysqlbinlog /var/lib/mysql/mysql-bin.000001 #
```
binlog_format:binlog日志的格式
STATEMENT:语句级别binlog中记录的都是写的命令
MIXED:混合，自动选取STATEMENT
ROW:行数据级别，binlog记录的哪些行数据发生了变化

### 七、sql预热

```sql
#1.查询所有有门派的人员信息(要求显示门派名称)
#select * from t_emp where deptId is not null;
select * from t_emp e inner join t_dept d on e.deptId = d.id;
#2.查询所有人员及其门派信息
select * from t_emp e left join t_dept d on e.deptId = d.id;
#3.列出所有门派
select * from t_dept;
#4.列出所有无门派人士
select * from t_emp e left join t_dept d on e.deptId = d.id
where d.id is null;
select * from t_emp where deptId is null;
#5.查询所有无人门派
select * from t_dept d left join t_emp e on d.id = e.deptId
where e.id is null;
#6.所有人员和门派的对应关系
select * from t_emp e left join t_dept d on e.deptId = d.id
union
select * from t_dept d left join t_emp e on e.deptId = d.id;
select * from t_emp e left join t_dept d on e.deptId = d.id
union all
select * from t_dept d left join t_emp e on e.deptId = d.id; #union all不去重
#7.没有门派的人员和没有成员的门派
select * from t_emp e left join t_dept d on e.deptId = d.id
where d.id is null
union
select * from t_dept d left join t_emp e on d.id = e.deptId
where e.id is null
#8.1求各个门派对应的掌门人名称
select * from t_dept d left join t_emp e on d.ceo = e.id;
#8.2求所有掌门人的平均年龄
select avg(age)
from (select age from t_dept d left join t_emp e on d.ceo = e.id) tmp;
select avg(age)
from (select * from t_emp e inner join t_dept d on e.id = d.ceo) tmp;.
#8.3所有人物对应的掌门名
select e1.name 'empname',tmp.name 'ceoname'
from t_emp e1 inner join 
(select d.id name from t_dept d left join t_emp e on d.ceo = e.id) tmp
on e1.deptId = tmp.id; #效率最低
select e.name 'empname' ,e1.name 'ceoname'
from t_emp e left join t_dept d on e.deptId = d.id
left join t_emp e1 on d.ceo = e1.id; #数据量大时效率最高
select tmp.name 'empname' ,e1.name 'ceoname'
from 
(select name,ceo from t_emp e left join t_dept d on e.deptId = d.id) tmp
left join t_emp e1 on tmp.ceo = e1.id;
select e.name 'empname' ,(select name from t_emp where id = d.ceo) 'ceoname'
from t_emp e 
left join t_dept d on e.deptId = d.id;
```

### 八、索引优化分析

#### 1.1 B-tree每个节点存储的信息

​	①当前索引列的值
​	②指向下一个节点的指针
​	③指向当前节点所在行所在磁盘块的指针

#### 1.2 B+tree每个到几点存储的信息：

​	①当前索引列的值
​	②当前节点所在行所在磁盘块的指针

B+树的磁盘读写代价更低
B+树的查询效率更加稳定

#### 2. 聚簇索引和非聚簇索引

#### 3.索引分类

单值索引
唯一索引
主键索引
复合索引

#### 4.基本语法

操作|命令
:-:|-
创建| `CREATE  [UNIQUE   ]  INDEX [indexName] ON   table_name(column))`
删除| `DROP INDEX [indexName] ON mytable; `
查看| `SHOW INDEX FROM table_name\G`
使用alter命令| `ALTER TABLE tbl_name ADD PRIMARY KEY (column_list)` : 该语句添加一个主键，这意味着索引值必须是唯一的，且不能为NULL。<br>`ALTER TABLE tbl_name ADD PRIMARY KEY (column_list)ALTER TABLE tbl_name ADD INDEX index_name (column_list)`: 添加普通索引，索引值可出现多次。<br> `ALTER TABLE tbl_name ADD FULLTEXT index_name (column_list)`:该语句指定了索引为 FULLTEXT ，用于全文索引。

#### 5.索引创建时机

**适合**创建索引的情况
主键自动建立唯一索引；
频繁作为查询条件的字段应该创建索引
查询中与其它表关联的字段，外键关系建立索引
单键/组合索引的选择问题， 组合索引性价比更高
查询中排序的字段，排序字段若通过索引去访问将大大提高排序速度
查询中统计或者分组字段

**不适合**创建索引的情况
表记录太少
经常增删改的表或者字段
Where条件里用不到的字段不创建索引
过滤性不好的不适合建索引

```sql
show index from t_emp; #查看有无索引
drop index idx_dept_id on t_emp; #删除索引
create index idx_name on t_emp(name); #新建单值索引
create index idx_name_age on t_emp(name,age); #新建复合索引
```

### 九、Explain性能分析
#### 1.使用方法：Explain + sql语句

#### 2.参数解释
参数|解释
:-:|-
id|代表sql中具体每个表查询的顺序<br>id越大查询优先级越高<br>id越多说明查询越复杂
select type| 查询的类型
table| 基于哪张表查询得到
type(最重要)|定性指标。决定当前sql的效率优劣，一般至少优化到range级别
possible_keys|可能使用的索引
key|最终选择的索引，一般情况下，一次查询，只会选择一个索引
key_len|用于复合索引被使用时，索引使用的充分性，key_len越长，说明索引使用的越充分
ref|使用什么类型的数据去匹配索引
rows|定量的指标，执行查询时必须检查的行数，越少越好（相对于总数）！
Extra|其他的额外重要信息

#### 3.type从优到劣依次为
system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL
**system** 表只有一行数据
**const** 表示通过索引一次就找到，const用于primary key或者unique索引
**eq_ref** 唯一性索引扫描，对于每个索引键，表中只有一条记录与之匹配。常见于主键或唯一索引扫描。
**ref** 非唯一性索引扫描，返回匹配某个单独值的所有行.本质上也是一种索引访问，它返回所有匹配某个单独值的行，然而，它可能会找到多个符合条件的行，所以他应该属于查找和扫描的混合体。
**range** 只检索给定范围的行,使用一个索引来选择行。
**index** 出现index是sql使用了索引但是没用通过索引进行过滤，一般是使用了覆盖索引或者是利用索引进行了排序分组。
**ALL** Full Table Scan，将遍历全表以找匹配的行。
**index_merge** 在查询过程中需要多个索引组合使用，通常出现在有 or 的关键字的sql中。
**ref_or_null** 对于某个字段既需要关联条件，也需要null值得情况下。查询优化器会选择用ref_or_null连接查询。
**index_subquery** 利用索引来关联子查询，不再全表扫描。
**unique_subquery** 该联接类型类似于index_subquery。 子查询中的唯一索引。

#### 4.Extra
**Using filesort** 出现该情况时只需让排序的字段用上索引
**Using temporary** 使用临时表保存中间结果
**Using index** 表示相应的select操作中使用了覆盖索引(Covering Index)，避免访问了表的数据行，效率不错！
**Using where** 使用where过滤
**Using join buffer** 使用了连接缓存，不是一个好的现象，关联操作没有使用关联的字段或关联无效。
**impossible where**
**select tables optimized away**

#### 5.索引优化的位置
```sql
select xxx from table1 join table2 on table1.value1 = table2.value2
where xxx
group by xxx
order by xxx
limit xxx
```
**优化** 
①表关联的字段，通常建立索引
②过滤时，过滤的字段可以建立索引
③group by 后面的字段，可以建立索引
④order by 后面的字段，可以建立索引
⑤select后的字段，尽量按需查询，有可能使用覆盖索引

### 十、批量数据查询
#### 1.建表
#### 2.设置参数
#### 3.编写随机函数


```sql
-- 随机生成一个n位的字符串
delimiter $$
create function rand_string(on TNT) returns vaarchar(255)
begin 
declare
...

-- 随机产生指定范围的编号
```
#### 4.创建存储过程
存储过程是没有返回值的函数
#### 5.调用存储过程
#### 6.批量删除表上的索引


### 十一、使用索引的单表查询
1.**全值匹配**我最爱，**复合索引**性价比高
2.最佳**左前缀**法则：当前字段能使用索引的前提时在索引的结构上，当前字段之前的字段已经全部使用索引
3.索引列上**不计算**（调用函数或类型转换）
4.索引列上不能有**范围**查询
5.按需查询不写`*`
6.使用**不等**号有时导致索引失效
7.当字段允许是null时，**is not null**索引失效 is null 索引生效
8.like前后模糊查询，**%写在左侧**不生效
9.同一个字段使用**or**查询时使用union或者union all替代

### 十二、关联查询优化
#### 1.left join
优化关联查询时，只有在被驱动表上建立索引才有效！
left join时，左侧的为驱动表，右侧为被驱动表。
#### 2.inner join
inner join 时，mysql会自动把小结果集的表选为驱动表，
straight join效果和inner join一样，但是会强制左侧为驱动表。
#### 3.四个关联查询案例分析
子查询尽量不要放在被驱动表，有可能使用不到索引，
left join时，尽量让实体表作为被驱动表。

### 十三、子查询优化
在范围判断时，尽量不要使用not in和not exists，使用 left join on xxx is null代替。

### 十四、排序分组优化
1.无过滤，不索引
2.顺序错，必排序
3.方向反，必排序
4.索引的选择
当范围条件和group by 或者 order by  的字段出现二选一时 ，优先观察条件字段的过滤数量，如果过滤的数据足够多，而需要排序的数据并不多时，优先把索引放在范围字段上。反之，亦然。
5.使用覆盖索引
覆盖索引：SQL只需要通过索引就可以返回查询所需要的数据，而不必通过二级索引查到主键之后再去查询数据。 
6.group by
group by 使用索引的原则几乎跟order by一致 ，唯一区别是groupby 即使没有过滤条件用到索引，也可以直接使2用索引。
