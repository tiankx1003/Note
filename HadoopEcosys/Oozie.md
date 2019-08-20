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
sbin/mr-jobhistory-daemon.sh start historyserver # 启动历史服务器
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

定义workflow，配置定时
将配置文件上传到HDFS指定路径
使用Oozie job提交任务

Oozie执行hive任务

## 1.Oozie调度shell脚本

Oozie是将shell脚本转成MR的形式运行
如果调度自定义脚本
需要把脚本上传至HDFS并通过`<file></file>`标签指定文件路径
或者把shell脚本上传到HDFS中job目录下的lib文件夹中

```bash
mkdir -p oozie-apps/shell # oozie根目录
vim job.properties
vim workflow.xml
```

```properties
#HDFS地址
nameNode=hdfs://hadoop101:8020
#ResourceManager地址
jobTracker=hadoop102:8032
#队列名称
queueName=default
examplesRoot=oozie-apps
oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/shell
```

```xml
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-wf">
<!--开始节点-->
<start to="shell-node"/>
<!--动作节点-->
<action name="shell-node">
    <!--shell动作-->
    <shell xmlns="uri:oozie:shell-action:0.2">
        <job-tracker>${jobTracker}</job-tracker>
        <name-node>${nameNode}</name-node>
        <configuration>
            <property>
                <name>mapred.job.queue.name</name>
                <value>${queueName}</value>
            </property>
        </configuration>
        <!--要执行的脚本-->
        <exec>mkdir</exec>
        <argument>/opt/module/d</argument>
        <capture-output/>
    </shell>
    <ok to="end"/>
    <error to="fail"/>
</action>
<!--kill节点-->
<kill name="fail">
    <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
</kill>
<!--结束节点-->
<end name="end"/>
</workflow-app>
```

```bash
# 上传任务配置
/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/bin/hadoop fs -put oozie-apps/ /user/tian
# 执行任务
bin/oozie job -oozie http://hadoop101:11000/oozie -config oozie-apps/shell/job.properties -run
# 杀死某个任务
bin/oozie job -oozie http://hadoop101:11000/oozie -kill 0000004-170425105153692-oozie-z-W
# 通过http://hadoop101:11000/oozie/查看任务执行情况
# 通过http://hadoop101:50070查看hdfs文件内容
```

## 2.Oozie逻辑调度执行多个Job *视频*

```bash
vim job.properites
vim workflow.xml
```

```properties
nameNode=hdfs://hadoop101:8020
jobTracker=hadoop102:8032
queueName=default
examplesRoot=oozie-apps
oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/shells
```

```xml
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-wf">
    <start to="p1-shell-node"/>
    <action name="p1-shell-node">
        <shell xmlns="uri:oozie:shell-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
            </configuration>
            <exec>mkdir</exec>
            <argument>/opt/module/d1</argument>
            <capture-output/>
        </shell>
        <ok to="p2-shell-node"/>
        <error to="fail"/>
    </action>

    <action name="p2-shell-node">
        <shell xmlns="uri:oozie:shell-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
            </configuration>
            <exec>mkdir</exec>
            <argument>/opt/module/d2</argument>
            <capture-output/>
        </shell>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
```

```bash
# 上传任务配置
bin/hadoop fs -rmr /user/tian/oozie-apps/
bin/hadoop fs -put oozie-apps/shells /user/tian/oozie-apps
# 执行任务
bin/oozie job -oozie http://hadoop101:11000/oozie -config oozie-apps/shells/job.properties -run
```

## 3.Oozie调度MapReduce任务 *视频*

```bash
# 拷贝模版到oozie-apps
cp -r /opt/module/cdh/ oozie-4.0.0-cdh5.3.6/examples/apps/map-reduce/ oozie-apps/
# 在yarn中测试wordcount运行
/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/bin/yarn jar /opt/module/cdh/hadoop-2.5.0-cdh5.3.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0-cdh5.3.6.jar wordcount /input/ /output/
vim job.properties
vim workflow.xml
```

```properties
nameNode=hdfs://hadoop101:8020
jobTracker=hadoop102:8032
queueName=default
examplesRoot=oozie-apps
#hdfs://hadoop101:8020/user/admin/oozie-apps/map-reduce/workflow.xml
oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/map-reduce/workflow.xml
outputDir=map-reduce
```

```xml
<workflow-app xmlns="uri:oozie:workflow:0.2" name="map-reduce-wf">
    <start to="mr-node"/>
    <action name="mr-node">
        <map-reduce>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare>
                <delete path="${nameNode}/output/"/>
            </prepare>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
                <!-- 配置调度MR任务时，使用新的API -->
                <property>
                    <name>mapred.mapper.new-api</name>
                    <value>true</value>
                </property>

                <property>
                    <name>mapred.reducer.new-api</name>
                    <value>true</value>
                </property>

                <!-- 指定Job Key输出类型 -->
                <property>
                    <name>mapreduce.job.output.key.class</name>
                    <value>org.apache.hadoop.io.Text</value>
                </property>

                <!-- 指定Job Value输出类型 -->
                <property>
                    <name>mapreduce.job.output.value.class</name>
                    <value>org.apache.hadoop.io.IntWritable</value>
                </property>

                <!-- 指定输入路径 -->
                <property>
                    <name>mapred.input.dir</name>
                    <value>/input/</value>
                </property>

                <!-- 指定输出路径 -->
                <property>
                    <name>mapred.output.dir</name>
                    <value>/output/</value>
                </property>

                <!-- 指定Map类 -->
                <property>
                    <name>mapreduce.job.map.class</name>
                    <value>org.apache.hadoop.examples.WordCount$TokenizerMapper</value>
                </property>

                <!-- 指定Reduce类 -->
                <property>
                    <name>mapreduce.job.reduce.class</name>
                    <value>org.apache.hadoop.examples.WordCount$IntSumReducer</value>
                </property>

                <property>
                    <name>mapred.map.tasks</name>
                    <value>1</value>
                </property>
            </configuration>
        </map-reduce>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Map/Reduce failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
```

```bash
# 拷贝jar包到map-reduce的lib目录
cp -a  /opt /module/cdh/hadoop-2.5.0-cdh5.3.6/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0-cdh5.3.6.jar oozie-apps/map-reduce/lib
# 上传配置目录
/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/bin/hdfs dfs -put oozie-apps/map-reduce/ /user/admin/oozie-apps
# 执行任务
bin/oozie job -oozie http://hadoop101:11000/oozie -config oozie-apps/map-reduce/job.properties -run
```

## 4.Oozie定时任务/循环任务 *视频*

```bash
# 首先配置时间同步，略
vim oozie-site.xml
# 修改js框架中的关于时间设置的代码
vim oozie-server/webapps/oozie/oozie-console.js
# 重启oozie
bin/oozied.sh stop
bin/oozied.sh start
```

```xml
<property>
    <name>oozie.processing.timezone</name>
    <value>GMT+0800</value>
    <description>修改时区为东八区区时</description>
</property>
```

```js
function getTimeZone() {
    Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    return Ext.state.Manager.get("TimezoneId","GMT");
}
```

```bash
# 拷贝官方模板配置定时任务
cp -r examples/apps/cron/ oozie-apps/
vim job.properties
vim workflow.xml
```

```properties
nameNode=hdfs://hadoop101:8020
jobTracker=hadoop102:8032
queueName=default
examplesRoot=oozie-apps

oozie.coord.application.path=${nameNode}/user/${user.name}/${examplesRoot}/cron
#start：必须设置为未来时间，否则任务失败
start=2017-07-29T17:00+0800
end=2017-07-30T17:00+0800
workflowAppUri=${nameNode}/user/${user.name}/${examplesRoot}/cron
EXEC=p1.sh
coordinator.xml
<coordinator-app name="cron-coord" frequency="${coord:minutes(5)}" start="${start}" end="${end}" timezone="GMT+0800" xmlns="uri:oozie:coordinator:0.2">
<action>
	<workflow>
	    <app-path>${workflowAppUri}</app-path>
	    <configuration>
	        <property>
	            <name>jobTracker</name>
	            <value>${jobTracker}</value>
	        </property>
	        <property>
	            <name>nameNode</name>
	            <value>${nameNode}</value>
	        </property>
	        <property>
	            <name>queueName</name>
	            <value>${queueName}</value>
	        </property>
	    </configuration>
	</workflow>
</action>
</coordinator-app>
```

```xml
<workflow-app xmlns="uri:oozie:workflow:0.5" name="one-op-wf">
<start to="shell-node"/>
  <action name="shell-node">
      <shell xmlns="uri:oozie:shell-action:0.2">
          <job-tracker>${jobTracker}</job-tracker>
          <name-node>${nameNode}</name-node>
          <configuration>
              <property>
                  <name>mapred.job.queue.name</name>
                  <value>${queueName}</value>
              </property>
          </configuration>
          <exec>${EXEC}</exec>
          <file>/user/tian/oozie-apps/cron/${EXEC}#${EXEC}</file>
          <capture-output/>
      </shell>
      <ok to="end"/>
      <error to="fail"/>
  </action>
<kill name="fail">
    <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
</kill>
<end name="end"/>
</workflow-app>
```

```bash
# 上传配置
/opt/module/cdh/hadoop-2.5.0-cdh5.3.6/bin/hdfs dfs -put oozie-apps/cron/ /user/tian/oozie-apps
# 启动任务
bin/oozie job -oozie http://hadoop101:11000/oozie -config oozie-apps/cron/job.properties -run
# oozie允许的最小执行任务的频率是5分钟
```

# 四、常见问题总结

1. MySQL权限配置
2. workflow.xml配置的时候不要忽略file属性
3. jps查看进程时，注意有没有bootstrap
4. 关闭oozie，如果bin/oozied.sh stop无法关闭，则可以使用kill命令关闭进程，并删除oozie-server/temp/xxx.pid
5. Oozie重新打包时，一定要注意关闭进程，删除对应文件的pid文件
6. 配置文件一定要生效，其实标签和结束标签无对应则不生效，配置文件的属性写错了，那么则执行默认的属性
7. libext下边的jar存放与某个文件夹中，导致share/lib创建不成功
8. 调度任务时，找不到指定的脚本，可能时oozie-site.xml里面的Hadoop配置文件没有关联上
9. 修改Hadoop配置文件需要分发配置并重启集群
10. JobHistoryServer必须开启
11. MySQL配置如果没有生效，默认使用derby数据库
12. 在本地修改完成的job配置，必须重新长传到HDFS
13. 将HDFS中上传的oozie配置文件下载下来查看是否错误
14. Linux用户名和Hadoop用户名不一致