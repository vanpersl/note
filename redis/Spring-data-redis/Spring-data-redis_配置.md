title: Redis 哨兵模式连接池配置
date: 2018-03-16
tags:
categories: Spring
permalink: xxx

---

摘要: 原创出处 https://x.x.x/「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 Spring 3.*.* 版本** 

- [1. Spring配置文件](https://github.com/vanpersl/note/blob/master/Redis/Spring-data-redis/Spring-data-redis_%E9%85%8D%E7%BD%AE.md#1-spring%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
- [2. Redis配置信息](https://github.com/vanpersl/note/blob/master/Redis/Spring-data-redis/Spring-data-redis_%E9%85%8D%E7%BD%AE.md#2-redis%E9%85%8D%E7%BD%AE%E4%BF%A1%E6%81%AF)
- [3. RedisServiceImpl工具类](https://github.com/vanpersl/note/blob/master/Redis/Spring-data-redis/Spring-data-redis_%E9%85%8D%E7%BD%AE.md#3-redisserviceimpl%E5%B7%A5%E5%85%B7%E7%B1%BB)
- [4. LeaseManager]()



**依赖的maven包版本** 
```xml
<dependency>
	<groupId>org.springframework.data</groupId>
	<artifactId>spring-data-redis</artifactId>
	<version>1.7.0.RELEASE</version>
</dependency>
<dependency>
	<groupId>redis.clients</groupId>
	<artifactId>jedis</artifactId>
	<version>2.8.0</version>
</dependency>
<dependency>
	<groupId>org.apache.commons</groupId>
	<artifactId>commons-pool2</artifactId>
	<version>2.0</version>
</dependency>
```

# 1. Spring配置文件
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p"
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:jee="http://www.springframework.org/schema/jee" xmlns:tx="http://www.springframework.org/schema/tx"
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="  
            http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd  
            http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

	<!-- Spring自动将该包目录下标记为@Service的所有类作为spring的Bean -->
	<context:property-placeholder location="classpath*:spring-data-redis.properties" />

	<bean id="poolConfig" class="redis.clients.jedis.JedisPoolConfig">
		<property name="maxTotal" value="${im.hs.server.redis.maxTotal}" />
		<property name="maxWaitMillis" value="${im.hs.server.redis.maxWaitTime}" />
		<property name="maxIdle" value="${im.hs.server.redis.maxIdle}" />
		<property name="testOnBorrow" value="${im.hs.server.redis.testOnBorrow}" />
		<property name="testOnReturn" value="true" />
		<property name="testWhileIdle" value="true" />
	</bean>

	<bean id="sentinelConfiguration"
		class="org.springframework.data.redis.connection.RedisSentinelConfiguration">
		<property name="master">
			<bean class="org.springframework.data.redis.connection.RedisNode">
				<property name="name" value="${im.hs.server.redis.sentinel.masterName}"></property>
			</bean>
		</property>
		<property name="sentinels">
			<set>
				<bean class="org.springframework.data.redis.connection.RedisNode">
					<constructor-arg name="host"
						value="${im.hs.server.redis.sentinel1.host}"></constructor-arg>
					<constructor-arg name="port"
						value="${im.hs.server.redis.sentinel1.port}"></constructor-arg>
				</bean>
				<bean class="org.springframework.data.redis.connection.RedisNode">
					<constructor-arg name="host"
						value="${im.hs.server.redis.sentinel2.host}"></constructor-arg>
					<constructor-arg name="port"
						value="${im.hs.server.redis.sentinel2.port}"></constructor-arg>
				</bean>
			</set>
		</property>
	</bean>

	<bean id="connectionFactory"
		class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
		<constructor-arg name="sentinelConfig" ref="sentinelConfiguration"></constructor-arg>
		<constructor-arg name="poolConfig" ref="poolConfig"></constructor-arg>
	</bean>

	<bean id="redisTemplate" class="org.springframework.data.redis.core.StringRedisTemplate">
		<property name="connectionFactory" ref="connectionFactory" />
	</bean>
</beans>
```

# 2. Redis配置信息
```bash
# Redis settings  
#sentinel1\u7684IP\u548C\u7AEF\u53E3  
im.hs.server.redis.sentinel1.host=10.1.1.1:26379
#sentinel2\u7684IP\u548C\u7AEF\u53E3  
im.hs.server.redis.sentinel2.host=10.1.1.2:26379
#sentinel\u7684\u9274\u6743\u5BC6\u7801  
im.hs.server.redis.sentinel.masterName=mymaster
##im.hs.server.redis.sentinel.password=xxxxxx
#\u6700\u5927\u95F2\u7F6E\u8FDE\u63A5\u6570  
im.hs.server.redis.maxIdle=300  
#\u6700\u5927\u8FDE\u63A5\u6570\uFF0C\u8D85\u8FC7\u6B64\u8FDE\u63A5\u65F6\u64CD\u4F5Credis\u4F1A\u62A5\u9519  
im.hs.server.redis.maxTotal=1000
im.hs.server.redis.maxWaitTime=1000  
im.hs.server.redis.testOnBorrow=true  
#\u6700\u5C0F\u95F2\u7F6E\u8FDE\u63A5\u6570\uFF0Cspring\u542F\u52A8\u7684\u65F6\u5019\u81EA\u52A8\u5EFA\u7ACB\u8BE5\u6570\u76EE\u7684\u8FDE\u63A5\u4F9B\u5E94\u7528\u7A0B\u5E8F\u4F7F\u7528\uFF0C\u4E0D\u591F\u7684\u65F6\u5019\u4F1A\u7533\u8BF7\u3002  
im.hs.server.redis.minIdle=300  
```
注意：这里的端口和地址都是sentinel的配置，不要用成redis的了

# 3. RedisServiceImpl工具类
```Java
@Service
public class RedisServiceImpl implements IRedisService {

	private Logger logger = LoggerFactory.getLogger(RedisServiceImpl.class);

	@Autowired
	RedisTemplate<?, ?> redisTemplate;

	@Override
	public void set(final String key, final Object value, final long expirationTime) {
		final Expiration expiration = Expiration.from(expirationTime, TimeUnit.SECONDS);
		redisTemplate.execute(new RedisCallback<Object>() {
			@Override
			public Object doInRedis(RedisConnection connection) throws DataAccessException {
				connection.set(redisTemplate.getStringSerializer().serialize(key), serialize(value), expiration, null);
				logger.debug("save key:" + key + ",value:" + value);
				return null;
			}
		});
	}

	

	@Override
	public Object get(final String key) {
		return redisTemplate.execute(new RedisCallback<Object>() {
			@Override
			public Object doInRedis(RedisConnection connection) throws DataAccessException {
				byte[] byteKye = redisTemplate.getStringSerializer().serialize(key);
				if (connection.exists(byteKye)) {
					byte[] byteValue = connection.get(byteKye);
					Object value = redisTemplate.getDefaultSerializer().deserialize(byteValue);
					logger.debug("get key:" + key + ",value:" + value);
					return value;
				}
				logger.error("valus does not exist!,key:" + key);
				return null;
			}
		});
	}

	@Override
	public void delete(final String key) {
		redisTemplate.execute(new RedisCallback<Object>() {
			public Object doInRedis(RedisConnection connection) {
				return connection.del(redisTemplate.getStringSerializer().serialize(key));
			}
		});
	}

	@Override
	public boolean expire(final String key, final int validTime) {
		return (Boolean) redisTemplate.execute(new RedisCallback<Object>() {
			@Override
			public Object doInRedis(RedisConnection connection) {
				return connection.expire(redisTemplate.getStringSerializer().serialize(key), validTime);
			}
		});
	}

	/**
	 * 序列化
	 * 
	 * @param value
	 * @return
	 */
	private byte[] serialize(Object value) {
		if (value == null) {
			throw new NullPointerException("Can't serialize null");
		}
		byte[] rv = null;
		ByteArrayOutputStream bos = null;
		ObjectOutputStream os = null;
		try {
			bos = new ByteArrayOutputStream();
			os = new ObjectOutputStream(bos);
			os.writeObject(value);
			os.close();
			bos.close();
			rv = bos.toByteArray();
		} catch (IOException e) {
			logger.error(e.getMessage(), e);
		} finally {
			try {
				if (os != null)
					os.close();
				if (bos != null)
					bos.close();
			} catch (Exception e2) {
				logger.error(e2.getMessage(), e2);
			}
		}
		return rv;
	}
	

}
```

