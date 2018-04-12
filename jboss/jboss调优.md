title: jboss性能调优
date: 2018-04-12
tags:
categories: jboss
permalink: xxx

---

摘要: 原创出处 https://www.cnblogs.com/xing901022/p/3978014.html 「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 jboss-eap-5.2 版本** 

- [1. JBOSS参数调优](https://github.com/vanpersl/note/blob/master/Spring/spring%E6%B3%A8%E8%A7%A3.md#1-%E6%A0%B9%E6%8D%AE%E6%9E%84%E9%80%A0%E5%99%A8%E5%8F%82%E6%95%B0%E7%9A%84%E7%B1%BB%E5%9E%8B)
- [2. JVM常见配置汇总](
https://github.com/vanpersl/note/blob/master/Spring/spring%E6%B3%A8%E8%A7%A3.md#2-%E6%A0%B9%E6%8D%AE%E7%B4%A2%E5%BC%95index%E6%B3%A8%E5%85%A5)
- [3. JBOSS生产环境下JVM调优](https://github.com/vanpersl/note/blob/master/Spring/spring%E6%B3%A8%E8%A7%A3.md#3-%E6%A0%B9%E6%8D%AE%E5%8F%82%E6%95%B0%E7%9A%84%E5%90%8D%E7%A7%B0%E6%B3%A8%E5%85%A5)
- [4. LeaseManager]()


```xml
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg value="qiao" />  
        <constructor-arg value="20" />  
        <constructor-arg ref="dept" />  
        <constructor-arg value="nv" />  
    </bean>  
```


吐血整理了以前Jboss以及JVM在生产环境下的调优参数，各种不同的案例，都是来自网友杜撰。整合后，希望对广大使用jboss作为生产应用服务器的朋友有所帮助。

# 1. JBOSS参数调优
配置deploy/jboss-web.deployer/server.xml文件 .
       

```xml
<Connector
         port="8080"
         address="0.0.0.0"
         maxThreads="1600"
        minSpareThreads="100"
        maxSpareThreads="250"
         emptySessionPath="false"
        enableLookups="false"
         redirectPort="8443"
         acceptCount="800"
        connectionTimeout="20000"
        disableUploadTimeout="true"
         URIEncoding="UTF-8"
         />
```

maxThreads：表示最多同时处理的连接数。应该将线程数（最大线程数）设置比最大预期负载（同时并发的点击）多25%（经验规则）。

acceptCount：当同时连接的人数达到maxThreads时，还可以接收排队的连接。

minSpareThread：指“启动以后，总是保持该数量的线程空闲等待”；设置比预期负载多25%。

maxSpareThread：指“如果超过了minSpareThread，然后总是保持该数量的线程空闲等待”；设置比预期负载多25%。

 

其中主要修改两个参数maxThreads和acceptCount值。

增加maxThreads，减少acceptCount值有利缩短系统的响应时间。但是maxThreads和acceptCount的总和最高值不能超过6000，而且maxThreads过大会增加CPU和内存消耗，故低配置用户可通过降低maxThreads并同时增大acceptCount值来保证系统的稳定。

下表罗列出了在不同并发情况下jboss参数与并发在线的一般关系。

并发数

服务器内存

jboss参数

 

 



 

 

## jvm调优讲解1
### A：JVM启动参数共分为三类：
        其一是标准参数（-），所有的JVM实现都必须实现这些参数的功能，而且向后兼容；
        其二是非标准参数（-X），指的是JVM底层的一些配置参数

　　这些参数在一般开发中默认即可，不需要任何配置。但是在生产环境中，并不保证所有jvm实现都满足，所以为了提高性能，往往需要调整这些参数，以求系统达到最佳性能。另外这些参数不保证向后兼容，也即是说“如有变更，恕不在后续版本的JDK通知”（这是官网上的原话）；

        其三是非Stable参数（-XX），这类参数在jvm中是不稳定的，不适合日常使用的，后续也是可能会在没有通知的情况下就直接取消了，需要慎重使用。
        
### B：而JVM 内存又可分为三个主要的域 ：
        新域、旧域以及永久域（有的也叫做新生代，年老代，和永久代）。JVM生成的所有新对象放在新域中。一旦对象经历了一定数量的垃圾收集循环后，便进入旧域。而在永久域中是用来存储JVM自己的反射对象的，如class和method对象，而且GC(GarbageCollection)不会在主程序运行期对永久域进行清理。

　　其中新域和旧域属于堆，永久域是一个独立域并且不认为是堆的一部分。
### C：各主要参数的作用如下 ：

```bash
        -Xms：设置jvm内存的初始大小
        -Xmx：设置jvm内存的最大值
        -Xmn：设置新域的大小（这个似乎只对 jdk1.4来说是有效的，后来就废弃了）
        -Xss：设置每个线程的堆栈大小(也就是说,在相同物理内存下，减小这个值能生成更多的线程)
        -XX：NewRatio :设置新域与旧域之比，如-XX：NewRatio = 4就表示新域与旧域之比为1：4
        -XX:NewSize：设置新域的初始值
        -XX:MaxNewSize ：设置新域的最大值
        -XX:PermSize：设置永久域的初始值
        -XX:MaxPermSize：设置永久域的最大值
        -XX:SurvivorRatio=n:设置新域中Eden区与两个Survivor区的比值。
```
 

Eden区主要是用来存放新生的对象，而两个 Survivor区则用来存放每次垃圾回收后存活下来的对象


### D：常见的错误 ：
        java.lang.OutOfMemoryError相信很多开发人员都用到过，

这个主要就是JVM参数没有配好引起的，但是这种错误又分两种：

java.lang.OutOfMemoryError:Java heap space和java.lang.OutOfMemoryError: PermGenspace，

其中前者是有关堆内存的内存溢出，可以同过配置-Xms和-Xmx参数来设置，而后者是有关永久域的内存溢出，可以通过配置 -XX:MaxPermSize来设置。

下面是个例子,请根据实际情况进行修改,修改run.conf文件中的如下内容：

 JAVA_OPTS="-Xms256m-Xmx2048m -XX:NewSize=256m -XX:MaxNewSize=512m -XX:PermSize=128m-XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC -XX:+CMSPermGenSweepingEnabled-XX:+CMSClassUnloadingEnabled -Djboss.platform.mbeanserver"
## JVM调优讲解2
在Java的Jvm分为主要为两大块：一个是heap和 nheap
Heap包括三个区域. Eden space 、survivor space、tenured space.
其中surivor space包括两个区，一个是from区，一个是to区
Eden是负责新对象的创建区域。当新对象无法在eden区创建的时候，eden区会进行minor gc,会将一些失效的对象清除。会将清除下来的部分对象放到survivor space区域或者tenured space区域。当tenured space的对象越来越多的时候，达到jvm内存不足10%的时候，会进行一次full gc来释放对象。项目要尽可能少的full gc ,应为full gc比较占用内存，一般要求吞吐量比较大的时候，尽量的将new区域设置的比较大一点。也就是eden和survivor这个区域。


下面简要的说一下配置参数

set JAVA_OPTS=%JAVA_OPTS% -Xms128m -Xmx512m -XX:MaxPermSize=256m 

-Xms512m 代表jvm最少用 512m内存,32bit操作系统最大在1.5g-2g之间。64位的无限制
-Xmx1024m 代表jvm最多使用 1024m内存,尽量的将-Xms和-Xmx大小设置相同，这样避免内存重新分配影响性能
-Xss=128k 线程初始化大小，5.0之前默认是128k,之后为1m,线程机器最大为3000-5000
-XX:MaxPermSize=256m.这是表明持久类，也就是noheap区域的最大为256
-XX:PermSize=256m这个持久区域初始化为256m，一般持久类的大小是64m
这个配置是最常用的配置。如果需要考虑到吞吐量，那么new space和old space你就得重新分配一下

 

Jvm垃圾收集器包括三种：串行，并行，并发
串行：处理小型数据，jdk1.4之前默认使用
并行：1.5和1.5之后使用，处理

 

# 2. JVM常见配置汇总
## 1. 堆设置
-Xss128m:JBoss每增加一个线程（thread)就会立即消耗128K,默认值好像是512k.
-Xms256m:初始堆大小,代表jvm最少用 512m内存
-Xmx:最大堆大小 一般为服务器的3/4内存量，推荐至少使用4G内存，不应该超过物理内存的90％。
-XX:NewSize=n:设置年轻代大小
-XX:NewRatio=n:设置年轻代和年老代的比值。如:为3，表示年轻代与年老代比值为1：3，年轻代占整个年轻代年老代和的1/4
-XX:SurvivorRatio=n:年轻代中Eden区与两个Survivor区的比值。注意Survivor区有两个。如：3，表示Eden：Survivor=3：2，一个Survivor区占整个年轻代的1/5
-XX:MaxPermSize=n:设置持久代大小
## 2. 收集器设置
-XX:+UseSerialGC:设置串行收集器
-XX:+UseParallelGC:设置并行收集器
-XX:+UseParalledlOldGC:设置并行年老代收集器
-XX:+UseConcMarkSweepGC:设置并发收集器
## 3. 垃圾回收统计信息
-XX:+PrintGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Xloggc:filename
## 4. 并行收集器设置
-XX:ParallelGCThreads=n:设置并行收集器收集时使用的CPU数。并行收集线程数。
-XX:MaxGCPauseMillis=n:设置并行收集最大暂停时间
-XX:GCTimeRatio=n:设置垃圾回收时间占程序运行时间的百分比。公式为1/(1+n)
## 5. 并发收集器设置
-XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况。
-XX:ParallelGCThreads=n:设置并发收集器年轻代收集方式为并行收集时，使用的CPU数。并行收集线程数。

 

# 3. JBOSS生产环境下JVM调优

## 查看CPU数

cat /proc/cpuinfo | grep "processor" | wc -l
JBOSS参数
　　生产环境8G内存jboss配置如下

if [ "x$JAVA_OPTS" = "x" ]; then    
   JAVA_OPTS="-Xss128k -Xms6000m -Xmx6000m -XX:MaxNewSize=512m -XX:MaxPermSize=512M -XX:+UseParallelGC -XX:ParallelGCThreads=16 -XX:+UseParallelOldGC -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"    
fi    
　　生产环境4G内存jboss配置如下

if [ "x$JAVA_OPTS" = "x" ]; then    
   JAVA_OPTS="-Xss128k -Xms3000m -Xmx3000m -XX:MaxNewSize=256m -XX:MaxPermSize=256m -XX:+UseParallelGC -XX:ParallelGCThreads=16 -XX:+UseParallelOldGC -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"    
fi   
## 数据库连接
　　在JBOSS_HOME\Server\default\deploy目录下存在**-xa-ds.xml文件，用于JBOSS同数据库连接等配置，默认情况下**-xa-ds.xml文件中不包含关于数据库连接池等方面的配置信息，可以添加一下内容进行数据库连接池方面的设置：

 
<min-pool-size>100</min-pool-size>    
<max-pool-size>500</max-pool-size>   
## 日志优化

优化JBOSS日志：%JBOSS_HOME%/server/default/conf/log4j.xml

## 修改Append

<SPAN><param name="Append" value="true"/>  
<param name="Threshold" value="WARN"/></SPAN>  
修改后的代码如下：

```xml
<SPAN><appender name="FILE" class="org.jboss.logging.appender.DailyRollingFileAppender">  
<errorHandler class="org.jboss.logging.util.OnlyOnceErrorHandler"/>  
<param name="File" value="${jboss.server.home.dir}/log/server.log"/>  
<param name="Append" value="true"/>  
<param name="Threshold" value="WARN"/>  
<param name="DatePattern" value="'.'yyyy-MM-dd"/>  
<layout class="org.apache.log4j.PatternLayout">  
<param name="ConversionPattern" value="%d %-5p [%c] %m%n"/>  
</layout>  
</appender></SPAN>  
```
 

## 修改Root

关闭控制台日志输出：
屏蔽：<appender-ref ref="CONSOLE"/>
```xml
<root>  
<!--<appender-ref ref="CONSOLE"/>-->  
<appender-ref ref="FILE"/>  
</root>  
```
 

# JBOSS瘦身
在JBOSS中提供许多通常不需要的服务和Jar包

　　比如JMX、Mail、AOP、Hibernate等，可以根据具体项目所涉及的技术，删减JBOSS内置应用，从而提高JBOSS中间件启动速度，减少占用系统资源。

删减服务
　　在%JBOSS_HOME%/server/default/deploy中含有一些比如jboss-aop.deployer等目录和mail-service.xml等应用配置文件，如果不需要使用这些应用的话，可以将其一一删除，不过删除时要分外小心，避免应用系统无法启动。
 
删减Jar包
在%JBOSS_HOME%/server/default/lib中包含一些应用系统不需要的Jar包，这些包同样可以进行删除。

 

JBoss性能优化：内存紧张的问题终于解决了(转载)----调优实例
    昨天查了一天的资料，运气不错，收获不小，解决了一个老大难问题：JBoss内存紧张的问题。
    这是一个困扰了我两年整的问题，就是从前年这个时候，用JBoss 3.2.1架站以来，始终是一个大问题。不大的站点，1G的内存都不够用，经常要消耗500Mb的交换内存（swap)。
原来是自己犯了非常低级的错误，不懂JAVA_OPTS各参数的含义造成的。
之前的JAVA_OPTS是 -Xms 520m -Xmx 1220m -Xss 15120k +XX:AggressiveHeap
 
这个JAVA_OPTS犯了2个致命的错误：
1. +XX:AggressiveHeap会使得 Xms 1220m没有意义。这个参数让jvm忽略Xmx参数，疯狂地吃完一个G物理内存，再吃尽一个G的swap。
另外Xmx作为允许jvm使用的最大内存数量，不应该超过物理内存的90％。
而之所以使用了这个参数，是因为不加的话，JBoss会在运行一天左右的时间后迅速崩溃，上机课是，甚至出现过半个小时就崩溃的情况。
之所以要用这个参数，用swap支持服务器运行，是因为犯了下面的错误：
2. -Xss 15120k
这使得JBoss每增加一个线程（thread)就会立即消耗15M内存，而最佳值应该是128K,默认值好像是512k.
这就是JBoss刚启动时，还有200Mb内存富余，但会在一个小时内迅速用完，因为服务器的threads在迅速增加。前3天，每天都多吃80Mb左右的swap.在第四天开始稳定下来。今年春节在外度假，观察到了这个现象，却不理解其原因：服务器在线程到达100之后，一般不再增加新的线程，新增加的在用完之后，会被迅速destroy，1.25-2.10所使用的线程基本是1.21- 1.23创建的，因此没有再消耗新的内存。服务器持续运行时间，也因此大大超乎我5天的预期，到达了20天。
昨天所作的修改：
1.修改JAVA_OPTS,去掉+XX:AggressiveHeap，修改Xss。现在的JAVA_OPTS为：
 －Xms 520m -Xmx 900m -Xss 128k

2.修改deploy/jbossweb-tomcat55.sar/service.xml
将maxThreads根据目前的访问量由默认的250降为75，并使用jboss 4默认未写在标准service.xml里面而jboss 3写入了的2个参数: 
maxSparseThreads=55
minSparseThreads=25
 

3.修改了oracle-ds.xml将最大连接数有150降为50.
 
4.去掉了一些不用的服务。
 
# Jboss 优化配置
## 一． Jboss后台启动：
添加后台修改命令：
 vi run.sh
 

```sh
while true; do
  if [ "x$LAUNCH_JBOSS_IN_BACKGROUND" = "x" ]; then
  # Execute the JVM in the foreground
  nohup "$JAVA" $JAVA_OPTS \
  -Djava.endorsed.dirs="$JBOSS_ENDORSED_DIRS" \
  -classpath "$JBOSS_CLASSPATH" \
  org.jboss.Main "$@"
  JBOSS_STATUS=$?
  else
  # Execute the JVM in the background
  "$JAVA" $JAVA_OPTS \
  -Djava.endorsed.dirs="$JBOSS_ENDORSED_DIRS" \
  -classpath "$JBOSS_CLASSPATH" \
  org.jboss.Main "$@" &
  JBOSS_PID=$!
  # Trap common signals and relay them to the jboss process
  trap "kill -HUP $JBOSS_PID" HUP
  trap "kill -TERM $JBOSS_PID" INT
  trap "kill -QUIT $JBOSS_PID" QUIT
  trap "kill -PIPE $JBOSS_PID" PIPE
  trap "kill -TERM $JBOSS_PID" TERM
  # Wait until the background process exits
  WAIT_STATUS=0
  while [ "$WAIT_STATUS" -ne 127 ]; do
  JBOSS_STATUS=$WAIT_STATUS
  wait $JBOSS_PID 2>/dev/null
  WAIT_STATUS=$?
  done
  fi
  # If restart doesn't work, check you are running JBossAS 4.0.4+
  # http://jira.jboss.com/jira/browse/JBAS-2483
  # or the following if you're running Red Hat 7.0
  # http://developer.java.sun.com/developer/bugParade/bugs/4465334.html  
  if [ $JBOSS_STATUS -eq 10 ]; then
  echo "Restarting JBoss..."
  else
  exit $JBOSS_STATUS
  fi
done &
```


## 二． Jboss内存优化：
修改这个两参数，给jvm分配适当的内存，一般为服务器的3/4内存量，推荐至少使用4G内存。
另外添加两个参数 -XX:+UseParallelGC -XX:+UseParallelOldGC 这两个让服务并行回收内存空间。修改完成后，大致为
JAVA_OPTS = “-Xms4096m -Xmx8192m -XX:+UseParallelGC -XX:+UseParallelOldGC -Dsum……
 
## 三． Jboss日志输出模式
 ```xml
[root@190MEM conf]# pwd
/usr/local/jboss/server/default/conf
[root@190MEM conf]# vi jboss-log4j.xml
  <appender name="FILE" class="org.jboss.logging.appender.DailyRollingFileAppender">
  <errorHandler class="org.jboss.logging.util.OnlyOnceErrorHandler"/>
  <param name="File" value="${jboss.server.log.dir}/server.log"/>
  <param name="Append" value="false"/>
  <param name="Threshold" value="ERROR"/>
```
 

## 四． Jboss数据库连接池优化
修改数据库连接池：
 ```xml
<datasources>
  <local-tx-datasource>
  <jndi-name>training_master_db</jndi-name> <connection-url>jdbc:mysql://211.100.192.128:3306/dts?useUnicode=true&amp;characterEncoding=UTF-8</connection-url>
  <driver-class>com.mysql.jdbc.Driver</driver-class>
  <user-name>root</user-name>
  <password></password>
  <min-pool-size>100</min-pool-size>
  <max-pool-size>500</max-pool-size> <exception-sorter-class-name>org.jboss.resource.adapter.jdbc.vendor.MySQLExceptionSorter</exception-sorter-class-name>
```

## 五． Jboss部署目录优化：
  去掉和应用无关的部署，加快jboss运行速度
    
 ```xml
bsh-deployer.xml 
client-deployer-service.xml  
ear-deployer.xml
ejb-deployer.xml 
http-invoker.sar 
jboss-bean.deployer 
jboss-ws4ee.sar
jms 
jsr88-service.xml  
schedule-manager-service.xml
scheduler-service.xml
sqlexception-service.xml
uuid-key-generator.sar
```
