# **Note**

#### CentOS 安装 VS Code

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
yum check-update
sudo yum install code
```
***依赖报错***
*错误：Package: code-1.35.1-1560350390.el7.x86_64 (code)
          Requires: libstdc++.so.6(GLIBCXX_3.4.15)(64bit)
错误：Package: code-1.35.1-1560350390.el7.x86_64 (code)
          Requires: libgtk-3.so.0()(64bit)
错误：Package: code-1.35.1-1560350390.el7.x86_64 (code)
          Requires: libstdc++.so.6(GLIBCXX_3.4.14)(64bit)
错误：Package: code-1.35.1-1560350390.el7.x86_64 (code)
          Requires: libsecret-1.so.0()(64bit)*

```bash
#CentOS6安装libstdc++
wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
yum install devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++
ln -s /opt/rh/devtoolset-2/root/usr/bin/* /usr/local/bin/
gcc --version
```



#### 卷积运算的实现

```C++
/*
C++卷积运算
*/
#include <iostream>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <vector>
#include <queue>
#include <map>
#include <algorithm>
using namespace std;
#define INF 0xfffffff
#define maxn 100010
int main()
{
    int m = 5, n = 5;
    int a[5] = {0, 1, 0, 2, 1}, b[5] = {0, 1, 0, 2, 1};
    int i, j;
    int k = m + n - 1; //卷积后数组长度
    int c[k];
    memset(c, 0, sizeof(c)); //注意一定要清零 /**卷积计算**/
    for (i = 0; i < k; i++)
    {
        for (j = max(0, i + 1 - n); j <= min(i, m - 1); j++)
            c[i] += a[j] * b[i - j];
        cout << c[i] << " ";
    }
    /****/
    cout << endl;
}
```



#### Remote-ssh @ VS Code

```powershell
#生成密钥对
ssh-keygen -t rsa #三次回车
```

```bash
vim /etc/ssh/sshd_config #修改服务器端ssh登录设置
#把RSAAuthentication和PubkeyAuthentication两行前面的#注释去掉
service sshd restart #重启服务
#上传公钥文件id_rsa.pub
scp id_rsa.pub root@tian01 #上传文件
mv id_rsa.pub authorized_keys #修改文件名
chmod 600 authorized_keys #设置文件权限
chmod 700 .ssh #设置目录权限
```

```conf
#config
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
Host test
    HostName test
    User root
    Port 22
    IdentityFile  C:\Users\Administrator\.ssh\id_rsa
```
**报错**无法连接到远程扩展主机服务器 (错误: Connection error: Unauthorized client refused.)
远程主机尝试重装ssh

### CenOS6更新OpenSSH
```bash
wget ftp://openbsd.ipacct.com/pub/OpenBSD/OpenSSH/portable/openssh-7.6p1.tar.gz
tar -zvxf openssh-7.6p1.tar.gz
cd openssh-7.6p1
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-zlib --with-md5-passwords --with-tcp-wrappers
make && make install
service sshd restart
ssh -V
```
### CentOS6更新libstdc++.so.6
```bash
##获取安装包并解压
wget http://ftp.gnu.org/gnu/gcc/gcc-6.1.0/gcc-6.1.0.tar.bz2
tar -xvf gcc-6.1.0.tar.bz2
##下载供编译需求的依赖项
cd gcc-6.1.0
./contrib/download_prerequisites
##建立一个目录供编译出的文件存放
mkdir gcc-build-6.1.0
cd gcc-build-6.1.0
##生成makefile文件
../configure -enable-checking=release -enable-languages=c,c++ -disable-multilib
##编译
make -j4 #-j4选项是make对多核处理器的优化，如果不成功请使用 make
##安装
make install
##查看安装
ls /usr/local/bin | grep gcc
##重启，查看gcc版本
gcc -v
##检查动态库
strings /usr/lib64/libstdc++.so.6 | grep GLIBC
##查找编译gcc时生成的最新动态库
find / -name "libstdc++.so*"
##拷贝文件到/usr/lib64
cp /opt/module/gcc-6.1.0/gcc-build-6.1.0/stage1-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.22 ./
##删除原来的软链接并新建软链接指向最新动态库
rm -rf libstdc++.so.6
ln -s libstdc++.so.6.0.22 libstdc++.so.6
##检查动态库
strings /usr/lib64/libstdc++.so.6 | grep GLIBC
```

***测试 Remote-shh @ VSCode 2 centos6***
安装CentOS6
设备名test
IP 192.168.2.200
网关 192.168.2.2
永久关闭防火墙
设置ssh
上传公钥
远程连接
更新ibstdc++.so.6
克隆虚拟机
更新ssh


```bash
#CentOS7防火墙设置
firewall-cmd --state
#停止防火墙
systemctl stop firewall.service
#禁止firewall开机启动
systemctl disable firewalld.service
```

```bash
[root@test gcc-6.1.0]# ./contrib/download_prerequisites 
```


>**总结**
Remote-ssh @ VSCode
能够正常连接CentOS 7 Ubuntu 1904
在连接CentOS 6.8时
客户端报错未授权
服务器日志文件显示libstdc++.so.6 GLIBC缺失
更新libstdc++.so.6至高版本，库文件缺失得到解决
客户端仍旧报错未授权
更新服务器端ssh-server未解决

>**步骤**
安装CentOS6.8
配置设备名和网络，永久关闭防火墙
更新gcc
更新libstdc++.so.6
更新openssh
上传公钥
命令行远程连接测试
配置config文件使用Remote-ssh连接

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


注册表路径
\HKEY_CLASSES_ROOT\Directory\Background\shell\


[Windows Terminal](https://docs.microsoft.com/zh-cn/windows/win32/termserv/win32-terminalterminalsetting)
