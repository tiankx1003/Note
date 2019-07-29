
## Note

* [ ] -
* [ ] **端口号汇总** *2019-7-29 10:17:34*
* [ ] **设计模式** *2019-7-29 09:21:44*
* [ ] **编写MapReduce扩充案例** *2019-7-29 00:39:00*
* [ ] **补充MapReduce笔记** *2019-7-29 00:37:39*
* [x] **Hadoop Xmind 总结**
* [ ] **Hadoop crontab 定时任务** *2019-7-25 14:44:55*
* [ ] **HDFS >> HDFS IO**
* [ ] **解决HDFS和MapReduce的所有TODO**
* [x] **MapReduce代码在IDEA上再写一遍**
* [ ] **自定义inputformat的debug**
* [ ] **shuffle源码**


## Settings

* [x] **VS Code Untitled open >> "startup" "init"**
```json
{
    "workbench.startupEditor": "none",
    "java.configuration.maven.userSettings": "C:\\Developing\\apache-maven-3.5.3\\conf\\settings.xml",
    "java.home": "C:\\Developing\\jdk1.8.0_211",
    "java.maven.downloadSources": true,
    "maven.executable.path": "C:\\Developing\\apache-maven-3.5.3\\bin\\mvn.cmd",
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "java.configuration.checkProjectSettingsExclusions": false,
    "workbench.iconTheme": "material-icon-theme",
    "explorer.confirmDragAndDrop": false,
    "explorer.confirmDelete": false,
    "workbench.editor.enablePreview": false,
    "markdown-preview-enhanced.previewTheme": "github-dark.css",
    "markdown-preview-enhanced.revealjsTheme": "black.css",
    "markdown-preview-enhanced.mermaidTheme": "dark",
    "markdown-preview-enhanced.codeBlockTheme": "atom-dark.css",
    "git.autofetch": true,
    "window.zoomLevel": 0,
    "window.menuBarVisibility": "toggle"
}
```

*2019-7-23 08:54:09*

<!-- test -->


## Learning

* [ ] **Linux crontab 4 Hadoop**

*2019-7-23 08:54:47*

Port
8080
3306
6379
50070
50090
8088
19888







>**Eclipse keymaps**
ctrl + shift + t  搜索查看类
ctrl + t 查看子类/实现类
ctrl + shift + o :全局导包

>**IDEA keymaps**



使用KeyValueTextInputFormat分隔符为":"
Map阶段
读取key为左侧Text，value为右侧Text
HashMap<Character,HashSet<Character>>
输出key为hashMap的key，value为hashMap的value
Reduce阶段
对key1和key2取交集
reduceMap.get(key1).containAll(reduceMap.get(key2))
