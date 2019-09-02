-- 1
drop table if exists `user_table`;
CREATE EXTERNAL TABLE `user_table`(
	userId string comment '用户编号',
	visitDate string comment '访问日期',
	visitCount int comment '访问次数'
)comment '用户访问数据'
ROW format delimited fields terminated BY '\t';
insert into table `user_table` values ('u02','2017/1/23',6);
insert into table `user_table` values ('u03','2017/1/22',8);
insert into table `user_table` values ('u04','2017/1/20',3);
insert into table `user_table` values ('u01','2017/1/23',6);
insert into table `user_table` values ('u01','2017/2/21',8);
insert into table `user_table` values ('U02','2017/1/23',6);
insert into table `user_table` values ('U01','2017/2/22',4);
insert into table `user_table` values ('u01','2017/1/21',3);
insert into table `user_table` values ('u01','2017/1/21',2);
select * from `user_table`;
-- 统计出每个用户访问数的每月小计和累积
select t2.id `用户id`,t2.mn `月份`,sum_vc `小计`,
	sum(sum_vc) over(partition by t2.id order by t2.mn) `累积`
from(
	select id,mn,sum(vc) sum_vc
	from(
		select lower(userid) id,
			from_unixtime(unix_timestamp(visitdate,'yyyy/mm/dd'),'yyyy-mm') mn,
			visitcount vc
		from user_table
		)t1
	group by id,mn)t2;

---------------------------------------------------------------------
-- 2
drop table if exists visit;
create table visit(
    shop string COMMENT '店铺名称',
    user_id string COMMENT '用户id',
    visit_time string COMMENT '访问时间'
)
row format delimited fields terminated by '\t';
insert into table visit values ('huawei','1005','2017-02-10');
insert into table visit values ('huawei','1005','2017-02-10');
insert into table visit values ('huawei','1005','2017-02-10');
insert into table visit values ('huawei','1005','2017-02-10');
insert into table visit values ('huawei','1004','2017-02-10');
insert into table visit values ('huawei','1004','2017-02-10');
insert into table visit values ('huawei','1003','2017-02-10');
insert into table visit values ('huawei','1003','2017-02-10');
insert into table visit values ('huawei','1001','2017-02-10');
insert into table visit values ('huawei','1002','2017-02-10');
insert into table visit values ('huawei','1006','2017-02-10');
insert into table visit values ('apple','1001','2017-02-10');
insert into table visit values ('apple','1001','2017-02-10');
insert into table visit values ('apple','1001','2017-02-10');
insert into table visit values ('apple','1001','2017-02-10');
insert into table visit values ('apple','1002','2017-02-10');
insert into table visit values ('apple','1002','2017-02-10');
insert into table visit values ('apple','1005','2017-02-10');
insert into table visit values ('apple','1005','2017-02-10');
insert into table visit values ('apple','1006','2017-02-10');
insert into table visit values ('apple','1004','2017-02-10');
insert into table visit values ('meizu','1006','2017-02-10');
insert into table visit values ('meizu','1006','2017-02-10');
insert into table visit values ('meizu','1006','2017-02-10');
insert into table visit values ('meizu','1006','2017-02-10');
insert into table visit values ('meizu','1003','2017-02-10');
insert into table visit values ('meizu','1003','2017-02-10');
insert into table visit values ('meizu','1003','2017-02-10');
insert into table visit values ('meizu','1002','2017-02-10');
insert into table visit values ('meizu','1002','2017-02-10');
insert into table visit values ('meizu','1004','2017-02-10');
select * from visit;
-- 每个店铺的UV（访客数）
select shop,count(distinct(user_id))
from visit
group by shop;

select shop,count(user_id)
from(
	select shop,user_id
	from visit
	group by shop,user_id)t1
group by shop;

-- 每个店铺访问次数top3的访客信息。输出店铺名称、访客id、访问次数

select shop,user_id,rank_num,counts
from(
	select 
		shop,
		user_id,
		counts,
		rank() over(partition by shop order by counts) rank_num
	from(
		select shop,user_id,count(visit_time) counts
		from visit
		group by shop,user_id
		)t1
	)t2
where rank_num<=3;

---------------------------------------------------------------------
-- 3
drop table if exists ORDER_TBL;
create table ORDER_TBL(
    `Date` String COMMENT '下单时间',
    `Order_id` String COMMENT '订单ID',
    `User_id` String COMMENT '用户ID',
    `amount` decimal(10,2) COMMENT '金额')
row format delimited fields terminated by '\t';
insert into table ORDER_TBL values ('2017-10-01','10029011','1000003251',19.50);
insert into table ORDER_TBL values ('2017-10-03','10029012','1000003251',29.50);
insert into table ORDER_TBL values ('2017-10-04','10029013','1000003252',39.50);
insert into table ORDER_TBL values ('2017-10-05','10029014','1000003253',49.50);
insert into table ORDER_TBL values ('2017-11-01','10029021','1000003251',130.50);
insert into table ORDER_TBL values ('2017-11-03','10029022','1000003251',230.50);
insert into table ORDER_TBL values ('2017-11-04','10029023','1000003252',330.50);
insert into table ORDER_TBL values ('2017-11-05','10029024','1000003253',430.50);
insert into table ORDER_TBL values ('2017-11-07','10029025','1000003254',530.50);
insert into table ORDER_TBL values ('2017-11-15','10029026','1000003255',630.50);
insert into table ORDER_TBL values ('2017-12-01','10029027','1000003252',112.50);
insert into table ORDER_TBL values ('2017-12-03','10029028','1000003251',212.50);
insert into table ORDER_TBL values ('2017-12-04','10029029','1000003253',312.50);
insert into table ORDER_TBL values ('2017-12-05','10029030','1000003252',412.50);
insert into table ORDER_TBL values ('2017-12-15','10029032','1000003255',612.50);
select * from order_tbl;
-- 2017年每个月的订单数、用户数、总成交金额
select date_format(`Date`,'yyyy-MM') mn,
	count(order_id) order_num,
	count(distinct(user_id)) user_num,
	sum(amount) amount_sum
from order_tbl
group by date_format(`Date`,'yyyy-MM')

-- 2017年11月的新客数(指在11月才有第一笔订单)
select count(user_id)
from(
	select user_id,`date`,
		lag(`date`,1,'none') over(partition by user_id order by `date`) last_order
	from order_tbl)t1
where last_order='none' and date_format(`date`,'yyyy-MM')='2017-11';

---------------------------------------------------------------------
-- 4
create table users(
	user_id string,
	name string,
	age int);
create table views(
	user_id string,
	url string
	);
-- 根据年龄段观看电影的次数进行排序

---------------------------------------------------------------------
-- 5
drop table if exists user_age;
create table user_age(
    dt string,
    user_id string,
    age int
)
row format delimited fields terminated by ',';.
/*
11,test_1,23
11,test_2,19
11,test_3,39
11,test_1,23
11,test_3,39
11,test_1,23
12,test_2,19
13,test_1,23
15,test_2,19
16,test_2,19
*/
load data inpath '/user/user_age.txt' into table user_age;
select * from user_age;
-- 所有用户和活跃用户(连续两天)的总数及平均年龄
with t0 as
(select count(distinct(user_id)) all_num,floor(avg(age)) all_avg
from user_age)
select count(distinct(user_id)) act_num,avg(age) act_avg
from(
	select user_id,avg(age) age,diff_date,count(age) diff_num
	from(
		select user_id,age,`dt`-`rank_num` diff_date
		from(
			select 
				dt,
				user_id,
				age,
				rank() over(partition by user_id order by dt) rank_num
			from user_age)t1)t2
	group by user_id,diff_date
	having diff_num>=2)t3;


---------------------------------------------------------------------
-- 6
create table ordertable(
	user_id string,
	money decimal(10,2),
	pt string comment 'paymenttime'
);

-- 所有用户中在今年10月份第一次购买商品的金额
select money
from(
	select user_id,money,pt
	from ordertable
	where year(pt)=2019 and month(pt)=10)t1
where day(pt)=min(day(pt));
---------------------------------------------------------------------
-- 7
