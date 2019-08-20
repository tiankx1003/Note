# Shell编程
## 一、Shell概述

## 二、Shell解析器
```bash
cat /etc/shells #查看Shell解析器
ll | grep bash #bash和sh的关系
echo $SHELL #CentOS默认解析器是bash
```
## 三、Shell脚本
### 1.脚本格式
脚本以`#!/bin/bash`开头（指定解析器）
### 2.HelloWorld！
```bash
touch helloworld.sh
vim helloworld.sh
```
```sh
#helloworld.sh
echo "Hello World!"
```
```sh
#test1.sh
echo "hello"
```
```bash
#脚本常用的执行方式
sh helloworld.sh
sh /home/tian/datas/helloworld.sh
bash helloworld.sh 
bash /home/tian/datas/helloworld.sh

chmod 777 helloworld.sh
./helloworld.sh #自己执行自己，需要权限
/home/tian/datas/helloworld.sh

bash ./test1.sh
sh ./test1.sh
echo $A # 空
./test1.sh 
echo $A # 空
. test1.sh #当前shell中执行，以上全是子shell
echo $A # hello
```

### 3.多命令处理
**需求**在用户家目录下创建一个banzhang.txt,在banzhang.txt文件中增加“I love cls”。
```sh
#!/bin/bash
cd /home/tian
touch cls.txt
echo "I love cls" >>cls.txt
```

## 四、Shell中的变量
### 1.系统变量
`$HOME` `$PWD` `$SHELL` `$USER`
```bash
echo $HOME #查看系统变量
set #查看所有系统变量
```
### 2.自定义变量
**语法**
定义变量：变量=值
撤销变量：unset 变量
声明静态变量：readonly 变量 #这种方式不能unset
**规则**
①变量名称可以由字母、数字和下划线组成，但是不能以数字开头，环境变量名建议大写
②等号两侧不能由空格
③在bash中，变量默认类型都是字符串类型，无法直接进行数值运算
④变量的值如果有空格，需要使用双引号或单引号括起来
```bash
A=5 #定义变量
echo $A
A=8 #重新赋值
unset A #撤销变量
readonly B=2 #声明静态变量，不能unset
C=1+2 #bash中变量都是字符串类型不能进行数值运算
D="I love Shell" #变量中如果有空格，用单引号或双引号括起来，不用在意数据类型
E=hello
F="$E world!" #使用双引号可以识别变量
G=`ll` #使用反引号可以把命令的结果赋值给变量
H=$(ll) #和反引号效果相同
```
### 3.特殊变量：$n
n为数字，$0代表该脚本名称，$1-$9代表第一到第九个参数，十以上的参数，十以上的参数需要用大括号包含，如${10}
```bash
tuoch parameter.sh
vim parameter.sh
chmod 777 parameter.sh
./parameter.sh cls xz
```
```sh
#parameter.sh
#!/bin/bash
echo "$0 $1 $2" #$0获取文件名字
```

### 4.特殊变量：$#
获取所有输入参数个数，常用于循环
```bash
./parameter.sh hello world
```
```sh
#parameter.sh
#!/bin/bash
echo "$0 $1 $2" #$0获取文件名字
echo $# #返回传入变量个数
echo "========='$n'========="
echo "========='$#'========="
echo '========="$n"========='
echo '========="$#"=========' #外单内双和外双内单不同
```
### 5.特殊变量：$*  $@
`$*`这个变量代表命令行中所有的参数，`$*`把所有的参数看成一个整体
`$@`这个变量也代表命令行中所有的参数，不过`$@`把每个参数区分对待
```sh
#parameter.sh
#!/bin/bash
echo "$0 $1 $2" #$0获取文件名字
echo $# #返回传入变量个数
echo $*
echo $@
```

### 6.特殊变量：$?
`$?`最后一次执行的命令的返回状态。如果这个变量的值为0，证明上一个命令正确执行；如果这个变量的值为非0（具体是哪个数，由命令自己来决定），则证明上一个命令执行不正确了
```bash
cd /root
echo $? #返回非零，没有正确执行
su root
cd /root 
echo $? #返回零，正确执行
```
## 五、运算符
①“$((运算式))”或“$[运算式]”
②expr  + , - , \*,  /,  %    加，减，乘，除，取余
**注意**：expr运算符间要有空格
```bash
expr 2 + 3
expr 3 - 2
expr `expr 3 + 2` \* 4
S=$[(2+3)*4]
echo $S
```
## 六、条件判断
`[ condition ]`（注意condition前后要有空格）
**注意**：条件非空即为true，[ tian ]返回true，[] 返回false。
**常用条件判断**
判断符|描述
:-:|:-:
**两整数比较**|
=|字符串比较
-lt|小于 less than
-le|小于等于 less equal
-eq|等于 equal
-gt|大于 greater than
-ge|大于等于 greater equal
-ne|不等于 not equal
**文件权限比较**|
-r|有读的权限 read
-w|有写的权限 write
-x|有执行的权限 execute
**文件类型比较**|
-f|文件存在且是一个常规文件 file
-e|文件存在 existence
-d|文件存在且是一个目录 directory

```bash
[ 23 -ge 22 ]
echo $? #0
[ 23 > 22 ]
echo $? #0,能用但是会在后面容易混淆
[ -w helloworld.sh ]
echo $? #0
[ -e ~/tian/workspace/shells/helloworld.sh ]
echo $? #0
[ condition ] && echo ok || echo notok #ok
[ condition ] && [  ] || echo notok #notok
```

## 七、流程控制
### 1.if判断
**语法**
```sh
if [ 条件判断式 ];then 
  程序 
fi 
#或者 
if [ 条件判断式 ] 
  then 
    程序 
fi
```
**注意**
[ 条件判断式 ]，中括号和条件判断式之间必须有空格
if后要有空格
```sh
#if.sh
#!/bin/bash

if [ $1 -eq "1" ]
then
    echo "banzhang zhen shuai"
elif [ $1 -eq "2" ]
then
    echo "cls zhen mei"
else
    echo else
fi
```
```bash
chmod 777 if.sh
./if.sh
```

### 2.case语句
**语法**
```sh
case $变量名 in 
  "值1"） 
    #如果变量的值等于值1，则执行程序1 
    ;; 
  "值2"） 
    #如果变量的值等于值2，则执行程序2 
    ;; 
  …省略其他分支… 
  *） 
    如果变量的值都不是以上的值，则执行此程序 
    ;; 
esac

```
**注意**
①case行尾必须为单词“in”，每一个模式匹配必须以右括号“）”结束。
②双分号“;;”表示命令序列结束，相当于java中的break。
③最后的“*）”表示默认模式，相当于java中的default。
```sh
#case.sh
#!/bin/bash

case $1 in
"1")
        echo "banzhang"
;;

"2")
        echo "cls"
;;
*)
        echo "renyao"
;;
esac
```
### 3.for循环
**语法**
*语法一*
```sh
for (( 初始值;循环控制条件;变量变化 )) 
  do 
    程序 
  done
```
```sh
#!/bin/bash
#1~100所有数的和
s=0
for((i=0;i<=100;i++))
do
  s=$[$s+$i]
done
echo $s
```
*语法二*
```sh
for 变量 in 值1 值2 值3… 
  do 
    程序 
  done
```
```sh
#!/bin/bash
#打印数字

for i in $*
    do
      echo "ban zhang love $i "
    done
```

**比较`$*`和`$@`区别**
```sh
#$*和$@都表示传递给函数或脚本的所有参数，不被双引号“”包含时，都以$1 $2 …$n的形式输出所有参数。
#!/bin/bash 

for i in $*
do
      echo "ban zhang love $i "
done

for j in $@
do      
        echo "ban zhang love $j"
done

###############################################################################
#当它们被双引号“”包含时，“$*”会将所有的参数作为一个整体，以“$1 $2 …$n”的形式输出所有参数；“$@”会将各个参数分开，以“$1” “$2”…”$n”的形式输出所有参数。
#!/bin/bash 

for i in "$*" 
#$*中的所有参数看成是一个整体，所以这个for循环只会循环一次 
        do 
                echo "ban zhang love $i"
        done 

for j in "$@" 
#$@中的每个参数都看成是独立的，所以“$@”中有几个参数，就会循环几次 
        do 
                echo "ban zhang love $j" 
done

```
### 4.while循环
**语法**
```sh
while [ 条件判断式 ] 
  do 
    程序
  done
```
```sh
#有问题
#!/bin/bash
s=0
i=1
while [ $i -le 100 ]
do
        s=$[$s+$i]
        i=$[$i+1]
done

echo $s
```
## 八、read读取控制台输入
**语法**
read(选项)(参数)
	选项：
-p：指定读取值时的提示符；
-t：指定读取值时等待的时间（秒）。
参数
	变量：指定读取值的变量名

```sh
#有问题
#read.sh
#!/bin/bash

read -t 7 -p "Enter your name in 7 seconds " NAME
echo $NAME
```

## 九、函数
### 1.系统函数
#### 1.1basename基本语法
basename命令会删掉所有的前缀包括最后一个（‘/’）字符，然后将字符串显示出来。
选项：
suffix为后缀，如果suffix被指定了，basename会将pathname或string中的suffix去掉。

```bash
basename [string / pathname] [suffix] 

#截取该/home/tian/banzhang.txt路径的文件名称
basename ~/workspace/banzhang.txt
basename ~/workspace/banzhang.txt .txt
```
#### 1.2dirname基本语法
从给定的包含绝对路径的文件名中去除文件名（非目录的部分），然后返回剩下的路径（目录的部分）
```bash
dirname 文件绝对路径
dirname ~/workspace/banzhang.txt
```
### 2.自定义函数
```sh
[ function ] funname[()]
{
	Action;
	[return int;]
}
funname
```
**经验技巧**
①必须在调用函数地方之前，先声明函数，shell脚本是逐行运行。不会像其它语言一样先编译。
②函数返回值，只能通过$?系统变量获得，可以显示加：return返回，如果不加，将以最后一条命令运行结果，作为返回值。return后跟数值n(0-255)
```sh
#!/bin/bash
function sum()
{
    s=0
    s=$[ $1 + $2 ]
    echo "$s"
}

read -p "Please input the number1: " n1;
read -p "Please input the number2: " n2;
sum $n1 $n2;
```
## 十、Shell工具（重点）
### 1.wc
**基本用法**
we [选项参数] filename
**参数说明**
选项参数|功能
:-:|:-:
-l|统计文件行数
-w|统计文件的单词数
-m|统计文件的字符数
-c|统计文件的字节数

```bash
ll|grep redis_6379.conf
cat -n redis-6379.conf
wc -w redis_6379.conf
wc -l redis_6379.conf
wc -m redis_6379.conf
```
### 2.cut
在文件中负责剪切数据使用，cut命令从文件的每一行剪切字节、字符和字段并将这些字节、字符和字段输出
**基本用法**
cut [选项参数] filename
**说明** 默认分隔符是个制表符
**参数说明**
选项参数|功能
:-:|-
-f|f为fileds，列号，提取第一列
-d|d为Descriptor分隔符，按照指定分隔符分割列

```bash
#以:为间隔切割PATH环境变量的第一列
echo $PATH
echo $PATH | cut -d ':' -f 1

#以:为间隔切割PATH环境变量的第二列、第三列
echo $PATH
echo $PATH | cut -d ':' -f 2,3

#选取系统PATH变量值，第二个:开始后的所有路径
echo $PATH
echo $PATH | cut -d: -f 3-

#以:为间隔，切割PATH环境变量的第一到三列和第五列
echo $PATH
echo $PATH | cut -d ':' -f 1-3,5

#切割ifconfig后打印的IP地址
ifconfig eth0 | grep "inet addr" | cut -d: -f 2 | cut -d" " -f 1
```
### 3.sed
**sed**是一种流编辑器，一次处理一行内容。处理时，把当前处理的行存储在临时缓冲区中，成为“模式空间”，接着用sed命令处理缓冲区中的内容，处理完成后，把缓存区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。**文件内容并没有改变**，除非你使用重定向存储输出。
**基本用法**
sed [选项参数] 'command' filename
**参数说明**
选项参数|功能
:-:|-
-e|直接在指令模式上进行sed的动作编辑

命令功能描述
命令|功能描述
:-:|-
a|新增，a的后面可以接字串，在下一行出现
d|删除
s|查找并替换
```txt
#文件准备
dong shen
guan zhen
wo  wo
lai  lai

le  le
```
```bash
touch sed.txt
vim sed.txt
#将“mei nv”这个单词插入到sed.txt第二行下，打印。
sed '2a mei nv' sed.txt
cat sed.txt
#删除sed.txt文件所有包含wo的行
sed '/wo/d' sed.txt
#删除sed.txt文件第二行
sed '2d' sed.txt
#删除sed.txt文件最后一行
sed '$d' sed.txt
#删除sed.txt文件第二行至最后一行
sed '2,$d' sed.txt
#将sed.txt文件中wo替换为ni
sed 's/wo/ni/g' sed.txt
#将文件中的第二行删除并将wo替换为ni
sed -e '2d' -e 's/wo/ni/g' sed.txt
```

### 4.awk
强大的文本分析工具，把文件逐行读入，以空格为默认分隔符将每行切片，切开的部分再进行分析洗处理
**基本用法**
awk [选项参数] 'pattern1{action1} pattern2{action2} ... ' filename
**pattern**表示awk在数据中查找的内容，就是匹配模式
**action**在找到匹配内容时所执行的一系列命令
**参数说明**
选项参数|功能
:-:|:-:
-F|指定输入文件的分隔符
-v|赋值一个用户定义变量
```bash
#准备数据
sudo cp /etc/passwd ./
#搜索passwd文件以root关键字开头的所有行，并输出该行的第七列
awk -F : '/^root/{print $7}' passwd
#搜索passwd文件以root关键字开头的所有行，并输出该行的第一列和第七列，中间以，分割
awk -F: '/^root/{print $1","$7}' passwd
#注意：只有匹配了pattern的行才会治I型那个action
#只显示第一列和第七列，以都好分割，且在所有行前面添加列名user,shell在最后一行添加“dahaige,/bin/zuishuai”
awk -F: 'BEGIN{print "user,shell"} {print $1","$7} END{print "dahaige,/bin/zuishuai"}' passwd
#注意：BEGIN在所有数据读取行之前执行；END在所有数据执行之后执行
#将passwd文件中的用户id增加数值1并输出
awk -v i=1 -F: '{print $3+i}' passwd
```
awk的内置变量
变量|说明
:-:|-
FILENAME|文件名
NR|已读的记录数（行号）
NF|浏览记录的域的个数（切割后列的个数）

```bash
#统计passwd文件名，每行的行号和每行的列数
awk -F: '{print "filename:" FILENAME ", linenumber:"NR ",column:" NF}' passwd
#切割IP
ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk -F " " '{print $1}'
#查询sed.txt中空行所在的行号
awk '/^$/{print NR}' sed.txt
```
### 5.sort
**sort**命令在linux中非常有用，它将文件进行排序，并将排序结果标准输出。默认情况以第一个字符串的字典顺序来排序！
**基本语法**
sort(选项)(参数)
选项|说明
:-:|-
-n|依照数值的大小排序
-r|以相反的顺序来排序
-t|设置排序时所用的分割字符，默认使用TAB
-k|指定需要排序的列
-u|u为unique的缩写，即相同的数据只出现一行

参数：指定待排序的文件列表
```bash
touch sort.txt
vim sort.txt
```
```
bb:40:5.4
bd:20:4.2
xz:50:2.3
cls:10:3.5
ss:30:1.6
```
```bash
sort -t : -nrk 3 sort.txt
```