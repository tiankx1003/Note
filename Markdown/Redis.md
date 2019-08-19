# Redis
### 现代互联网架构（略）

### NoSQL
关系型数据库的查询瓶颈
**CAP**无法三者兼顾
    Redis
    Mongdb
    HBase
    Neo4j

#### Redis优点

### Redis安装
上传tar包
解压tar包
安装gcc-c++
编译
配置环境变量

```bash
tar -zcvf file.tar.gz -C /opt/module #解压
yum -y install gcc-c++ #安装gcc编译器
make #编译
make install #安装在/usr/local/bin
vim /etc/profile #配置环境变量
```
#### redis.conf
```properties
bind 127.0.0.1 192.168.2.101
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
save 900 1 
save 300 10
save 60 10000
```


```bash
redis-server
redis-cli -h
redis-cli -p
```

### redis操作e
```sql
shutdown #关闭服务端
exit #退出
select 1 ~ 15 #切库

set k1 v1 #存放键值对数据
set k2 v2
dbsize #显示库中数据个数
flushdb #清空数据库
flushall #清空所有库

get k2 #返回v2
keys * #返回所有key，不推荐使用
keys k? #？表示一位占位符
keys k??
type k1 #返回类型
exists k1 #是否存在
del k1 #删除

expire k1 10 #设置过期时间
ttl k1 #是否过期

rename key newkey #重命名，已存在则覆盖
renamenx key newkey #已存在则不操作
```

### 常用五大数据类型
key(String)-value(各种数据类型)

| 数据类型 | 说明 |
| :-----: | :---: |
| String | 字符串，最大512M，二进制安全，可以存储字节数组 |
| list | 有序可重复，双向链表，压栈(push) 弹栈(pop)，每个数据对应两个索引值 |
| set | 无序不可重复，|
| hash | 不支持进一步扩展,json直接存数据库 |
| zset | sorted set 多保存了一个score进行排序 |


```sql
-- String操作
set key value
get key
mset key1 value1 key2 value2
mget key1 key2
msetnx key1 value1 key2 value2 #仅当所有key都不存在时生效
getrange key startindex endindex #按区间获取值
setrange key startindex endindex #覆盖指定区间的值
getset key value #以新换旧，获取旧值
setex key 过期时间 #
append key value
strlen key #获取值的长度

-- list操作
lpush numlist 0 1 2 3 #左侧压栈
rpush numlist 4 5 6 #右侧压栈
lrange key start stop #查看指定区间的元素
lpop numlist
rpop numlist
llen numlist
lindex numlist 2 
lindex numlist -4
linsert numlist before before 0 new #在零的位置插入'new'
lrem key n value #从左侧删除n个value
lset key index value #从索引位置替换另一个值
ltrim key start stop #
rpoplpush key1 key2 #

-- set操作
smembers key
sismenber key value
scard key
srem key member [member ...] 
spop key [count]
srandommember key [count]
sinter key [key ...]
sunion key [key ...]
sunionstore dest key [key ...]
sdff key [key ...]
sdiffstore dest key [key ...]

-- hash操作
hset key field value #为key中的field复制value
hmset key field value [filed value ...] #保存多个
hkeys stu
hvals stu
hlen stu
hget stu age
hmget stu age name
hexists key field
hincrby key field increment

-- zset操作
zadd key [score member ...]
zscore key member
zrange key start stop [withscores]
zrangescore key min max [withscores] [limit offset count]
zrangescore key max min [withscores] [limit offset count]
zcard key
zcount key min max
zrem key member
zrevrangebyscore subject +inf 95 withscore
zrevrangebyscore subject -inf 100 withscore
```


### 持久化
**原因**：Redis基于内存，内存中的数据由于特殊情况，容易丢失！
为了保证数据安全，采用吃持久化，将内存中的数据落盘，便于恢复
Redis支持RDB(快照存储)和AOF(日志存储)两种持久化方式
AOF默认不开启，需要手动开启，记录写命令到日志文件，恢复时直接读取日志文件从头开始执行命令并恢复数据。
appendonly yes 开启AOF
appendfilename是aof日志文件的名称 appendonly.aof
AOF可以恢复一些致命操作，如flushall，可以在日志中直接修改
aof文件重写来减少日志文件的冗余
重写策略，文件大小达到64M且超过一倍

```sql
set k1 v1
set k2 v2
save
bgsave #主进程不会阻塞
flushall #会自动进行持久化
shutdown #会自动进行持久化
```

### 事务
Redis中的数据库是一个隔离操作，用于串联命令防止别的命令插队
```sql
multi #开启组队
exec #一次性执行事务中的命令
discard #解散
watch #锁
```
执行时报错不影响其他命令的执行
发送命令时报错事务自动解散
**watch-锁**
悲观锁：绝对安全，高并发情况下效率低
乐观锁：基于版本号，读操作时效率很高，多写操作时会有资源浪费
Redis不支持悲观锁

### 消息订阅
消息中间件，临时把消息持久化
```sql
subscribe cctv-1 #订阅x消息
publish cctv-1 news #发送消息
#先订阅再发消息
```
### 主从复制
读写分离，分担压力，避免单点故障，容灾快速恢复
slaveof no one



### 哨兵模式

master下线后，从slaver中选取一个作为master，之前的master重连后变为slaver
新master选取时的条件
1.优先级靠前
2.偏移量最大
3.runid最小

主观下线
哨兵在检测到无法连接master后，发起投票，投票达到一定个数后也默认为下线

sentinel monitor mymaster sentinel. conf
redis-sentinel sentinel.conf

```java
//jedis配置时，连接哨兵
public void testSentinel() throws Exception {
    Set<String> set = new HashSet<>();
    // set中放的是哨兵的Ip和端口
    set.add("192.168.6.10:26379");
    GenericObjectPoolConfig poolConfig = new GenericObjectPoolConfig();
    JedisSentinelPool jedisSentinelPool = 
        new JedisSentinelPool("mymaster", set, poolConfig, 60000);//set放置所有哨兵的IP和端口号
    Jedis jedis = jedisSentinelPool.getResource();
    String value = jedis.get("k7");
    jedis.set("Jedis", "Jedis");
    System.out.println(value);
}
//启动后如果显示所有哨兵都down，那就在配置文件sentinel.conf中添加bind
```

### Redis Cluster

容量不够需要扩容，或并发写操作过多，需要分摊压力

集群的安装

集群中多了slot(插槽)的设计。一个 Redis 集群包含 16384 个插槽（hash slot）， 数据库中的每个键都属于这 16384 个插槽的其中一个， 集群使用公式 CRC16(key) % 16384 来计算键 key 属于哪个槽， 其中 CRC16(key) 语句用于计算键 key 的 CRC16 校验和 。

集群的创建



```java
//集群的Jedis连接
public void testCluster(){
		Set<HostAndPort> jedisClusterNodes = new HashSet<HostAndPort>();
		//Jedis Cluster will attempt to discover cluster nodes automatically
		jedisClusterNodes.add(new HostAndPort("192.168.4.128", 6379));
		JedisCluster jc = new JedisCluster(jedisClusterNodes);
		jc.set("foo", "bar");
		String value = jc.get("foo");
}
```

