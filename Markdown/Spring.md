### Spring HelloWorld
#### 1.导包
1.1 创建Maven工程后，引入**依赖** 推荐使用4.0版本 pom.xml 

```xml
<dependency>
  	  <groupId>org.springframework</groupId>
	  <artifactId>spring-context</artifactId>
	  <version>4.0.0.RELEASE</version>
</dependency>
```
#### 2.准备配置文件
2.1 添加配置文件 **beans.xml** 
创建bean，Person.java，通过容器创建对象
2.2**工作集**概念

#### 3.编写配置文件
```xml
<bean id="person02" class="com.tian.spring.bean.Person">
    <property name="name" value="rose" />
    <property name="age" value="20" />
    <property name="gender" value="female" />
    <!-- 引用数据类型使用ref属性进行赋值 -->
    <property name="teacher" ref="Cang"/>
    <property name="father">
        <!-- 内部bean -->
		<bean class="com.tian.spring.bean.Father">
            <property name="name" value="rose" />
            <property name="age" value="20" />
		</bean>
    </property>
</bean>
```
#### 4.使用
```java
//使用时先获取容器对象
ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
//从容器中获取想要的对象
Person bean1 = (Person)context.getBean("person01");
Sytem.out.print(bean1);
```
#### 5.常见报错


### 依赖注入 DI
#### 1.容器配置文件 di.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:context="http://www.springframework.org/schema/context"
	xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
		http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.0.xsd">
		 <context:component-scan base-package="com.tian.spring"></context:component-scan>
</beans>
```
#### 2.通过注解创建对象
四个注解功能一样！主要为了让开发人员进行区分，当前类的功能！	
@Repository： 声明当前类是一个持久化层的类,将数据和dao层交互
@Service：  声明当前类是一个服务层组件,服务层了完成某个功能！
@Controller： 声明当前类是一个控制层组件,控制层为了完成业务逻辑的核心跳转和控制
@Component：  如果当前类是除了以上三类之外的一个类，例如普通类，标上 @Component
#### 3.创建容器对象
声明对象后即可直接调用

###Spring Web MVC HelloWorld
**M**odel:Bean Dao
**V**iew:html,jsp,css
**C**ontroller:Servlet,Filter
View----Request----Controller----Serevice----Dao----Bean----View
#### 1.导包
在pom.xml中加入SpringMVC的依赖
```xml
<dependency>
  	  <groupId>org.springframework</groupId>
	  <artifactId>spring-webmvc</artifactId>
	  <version>4.0.0.RELEASE</version>
</dependency>
```
#### 2.配置前端控制器
使用注释提示快捷键，选择DispatcherServlet
```xml
<servlet>
	<servlet-name>springDispatcherServlet</servlet-name>
	<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<init-param>
	         <param-name>contextConfigLocation</param-name>
			<param-value>classpath:springmvc.xml</param-value>
		</init-param>
	<load-on-startup>1</load-on-startup>
</servlet>

<servlet-mapping>
	<servlet-name>springDispatcherServlet</servlet-name>
	<url-pattern>/</url-pattern>
</servlet-mapping>
```
#### 3.定义控制器
创建一个类标上注解@Controller
处理请求
```java
//请求处理器
@Controller
public class HelloWorldHandler {
}
/**
* 请求处理方法
* 浏览器端: http://localhost:8080/Springmvc01/hello
* @RequestMapping: 请求映射. 指定哪个请求交给哪个方法处理.
*/
	@RequestMapping(value="/hello")
	public String  handleHello() {
		System.out.println("Hello Springmvc .");
		return "success";
	}
```
#### 4.编写视图

###Spring MVC REST
Representational State Transfer （资源）表现层状态转化，目前最流行的互联网软件架构
	REST是一种思想，REST推崇简洁的URL表达！
	REST的这种思想，人文万物皆资源，所有的请求都是为了获取资源。

| 以对Book的操作为例 | 过去URL                          | 使用REST的URL           |
| ------------------ | -------------------------------- | ----------------------- |
| 增                 | /addBook?bookName=xx             | /book(发送POST请求)     |
| 删                 | /deleteBook?bookId=1             | /book/1(发送DELETE请求) |
| 改                 | /updateBook?bookId=1&bookName=xx | /book/1(发送PUT请求)    |
| 查                 | /getBook?bookId=1                | /book/1(发送GET请求)    |

修改服务器端xml配置文件需要手动重启
修改服务器端java文件可等待服务器自动重启
修改视图文件html或jsp只需刷新页面
乱码的处理：CharacterEncodingFilter,encoding=utf-8,forceEncoding=true

获取**路径**上的某层**变量**

```java
@RequestMapping(value="/book/{id}")
public void getBook(@PathVariable("id") Integer id)｛
	System.out.print(id);
}
```

使用Handle决定请求方式

```java
@RequestMapping(method={Request.GET})
public String getBook(){
    return "success";
}
```

`<a></a>`标签只能发get请求
使用`<form></form>`标签能发送get和post请求

put和delete请求的发送
使用HttpServletRequest.getMethod()方法能够获取请求方式
使用Filter拦截请求，修改请求方式后放行
SpringMVC提供了一个拦截器HiddenHttpMethodFilter
具体实现
①获取名为`_method`的请求参数
②当页面发出post请求，且_method参数非空，进入修改逻辑
③HttpMethodRequestWrapper中重写了getMethod()方法，修改method并返回

```java
//待补全
```

使用要求：
①发送post请求
②提供_method参数
③在web.xml中配置Filter

```xml
<!-- 待补全 -->
<filter-name></filter-name>
<filter-class></filter-class>
<filter-patern></filter-patern>
```

配置**Filter**的顺序与**乱码**问题的解决
HiddenHttpMethodFilter会发送一个method参数，而CharacterEncodingFilter需要在获取请求前设置编码方式

get,post,put,delete在服务器端如何**响应**
方法上添加ResponseBody响应体，作用是把方法的返回值直接当作响应
解决**响应乱码**问题，为@RequestMapping添加produces属性，

```java
@RequestMapping(value="/response/handle1",produces="text/html;charset=utf-8")
@ResponseBody
public String handle1() {
    System.out.println("处理了handle1请求！");
    return "成功！";
}
```

响应为转发至jsp
1.在转发中向请求域保存数据
**方法①**传参public String handle(Map map , Model model , ModelMap modelMap){}

```java
//待补全
```

map,model,modelMap是隐含模型，都是。。。的同一个对象
**方法②**使用ModelAndView保存数据（其中包含转发的页面地址，和向其对象保存的数据）

```java
//待补全
```

向session域或application域保存数据使用原生API

发送**Ajax**请求并响应**jsonstr**
以往我们使用Gson，在SpringMVC中提供了对Jackson的支持
需要在xml配置中添加依赖databind    annotation    core
使用MySQL需要在Maven中添加驱动的依赖

*console(data)在Browser的Console输出数据

请求过多可以用一个pojo作为模型存放信息
发送Ajax请求并传递数据，把json转为jsonstr并声明
handler参数中添加请求体进行说明

```java
//待补全
```

```java
//待补全
```



