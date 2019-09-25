# 一、概述


# 二、案例


# 三、编程模型
无界表的概念
输入表(原始数据，会丢弃))
结果表(数据是否丢弃参照输出模式)
事件事件和延迟数据
structured streaming模型中当有新的数据时，spark负责更新结果表完成exactly once
event-time在数据格式中有所体现
event-time用途广泛
超时时间和水印，引擎清楚相应的数据

容错语义
exactly once是structured streaming的主要设计目标
结构化流数据源

## 1.基本概念
### 1.1 输入表


### 1.2 结果表


### 1.3 输出


### 1.4 再说明


## 2.处理事件事件和延迟数据


## 3.容错语义



<!-- TODO  -->


# 四、Structured String数据源
## 1.socket source
 * 见WordCount案例

## 2.file source


## 3.Kafka Source


## 4.Rate Source



# 五、Streaming DF/Streaming DS 操作

## 1.

事件时间按窗口

   * The windows are calculated as below:
   * maxNumOverlapping <- ceil(windowDuration / slideDuration)
   * for (i <- 0 until maxNumOverlapping)
   *   windowId <- ceil((timestamp - startTime) / slideDuration)
   *   windowStart <- windowId * slideDuration + (i - maxNumOverlapping) * slideDuration + startTime
   *   windowEnd <- windowStart + windowDuration
   *   return windowStart, windowEnd

窗口
水印
去重
连接
不支持
输出
触发器