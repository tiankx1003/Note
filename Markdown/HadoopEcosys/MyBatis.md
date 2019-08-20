## Mybatis
**半自动**  **ORM**  **DAO**
相比较而言，**Hibernate**为全自动，不需要开发者写sql语句，所以大的项目优化成本过高半自动需要开发者自己写sql语句，但是较容易优化，
MyBatis把sql语句放在xml中易于分成解耦

### Mybatis HelloWorld!
#### 1.创建Maven工程并在pom.xml中引入Mybatis依赖



#### 2.构建SqlSessionFactory
从Mybatis全局xml的配置文件创建SqlSessionFactor(负责创造SqlSession，类似于JDBC中的connection)，在Mybatis的全局配置文件中引入properties标签，在pom.xml中导入驱动。

#### 3.创建SqlSession
```java
SqlSession sqlSession = sqlSessionFactory.openSession();
```

#### 4.把sql放入xml
需要什么操作就用什么标签
使用别名来满足ORM，或使用setting，mapUnderscoreToCamelcase,下划线转驼峰

### log4j日志
现在pom.xml中引入
配置xml
注意SqlSession线程不安全，且用完之后要关闭

### 接口式编程完成CRUD  
*视频16*
查询不要事务，增删改一定有事务
