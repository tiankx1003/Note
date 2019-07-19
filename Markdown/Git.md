# GIT

版本控制工具

### Git概念

**工作区**：工作的目录，本地的一个目录
**本地库**：本地库时git保存数据的目录，通常是工作区中的一个名为.git的隐藏目录
**暂存区**：对应.get/index文件，代表

使用**原则**：将工作区最新的修改提交到本地库

### 安装git 

设置命令行形式为bash

### 常用git命令

```bash
git config --global user.name tian #设置账户
git config --global user.email tiankx@gmail.com #设置邮箱
vim ~/gitconfig #查看配置文件
git init
vim hello.txt
git status
git add hello.txt
git rm --cached hello.txt #如果文件在本地库还没有历史版本可以使用该命令撤回
git checkout -- hello.txt #如果本地库有历史版本，则撤销更改
git commit hello.txt 
git commit -m hello.txt
git status
```

### 版本切换

多个已经管理的版本之间进行切换

```bash
git log #完整格式查看提交日志
git log --pretty=oneline #精简日志格式
git reset --hard HEAD^ #回退版本
git reset --hard HEAD~n #回退n个版本
git reflog #查看所有操作的历史记录
git reset --hard versionID #回退到指定操作，可以用于前进
rm Hello.txt #删除操作也要提交为最新
git checkout -- test.log #从本地库检出恢复
git diff file #工作区和暂存区比较
git diff HEAD file #工作区和本地库比较
git diff --cached file #暂存区和本地库比较
```

### 分支操作

从主干拉去分支，开发完成后合并到主干
```bash
git branch -v #显示分支信息
git branch dev #新建一个名为dev的分支
git checkout dev #切换到dev分支
git merge dev #把dev分支合并到当前所在的分支(master)
git branch -d dev #删除dev分支
git branch dev
git checkout -b test #新建并切换分支
```
多分支合并冲突，需要解决冲突并重新提交（不需要指明文件名）

### Github
```powershell
ssh-keygen -t rsa #三次回车，生成密钥对，上传公钥
```
```bash
ssh -T git@github.com #测试连接
git remote add  Note git@github.com:Tiankx1003/Note.git #为远程地址添加代号
git push -u Note master #把本地分支推送到远程库
git remote -v #查看远程分支
git fetch origin master #从远程库获取更新并不合并
git pull Note master #本地库抓取远程库
git clone git@github.com:Tiankx1003/Note.git GitNote #克隆远程库项目到本地
```

#### 冲突解决

冲突原因：本地库的版本和远程库的版本都做了更新！
在推送之前，执行git fetch，发现远程库和本地库有版本变化。
查看git status
此时，建议先pull，将远程库的版本和本地库的版本merge后再push！
如果强行push,报错！
解决办法：先pull，pull的时候会发现报错冲突
因此开始解决冲突，编辑冲突文件！
编辑完成后再push
总结：pull ---- merge ---- push

#### 邀请成员

#### fork

如果其他人，搜索到了你的项目，想对其做一些编辑时，必须先执行fork操作。
①搜索感兴趣的项目
②fork到自己的远程库，fork到自己的github后，自己可以进行编辑！
③将自己做的pull request给原作者，以等待原作者采纳！
④原作者查看后，执行合并操作
⑤确认没有冲突后，执行合并操作！

### Egit
#### 准备工作
1.1安装Egit
1.2设置git账户
1.3设置ssh密钥
1.4创建Java项目
#### 本地项目推送至github
2.1将本地项目变为git项目
2.2项目添加到暂存区
2.3提交到本底库
2.4推送到远程仓库
#### 较高版本eclipse导入git工程
3.1直接导入github上的工程
3.2clone一个项目
#### 获取远程库的更新
#### 处理冲突
