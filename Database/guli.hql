-- 1. 统计视频观看数Top10

select videoId , views 
from gulivideo_orc 
order by views desc  limit  10 ;


-- 2. 统计视频类别热度Top10 ( 每个类别下视频的个数 )

-- a. 炸开视频类别
select videoId, category_name 
from gulivideo_orc 
lateral view explode(category) category_t as category_name        ;---->  t1 

-- b. 按照类别分组，并count当前类别下视频的总个数

select t1.category_name, count(*) hot
from t1
group by t1.category_name
order by hot desc        ;---->  t2 

-- c. Top10 

select  t2.category_name ,t2.hot
from t2 
limit 10 ;


-- 结果: 
select  t2.category_name ,t2.hot
from  (select t1.category_name, count(*) hot
from (select videoId, category_name 
from gulivideo_orc 
lateral view explode(category) category_t as category_name )t1
group by t1.category_name
order by hot desc)t2 
limit 10 ;


-- 格式化:

SELECT t2.category_name, t2.hot
FROM (
	SELECT t1.category_name, COUNT(*) AS hot
	FROM (
		SELECT videoId, category_name
		FROM gulivideo_orc
			LATERAL VIEW explode(category) category_t AS category_name
	) t1
	GROUP BY t1.category_name
	ORDER BY hot DESC
) t2
LIMIT 10;

-- 结果:
-- +-------------------+---------+--+
-- | t2.category_name  | t2.hot  |
-- +-------------------+---------+--+
-- | Music             | 179049  |
-- | Entertainment     | 127674  |
-- | Comedy            | 87818   |
-- | Animation         | 73293   |
-- | Film              | 73293   |
-- | Sports            | 67329   |
-- | Gadgets           | 59817   |
-- | Games             | 59817   |
-- | Blogs             | 48890   |
-- | People            | 48890   |
-- +-------------------+---------+--+


-- 3.统计出视频观看数最高的20个视频的所属类别以及类别包含Top20视频的个数

-- a. 视频观看数最高的20个视频的类别
select videoId , views  , category
from gulivideo_orc 
order by views desc  limit  20        ;---->  t1

-- b. 炸开每个视频的类别 

select  videoId, category_name 
from t1 
lateral view explode(category) category_t as category_name       ;---->  t2

-- c.按照类别分组，并统计视频的个数

select t2.category_name ,count(*) hot  
from t2 
group by t2.category_name 
order by hot desc    ;


-- 结果:
select t2.category_name ,count(*) hot  
from  (select  videoId, category_name 
from (select videoId , views  , category
from gulivideo_orc 
order by views desc  limit  20)t1 
lateral view explode(category) category_t as category_name)t2 
group by t2.category_name 
order by hot desc ;



-- +-------------------+------+--+
-- | t2.category_name  | hot  |
-- +-------------------+------+--+
-- | Entertainment     | 6    |
-- | Comedy            | 6    |
-- | Music             | 5    |
-- | People            | 2    |
-- | Blogs             | 2    |
-- | UNA               | 1    |
-- +-------------------+------+--+


-- 4. 统计视频观看数Top50所关联视频的所属类别Rank(排名)

-- a. 统计视频观看数Top50  (一个视频对应多个关联视频(array))

select videoId, views , relatedId
from gulivideo_orc 
order by views desc limit 50       ;---->  t1

-- b.炸开每个视频的关联视频

select relatedId_Id 
from t1 
lateral view explode(relatedId) relatedId_t as relatedId_Id   ;---->t2


-- c. t2  与 gulivedio_orc进行join, 拿到每个视频对应的类别 

select t2.relatedId_Id ,t3.category 
from t2 join gulivideo_orc t3 
on t2.relatedId_Id = t3.videoId        ;---->  t4 

-- d. 炸开每个视频的类别

select category_name 
from t4 
lateral view explode(category) category_t as category_name      ;---->  t5 

-- e. 根据类别分组，统计每个组的总个数

select category_name , count(*) hot
from t5 
group by category_name   ;---->t6   

-- f. 按照hot排序， 计算排名
select category_name , hot , row_number() over( order by hot desc )
from t6     ;


-- 结果:
select category_name , hot , row_number() over(order by hot desc )
from (select category_name , count(*) hot
from (select category_name 
from (select t2.relatedId_Id ,t3.category 
from (select relatedId_Id 
from (select videoId, views , relatedId
from gulivideo_orc 
order by views desc limit 50)t1 
lateral view explode(relatedId) relatedId_t as relatedId_Id)t2 join gulivideo_orc t3 
on t2.relatedId_Id = t3.videoId)t4 
lateral view explode(category) category_t as category_name)t5 
group by category_name )t6 ;

-- +----------------+------+----------------------+--+
-- | category_name  | hot  | row_number_window_0  |
-- +----------------+------+----------------------+--+
-- | Comedy         | 237  | 1                    |
-- | Entertainment  | 216  | 2                    |
-- | Music          | 195  | 3                    |
-- | Blogs          | 51   | 4                    |
-- | People         | 51   | 5                    |
-- | Film           | 47   | 6                    |
-- | Animation      | 47   | 7                    |
-- | News           | 24   | 8                    |
-- | Politics       | 24   | 9                    |
-- | Games          | 22   | 10                   |
-- | Gadgets        | 22   | 11                   |
-- | Sports         | 19   | 12                   |
-- | Howto          | 14   | 13                   |
-- | DIY            | 14   | 14                   |
-- | UNA            | 13   | 15                   |
-- | Places         | 12   | 16                   |
-- | Travel         | 12   | 17                   |
-- | Animals        | 11   | 18                   |
-- | Pets           | 11   | 19                   |
-- | Autos          | 4    | 20                   |
-- | Vehicles       | 4    | 21                   |
-- +----------------+------+----------------------+--+



-- 5. 统计每个类别中的视频热度Top10

-- a. 炸开每个视频的类别
select videoId , views , category_name 
from gulivideo_orc 
lateral view explode(category) category_t as category_name       ;---->  t1

-- b. 按照类别分区，观看数排序

select videoId,  category_name ,views , 
row_number() over(distribute by category_name sort by views desc ) rn
from t1         ;---->  t2

-- c. Top10 
select  videoId, category_name, views ,rn 
from t2 
where t2.rn <=10 ;

-- 结果:

select  videoId, category_name, views ,rn 
from (select videoId,  category_name ,views , 
row_number() over(distribute by category_name sort by views desc ) rn
from (select videoId , views , category_name 
from gulivideo_orc 
lateral view explode(category) category_t as category_name)t1 )t2 
where t2.rn <=10 ;


-- 6.统计每个类别中视频流量Top10
-- a. 炸开每个视频的类别
select videoId , ratings , category_name 
from gulivideo_orc 
lateral view explode(category) category_t as category_name       ;---->  t1

-- b. 按照类别分区，观看数排序

select videoId,  category_name ,ratings , 
row_number() over(distribute by category_name sort by ratings desc ) rn
from t1         ;---->  t2

-- c. Top10 
select  videoId, category_name, ratings ,rn 
from t2 
where t2.rn <=10 ;

-- 结果:

select  videoId, category_name, ratings ,rn 
from (select videoId,  category_name ,ratings , 
row_number() over(distribute by category_name sort by ratings desc ) rn
from (select videoId , ratings , category_name 
from gulivideo_orc 
lateral view explode(category) category_t as category_name)t1 )t2 
where t2.rn <=10 ;

-- 7.统计上传视频最多的用户Top10  以及  他们上传的观看次数在前20的视频

-- a. 上传视频最多的用户Top10
select  uploader ,videos
from gulivideo_user_orc 
order by videos desc 
limit 10        ;---->  t1

-- b. 找到10个人上传的所有的视频 

select  t1.uploader , t2.videoId ,t2.views 
from t1  join gulivideo_orc t2 
on t1.uploader = t2.uploader         ;---->  t3

-- c. 根据views排序， Top20

select  t3.uploader,t3.videoId, t3.views
from t3 
order by views desc limit 20 ;


-- 结果: 

select  t3.uploader,t3.videoId, t3.views
from  (select  t1.uploader , t2.videoId ,t2.views 
from  (select  uploader ,videos
from gulivideo_user_orc 
order by videos desc 
limit 10 )t1  join gulivideo_orc t2 
on t1.uploader = t2.uploader)t3 
order by views desc limit 50 ;

-- +----------------+--------------+-----------+--+
-- |  t3.uploader   |  t3.videoid  | t3.views  |
-- +----------------+--------------+-----------+--+
-- | expertvillage  | -IxHBW0YpZw  | 39059     |
-- | expertvillage  | BU-fT5XI_8I  | 29975     |
-- | expertvillage  | ADOcaBYbMl0  | 26270     |
-- | expertvillage  | yAqsULIDJFE  | 25511     |
-- | expertvillage  | vcm-t0TJXNg  | 25366     |
-- | expertvillage  | 0KYGFawp14c  | 24659     |
-- | expertvillage  | j4DpuPvMLF4  | 22593     |
-- | expertvillage  | Msu4lZb2oeQ  | 18822     |
-- | expertvillage  | ZHZVj44rpjE  | 16304     |
-- | expertvillage  | foATQY3wovI  | 13576     |
-- | expertvillage  | -UnQ8rcBOQs  | 13450     |
-- | expertvillage  | crtNd46CDks  | 11639     |
-- | expertvillage  | D1leA0JKHhE  | 11553     |
-- | expertvillage  | NJu2oG1Wm98  | 11452     |
-- | expertvillage  | CapbXdyv4j4  | 10915     |
-- | expertvillage  | epr5erraEp4  | 10817     |
-- | expertvillage  | IyQoDgaLM7U  | 10597     |
-- | expertvillage  | tbZibBnusLQ  | 10402     |
-- | expertvillage  | _GnCHodc7mk  | 9422      |
-- | expertvillage  | hvEYlSlRitU  | 7123      |
-- +----------------+--------------+-----------+--+