### CentOS7minimal

```
关闭K
手动分区
设置时间地区
设置主机名
配置网络
```

### Setting

```bash
yum install -y net-tools
yum install -y vim
vim /etc/vimrc # 配置vim
vim /etc/hosts # 设置hosts
```

```
colorscheme darkblue
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
useradd tian
passwd tian # tian
vim /etc/sudoers
#	tian	ALL=(ALL)	NOPASSWD:(ALL)
su tian
mkdir /home/tian/bin/
vim xsync
vim copy-ssh
chmod 777 xsync copy-ssh
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

for((host=101; host<104; host++)); do
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

### env

```powershell
scp .\software\ root@test:/opt/ # 远程拷贝mysql jdk hadoop zookeeper hive安装包 和 mysql驱动
```

```bash
## CentOS 6安装MySQL
## 查看
rpm -qa|grep -i mysql
#mysql-libs-5.1.73-7.el6.x86_64
## 卸载
rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64

## 安装MySQL server
rpm -ivh MySQL-server-5.6.24-1.el6.x86_64.rpm
# 查看随机产生的密码
cat /root/.mysql_secret
#OEXaQuS8IWkG19Xs
#查看MySQL状态
service mysql status
#启动MySQL
service mysql start
## 安装MySQL client
rpm -ivh MySQL-client-5.6.24-1.el6.x86_64.rpm
# 连接MySQL
mysql -uroot -pOEXaQuS8IWkG19Xs
## MySQL在user表中主机配置
show databases;
use mysql;
show tables;
desc user;
select User, Host, Password from user;
# 修改user表，把Host表内容修改为%
update user set host='%' where host='localhost'
# 删除root中的其他账户
delete from user where Host='hadoop102';
delete from user where Host='127.0.0.1';
delete from user where Host='::1';
# 刷新
flush privileges;
\q;

## CentOS 7 安装MySQL
# uninstall mariadb
## install MySQL
#下载并安装MySQL官方的 Yum Repository
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
#然后就可以直接yum安装了
yum -y install mysql57-community-release-el7-10.noarch.rpm
#开始安装MySQL服务器
#yum -y install mysql-community-server
#启动MySQL
systemctl start  mysqld.service
#查看MySQL运行状态
systemctl status mysqld.service
#通过日志文件查看root密码
grep "password" /var/log/mysqld.log
#进入数据库
mysql -uroot -p
#卸载Yum Repository防止自动更新配置
yum -y remove mysql57-community-release-el7-10.noarch
```

```bash
## 安装 jdk hadoop zookeeper hive 并配置环境变量
tar -zxvf jdk-8u144-linux-x64.tar.gz -C ../module/
tar -zxvf hadoop-2.7.2.tar.gz -C ../module/
tar -zxvf zookeeper-3.4.10.tar.gz -C ../module/
tar -zxvf apache-hive-1.2.1-bin.tar.gz -C ../module/
tar -zxvf mysql-connector-java-5.1.27.tar.gz # MySQL驱动包
vim /etc/profile # 添加环境变量
source /etc/profile
```

```
export JAVA_HOME=/opt/module/jdk1.8.0_144
export PATH=$PATH:$JAVA_HOME/bin
export HADOOP_HOME=/opt/module/hadoop-2.7.2
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export ZOOKEEPER_HOME=/opt/module/zookeeper-3.4.10
export PATH=$PATH:$ZOOKEEPER_HOME/bin
export HIVE_HOME=/opt/module/hive
export PATH=$PATH:$HIVE_HOME/bin
```


### hadoop

```bash
copy-ssh # 配置节点间的免密连接
xsync /home/tian/bin/ # 分发脚本
```


|-|hadoop101|hadoop102|hadoop103|
|:-:|:-|:-|:-|
|**HDFS**|NameNode<br>DataNode|DataNode|SecondaryNameNode<br>DataNode|
|**YARN**|NodeManager|ResourceManager<br>NodeManager|NodeManager|

```bash
echo $JAVA_HOME
vim hadoop-env.sh
vim yarn-env.sh
vim mapred-env.sh

vim /opt/module/hadoop-2.7.2/etc/hadoop/slaves # 不能由空行

vim core-site.xml
vim hdfs-site.xml
vi yarn-site.xml 
cp mapred-site.xml.template mapred-site.xml
vim mapred-site.xml

xsync /opt/module/hadoop-2.7.2/etc/hadoop/ # 分发配置
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
	<value>3</value>
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

```
hadoop101
hadoop102
hadoop103
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
</property>*
```

### zookeeper

```bash
mkdir -p zkData
vi myid # server对应的编号 每个节点的标号要分别改
mv zoo_sample.cfg zoo.cfg
vim zoo.cfg
```

```
dataDir=/opt/module/zookeeper-3.4.10/zkData
#######################cluster##########################
server.1=hadoop101:2888:3888
server.2=hadoop102:2888:3888
server.3=hadoop103:2888:3888
```

### hive

```bash
mv apache-hive-1.2.1-bin/ hive
mv hive-env.sh.template hive-env.sh
# export HADOOP_HOME=/opt/module/hadoop-2.7.2
# export HIVE_CONF_DIR=/opt/module/hive/conf
# Hive元数据配置到MySQL
# 拷贝驱动
tar -zxvf mysql-connector-java-5.1.27.tar.gz
cp mysql-connector-java-5.1.27-bin.jar /opt/module/hive/lib/

# 配置Metastore到MySQL
vi hive-site.xml
```

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop101:3306/metastore?createDatabaseIfNotExist=true</value>
        <description>JDBC connect string for a JDBC metastore</description>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
        <description>Driver class name for a JDBC metastore</description>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
        <description>username to use against metastore database</description>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>root</value>
        <description>password to use against metastore database</description>
    </property>
</configuration>
```

### clone vm

```bash
vim /etc/udev/rules.d/70-persistent-net.rules
vim /etc/sysconfig/network-scripts/ifcfg-eth0
vim /etc/sysconfig/network
```

### test
```bash
bin/hdfs namenode -format #101
sbin/start-dfs.sh #101
sbin/start-yarn.sh #102
jps

bin/zkServer.sh start
bin/zkServer.sh status
bin/zkServer.sh stop
```

[Web端查看SecondaryNameNode](http://hadoop103:50090/status.html).

[web端查看HDFS文件系统](http://tian:50070/dfshealth.html#tab-overview)

[Web页面查看YARN](http://hadoop102:8088/cluster)

[查看JobHistory](http://hadoop101:19888/jobhistory)

[Web查看日志](http://hadoop102:19888/jobhistory)

