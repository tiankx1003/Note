## day01
### 一、技术体系
Javaweb负责使用Java语言，开发服务器端程序的技术。
Javaweb开发的程序，一般都采用B/S架构。

**浏览器端：**
html:  负责构建静态页面。特点由标签组成，需要什么功能就使用什么标签。
css :  负责页面样式
javascript： 负责将静态页面变为动态页面，负责和用户进行交互。

jquery:  js框架，简化js代码的开发。
ajax :  发送异步请求，局部刷新页面

**服务器端：**
Servlet:  服务器的小程序，最核心组件，负责处理请求，响应页面
Filter:   服务器的程序，负责拦截请求，过滤后，放行请求。
Listener:  服务器的程序，监听服务器的行为，触发指定的动作。

页面显示技术： JSP(java server page) + EL + JSTL

会话控制：  浏览器访问服务器，采用HTTP协议，这个协议无状态。
cookie:    保存在浏览器端
session:   服务端技术

### 二、html

<!DOCTYPE html>
<html>
<head  属性名=属性值>     // 开始标签
声明属性信息，或其他额外信息   //标签体（标签的内容）
</head>   // 结束标签
<body>
页面的主体
</body>
</html>

如果不需要声明标签体，可以使用自结束标签<xxx/>

***常用标签：***

```html
<h1>-<h6>: 加粗显示字体（强调）
<p>: 用于显示一段文字
<span>:  用于将一部分内容组合为一个整体
<table>: 声明表格
<tr>:  声明一行
<th>:  加粗声明一个单元格
<td>:  声明一个单元格
<br>: 换行
<hr>:  分割线
<a> :  超链接标签，点击后向指定目标发送请求
<form>:  表单标签，用于提交关键的信息
<input name="" value=""  type="">： 输入框
    name是发送时的属性名
    value是发送的属性值，一般是接受用户的输入
    type是输入框的类型,默认为text;
    password： 隐去输入的内容
    submit: 提交按钮
    radio :  单选框
<select>: 下拉框
<option>:  下拉框的每个下拉选项
```

### 三、css

1. 声明方式
①在标签头上，使用style=""
②批量为标签设置样式，使用css语法
selector {属性名=属性值;xxx}
使用<style>将css语法的样式，进行写入
③将css语法的样式，写入到一个外部的xxx.css文件中
使用<link>进行引入
<link type="text/css" href="my.css" rel="stylesheet ">

2. 选择器
元素（标签）选择器：  标签名，所有匹配到的标签，都会被选中
id选择器：   #id，匹配指定id的标签（最精确）
类选择器：  .类名，匹配指定class属性值的标签
组合选择器：  选择器1，选择器2，...{}

### 四、tomcat
tomcat是一个服务器软件，由java代码编写，运行必须有JAVA_HOME环境变量。

启动： bin/startup.bat
停止： bin/shutdown.bat

bin： 常用的工具目录
conf: 配置文件目录
webapps:  放已经打好的war（web工程）包

tomcat可以运行java的servlet程序，也称为servlet容器。

### 五、Servlet
Servlet意为服务端的小程序，是sun公司制定的一个标准。具体由服务器厂商实现。
Servlet的实例由tomcat自动创建，其中的方法也由tomcat自动调用
Servlet是单例多线程，注意线程安全问题。
Servlet的生命周期：
接受第一个请求时，创建Servlet对象--init()-- service(N次)---destroy()

作用： 

接受请求:  在web.xml中，

```xml
<select-mapping>
<url-pattern/>
<select-mapping>
```

处理请求:  tomcat自动调用service方法处理请求
service(ServletRequest request,ServletResponse response)有两个入参
ServletRequest代表请求对象；
ServletResponse代表响应对象；
完成响应： 使用ServletResponse完成响应

实现：  继承HttpServlet,重写doGet() 和 doPost()
在webl.xml中注册，使用<sevlet>注册



## day02
### 一、处理请求和完成响应
处理请求：  HttpServletRequest
接受请求参数： HttpServletRequest.getParameter("name")
完成响应：  HttpServletResponse
向页面输出信息：  HttpServletResponse.getWriter().print(xxx);
 
### 二、解决乱码
乱码分类：
    请求乱码：
        get请求：
            请求参数附加在url后面，由tomcat进行解析。
            tomcat服务器，默认编码是iso-8859-1.
            修改： 在server.xml中，修改
            <connector port=8080 URIEncoding=utf-8>
        post请求： 
            post请求参数是在请求体中。请求体默认使用iso-8859-1编码。
            设置请求体的编码
            HttpServletRequest.setCharactorEncoding("utf-8")；
            注意：必须在第一次获取请求参数前调用。
    响应乱码：    HttpServletResponse.getWriter() 采用iso-8859-1编码。
        设置编码格式：
            // 既可以设置响应的数据类型，还可以指定浏览器使用什么字符集解释
            HttpServletResponse.setContentType("text/html;charset=utf-8");

### 三、重定向和转发

*重定向：*
实现： HttpServletResponse.sendRedirect("url");
url被浏览器解析，需要加上项目名。

原理： 服务器第一次响应后，发送一个302状态码。
浏览器会继续向第一次的响应头的location属性的url再次发送请求。
请求被处理后，最终响应。

**不能共享数据**！浏览器的地址栏发生变化！					 

*转发：*
实现：  HttpServletRequest.getRequestDispatcher("url").forward(request,response);
url被服务器解析，不需要加上项目名。
特点： 一次请求。可以在多个servlet中共享数据。浏览器的地址栏不会发生变化！
选择： 需要共享数据，使用转发，否则使用重定向。

### 四、jsp
jsp是java服务端的页面技术。主要是为了动态显示页面。
本质是一个servlet。
当访问xxx.jsp页面时，tomcat将xxx.jsp翻译为xxx_jsp.java，编译为xxx_jsp.class，
加载到jvm执行。
xxx_jsp.java重写了service(),调用了_jspService();

在_jspService()，执行java代码，将Jsp页面的其他元素使用流写出。

可以编写：  ①html标签
②jsp声明  <%@  xxx %>，声明页面的属性和导包
③jsp脚本片段 <%  java代码 %>
④jsp的表达式   <%=  变量名 %>   将变量输出到页面
⑤jsp的注释<%--  xxx --%>  直接被忽略

jsp主要还是作为一种显示的技术。
servlet负责流程控制(业务逻辑)+ jsp(页面显示)

九大内置对象，这些对象是服务器提前创建好的，可以在页面直接使用。

HttpServletResponse  response

以下四个对象，称之为四大域对象。分别有一个Map属性，这个Map称为四大域对象的域。

PageContext pageContext    代表当前页面，每个jsp页面都会创建自己的pageContext对象
HttpServletRequest request  代表当前请求
HttpSession session       代表当前会话
会话：  浏览器第一次访问web工程到浏览器关闭或session失效，这期间称之为一次会话
ServletContext application  代表当前应用
tomcat启动应用到应用被销毁，期间application对象一直存在

四大域对象主要的功能就是向它们的域(Map)中存放数据。

存放数据：  域对象.setAttribute("name","value");
取出数据： 域对象.getAttribute("name")

作用域的范围：  pageContext <  request <  session < application

使用的原则： 常用的是request.
能用小的不用大的。

## day03		
### 一、JS
JS是在浏览器端运行的脚本语言，负责将Html变成动态页面，和用户的交互。

特点： JS是脚本语言，解释性语言。 弱类型，跨平台。

基本数据类型：  String,number,boolean,Object,function

特殊值：  null, NAN(使用一个非数值类型和一个数值类型计算),undefine(只声明未定义)

JS的声明：
①在`<script><script>`中书写
②将js代码编写在一个外部文件中，使用`<script src="">`来引入
src属性，使浏览器向指定的url地址发送一个请求。
xx.js不能放入web工程的WEB-INF目录

### 二、BOM和DOM
BOM： 浏览器对象模型。使用多个内置的对象，来代表浏览器的多个组件。
例如：  window: 代表浏览器窗口
window中有很多子对象，例如history，navigator

DOM :  文档对象模型，专指BOM中的document对象。
document对象代表浏览器加载的整个文档。
使用一种树形结构描述文档。
使用document可以获取文档中所有的子标签，可以通过子标签获取或修改标注中的属性或内容。

var  dom=document.getElementById("id");   //DOM对象

innerHTML: 代表标签的内容（标签体）
name: 
value: 

### 三、事件
浏览器自动监听某些行为，一旦行为发生，生成一个事件。
可以事先为事件绑定一个函数，这个事件一旦触发，执行绑定的函数。

系统事件： 浏览器在加载或执行页面期间，自动发送的事件。
onload：  文档（页面）全部加载到浏览器后，发生
用户事件：  onclick:  某个标签发生用户点击
onchange:  文本框的value属性发生变化
onblur:  失去焦点
onfocus: 获得焦点

为事件绑定函数：
原生dom方式：  
document.getElementById("id").onclick=function(){};

使用Jquery: 
$("#id").click(function(){});

注意：使用代码方式为事件绑定函数，这部分代码必须写在onload()函数中！

或者直接在html标签的属性上复制： `<xxx onclick=函数名()></xxx>`

### 四、Jquery

Jquery是一个JS框架，提前封装好了很多JS的类库，可以直接使用。
Jquery有一个核心对象，叫jquery，或$

```jsp
简化代码：   
为onload事件赋值：   $(function(){});
根据id选中某个标签：  $("#id")
获取某个属性：	
$("#id").attr("属性名")
修改某个属性：	
$("#id").attr("属性名","属性值")

获取value属性：	
$("#id").val()
修改value属性：	
$("#id").val("属性值")

获取标签内容：	
$("#id").html()
修改标签内容：	
$("#id").html("内容")
```

### 五、ajax

ajax是一种浏览器端的技术，主要为了发送异步请求，局部刷新页面。

```jap
使用jquery发送ajax:
$.ajax(
    {
        url:xxx,
        type: xxx,
        data: xxx,
        success:function(msg){
        //msg服务端响应的文件
    	}
	}
);
```



### 六、EL
EL表达式，用于在JSP页面，获取四大域对象的数据，向页面输出。
目的消除Java代码。

**格式**：  ${ expression }

获取某个对象的属性：  ${ 对象名.属性名 }
获取某个map中的key:   ${ map对象名.key }

核心使用： 从四大域对象中取出数据

在EL中内置了11个隐含对象：

pageScope:   jsp中的PageContext  pageContext对象保存数据的map（域），简称为page域
requestScope:   request域
sessionScope:   session域
applicationScope:  application域

从某个域对象的域中取值：  ${xxxScope.key}

**简写**：  ${key},依次从page域...application域,直到取出值。

el取出的对象值为null，在页面不显示。

### 七. JSTL
jsp standard tag libary: jsp的标注标签库。

有五个子功能库，最常使用的是核心标签库。

引入：  在jsp页面，使用jsp声明引入
<%@ taglib uri="xxx" prefix="c"%>

使用：`<c:foreach>`

原理： 允许在Jsp页面使用标签的方式，完成某些功能。
`<c:foreach>`完成一个集合的遍历功能。
这个标签最终会解析为一个类，将标签中的属性，传递给这个类的某个方法，执行
java代码完成这个功能。

目的：  使用标签，消除java代码。

EL+JSTL,都是在jsp页面使用，目的都是消除java代码。

原则： jsp负责页面的显示，不希望有非显示的代码出现。



## day04

### 一、Cookie

**Cookie**是一种在浏览器端保存服务端所生成信息的技术。

​	创建：   new Cookie(String name,String value);

​	发送：  response.addCookie(xxx);

​	属性：   
​		path:  cookie的路径，默认是项目名。
​		在访问指定的路径时，一旦和cookie的路径匹配，就会携带cookie(在请求头中)。
​		Cookie.setPath();
​		MaxAge:   默认为-1，浏览器关闭就过期。

​	设置：  Cookie.setMaxAge();

​	查看cookie:
​		①浏览器端：
​			F12----Application---Cookies
​		②服务端：
​			Cookie [] cookies=request.getCookies();
​			获取cookie的name：  Cookie.getName()
​			获取cookie的value：  Cookie.getValue()

### 二、Session
Session在**服务器端**产生。代表一次会话。

**原理**：  每次浏览器在发送请求时，会携带一个cookie，名为JESSIONID。
当访问xxx.jsp或访问一个servlet，在这个servlet中，开发者调用了getSeesion();

a) 判断当前请求是否携带JESSIONIDcookie
携带：  尝试获取JESSIONID的value属性，以此为id，从tomcat中取出指定的session
取出： 返回
null--->  创建一个session，生成JESSIONID的cookie，加入到响应中，在响应浏览器时，更新之前的JESSIONIDcookie。
为携带： 
创建一个session，生成JESSIONID的cookie，加入到响应中，在响应浏览器时，更新之前的JESSIONIDcookie。

如何判断多次请求是一个会话，判断他们的JESSIONID的cookie的值是否相同。


​				
如果是同一个session，可以在这个session中共享数据。

session在服务端保存，默认的超时时间为30min。 距离上一次访问此session的请求间隔30min。
### 三、Filter
Filter意为过滤器，javaweb服务端三大组件之一。

Filter由tomcat创建，由tomcat自动调用其方法。

Filter在web应用一启动就创建。作用是拦截匹配到的请求，执行一些处理（放行或直接响应）。

核心方法：  doFilter(ServletRequest request,ServletResponse response,FilterChain chain){
ServletRequest request:  获取请求中所有的参数；转发！
ServletResponse response： 可以直接响应浏览器，重定向！

FilterChain chain： 代表当前请求的处理链。由多个拦截器和servlet组成。

放行：  chain.doFilter();
将request和response交给链中的下一个组件继续处理！
}

多个Filter:   按照在web.xml中配置的顺序，进行拦截，依次处理。
先进后出。

### 四、Listener

Listener意为监听器，javaweb服务端三大组件之一。

Listener由tomcat创建，由tomcat自动调用其方法。

Listener在web应用一启动就创建。作用是监听服务端的行为，一旦触发事件，执行其方法。

根据需要选择何时的Listener。

### 五、数据交换格式
XML：  一般用作工程的配置文件。适合层次多的信息的表现。尤其是复杂信息。

JSON：  轻量级的数据交换格式。目前的主流交换格式。
JSON天然和JS集成，使用方便。
在服务器端可以使用Gson等框架将JSON转为java对象处理。

大部分的B/S架构项目，或C/S架构，采用客户端和服务端分离的设计。

Browser/Android/IOS/windosw  <-----JSON格式----->  服务端

浏览器端转换：
JS对象转JSONSTR:	JSON.stringify(js对象)
JSONSTR转JS对象：   JSON.parse(json字符串)

服务端：  借助Gson
java对象转jsonstr	new Gson().toJson(java对象);
jsonstr转java对象   new Gson().fromJson(String jsonstr,T t)
new Gson().fromJson(String jsonstr,Type t)
new Gson().fromJson(xxx,new new TypeToken<集合类型>() {}.getType())

### 六、Ajax请求数据，局部刷新页面

```jsp
$.ajax({
	dataType:"json"  // 将服务端返回的jsonstr转为js对象
});
```

