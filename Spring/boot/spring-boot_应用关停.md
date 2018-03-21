title: Spring 注解学习
date: 2018-03-16
tags:
categories: Spring
permalink: xxx

---

摘要: 原创出处 http://blog.csdn.net/qxs965266509/article/details/8848794 「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 Spring 3.*.* 版本** 

- [1. 引入spring boot相关的包](https://github.com/vanpersl/note/blob/master/Spring/spring%E6%B3%A8%E8%A7%A3.md#1-%E6%A0%B9%E6%8D%AE%E6%9E%84%E9%80%A0%E5%99%A8%E5%8F%82%E6%95%B0%E7%9A%84%E7%B1%BB%E5%9E%8B)
- [2. 配置application.yml](
https://github.com/vanpersl/note/blob/master/Spring/spring%E6%B3%A8%E8%A7%A3.md#2-%E6%A0%B9%E6%8D%AE%E7%B4%A2%E5%BC%95index%E6%B3%A8%E5%85%A5)
- [3. 测试应用关停](https://github.com/vanpersl/note/blob/master/Spring/spring%E6%B3%A8%E8%A7%A3.md#3-%E6%A0%B9%E6%8D%AE%E5%8F%82%E6%95%B0%E7%9A%84%E5%90%8D%E7%A7%B0%E6%B3%A8%E5%85%A5)
- [4. LeaseManager]()




下面的是常用的spring构造函数的注入方式
# 1. 引入spring boot相关的包
```xml
    <dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-jpa</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-actuator</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-security</artifactId>
		</dependency>
```

# 2. 配置application.yml

```yml
spring:
  datasource:
      driver-class-name: com.mysql.jdbc.Driver
      url: jdbc:mysql://127.1.1.1:3306/db?characterEncoding=UTF-8
      username: admin
      password: admin
  jpa:
    database: MYSQL
    hibernate:
      ddl-auto: update
    naming:
      physical-strategy: com.xxx.xxx.xxx.xxx.MySQLUpperCaseStrategy
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL5Dialect
    show-sql: true
  security: 
    user: 
      name: admin
      password: admin
      roles: SUPERUSER
      
server: 
  port: 8080
  servlet: 
    context-path: /app
    
management: 
  endpoints: 
    web: 
      exposure: 
        include: '*'
      base-path: /manage
  endpoint: 
    shutdown: 
      enabled: true
```

# 3. 测试应用关停


```xml 
curl -X POST http://127.0.0.1:8080/app/manage/shutdown
$ {"message":"Shutting down, bye..."}
```

