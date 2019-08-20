## Maven

#### 1.概念

Maven是一个项目管理工具
项目管理：项目构建、依赖管理和项目信息管理

#### 2.自动化构建

```
自动化构建Maven的文件结构
项目名/src
	main
		java
			resources
		test
			java
			resources
```

#### 3.坐标

**G**roup：一般为公司或组织域名反写
**A**rtifict：模块名或项目名
**V**ersion：版本号
            release-3.5.4   正式发布版
            stable-2.3.2    稳定版
            alpha-1.2       测试版（内测版）
            beta-0.2.1      公测版
每一个Maven项目都有一个**pom.xml**文件用于确定引用了哪些内容

#### 4.依赖管理

scope属性代表jar的生效范围（作用域）
	常用scope有compile  test  provided
依赖的传递
	只有个scope属性为compile的依赖才会向下传递！

```xml
<!-- 依赖的排除 -->
<exclusions>
	<exclusion>
		<groupId>com.tian.xiyou</groupId>
		<artifactId>JinGuBang</artifactId>
		<!-- 必须要<version> -->
	</exclusion>
</exclusions>
```

#### 5.继承和聚合

##### 继承
​	**子工程**：普通的Maven工程，可以是jar也可以是war
​	**父工程**：packaging=pom

```xml
<!-- 子工程继承父工程，在子工程中使用 -->
<parent>父工程的GAV</parent>
<!-- 从父工程中取jar包建议使用 -->
<dependencyManagement>
    <dependencies>
    </dependencies>
</dependencyManagement>
```

​	**目的**：大型项目开发，分模块开发。不同模块有可能使用相同的jar，版本相同
​		为了避免冲突，使用一个父工程，提前将所有的jar确定，版本确定
​		子工程通过继承父工程的形式获取jar包，避免冲突！

##### 聚合

​	作用：它使用一个Maven工程将需要的多个Maven进行聚集
​				可以通过运行聚合工程，打到在其配置的多个被聚合工程中，批量执行命令！

​	聚合工程必须packaging=pom