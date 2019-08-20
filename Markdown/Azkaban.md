# TODO

* [ ] **邮件提醒设置** *2019-8-19 12:44:57*
* [ ] **Hive脚本任务** *2019-8-19 12:45:37*

# 一、概述

## 1.概念

Azkaban是由Linkedin公司推出的一个批量工作流任务调度器，主要用于在一个工作流内以一个特定的顺序运行一组工作和流程，它的配置是通过简单的key:value对的方式，通过配置中的Dependencies 来设置依赖关系。Azkaban使用job配置文件建立任务之间的依赖关系，并提供一个易于使用的web用户界面维护和跟踪你的工作流。

一套工作流程有前后依赖关系，实现工作流程的提交
实现无人值守定时调度

## 2.工作调度

> 一个完整的数据分析系统通常都是由**大量任务单元组成**：
Shell脚本程序，Java程序，MapReduce程序、Hive脚本等

>各任务单元之间存在时间先后及前后**依赖关系**

>为了很好地组织起这样的复杂执行计划，需要一个工作流调度系统来调度执行；
>例如，我们可能有这样一个需求，某个业务系统每天产生20G原始数据，我们每天都要对其进行处理，处理步骤如下所示：
>
>```
>1)	通过Hadoop先将原始数据上传到HDFS上（HDFS的操作）；
>2)	使用MapReduce对原始数据进行清洗（MapReduce的操作）；
>3)	将清洗后的数据导入到hive表中（hive的导入操作）；
>4)	对Hive中多个表的数据进行JOIN处理，得到一张hive的明细表（创建中间表）；
>5)	通过对明细表的统计和分析，得到结果报表信息（hive的查询操作）；
>```

![](img\azkaban-workflow.png)

## 3.特点

> **Azkaban兼容任何版本的Hadoop**
> Azkaban的调度框架不依赖于Hadoop框架
> 友好的Web交互界面
> 定时调度
> 监控

> **简单的工作流上传**
> 直接在Web页面提交

> **方便设置任务之间的依赖关系**
> 易于解决复杂的依赖关系

> **调度工作流**
> 最根本的作用

> **模块化和可插拔的插件机制**
> Web服务器(任务上传与展示)
> Executor Server(执行任务)
> 兼容多种工作类型(使用插件实现)
> 可自定义插件

> **认证/授权(权限工作)**
> 对于工作流的操作可以配置权限

> **能够杀死并重新启动工作流**
> 自动失败重试

> **电子邮件提醒**
> 用于提醒用户任务的成功或失败

## 4.常见工作流调度系统

> **简单的任务调度**
> 直接使用crontab实现；

> **复杂的任务调度**
> 开发调度平台或使用现成的开源调度系统，比如ooize、azkaban等

## 5.架构

![](img\azkaban-struc.png)

> **Web Server**
> 整个工作流系统的主要管理者，用户认证，project管理，定时调度，跟踪工作流执行进度等一系列任务。

> **Executor Server**
> 负责具体的工作流的提交、执行，它们通过mysql数据库来协调任务的执行。

> **MySQL**
> 存储大部分执行流状态，AzkabanWebServer和AzkabanExecutorServer都需要访问数据库。

> **Azkaban工作流程**
> 通过配置文件定义工作流程(workflow)
> 通过Web Server上传工作流程
> 文件被存放在MySQL
> 设置定时调度或立即执行
> 指定任务请求发给Executor
> Executor收到命令后把MySQL中的文件下载到本地
> 并执行任务，把执行任务的状态存入MySQL
> Web Server读取MySQL中的任务执行状态

# 二、安装部署

[==**下载地址**==](http://azkaban.github.io/downloads.html)

```bash
mkdir /opt/module/azkaban
tar -zxvf azkaban-web-server-2.5.0.tar.gz -C /opt/module/azkaban/
tar -zxvf azkaban-executor-server-2.5.0.tar.gz -C /opt/module/azkaban/
tar -zxvf azkaban-sql-script-2.5.0.tar.gz -C /opt/module/azkaban/
mv azkaban-web-2.5.0/ server
mv azkaban-executor-2.5.0/ executor
mysql -uroot -proot # 建表
keytool -keystore keystore -alias jetty -genkey -keyalg RSA # 生成密钥和整数
tzselect # 同步时间
```

```sql
create database azkaban;
use azkaban;
source /opt/module/azkaban/azkaban-2.5.0/create-all-sql-2.5.0.sql;
```

```bash
# Web Server 配置
vim /opt/module/azkaban/server/conf/azkaban.properties
vim /opt/module/azkaban/server/conf/azkaban-users.xml
```

```properties
#默认web server存放web文件的目录
web.resource.dir=/opt/module/azkaban/server/web/
#默认时区,已改为亚洲/上海 默认为美国
default.timezone.id=Asia/Shanghai
#用户权限管理默认类（绝对路径）
user.manager.xml.file=/opt/module/azkaban/server/conf/azkaban-users.xml
#global配置文件所在位置（绝对路径）
executor.global.properties=/opt/module/azkaban/executor/conf/global.properties
#数据库连接IP
mysql.host=hadoop101
#数据库用户名
mysql.user=root
#数据库密码
mysql.password=000000
#SSL文件名（绝对路径）
jetty.keystore=/opt/module/azkaban/server/keystore
#SSL文件密码
jetty.password=000000
#Jetty主密码与keystore文件相同
jetty.keypassword=000000
#SSL文件名（绝对路径）
jetty.truststore=/opt/module/azkaban/server/keystore
#SSL文件密码
jetty.trustpassword=000000
# mial settings
mail.sender=Tiankx1003@gmial.com
mail.host= stmp.gmail.com
mail.user=Tiankx1003@gmail.com
mail.password=Tt181024
# web 配置
job.failure.email= 
# web 配置
joa.success.email= 
```

```xml
<azkaban-users>
	<user username="azkaban" password="azkaban" roles="admin" groups="azkaban" />
	<user username="metrics" password="metrics" roles="metrics"/>
	<user username="admin" password="admin" roles="admin,metrics"/>
	<role name="admin" permissions="ADMIN" />
	<role name="metrics" permissions="METRICS"/>
</azkaban-users>
```

```bash
# Executor Server 配置
vim /opt/module/azkaban/server/conf/azkaban.properties
```

```properties
#时区
default.timezone.id=Asia/Shanghai
executor.global.properties=/opt/module/azkaban/executor/conf/global.properties
mysql.host=hadoop101
mysql.database=azkaban
mysql.user=root
mysql.password=000000
```

先启动executor在执行web，避免web server因为找不到executor启动失败

```bash
bin/azkaban-executor-start.sh # executor
bin/azkaban-web-start.sh # server
jps
bin/azkaban-executor-shutdown.sh
bin/azkaban-web-shutdown.sh
```

[==**Web页面查看 https://hadoop101:8443**==](hattps://hadoop101:8443)

# 三、实战

## 1.单一Job(传参、执行脚本、邮件通知)

```properties
# first.job
type=command
command=echo 'this is first job'
```

```properties
# second.job
type=command
command=sh p1.sh
```

```sh
# 文件中追加时间,date.sh
echo date >> /opt/module/datas/date.txt
```

```bash
zip first.zip first.job # 打成zip包
zip second.zip second.job date.sh # 同一目录打包可使用相对路径
```

## 2.多Job工作流

```properties
#start.job
type=command
command=touch /opt/module/kangkang.txt
```

```properties
#step1.job
type=command
dependencies=start
command=echo "this is step1 job"
```

```properties
#step2.job
type=command
dependencies=start
command=echo "this is step2 job"
```

```properties
#finish.job
type=command
dependencies=step1,step2
command=echo "this is finish job"
```

```bash
zip jobs.zip start.job step1.job step2.job finish.job
```

## 3.Java操作任务

```java
package com.tian.javajob;

import java.io.FileOutputStream;
import java.io.IOException;

/**
 * 打包成JavaJob.jar
 * 
 * @author JARVIS
 * @version 1.0
 * 2019/8/19 11:05
 */
public class AzkabanTest {
    public void run() throws IOException {
        // 根据需求编写具体代码
        FileOutputStream fos = new FileOutputStream("/opt/module/azkaban/output.txt");
        fos.write("this is a java progress".getBytes());
        fos.close();
    }

    public static void main(String[] args) throws IOException {
        AzkabanTest azkabanTest = new AzkabanTest();
        azkabanTest.run();
    }
}
```

```properties
#JavaJob.job
type=javaprocess
java.class=com.tian.javajob.AzkabanTest
classpath=./*
```

```bash
zip JavaJob.zip JavaJob.jar JavaJob.job
```

## 4.HDFS操作任务

```properties
#hdfs job
type=command
command=/opt/module/hadoop-2.7.2/bin/hadoop fs -mkdir /azkaban
```

```bash
zip hdfs.zip hdfs.job
```

## 5.MapReduce操作任务

```properties
#mapreduce job
type=command
command=/opt/module/hadoop-2.7.2/bin/hadoop jar /opt/module/hadoop-2.7.2/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar wordcount /wordcount/input /wordcount/output
```

```bash
zip mr.zip mr.job
```

## 6.Hive脚本任务

```sql
use default;
drop table student;
create table student(id int, name string)
row format delimited fields terminated by '\t';
load data local inpath '/opt/module/datas/student.txt' into table student;
insert local directory '/opt/module/datas/student'
row format delimited fields terminated by '\t'
select * from student;
```

```properties
#hive job
type=command
command=/opt/module/hive/bin/hive -f ./student.sql
```

```bash
zip hive.zip hive.job student.sql
```