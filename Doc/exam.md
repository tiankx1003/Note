### 一、Linux

1. Linux常用命令
 * find df tar ps top netstat
2. CentOS查看版本
 * cat /etc/issue
3. Linux查看端口调用
 * netstat -anp|grep PORT
4. Linux命令查看内存、磁盘io、端口、进程
 * 查看内存: top
 * 查看磁盘存储情况: df -h
 * 查看端口: netstat -anp|grep PORT
 * 查看进程: ps aux 、 ps -ef
5. 使用Linux命令查询file1里面空行所在行
 * awk '/^$/{print NR}' file1
6. 文件中指定列的和并输出
 * awk -v sum=0 -F ""'{sum+=$2} END{print sum}' chengji.txt
7. 把Linux文件`/home/dim_city.txt`加载到hive内部表`dim_city`外部表中，HDFS路径为`/user/dim/dim_city`
```sql
-- 建表指定外部表类型为外部表，指定表的location属性
create external table dim_city(...) location '/user/dim/dim_city';
-- 加载数据
load data local inpath '/home/dim_city.txt' into table dim_city;
```
8. Shell脚本里如何检查文件是否存在，如果文件不存在该如何处理?Shell里如何检查一个变量是否是空?
```sh
if [-f file.txt];then
	echo "文件存在!"
else
	echo "文件不存在!"
fi
```
9. Shell脚本里如何统计一个目录下(包含子目录)有多少个java文件?如何取得每一个文件的名称(不包含路径)
ls -lR 目录名|grep ".java$"|wc -l
获取文件名: basename path
<!-- TODO ??? -->

### 二、Hadoop入门
1. 简述apache的一个开源Hadoop的步骤
 * 根据Hadoop版本安装匹配JDK，配置`JAVA_HOME`
 * 解压安装Hadoop，配置`HADOOP_HOME`，将bin&sbin目录添加到PATH
 * 配置Hadoop的配置文件，hadoop-env.sh,yarn-env.sh,mapred-env.sh中添加环境`JAVA_HOME`，如果配置了~/.bashrc也可以不配置
   配置hdfs-site.xml,yarn-site.xml,mapred-site.xml,core-site.xml中添加必要配置(NN,2NN,YARN,tmp路径，压缩方式、副本个数、历史服务器、日志聚集等)
 * 对于完全分布式的集群，则需要配置所有及其的hosts映射信息，配置ResourceManager到其他及其的ssh免密登录
 * 在ResourceManager所在主机编辑`$HADOOP_HOME/etc/hadoop/slave`文件，配置集群中的所有主机名
 * 分发安装配置好的hadoop到其他节点
2. Hadoop中需要哪些配置文件，有什么作用
 * *-env.sh 文件为配置Hadoop各个组件运行的环境信息
 * core-site.xml 用户自定义核心组件，如NameNode所在rpc地址
<!-- TODO rpc ??? -->
 * hdfs-site.xml 用户自定义的hdfs相关参数
 * mapred-site.xml 用户自定义的mapreduce相关参数
 * yarn-site.xml 用户自定义和yarn相关的参数
3. 列出正常工作的Hadoop集群都分别启动哪些进程，简述他们的作用
 * ResourceManager 负责整个集群中所有计算资源(CPU、内存、IO、硬盘)的管理
 * NodeManager 负责单个节点中所有计算资源(CPU、内存、IO、硬盘)的管理，领取ResourceManager中的Task，分配container运行Task
 * NameNode 负责HDFS中元数据的管理和处理客户端的请求
 * DataNdde 以块为单位存储HDFS中的数据
 * SecondaryNameNode 帮助NameNode定期合并fsimage和edits文件，HA中可以省略此进程
4. 简述Hadoop中的默认端口和含义
 * 50070	NameNode的http服务端口
 * 9000		NameNode的接收客户端rpc调用端口<!-- TODO ??? -->
 * 8088		Yarn的http服务端口
 * 10888	MapReduce运行历史手机服务的http服务端口
 * 8042		NodeManager的http服务端口
### 三、Hadoop的HDFS
1. HDFS的存储机制(读写流程)
   ▼写流程
 * 1.客户端创建一个分布式文件系统客户端对象，向NN发送请求，请求上传文件
 * 2.NN处理请求，对请求进行合法性检查(权限，文件路径是否存在等)，验证请求合法后，响应客户端，通知写操作
 * 3.客户端创建一个输出流，输出流在写文件时，以块(128M)为单位，块又由packet(64k)作为基本单位，packet由多个chunk(512B+4B校验位)组成!
 * 4.开始第一块的上传，在上传时，会请求NN，根据网络拓扑距离，和上传的副本数，分配指定数量的距离客户端最近的DataNode节点列表
 * 5.客户端请求距离最近的一个DN建立通道，DN列表中的DN依次请求建立通道，全部通道建立完成，开始传输!客户端将一个块的0-128信息，以packet形式进行封装，将封装好的packe放入`data_queue`队列中，输出流在传输时，会建立一个`ack_queue`，将data_queue要传输的packet一次放入`ack_queue`中!
 * 6.客户端只负责当前的packet发送给距离最近的DN，DN会在收到packet后，向客户端的流对象发送ack命令，当ack_queue中的packet已经被所有的DN收到，那么在当前队列中就会删除次packet
 * 7.第一块上传完毕后，会上报NN，当前块已经发送到了哪些DN上!开始传输第二块(128M-...)，和第一块一样的流程
 * 8.当所有的数据都上传完毕，关闭流等待NN的一个响应
   ▼读流程
 * 1.客户端向NN发送请求，请求读取指定路径文件
 * 2.NN处理请求，返回当前文件的所有块列表信息
 * 3.客户端创建一个输入流，根据块的信息，从第一块开始读取，根据拓扑距离选择最近一个节点进行读取，剩余块一次读取
 * 4.所有块信息读取完毕，关流
2. SecondaryNameNode工作机制
 * 2NN和NN不是主从关系，2NN不是NN的热备，是两个不同的进程，2NN负责辅助NN工作，定期合并NN中产生的edits日志文件和fsimage镜像文件
 * 2NN基于连个触发条件，执行CheckPoint(合并)，每隔`dfs.namenode.checkpoint.period`秒合并一次，默认为1小时，每个`dfs.naemnode.checkpoint.txns`次合并一次，默认为100W，<!-- TODO ??? -->2NN默认每间隔60秒向NN发送请求，判断CheckPoint的条件是否满足，如果满足，向NN发送请求立刻滚动日志(产生一个新的日志，之后的操作都向新日志写入)，将历史日志和fsimage文件拷贝到2NN工作目录中，加载到内存进行合并，合并后，将新的fsimage文件传输给NN，覆盖老的fsimage文件
3. NameNode与SecondaryNameNode的区别和练习
   ▼联系
 * 2NN需要配合NN工作，NN启动，2NN工作才有意义
 * 2NN可能会保存部分和NN一致的元数据，可以用来NN的容灾回复
   ▼区别
 * 这是两个功能不同的进程，不是主备关系
4. 服役新节点和退役旧节点步骤
 * 服役新节点: 添加服务器、安装软件、配置环境、启动进程
 * 退役旧节点: 使用黑白名单
5. NameNode元数据损坏怎么办
 * 如果配置了NN的多目录配置，还可以照常启动
 * 如果多个目录的元数据都损坏，可以查看是否启用了HA，或者查看是否启用了2NN
 * 可以通过另外一个NN或者2NN中的元数据进行恢复
### 四、Hadoop的MapReduce
1. Hadoop的序列化和反序列化及自定义bean对象实现序列化
 * Hadoop中如果有reduce阶段，那么Mapper和Reducer中的key-value实现序列化
 * Hadoop采用的是自己的序列化机制(Writable机制)，是一种轻量级的序列化机制，储存的数据少，适合大数据量的网络传输
 * 无论是Map还是Reduce阶段，key-value需要实现Writable接口即可，重写readFiles()和writeFields()方法即可
2. FileInputFormat切片机制
 * 将输入目录中的所有文件，以文件单位进行切片
 * 根据isSplitable()方法，以文件的后缀名为依据，判断文件是否使用了压缩个格式，如果是普通文件则可切，否则判断是否是一个可切的压缩格式
 * 如果文件不可切，真个作为一片
 * 可切，确定每片的大小(默认是块大小)，之后以此大小为依据，循环进行切片
 * 除了最后一篇有可能时切片大小的1.1倍，其余每片切片大小为大小
 <!-- TODO 切片机制描述太模糊 -->
3. 自定义InputFormat流程
    继承InputFormat类，通常可以继承FileInputFormat以节省方法的实现
 * 如果需要实现自定义的切片逻辑，实现或重写createSplits()方法
 * 实现createRecordReader()方法，返回一个RecordReader对象
 * RecordReader负责将切片中的数据以key-value形式读入到Mapper中
 * 其核心方法是nextKeyValue()，这个方法负责读取一对key-value，读到则返回true，否则返回false
 * 可以根据需要实现isSplitable()方法
4. 如何决定一个job的map和reduce数量
 * maptask数量取决于切片数，可以通过调整切片的大小来控制map的数量
 * reducetask数量取决于Job.setNumReduceTasks()的值
5. MapTask工作机制
 * Map阶段: 使用InputFormat的RecordReader读取切片中的每一对key-value，每一对key-value都会调用mapper的map()处理
 * Sort阶段: 在Mapper和map()方法处理后，输出的key-value会先进行分区，之后被收集到缓冲区，当缓冲区达到一定的溢写阈值时,每个区的key-value会进行排序，之后溢写到磁盘，每次溢写的文件，最后会进行合并为一个总的文件，这个文件包含若干区，而且每个区内都是有序的
6. ReduceTask工作机制
 * copy阶段: ReduceTask启动Shuffle进程，到指定的maptask拷贝指定的数据，拷贝后会进行合并，合并成一个总的文件
 * sort阶段: 在合并时，保证所有的数据都是合并后有序的，所以会进行排序
 * reduce阶段: 在合并后的数据，会进行分组，每一组数据，调用Reducer的reduce()方法，之后的reduce通过OutputFormat的RecordWriter将数据输出
7. 请描述mapReduce有几种排序及排序发生的阶段
 * 两种排序: 快速排序、归并排序
 * MapTask阶段，每次溢写前进行快排，最后合并时进行归并排序
 * ReduceTask阶段，在sort和merge时使用归并排序
8. 请描述MapReduce中shuffle阶段的工作流程，如何优化shuffle阶段
 * 从Mapper的map()结束后到Reducer的reduce()开始前为shuffle
 * 工作流程 sort() --> copy() --> sort()
 * 优化:本质就是减少磁盘IO(减少溢写次数和每次溢写的数据量)和网络IO(减少网络数据传输量)
   >MapTask阶段优化
    map端减少一些次数，调大`mapreduce.task.io.sort.mn`和`mapreduce.map.sort.spill.percent`
    map端减少合并的次数，调大`io.sort.factor`
    在合适的情况下使用Combiner对数据在map端进行局部合并
    使用压缩，减少数据传输量

   >ReduceTask端优化
    reduce端减少溢写次数，调大`mapred.job.reduce.input.buffer.percent`

9. 请描述MapReduce中combiner的作用是什么，使用情景，哪些情况不需要，和reduce的区别
 * 作用是在每次溢写数据到磁盘时，对数据进行局部的合并，减少溢写数据量
 * 求和，汇总等场景适合使用，不是适合的场景例如求平均数
 * 和reduce的唯一区别，就是Combiner时运行在Shuffle阶段，且主要时MapTask端的shuffle阶段，而Reducer运行在reduce阶段
10. 如果没有定义partitioner，那数据在被送达Reducer前是如何被分区的
 * 如果ReduceTask个数为1，那么所有key-value都是0号区
 * 如果ReduceTask个数是大于1，默认使用HashPartitioner，根据key的hashCode()方法和Integer最大值做与运算，之后模除ReduceTask的个数
 * 所有数据的区号介于0和ReduceTask个数-1的范围内
11. MapReduce怎么实现TopN
  在Map端使数据根据排名字段进行排序
 * 合理设置Map的key，key中需要包含排序的字段
 * 通过时key实现WritableComparable接口或者自定义key的RawComparator类型比较器，归根到底，在排序时都是使用用户实现的compareTo()方法进行比较
  在Reduce端是输出数据
 * reduce端处理的数据已经自动排序完成，只需要控制输出N个key-value即可
12. 有可能使Hadoop任务输出到多个目录中么?如果可以怎么做?
 * 可以，通过自定义OutputFormat进行实现，核心时实现OutputFormat中的相关的RecordWriter，通过实现其write()方法就需要的数据输出到指定的目录
13. 简述Hadoop实现join的几种方法及每种方法的实现方法
 * ReduceJoin: 在Map阶段，对所有的输入文件进行组装，打标记输出，到reduce阶段，只处理啊需要join的字段，进行合并即可
 * MapJoin: 在Map阶段，将小文件以分布式缓存的形式进行存储，在Mapper的map()方法处理前，读取小文件的内容，和大文件进行合并即可，不需要有reduce阶段
14. 请简述hadoop怎样实现二级排序
 * key实现WritableComparable()接口，实现CompareTo()方法，先根据一个字段比较，如果当前字段相等继续按照另一个字段进行比较
15. 已知MapReduce场景为(HDFS文件块大小为64M，输出类型为FileInputFormat，有三个文件的大小分别时64k、65MB、127MB)，hadoop框架会把这些文件且多少片
 * 4片
16. Hadoop中RecordReader的作用是什么
 * 读取每一片中的记录为key-value，传给Mapper
17. 若有一个1G的数据文件，分别有id,name,mark,source四个字段，按照mark分组，id排序，减少排序的核心逻辑思路，其中启动几个MapTask
 * Map阶段key的比较器，使用根据mark和id进行二次排序
 * Reduce阶段分布比较器，根据mark进行比较，mark相同视为key相同
 * 默认启动8个MapTask
### 五、Hadoop的Yarn
1. 简述Hadoop1和Hadoop2的架构异同
 * Hadoop1使用JobTracker调度MR的运行
 * Hadoop2提供Yarn框架进行资源的调度
 * Hadoop2支持HA集群搭建
2. 为什么会产生Yarn，它解决了什么问题，有什么优势
 * Yarn为了将MR编程模型和资源的调度分层解耦
 * 使用Yarn后软件维护方便，Yarn还可以为其他的计算框架例如spark等提供资源的调度
3. MR作业提交全过程
<!-- TODO 添加配图 -->
4. HDFS的数据压缩算法
 * 系统内置: deflate、gzip、bzip2
 * 额外安装: lzo、snappy
 * 压缩率高: bzip2
 * 速度快:   snappy、lzo
 * 可切片的: lzo、bzip2
 * 使用麻烦: lzo
5. Hadoop调度器总结
   ▼FIFO调度器
 * 单队列
 * 按照job提交的顺序先进先出
 * 容易出现单个用的job独占资源，而其他的小job无法及时处理的问题
   ▼容量调度器
 * 多个队列，队列内部FIFO，内个队列可以指定容量
 * 资源利用率高，处理灵活，空闲队列的资源可以补充到繁忙队列
 * 可以设置单个用户的资源限制，防止单个用户独占资源
 * 动态调整，维护方便
   ▼公平调度器
 * 在容量调度器的基础上，改变了FIFO的调度策略
 * 默认参考集群中内存资源使用最大最小公平算法，保证小Job可以及时处理，大job不至于饿死，对小job有优势
6. MapReduce推测执行算法及原理
<!-- TODO 推荐执行算法配图 -->
### 六、Hadoop优化
1. MapReduce跑的慢的原因
 * Task运行申请的资源少，可以通过调节相关参数解决
 * 程序逻辑复杂，可以将复杂逻辑拆分为多个job，串行执行
 * 产生了数据倾斜，可以通过合理设置切片策略和设置分区及调节ReduceTask数量解决
 * Shuffle过程漫长，可以通过合理使用Combiner，使用压缩，调大Map端缓冲区大小等解决
2. MapReduce优化方法
<!-- TODO HadoopMapReduce第六章第2节 -->
3. HDFS小文件优化方法
 * 在源头处理，就小文件压缩和打包
 * 使用Har进行归档，Har归档后的文件只能节省NameNode的内存空间，在进行MapReduce计算时，依然以小文件的形式存在
 * 使用CombineTextInputFormat
 * 使用紧凑的文件格式，例如SequenceFile
4. MapReduce怎么解决数据均衡问题，如何确定分区号
 * Map端避免数据倾斜: 抽样数据，避免不可切分的数据，小文件过多，使用CombineTextInputFormat
 * Reduce端避免数据倾斜: 抽样数据，合理设置数据的分区，合理设置ReduceTask的个数
 * 使用Partitioner的getPartition()确定分区号
5. Hadoop中job和Task之间的区别是什么
 * 一个job在运行期间，会启动多个task来完成每个阶段的具体任务
### 七、ZooKeeper
