# 一、功能模块介绍

Oozie需要部署到Java Servlet容器中运行。主要用于定时调度任务，多任务可以按照执行的逻辑顺序调度。
Oozie根据**Hadoop历史服务器**判断状态

## 1.模块

**Workflow**
顺序执行流程节点
**Coordinator**
定时触发workflow
**Bundle**
解决多个工作流程之间的关系，很少用到，绑定多个Coordinator

以上三个模块分别对应三个文件

## 2.Workflow常用节点

> **控制流节点**(Control Flow Nodes)
> 控制流节点将多个动作节点串起来，如start,end,kill

> **动作节点**(Action Nodes)
> 执行具体的动作，如拷贝文件，执行脚本

# 二、安装部署

## 1.部署Hadoop(CDH)

```bash
mkdir /opt/module/cdh/
tar -zxvf hadoop-2.5.0-cdh5.3.6.tar.gz -C ../module/cdh/
# 解压后配置四个site文件，三个env文件和slave文件
# env配置JAVA_HOME
echo $JAVA_HOME
vim hadoop-env.sh
vim mapred-env.sh
vim yarn-env.sh
vim core-site.xml # 配置data路径为当前hadoop路径
vim hdfs-site.xml # 
vim mapred-site.xml # 历史服务器
vim yarn-site.xml # mapreduce_shuffle ResourceManager
vim slave # 添加集群节点host
xsync /opt/module/cdh # 分发配置
bin/hdfs namenode -format # 
sbin/start-dfs.sh # hadoop101
sbin/start-yarn.sh # hadoop102
```

```xml
<!-- 指定HDFS中NameNode的地址 -->
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://hadoop101:8020</value>
</property>

<!-- 指定hadoop运行时产生文件的存储目录 -->
<property>
    <name>hadoop.tmp.dir</name>
    <value>/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/data/tmp</value>
</property>


<!-- Oozie Server的Hostname -->
<property>
    <name>hadoop.proxyuser.tian.hosts</name>
    <value>*</value>
</property>

<!-- 允许被Oozie代理的用户组 -->
<property>
    <name>hadoop.proxyuser.tian.groups</name>
    <value>*</value>
</property>
```

```xml
<property>
    <name>dfs.replication</name>
    <value>3</value>
</property>

<property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>hadoop103:50090</value>
</property>
```

```xml
<!-- 指定mr运行在yarn上 -->
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
<!-- 配置 MapReduce JobHistory Server 地址 ，默认端口10020 -->
<property>
    <name>mapreduce.jobhistory.address</name>
    <value>hadoop101:10020</value>
</property>

<!-- 配置 MapReduce JobHistory Server web ui 地址， 默认端口19888 -->
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop101:19888</value>
</property>
```

```xml
<!-- Site specific YARN configuration properties -->
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>

<!-- 指定YARN的ResourceManager的地址 -->
<property>
    <name>yarn.resourcemanager.hostname</name>
    <value>hadoop102</value>
</property>
<property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
</property>

<!-- 任务历史服务 -->
<property>
    <name>yarn.log.server.url</name>
    <value>http://hadoop101:19888/jobhistory/logs/</value>
</property>
```

## 3.部署Oozie

```bash
tar -zxvf /opt/software/cdh/oozie-4.0.0-cdh5.3.6.tar.gz -C /opt/module
tar -zxvf oozie-hadooplibs-4.0.0-cdh5.3.6.tar.gz -C ../ # Oozie根目录下解压
# 拷贝依赖的jar包
mkdir libext/
cp -ra hadooplibs/hadooplib-2.5.0-cdh5.3.6.oozie-4.0.0-cdh5.3.6/* libext/
cp -a /opt/software/mysql-connector-java-5.1.27/mysql-connector-java-5.1.27-bin.jar ./libext/

cp -a /opt/software/cdh/ext-2.2.zip libext/
# 修改Oozie配置文件
vim oozie-stie.xml
mysql -uroot -proot # 创建数据库
# create database oozie
```

```bash
# 初始化Oozie
bin/oozie-setup.sh sharelib create -fs hdfs://hadoop101:8020 -locallib oozie-sharelib-4.0.0-cdh5.3.6-yarn.tar.gz
# 执行成功之后，去50070检查对应目录有没有文件生成
# 创建oozie.sql文件
bin/ooziedb.sh create -sqlfile oozie.sql -run
# 打包项目生成war包
bin/oozie-setup.sh prepare-war
bin/oozied.sh start # 启动
bin/oozied.sh stop # 关闭
```

[==Oozie Web页面==http://hadoop101:11000/oozie](http://101:11000/oozie)

# 三、实战

1.Oozie调度shell脚本



2.Oozie逻辑调度执行多个Job



3.Oozie调度MapReduce任务



4.Oozie定时任务/循环任务