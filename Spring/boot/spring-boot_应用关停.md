title: Spring boot学习
date: 2018-03-21
tags:
categories: Spring
permalink: xxx

---

摘要: vanpersl原创 「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 Spring Boot 2.0.0.RELEASE 版本** 

- [1. 引入spring boot相关的包](https://github.com/vanpersl/note/blob/master/Spring/boot/spring-boot_%E5%BA%94%E7%94%A8%E5%85%B3%E5%81%9C.md#1-%E5%BC%95%E5%85%A5spring-boot%E7%9B%B8%E5%85%B3%E7%9A%84%E5%8C%85)
- [2. 配置application.yml](
https://github.com/vanpersl/note/blob/master/Spring/boot/spring-boot_%E5%BA%94%E7%94%A8%E5%85%B3%E5%81%9C.md#2-%E9%85%8D%E7%BD%AEapplicationyml)
- [3. 测试应用关停](https://github.com/vanpersl/note/blob/master/Spring/boot/spring-boot_%E5%BA%94%E7%94%A8%E5%85%B3%E5%81%9C.md#3-%E6%B5%8B%E8%AF%95%E5%BA%94%E7%94%A8%E5%85%B3%E5%81%9C)
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

