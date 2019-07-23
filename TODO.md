
## Note.md

* [ ] **HDFS >> HDFS IO**

* [x] **MapReduce >> MapReduce框架原理 **

  ​	**>> InputFormat数据输入 & 切片与MapTask并发度决定机制**

*2019-7-23 08:53:49*

* [ ] test


## Settings

* [x] **VS Code Untitled open >> "startup" "init"**
```json
"workbench.startupEditor": "none",
"workbench.editor.enablePreviewFromQuickOpen": true,
"workbench.editor.enablePreview": true
```

*2019-7-23 08:54:09*

<!-- test -->

test


## Learning

* [ ] **Linux crontab 4 Hadoop**

*2019-7-23 08:54:47*

```
1. job.WaitForCompletion();
2. 
3. submit();
	3.1 ensureState(JobState.DEFINE);确认Job的状态
	3.2 setUseNewAPI();设置使用新的API
	3.3 connect();
		[1] 创建cluster对象，return new Cluster(getConfiguration());
		[2] initialize方法中创建cluster
		[3] 
	3.4 ★ submitJobInternal();
		[1] checkSpecs(job);判断输出路径是否存在，如果存在抛出异常
		[2] JobSubmissionFiles.getStagingDir(cluster,conf);
			创建临时目录用于存放切片和job信息
		[3] submitClient.getNewJobID();生成一个jobID
		[4] copyAndConfigureFile();拷贝并配置文件
		[5] ★ writeSplits(job,submitJobDir);生成切片信息
			a. 默认使用的FileInputFormat是TextInputFormat
			b. input.getSplits(job);获取切片信息
				long minSize -- 
				long maxSize -- Long的最大值
				本地块BlockSize大小默认 -- 32M
				获取切片大小 -- 
				判断是否继续切片 -- 
		[6] writeConf(conf,jobFile);将所有xml配置信息写入job.xml
		[7] submitClient.submitJob(jobID,submitJobDir.toString());
			提交job，删除存放job和切片的临时目录
		
```



​	ctrl + shift + t  搜索查看类

​	ctrl + t 查看子类/实现类

​	ctrl + shift + o :全局导包



