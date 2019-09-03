# 一、变量和数据类型
## 1.声明和初始化
```scala
// 变量声明时必须进行初始化
var a:Int = 10 // ;可以选择性忽略
val b:Int = 10 // 常量，重新赋值时编译报错
var c = false //变量类型推断为Boolean
```

>**说明**
在实际开发中，虽然定义变量的场景很多，但我们很少为变量重新赋值，而是当作常量来用，所以在使用scala编程时有限使用val，即能用常量的地方不用变量。

## 2.标识符命名规则与规范
标识符(变量，常量，对象名，方法名或函数名)
1. java的规则在scala通用
   标识符由字母、数字、下划线和$组成
   不使用数字开头
2. 支持使用运算符作为变量名
   `+ - ++ --`
   scala中没有传统意义的运算符，所有的运算本质上是方法(函数)
3. 使用``定义变量名
   ```scala
   var ` ` = 10 // 使用``定义变量名为空格
   var `type` = 10 // 定义变量名为关键字type
   ```
   在``内可以使用一切符号构成变量名

```scala
/* scala中的输出方式 */
System.out.println("Hello World!")
println("Hello World!")
printf("Hello World!")
//使用占位符的方式确定输入参数
var a = 20
var b = 20.1
var c = "Hello World!"
printf("print %d %f %.2f $s",a,b,b,c)
// print 20 20.100000 20.10 Hello World!
// 字符模板输出
val s =
    s"""
        |select
        |	name,
        |	age,
        |	sex
        |from user
        |where name='${name}' and age=${age + 2}
    """.stripMargin
println(s)
/* scala读取键盘输入 */
val line = StdIn.readLine("input please:")
println(line)
```

```c
%d // 十进制有符号整数
%u // 十进制无符号整数
%f // 浮点数
%s // 字符串
%c // 单个字符
%p // 指针的值
%e // 指数形式的浮点数
%x, %X // 无符号以十六进制表示的整数
%0 // 无符号以八进制表示的整数
%g // 自动选择合适的表示法
```

## 3.数据类型
![]()
<!-- TODO 添加数据类型关系配图 -->

>**说明**
scala中的**StringOps**是对java中的string的增强补充
scala可以对代码进行**隐式转换**，当Java中某个类型的对象没有某个方法时就调用scala中的方法
**Unit**作为方法的返回值类型，表示该方法没有返回值，Unit作为一种数据类型只有一个值(一对圆括号)，可以声明Unit类型的变量
**Null**类型只有一个值null，Null是任意类型的子类，null可以复制给任何一种引用类型的变量
所有引用类型有个共同的父类**Object**
**Nothing**是其他任意类型(包括数据类型和引用类型)的子类，主要用于帮助方法返回值的推导，Nothing的象征意义大于实际意义

>**数值类型自动转换**
scala支持java中的自动类型提升
scala中的自动类型提升`val a:Int = 10.6.toInt`
其他方法与之同理，toSting toDouble toByte...

 * scala中可以可以可以盛烈省略调用方法时的`.`，如果没有参数或参数只有一个则可以省略括号

# 运算符
```
经典除法 10 / 3 = 3
真除 10 / 3 = 3.333333
```

>**算术运算符**
scala中出列没有自加自减和三元运算符外其他算术运算符和java相同
scala没有真正意义的运算符，都是通过方法来实现

```scala
val i:Int = 2 + 3
val j:Int = 2.+(3) //运算符的本质是方法
```

>**比较运算符**
scala中的`==`和java中的`equals`更接近
scala使用`eq()`方法实现java中的`==`

 * 其他运算符和java一致
 * scala通过if判断的简写形式实现代替三元运算符
 * 在scala中所有的语法结构都有值

```scala
val max = if(m>n) m else n
```

# 流程控制
## 1.分支结构
 * scala中使用模式匹配的方式实现`switch-case`
 * 在scala中所有的语法结构都有值
 * 语法结构的值为结构中有效代码的最后一行

```scala
if(m > n){
    //block1
}else if{
    //block2
}else{
    //block3
}
val j = if(3 < 2) 10 else if(3 < 1) 20 else 30
// if结构的值为有效代码(实际运行经过的代码)中最后一行
```

## 2.循环
### 2.0 Array
```scala
var arr0 = Array(10,20,30,40) //自动推断数据类型为元素共同祖先
var arr1 = Array[Int](10,20,30,40) //泛型
arr(1) //使用圆括号确定索引
```

### 2.1 while & do-while
 * 同java

### 2.2 for
 * scala中的for循环严格意义上是对序列的遍历

#### 2.2.0 循环与序列
```scala
val s = "abcd"
for(c <- s){ // 循环遍历字符串
    println(c.getClass.getSimpleName)
}
// 1~10 //左闭又闭
1 to 10
// 1~9
1 until 9 //左闭右开
0 to arr.length - 1
0 until arr.length

val arr = Array(10,20,30)
for (i <- arr){
    println(i)
}
for (i <- 0 to (arr.length -1)){
    println(arr(i))
}
for (i <- 0 until arr.length){ //效果同上
    println(arr(i))
}
```

#### 2.2.1 循环守卫
```scala
for (m <- 1 to 100 if m % 2 == 1){ //只有奇数进入循环
    println(m)
}
```

#### 2.2.2 循环步长
```scala
for (i <- 1 to (100,2)){ //按步长为2递增
    println(i)
}
for (i <- 100 to (1,-1)){ //递减
    println(i)
}
for (i <- 1 to 100 reverse){ //反向
    println(i)
}
```

#### 2.2.3 跳出循环
 * 在scala中没有循环的break关键字
 * 通过抛出异常并`try-catch`的方法使循环结束
 * 也可把循环放进方法使用return跳出方法从而跳出循环

```scala
breakable { // 本质上是try-catch,变圆括号为大括号
    for (i <- 1 to 10){
        println(i)
        if (i == 5) break // 本质是在抛出异常，Break.break的缩写
    }
}
```

# 函数式编程