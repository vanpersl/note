title: Spring 注解学习
date: 2018-03-16
tags:
categories: Spring
permalink: xxx

---

摘要: 原创出处 http://blog.csdn.net/qxs965266509/article/details/8848794 「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 Spring 3.*.* 版本** 

- [1. 根据构造器参数的类型]()
- [2. 根据索引index注入]()
- [3. 根据参数的名称注入]()
- [4. LeaseManager]()


```xml
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg value="qiao" />  
        <constructor-arg value="20" />  
        <constructor-arg ref="dept" />  
        <constructor-arg value="nv" />  
    </bean>  
```

下面的是常用的spring构造函数的注入方式
# 1. 根据构造器参数的类型
```xml
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg type="java.lang.String" value="qiao" />  
        <constructor-arg type="java.lang.Integer" value="20" />  
        <constructor-arg type="www.csdn.spring.cust.Dept" ref="dept" />  
        <constructor-arg type="java.lang.String" value="nv" />  
    </bean>  
```

# 2. 根据索引index注入

```xml
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg index="0" value="qiao" />  
        <constructor-arg index="1" value="20" />  
        <constructor-arg index="2" ref="dept" />  
        <constructor-arg index="3" value="nv" />  
    </bean>  
```

# 3. 根据参数的名称注入
[html] view plain copy

```xml
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg name="name" value="qiao" />  
        <constructor-arg name="age" value="20" />  
        <constructor-arg name="dept" ref="dept" />  
        <constructor-arg name="sex" value="nv" />  
    </bean>  

```



下面是我定义的2个类
Dept.java

```Java
package www.csdn.spring.cust;  
  
public class Dept {  
  
    public String num;  
    public String name;  
  
    public void setNum(String num) {  
        this.num = num;  
    }  
  
    public void setName(String name) {  
        this.name = name;  
    }  
  
    @Override  
    public String toString() {  
        return "Dept [num=" + num + ", name=" + name + "]";  
    }  
  
} 

```
Employee.java

```Java
package www.csdn.spring.cust;  
  
public class Employee {  
  
    public String name;  
    public Integer age;  
    public Dept dept;  
    public String sex;  
  
    public Employee(String name, Integer age, Dept dept, String sex) {  
        super();  
        this.name = name;  
        this.age = age;  
        this.dept = dept;  
        this.sex = sex;  
    }  
  
    @Override  
    public String toString() {  
        return "Member [name=" + name + ", age=" + age + ", dept=" + dept  
                + ", sex=" + sex + "]";  
    }  
  
}  

```
spring.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans  
           http://www.springframework.org/schema/beans/spring-beans.xsd">  
  
    <!-- <bean id="employee" class="www.csdn.spring.cust.Employee"> <constructor-arg   
        value="qiao" /> <constructor-arg value="20" /> <constructor-arg ref="dept"   
        /> <constructor-arg value="nv" /> </bean> -->  
    <!-- <bean id="employee" class="www.csdn.spring.cust.Employee"> <constructor-arg   
        type="java.lang.String" value="qiao" /> <constructor-arg type="java.lang.Integer"   
        value="20" /> <constructor-arg type="www.csdn.spring.cust.Dept" ref="dept"   
        /> <constructor-arg type="java.lang.String" value="nv" /> </bean> -->  
  
    <!-- <bean id="employee" class="www.csdn.spring.cust.Employee"> <constructor-arg   
        index="0" value="qiao" /> <constructor-arg index="1" value="20" /> <constructor-arg   
        index="2" ref="dept" /> <constructor-arg index="3" value="nv" /> </bean> -->  
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg name="name" value="qiao" />  
        <constructor-arg name="age" value="20" />  
        <constructor-arg name="dept" ref="dept" />  
        <constructor-arg name="sex" value="nv" />  
    </bean>  
  
    <bean id="dept" class="www.csdn.spring.cust.Dept">  
        <property name="num" value="xx001" />  
        <property name="name" value="教育部" />  
    </bean>  
</beans>  
```

spring中null值的注入
```xml
<?xml version="1.0" encoding="UTF-8"?>  
<beans xmlns="http://www.springframework.org/schema/beans"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
    xsi:schemaLocation="http://www.springframework.org/schema/beans  
           http://www.springframework.org/schema/beans/spring-beans.xsd">  
  
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <!-- value="null" null是字符串 -->  
        <property name="name">  
            <null />  
        </property>  
        <property name="dept">  
            <null />  
        </property>  
    </bean>  
  
</beans>  
```
