# Linux


## 一、文件和目录结构

### 1.文件
Linux系统中一切皆文件。
在Linux系统中任何东西都是以文件形式来存储的。这其中不仅包括我们熟知的文本文件、可执行文件等等，还包括硬件设备、虚拟设备、网络连接等等，甚至连目录其实都是一种特殊的文件。

### 2.目录结构

Linux下文件**不区分**后缀和扩展名，存在的意义是便于用户识别
目录|描述
:-:|-
/bin | 可执行文件
/sbin | 超级管理员所需执行的文件
/home | 用户目录，内部存放各个普通用户的文件
/root | root用户存放用户文件的目录
/lib | 系统的基本动态连接共享库
/lost+found | 系统非法关机后用于存放一些文件，一般为空
/etc | 配置目录，统一存放系统服务配置
/usr | 编译之后安装程序的安装目录
/boot | 启动linux需要的核心文件
/tmp | 临时文件目录
/dev | 设备驱动文件
/media | 第三方设备文件
/opt | 免安装程序文件目录
/var | 日志
/selinux | 是一种安全子系统只能访问特定文件

### 3.Linux系统中的路径
**绝对路径**从“/”根目录开始逐层查找文件和目录。
/etc/sysconfig/network-scripts
/tmp/vmware-root/vmware-db.pl.2267
**相对路径**以当前目录或上一级目录为基准逐层查找文件和目录
当前目录：“./”
当前目录的上一级目录：“../”

### 4.用户家目录
**作用**Linux系统为每一个用户提供了一个专属的目录用来存放它自己的文件内容，在Linux中使用“~”代表用户的家目录
**root用户**家目录是/root目录。
**普通用户**在创建后会在/home目录下创建与用户名同名的目录。例如：用户tom的家目录是/home/tom


## 二、VIM编辑器

### 1.一般模式

|   按键    |       功能描述        |
| :-------: | :-------------------: |
|    yy     |      复制当前行       |
|  y数字y   |    从当前行复制n行    |
|     p     | 箭头移动到目标行粘贴  |
|     u     |      撤销上一步       |
|    dd     |    删除光标当前行     |
|  d数字d   | 删除光标（包含）后n行 |
|     x     |    delete一个字母     |
|     X     |   backspace一个字母   |
|    yw     |      复制一个词       |
|    dw     |      删除一个词       |
| shift+6 ^ |      移动到行头       |
| shift+5 % |      移动到行尾       |
|     G     |      移动到页尾       |
|    1+G    |   移动到页头，数字    |
|  数字+G   |     移动到目标行      |

### 2.编辑模式

| 按键 | 功能                   |
| ---- | ---------------------- |
| i    | 当前光标前             |
| a    | 当前光标后             |
| o    | 当前光标行的下一行     |
| I    | 光标所在行最前         |
| A    | 光标所在行最后         |
| O    | 当前光标行的上一行     |
| s    | 删除当前字符并进入编辑 |
| S    | 删除整行并进入编辑     |

### 3.指令模式

| 命令            | 功能                       |
| --------------- | -------------------------- |
| :w              | 保存                       |
| :q              | 退出                       |
| :!              | 强制执行                   |
| /要查找的词     | n 查找下一个，N 往上查找   |
| ? 要查找的词    | n是查找上一个，N是往下查找 |
| :set nu         | 显示行号                   |
| :set nonu       | 关闭行号                   |
| :%s/str1/str2/g | 将str1批量替换为str2       |

**注意**
①其实强制保存时，还要看是否具备权限，如果没有权限加了强制也不一定能保存进去
②如果有未保存的修改则无法退出
```bash
which vim #查看命令对应的位置
echo $PATH #查看环境变量
```

![](img/vim-key.jpg)

## 三、常用命令

### 0.帮助命令
#### 0.1 main获得帮助信息

信息	|   功能
:-:|-
NAME	|   命令的名称和单行描述
SYNOPSIS	|   怎样使用命令
DESCRIPTION	    |   命令功能的深入讨论
EXAMPLES  	|   怎样使用命令的例子
SEE ALSO	|   相关主题（通常是手册页）

#### 0.2 help 获得shell内置命令的帮助信息
```bash
help cd
#man [命令] 用于查看帮助 空格键翻页
man ls

ls -l ##ll
ls -a #不忽略以.开头的文件
ls -al
ls -R #递归显示目录结构
help cd #查看shell命令的
# [命令] --help 查看命令描述
ls --help
clear
#tab键自动补全
reset
```

#### 0.3 常用快捷键
常用快捷键|功能
:-:|-
ctrl + c	|   停止进程
ctrl+l	|   清屏；彻底清屏是：reset
q	|   退出
善于用tab键	|   提示(更重要的是可以防止敲错)
上下键	|   查找执行过的命令
ctrl +alt	|   linux和Windows之间切换

### 1.网络配置与系统管理

**域名映射为IP地址**
映射先用hosts进行映射，再用DNS服务器进行映射
修改hosts文件后可以通过主机名或域名方式ping通指定地址

```bash
ifconfig #显示所有网络接口的配置
ping baidu.com #ping域名
ping 192.168.2.102 #pingIP地址
ping tian01 #hosts指定了名称

#修改IP地址
vim /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart #重启网络服务
reboot #重启
halt #直接关机
```
```
#vim /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0                #接口名（设备,网卡）
HWADDR=00:0C:2x:6x:0x:xx   #MAC地址 
TYPE=Ethernet               #网络类型（通常是Ethemet）
UUID=926a57ba-92c6-4231-bacb-f27e5e6a9f44  #随机id
#系统启动的时候网络接口是否有效（yes/no）
ONBOOT=yes                
# IP的配置方法[none|static|bootp|dhcp]（引导时不使用协议|静态分配IP|BOOTP协议|DHCP协议）
BOOTPROTO=static      
#IP地址
IPADDR=192.168.1.101   
#网关  
GATEWAY=192.168.1.2      
#域名解析器
```

```bash
hostname #查看主机名
vi /etc/sysconfig/network #修改主机名
vim /etc/hosts #修改hosts
```
```
# vi /etc/sysconfig/network
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME= hadoop100
# 注意：主机名称不要有“_”下划线
```
```
#hosts
192.168.2.100 tian
192.168.2.101 tian01
192.168.2.102 tian02
192.168.2.200 ubuntu
192.168.2.201 test01
192.168.2.202 test02
```
```bash
service serviceName start #开启服务
service serviceName stop #关闭服务
service serviceName restart #重启服务
service serviceName status #查看服务状态
service --status-all #查看所有服务状态
cd /etc/init.d/
ls -a #查看所有服务
#/etc/init.d/serviceName

chkconfig #查看所有自启配置
chkconfig serviceName off #关掉指定服务的自启动
chkconfig serviceName on #开启指定服务的自启动
chkconfig serviceName --list #查看服务开机启动状态
```
**运行级别**
开机 -> BIOS -> /boot -> init进程 -> 运行级别 -> 运行级对应的任务
```bash
vi /etc/inittab #查看默认级别
```
运行级别|描述
:-:|-
0|系统停机状态，系统默认运行级别不能设置为0，否则不能正常启动
1|单用户工作状态，root权限，用于系统维护，禁止远程登录
2|多用户状态（没有NFS），不支持网络
3|完全的多用户状态（支持NFS），登录后进入控制台命令行模式
4|系统未使用，保留
5|x11控制台，登录后进入图形GUI模式
6|系统正常关闭并重启，默认运行级别不能为6，否则不能正常启动

```bash
service iptables status #查看防火墙状态
service iptables stop #关闭防火墙
chkconfig iptables --list #查看防火墙开机状态
chkconfig iptables off #关闭防火墙开机启动

sync #内存中数据同步到硬盘
halt #直接关闭系统
reboot #直接重启
shutdown -h 5 #五分钟后halt
shutdown -r 5 #五分钟后reboot
shutdown -h now #halt
shutdown -r now #reboot

```

**经验**
Linux系统中为了提高磁盘的读写效率，对磁盘采取了 “预读迟写”操作方式。当用户保存文件时，Linux核心并不一定立即将保存数据写入物理磁盘中，而是将数据保存在缓冲区中，等缓冲区满时再写入磁盘，这种方式可以极大的提高磁盘写入数据的效率。但是，也带来了安全隐患，如果数据还未写入磁盘时，系统掉电或者其他严重问题出现，则将导致数据丢失。使用sync指令可以立即将缓冲区的数据写入磁盘。

### 2.文件目录操作

```bash
pwd #打印当前目录
cd #change directory
ls #显示文件列表

mkdir #创建目录
mkdir hello1 hello2 #创建多个目录
mkdir hello3/h1/n1 #无法递归创建目录
mkdir hello3/h1/n1 -p #级联创建多层目录

rmdir hello1 #删除目录
rmdir hell03 #非空目录删除失败
vim hello #hello文件存在则直接编辑，hello不存在直接创建
touch hello2 #创建空文件

cp source dest #复制文件
cp sourcef dest -r #复制目录
rm deleteFile #删除文件
rm deleteFile -r #递归删除
rm deleteFile -f #强制删除
rm deleteFIle -v #删除并显示删除了哪些东西
rm -rf / #无权限
find module -type f -name "*.cmd" -exec rm -f {} \; ## 删除module目录下多层目录同一后缀的文件
#移动到不同目录为剪切，同一目录为重命名
mv oldNameFile newNameFile 
mv aa/bb cc/aa

cat file #查看小文件
cat file -n #查看文件并显示行号
more file #查看内容较多的文件,文件全部加载到内存
##根据对应的指令能够翻页滚屏退出等操作
less file #查看分屏查看文件，文件分屏加载到内存，使用与more类似
head file #显示文件的前十行
head file -n 5 #显示文件的前五行
tail file #显示文件的后十行
tail file -n 5 #显示文件的后五行
tail file -f #实施追踪文档的更新
#tail较为常用，主要用来查看日志文件

echo hello #向屏幕打印hello
cat abc
echo hello > abc #覆盖写入到文件
echo hello >> abc #追加写入到文件

ln -s 文件或目录 链接名 #软链接就是快捷方式，指向对应的文件
#删除任意一个文件，另一个还存在
lm 文件或目录 链接名 #硬链接即是文件的一种备份，实时同步内容
删除目标文件后，链接失效

history #查看之前执行过的命令
```

### 3.时间日期类

```bash
date 
date 日期格式 #显示指定格式的日期
date -d 字符串 #显示非当前时间
date -d 'yesterday' #显示昨天
date -s <时间> #设置系统时间

cal #日历,后跟参数可显示指定时间点的日历
```

### 4.用户管理

```bash
passwd root #修改root密码
useradd 用户名 #添加用户
usreadd 用户名 -g 组名 #新建用户时指定组名
userdel 用户名 #删除用户，不删除用户的文件目录
userdel 用户名 -r #删除用户和目录
passwd 用户名 #该用户密码，用户名在用户创建后不可修改
id 用户名 #查看用户是否存在
cat /etc/passwd #所有的用户信息都保存在一个文件中
cat /etc/shadow #用户密码文件

su 用户 #从当前用户切换到指定用户
su - 用户 #从当前用户切换到指定用户，与前者的区别是环境变量的不同
exit #当前用户回退到上一个用户
who #查看当前有哪些用户登录
who am i #从哪个用户切换而来
whoami #当前是哪个用户
```


### 5.用户组管理

```bash
cat etc/group #查看用户组的文件
groupadd 组名 #新建组
groupdel 组名 #删除组
groupmod -n 新组名 旧组名 #修改组名
usermod 用户名 -g 组名 #修改用户组
```

etc/passwd **格式**
普通用户的uid从500开始，gid从500开始
如果添加用户时没有指定组名，则在home下生成一个同名的组

### 6.文件权限

```bash
chmod g+wx tom #为tom同组的人添加写和执行权限
chmod g-rwx tom #为tom同组的人移除读写和执行权限，-
```
rwx对应的有无转三位二进制数
把三位二进制数转十进制数来表示权限

删除文件的前提是对该文件的父目录有写权限

### 7.搜索查找

```bash
find /aa -name '*.log'
find /tmp -user 'tom'
find /tmp -size +200M #体积大于200M的文件

updatedb #更新索引
locate yum.log #查找文件位置，忽略tmp目录

grep 搜索的内容 文件名 #搜索指定文件有无指定内容
grep -n 搜索的内容 文件名 #搜索并显示匹配行与行号
ls | grep -n hello #前边命令的执行结果作为后者的传入数据
ll | grep hello | grep .log #多层管道
```

### 8.压缩和解压缩

```bash
gzip 文件 #只能压缩文件，不能压缩目录
gunzip 压缩包 #解压后删除压缩包

zip 文件
zip -r file.zip hello/ hello/2 #递归压缩文件目录
unzip file.zip -d /tmp/ #解压到指定目录

#归档
tar -c
tar -v
tar -f
tar -z
tar -x
tar -zcvf file.tar.gz dir/
```

### 9.磁盘分区

```bash
df #显示磁盘使用情况
df -h #
fdisk -l #查看分区信息
mount #挂载
umount #卸载
mount [-t vfstype] [-o options] device dir
```
**参数说明**

参数|功能
:-:|-
| -t vfstype | 指定文件系统的类型，通常不必指定。mount 会自动选择正确的类型。常用类型有：   光盘或光盘镜像：iso9660   DOS fat16文件系统：msdos   [Windows](http://blog.csdn.net/hancunai0017/article/details/6995284) 9x fat32文件系统：vfat   Windows NT ntfs文件系统：ntfs   Mount Windows文件[网络](http://blog.csdn.net/hancunai0017/article/details/6995284)共享：smbfs   [UNIX](http://blog.csdn.net/hancunai0017/article/details/6995284)(LINUX) 文件网络共享：nfs |
| -o options | 主要用来描述设备或档案的挂接方式。常用的参数有：   loop：用来把一个文件当成硬盘分区挂接上系统   ro：采用只读方式挂接设备   rw：采用读写方式挂接设备   　  iocharset：指定访问文件系统所用字符集 |
| device     | 要挂接(mount)的设备                                          |
| dir        | 设备在系统上的挂接点(mount   point)                          |


```bash
mount device dir #设备临时挂载到指定目录，reboot后丢失
umount dir #解除挂载

#永久挂载
vim /etc/fstab 
mount -a #执行生效
```

```bash
fdisk -l #查看磁盘状态
fdisk /dev/sdb #分区
#m 显示命令列表
#p 显示磁盘分区
#n 新增分区
#d 删除分区
#w 写入并退出
mkfs -t ext4 /dev/sdb1 #格式化分区
-df -h #查看当前磁盘挂载情况

```


### 10.进程线程

```bash
ps -ef
ps aux | less ##
ps -ef #显示进程父子关系
kill 进程号 #精确地杀死单个进程
killall 进程名称 #杀死和进程名匹配的所有进程
pstree #进程树
pstree -u #显示进程树和用户
top #
netstat -anp #查看网络信息
service crond restart #定时任务
#crond以用户为单位
crondtab -l
crondtab -e #进入vim编辑定时任务
```

### 11.crond系统定时任务

### 12.软件安装
#### 12.1 安装软件
```bash
rpm -qa #查看安装哪些软件
rpm -qa | grep firefox 
rpm -ivh 安装包

#yum可自动处理依赖关系
yum -y install tree ##所有提问默认为y
```

#### 12.2 开发环境的搭建
```bash
cd opt
mkdir soft module
tar -zxvf 安装包 -C /opt/module #解压文件到指定目录

vim etc/profile #添加环境变量 JAVA_HOME PATH并导出为全局变量
source /etc/profile #导出后执行
```

## 四、其他操作
### 切换 图形化/命令行 界面
1.设置默认启动级别为3
2.使用快捷键完成图形化界面和命令行界面的切换
    **ctl+alt+F1**
    **ctl+alt+F2**

永久命令行模式
```bash
###CentOS6永久关闭图形化界面
#临时关闭
init 3
#永久关闭
vi /etc/inittab #id:3:initdefault:

###CentOS7永久关闭图形化界面
#查看默认的target，执行：
systemctl get-default
#开机以命令模式启动，执行：
systemctl set-default multi-user.target
#开机以图形界面启动，执行：
systemctl set-default graphical.target
```