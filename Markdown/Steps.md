### 安装虚拟机
最小安装版yum安装vim tar rsync openssh openssh-client
设置vimrc
```
colorscheme murphy
syntax on
set showmode
set showcmd
set t_Co=256
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
set autoindent
set cindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set number
set cursorline
set linebreak
set wrapmargin=0
set incsearch
set smartcase
set nobackup
set noswapfile
set undofile
set noerrorbells
set visualbell
set history=1000
set autoread
```

```bash
#设置IP 主机名 hosts 关闭防火墙
service iptables status
service iptables stop
chkconfig iptables --list
chkconfig iptables off
```
```host
192.168.2.100 hadoop100
192.168.2.101 hadoop101
192.168.2.102 hadoop102
192.168.2.103 hadoop103
192.168.2.104 hadoop104
192.168.2.105 hadoop105
192.168.2.106 hadoop106
```
```bash
#编写同步脚本和免密连接配置文件
vim /home/tian/bin/xsync
vim /home/tian/bin/copy-ssh
```
```sh
#!/bin/bash

pcount=$#

if ((pcount==0)); then
echo no args;
exit;
fi

p1=$1
fname=`basename $p1`
echo fname=$fname
pdir=`cd -P $(dirname $p1); pwd`
echo pdir=$pdir
user=`whoami`

for((host=101; host<107; host++)); do
        echo ------------------- hadoop$host -------------------
        rsync -av $pdir/$fname $user@hadoop$host:$pdir
done
```
```sh
#!/bin/bash
ssh-keygen -t rsa
ssh-copy-id hadoop101
ssh-copy-id hadoop102
ssh-copy-id hadoop103
ssh-copy-id hadoop104
ssh-copy-id hadoop105
ssh-copy-id hadoop106
```

```bash
###新建用户授权
useradd tian
passwd tian
vim /etc/sudoer
#tian ALL=(ALL)    NOPASSWD:ALL
```
```sh
#上传本地端公钥(root & tian)
ssh-copy-id hadoop100
```
```bash
#安装软件配置环境变量
chown tian:tian /opt/module/ /opt/software -R
```

### 克隆虚拟机
```bash
vim /etc/udev/rules.d/70-persistent-net.rules
vim /etc/sysconfig/network-scripts/ifcfg-eth0
vim /etc/sysconfig/network #修改主机名
```
*配置多个节点之间的免密连接*

### 集群配置

-|hadoop101|hadoop102|hadoop103
:-:|:-|:-|:-
**HDFS**|NameNode<br>DataNode|DataNode|SecondaryNameNode<br>DataNode
**YARN**|NodeManager|ResourceManager<br>NodeManager|NodeManager

```bash
vim core-site.xml
vim hdfs-site.xml
vi yarn-site.xml 
cp mapred-site.xml.template mapred-site.xml
vim mapred-site.xml

echo $JAVA_HOME
vim hadoop-env.sh
vim yarn-env.sh
vim mapred-env.sh
```

```xml
<!-- core-site.xml -->
<property>
		<name>fs.defaultFS</name>
      <value>hdfs://hadoop101:9000</value>
</property>

<property>
		<name>hadoop.tmp.dir</name>
		<value>/opt/module/hadoop-2.7.2/data/tmp</value>
</property>
```
```xml
<!-- hdfs-site.xml -->
<property>
		<name>dfs.replication</name>
		<value>6</value>
</property>

<property>
      <name>dfs.namenode.secondary.http-address</name>
      <value>hadoop103:50090</value>
</property>
```
```xml
<!-- yarn-site.xml  -->
<property>
		<name>yarn.nodemanager.aux-services</name>
		<value>mapreduce_shuffle</value>
</property>

<property>
		<name>yarn.resourcemanager.hostname</name>
		<value>hadoop102</value>
</property>
```
```xml
<!-- mapred-site.xml -->
<property>
		<name>mapreduce.framework.name</name>
		<value>yarn</value>
</property>
```

```bash
##配置历史服务器
vim mapred-site.xml
sbin/mr-jobhistory-daemon.sh start historyserver
##配置日志聚集
vim yarn-site.xml
```
```xml
<property>
<name>mapreduce.jobhistory.address</name>
<value>hadoop101:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop101:19888</value>
</property>
```
```xml
<property>
<name>yarn.log-aggregation-enable</name>
<value>true</value>
</property>

<property>
<name>yarn.log-aggregation.retain-seconds</name>
<value>604800</value>
</property>
```

*集群上分发配置*

[web端查看HDFS文件系统](http://tian:50070/dfshealth.html#tab-overview)

[Web页面查看YARN](http://hadoop102:8088/cluster)

[查看JobHistory](http://hadoop101:19888/jobhistory)

[Web查看日志](http://hadoop102:19888/jobhistory)



### 单点启动
```bash
#如果集群是第一次启动，需要格式化NameNode
hdfs namenode -format
#在hadoop101上启动NameNode
hadoop-daemon.sh start namenode
#在hadoop101、hadoop102以及hadoop103上分别启动DataNode
hadoop-daemon.sh start datanode
jps
```

### 群起集群

```bash
##配置slaves
vim /opt/module/hadoop-2.7.2/etc/hadoop/slaves
```

```
hadoop101
hadoop102
hadoop103
hadoop104
hadoop105
hadoop106
```
*该文件中添加的内容结尾不允许有空格，文件中不允许有空行。
集群同步slaves文件*

```bash
#第一次启动集群时需要格式化namenode
bin/hdfs namenode -format #101
#启动HDFS
sbin/start-dfs.sh #101
jps #102
#4166 NameNode
#4482 Jps
#4263 DataNode
jps #102
#3218 DataNode
#3288 Jps
jps #103
#3221 DataNode
#3283 SecondaryNameNode
#3364 Jps
#启动YARN
sbin/start-yarn.sh #102
```
[Web端查看SecondaryNameNode](http://hadoop103:50090/status.html).

### 集群测试
```bash
#hadoop fs -mkdir -p /user/tian/input
hdfs dfs -mkdir -p /usrer/tian/input1
hdfs dfs -put wcinput/wc.input /user/tian/input1
#wordcount
hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar wordcount /user/tian/input1/ /user/tian/output1
hdfs dfs -cat /user/tian/input1/wc.input
hdfs dfs -get /user/tian/input1/wc.input ./output
hdfs dfs -rm /user/tian/input1/wc.input

hadoop fs -put /opt/software/hadoop-2.7.2.tar.gz  /user/tian/input2
#/opt/module/hadoop-2.7.2/data/tmp/dfs/data/current/BP-938951106-192.168.10.107-1495462844069/current/finalized/subdir0/subdir0
#查看HDFS在磁盘存储文件内容
cat blk_1073741835
cat blk_1073741836>>tmp.file
cat blk_1073741837>>tmp.file
tar -zxvf tmp.file
```

### 宕机异常
```
19/07/18 16:24:47 INFO hdfs.DFSClient: Exception in createBlockOutputStream
java.io.IOException: Got error, status message , ack with firstBadLink as 192.168.2.106:50010
        at org.apache.hadoop.hdfs.protocol.datatransfer.DataTransferProtoUtil.checkBlockOpStatus(DataTransferProtoUtil.java:140)
        at org.apache.hadoop.hdfs.DFSOutputStream$DataStreamer.createBlockOutputStream(DFSOutputStream.java:1363)
        at org.apache.hadoop.hdfs.DFSOutputStream$DataStreamer.nextBlockOutputStream(DFSOutputStream.java:1266)
        at org.apache.hadoop.hdfs.DFSOutputStream$DataStreamer.run(DFSOutputStream.java:449)
19/07/18 16:24:47 INFO hdfs.DFSClient: Abandoning BP-221899475-192.168.2.101-1563437596084:blk_1073741827_1003
19/07/18 16:24:47 INFO hdfs.DFSClient: Excluding datanode DatanodeInfoWithStorage[192.168.2.106:50010,DS-8d6b136a-9870-4862-a76f-7339d84833f5,DISK]
```
***不影响数据的读写***

>**思考**
namenode宕机，secondarynamenode正常工作，集群状态如何
仅有secondarynamenode工作，集群状态如何
六个节点存入数据后，namemode之外的所有datanode宕机，状态如何
宕机后存取数据操作后，其他节点重新上线，状态如何（会不会有节点间的数据同步）