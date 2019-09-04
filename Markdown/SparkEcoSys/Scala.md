# 一、变量和数据类型
## 1.声明和初始化
```scala
// 变量声明时必须进行初始化
var a:Int = 10 // ;可以选择性忽略
val b:Int = 10 // 常量，重新赋值时编译报错
var c = false //变量类型推断为Boolean
```
<!-- TODO 不能进行类型推断的场景 -->

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
val ss = s"age = ${a}"
println(s)
println(ss)
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
![](img/scala-variable-type.png)

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

 * scala中可以省略调用方法时的`.`，如果没有参数或参数只有一个则可以省略括号

# 二、运算符
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

# 三、流程控制
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
package com.tian.preview.day01

import scala.util.control.Breaks
import scala.util.control.Breaks._

/**
 * @author tian
 *         2019/9/3 20:43
 */
object BreakDemo {
    /**
  在scala中没有循环的break关键字
  通过抛出异常并`try-catch`的方法使循环结束
  也可把循环放进方法使用return跳出方法从而跳出循环
  @param args
     */
    def main(args: Array[String]): Unit = {
        // 原生try-catch
        try {
            for (i <- 1 to 100) {
                println(i)
                if (i == 10) throw new NullPointerException
            }
        } catch {
            case e =>
        }
        println("done")
        // 通过调用方法进行简化
        Breaks.breakable(
            for (i <- 1 to 100) {
                println(i)
                if (i == 10) Breaks.break()
            }
        )
        println("done")
        // 导包后还可简化为
        breakable { // 本质上是try-catch,变圆括号为大括号
            for (i <- 1 to 10){
                println(i)
                if (i == 5) break // 本质是在抛出异常，Break.break的缩写
            }
        }
        println("done")
    }
}

```

#### 2.2.4 循环嵌套
```scala
//输出九九乘法表
for (i <- 1 to 9) {
    for (j <- 1 to i) {
        print(s"$j * $i = ${j * i}\t")
    }
    println()
}

//使用for的嵌套
for (i <- 1 to 9; j <- 1 to i) {
    print(s"$j * $i = ${j * i}\t")
    if (j == i) println()
}
```

#### 2.2.4 for推导
```scala
//使用for推导输出序列中每个数的三次方
val arr: immutable.IndexedSeq[Int] = for(i <- 1 to 5) yield i*i*i
println(arr)
//序列中的每个元素加3
println((1 to 4).map(_ + 3))
```

# 四、函数式编程
 * 函数可以当作一个值进行传递--高阶函数
 * scala把函数式编程和面向对象变成完美的融合到了一起

## 1.基本语法

>**语法说明**
函数体内可以没有`return`，自动把代码最后一行的值返回
返回值类型省略后根据最后一行代码的值进行`类型推导`
当没有省略return时必须写明返回值类型
省略`=`时表示函数返回`Unit`，无论函数体怎么定义，这时无论函数体如何return，都是返回Unit，这种函数被成为过程
*具体简写规则见至简规则*

>**纯函数**
**特点**:不产生副作用(控制台打印、修改外部变量的值、数据落盘)，引用透明(函数的返回值只和形参有关，和其他值无关)
**优点**:天然的支持高并发，计算速度快(计算的结果直接放进缓存)

>**过程**
与纯函数相反，只有副作用没有返回值的函数

### 1.1 函数的定义
```scala
def foo(a:Int,b:Int):Int = {//函数签名确定函数名，形参列表，返回值类型
    //函数体内编写具体的实现方法
    return a + b
}

def foo2(a:Int,b:Int) = { //省略返回值类型，自动推断
    a + b //省略return，自动返回函数中最后执行的一行语句
}

def foo3(a:Int,b:Int) = {// 错误演示
    return a + b // 当return没有省略时，返回值类型也不能省略
}

def fun1():Unit = {
    print ("Hello fun!")
}
// 简写
def fun1() = {
    print ("Hello fun!")
}
def fun1() = print("Hello fun!")
def fun1 = print("Hello fun!")
```
 * 具体的简写规则见至简原则

### 1.2 可变形参
```scala
//可变参量
def add1(arr: Int*) = {
    var sum = 0
    for (elem <- arr) {
        sum += elem
    }
    sum
}

//可变参量出于形参列表的最后
def add2(a: Double, b: Int, arr: Int*) = {
    var sum = 0
    for (elem <- arr) {
        sum += elem
    }
    sum * a + b
}
```

### 1.3 形参默认值、命名参量
 * 在定义函数时可以为形参指定默认值，调用函数时若没有传入该参数则使用默认值
 * 调用参数时，可以直接指定传入实参对应的形参的名称，有了命名参量，参量顺序没有要求

```scala
def f1(a: Int, b: Int, c: Int = 3) = a + b + c
val m = f1(1,2) // c为默认值3
val n = f1(c = 1, b = 2, a = 2) //通过命令参量传值，可以不考虑顺序
def f2(a: Int, b: Int = 3, c: Int = 4) = a + b + c
val x = f2(3, c = 2) //f2的三个参量中有两个是默认值，传入两个参数，必须通过命名参量确定
def f3(a: Int, b: Int = 2, c: Int) = a + b + c
val y = f3(1, c = 2) // b有形参默认值，不指定命名参量，只传入两个默认第二个仍为b
```

```scala
//求指定范围内的质数的和

def sumPrime(start: Int, end: Int) = {
    var sum = 0
    for (n <- start to end) {
        if (isPrime(n)) sum += n
    }
    sum
}

def isPrime(num: Int): Boolean = {
    for (i <- 2 until num) {
        if (num % i != 0) return false
    }
    true
}

// TODO 有逻辑错误
def sumPrime2(start: Int, end: Int) = {
    var sum = 0
    for (i <- start to end; j <- 2 until i if i % j != 0)
        sum += i
    sum
}
```

### 1.4 惰性函数
 * 只在第一次被调用时执行

<!-- TODO 执行实际说明 -->
```scala
lazy val a0 = {
    println("a...")
    10
}

def main(args: Array[String]): Unit = {
    println(a0)
    println(a0)
}

// 执行时机
val a = 10 //第一次加载object时执行
lazy val b = 10 //第一次调用b时执行
def c = 10 //每次调用时执行
```

## 2.至简原则
```scala
//0.标准写法
def f0(s: String): String = {
    return s + "String"
}

//1.return可以省略，scala使用函数体的最后一行代码作为返回值
//注:如果return没有省略，那么返回值类型也不能省略，同f0
def f1(s: String): String = {
    s + "String"
}

//2.返回值的类型如果可以推断(根据方法体的最后一行代码)出来，也可以省略
def f2(s: String) = {
    s + "String"
}

//3.如果函数体只有一行代码，也可以省略花括号
def f3(s: String) = s + "String"

//4.如果函数没有参数列表，那么小括号可以省略(调用时必须也省略)
def f4 = "String"

val a = f4

//5.如果函数签名明确了返回值为Unit，return不生效
def f5: Unit = return 10
val b = f5 //Unit

//6.如果省略等号，则自动推断返回值为Unit，这时return也不生效
def f6 {
    print("Hello World!")
    return 10
}

//7.如果不关心函数名，只关心逻辑关系，则可省略函数名(和def) -- 匿名函数
val f = (s: String) => return s + "String"
```

## 3.高阶函数
 * 在函数式编程里，除了函数的定义、调用，还能进行函数传递

```scala
// 函数传递
def fun1() = print("fun1")
val f = fun1 _ // 没有调用函数，知识把函数传递(赋值)给f
f() // 传递(赋值)后的变量可以用于调用函数
```

>**高阶函数**
一个函数可以接收一个函数作为参数，或者可以返回一个函数，
这样的函数就是高阶函数(高阶算子)

```scala
def main(args:Array[String]):Unit = {
    print(fun(add)) // 6
}
def add(a:Int,b:Int) = a + b
def fun(n:(Int,Int) => Int) = n(2,4)
```

<!-- TODO 接口回调 -->

## 4.匿名函数
```scala
def main(args: Array[String]): Unit = {
operation(Array(1, 2, 3), (ele: Int) => { //传入的参数为匿名函数
    print(ele) // 匿名函数的函数体
})
// 简写形式
operation(Array(1, 2, 3), i => print(i)) // 函数体只有一行语句省略大括号
operation(Array(1, 2, 3), print(_)) // 每个参数只使用一次，省略参数的说明
}

def operation(arr: Array[Int], op: Int => Unit) =
    for (i <- arr) op(i)
```

```scala


```

## 5.闭包与柯里化
>**说明**
java程序中内部类无法访问局部变量
因为java中没有闭包
闭包可以延长局部变量的声明周期

```java
public static void main(String[] args) {
    int i = 10;
    // i = 20;
    new Thread() {
        @Override
        public void run() {
            System.out.println(i);
        }
    };
}
```

## 6.递归

## 7.控制抽象

# 五、面向对象
 * scal的面向对象和java中的面向对象思想相同，知识在语法上有所精简
 * 在做面向对象分析阶段是先有对象，然后是对象的属性特征归类
 * 在具体程序的实现时是先定义类，在根据类创建对象
## 1.



## 2.



## 3.




