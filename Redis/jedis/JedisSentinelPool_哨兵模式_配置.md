title: Redis 哨兵模式连接池配置
date: 2018-03-16
tags:
categories: Spring
permalink: xxx

---

摘要: 原创出处 https://my.oschina.net/visionit/blog/756319「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 Spring 3.*.* 版本** 

- [1. Spring配置文件](https://github.com/vanpersl/note/blob/master/Redis/jedis/JedisSentinelPool_%E5%93%A8%E5%85%B5%E6%A8%A1%E5%BC%8F_%E9%85%8D%E7%BD%AE.md#1-spring%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6)
- [2. Redis配置信息](https://github.com/vanpersl/note/blob/master/Redis/jedis/JedisSentinelPool_%E5%93%A8%E5%85%B5%E6%A8%A1%E5%BC%8F_%E9%85%8D%E7%BD%AE.md#2-redis%E9%85%8D%E7%BD%AE%E4%BF%A1%E6%81%AF)
- [3. Jedis工具类](https://github.com/vanpersl/note/blob/master/Redis/jedis/JedisSentinelPool_%E5%93%A8%E5%85%B5%E6%A8%A1%E5%BC%8F_%E9%85%8D%E7%BD%AE.md#3-jedis%E5%B7%A5%E5%85%B7%E7%B1%BB)
- [4. LeaseManager]()




# 1. Spring配置文件
```xml
<context:property-placeholder ignore-unresolvable="true" location="classpath:redis.properties" />
<bean id="poolConfig" class="redis.clients.jedis.JedisPoolConfig">
	<property name="maxTotal" value="${redis.maxTotal}" />
	<property name="minIdle" value="${redis.minIdle}" />
	<property name="maxWaitMillis" value="${redis.maxWaitTime}" />
	<property name="maxIdle" value="${redis.maxIdle}" />
	<property name="testOnBorrow" value="${redis.testOnBorrow}" />
	<property name="testOnReturn" value="true" />
	<property name="testWhileIdle" value="true" />
</bean>
<bean id="jedisSentinelPool" class="redis.clients.jedis.JedisSentinelPool">
	<constructor-arg index="0" value="mymaster" />
	<constructor-arg index="1">
		<set>
			<value>${redis.sentinel1.host}:${redis.sentinel1.port}</value>
			<value>${redis.sentinel2.host}:${redis.sentinel2.port}</value>
		</set>
	</constructor-arg>
	<constructor-arg index="2" ref="poolConfig" />
	<constructor-arg index="3" value="${redis.password}" />
</bean>
```

# 2. Redis配置信息
```bash
#sentinel1的IP和端口
redis.sentinel1.host=192.168.231.130
redis.sentinel1.port=26379
#sentinel2的IP和端口  
redis.sentinel2.host=192.168.231.130
redis.sentinel2.port=26380
redis.password=123456
 
redis.maxIdle=500
redis.maxTotal=5000
redis.maxWaitTime=1000 
redis.testOnBorrow=true
redis.minIdle=300
```
注意：这里的端口和地址都是sentinel的配置，不要用成redis的了

# 3. Jedis工具类
```Java
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.powercn.fcity.common.base.Global;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisSentinelPool;
import redis.clients.jedis.exceptions.JedisException;

public class JedisUtils {

	private static Logger logger = LoggerFactory.getLogger(JedisUtils.class);
	
//	private static JedisPool jedisPool = SpringContextHolder.getBean(JedisPool.class);
	private static JedisSentinelPool jedisPool=SpringContextHolder.getBean(JedisSentinelPool.class);;
	public static final String KEY_PREFIX = Global.getConfig("redis.keyPrefix");

	public static String get(String key) {
		String value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				value = jedis.get(key);
				value = StringUtils.isNotBlank(value) && !"nil".equalsIgnoreCase(value) ? value : null;
			}
			logger.debug("get {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("get {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}
	
	public static Set<String> keys(String pattern) {
		Set<String> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			value=jedis.keys(pattern);
			logger.debug("keys {} = {}", pattern, value);
			return value;
		} catch (Exception e) {
			logger.warn("keys {} = {}", pattern, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static Object getObject(String key) {
		Object value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				value = toObject(jedis.get(getBytesKey(key)));
				logger.debug("getObject {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getObject {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static String set(String key, String value, int cacheSeconds) {
		String result = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.set(key, value);
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("set {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("set {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static String setObject(String key, Object value, int cacheSeconds) {
		String result = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.set(getBytesKey(key), toBytes(value));
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setObject {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setObject {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static List<String> getList(String key) {
		List<String> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				value = jedis.lrange(key, 0, -1);
				logger.debug("getList {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getList {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static List<Object> getObjectList(String key) {
		List<Object> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				List<byte[]> list = jedis.lrange(getBytesKey(key), 0, -1);
				value = Lists.newArrayList();
				for (byte[] bs : list){
					value.add(toObject(bs));
				}
				logger.debug("getObjectList {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getObjectList {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static long setList(String key, List<String> value, int cacheSeconds) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				jedis.del(key);
			}
			result = jedis.rpush(key, (String[])value.toArray());
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setList {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setList {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long setObjectList(String key, List<Object> value, int cacheSeconds) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				jedis.del(key);
			}
			List<byte[]> list = Lists.newArrayList();
			for (Object o : value){
				list.add(toBytes(o));
			}
			result = jedis.rpush(getBytesKey(key), (byte[][])list.toArray());
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setObjectList {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setObjectList {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long listAdd(String key, String... value) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.rpush(key, value);
			logger.debug("listAdd {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("listAdd {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long listObjectAdd(String key, Object... value) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			List<byte[]> list = Lists.newArrayList();
			for (Object o : value){
				list.add(toBytes(o));
			}
			result = jedis.rpush(getBytesKey(key), (byte[][])list.toArray());
			logger.debug("listObjectAdd {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("listObjectAdd {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static Set<String> getSet(String key) {
		Set<String> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				value = jedis.smembers(key);
				logger.debug("getSet {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getSet {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static Set<Object> getObjectSet(String key) {
		Set<Object> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				value = Sets.newHashSet();
				Set<byte[]> set = jedis.smembers(getBytesKey(key));
				for (byte[] bs : set){
					value.add(toObject(bs));
				}
				logger.debug("getObjectSet {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getObjectSet {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static long setSet(String key, Set<String> value, int cacheSeconds) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				jedis.del(key);
			}
			result = jedis.sadd(key, (String[])value.toArray());
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setSet {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setSet {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long setObjectSet(String key, Set<Object> value, int cacheSeconds) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				jedis.del(key);
			}
			Set<byte[]> set = Sets.newHashSet();
			for (Object o : value){
				set.add(toBytes(o));
			}
			result = jedis.sadd(getBytesKey(key), (byte[][])set.toArray());
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setObjectSet {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setObjectSet {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long setSetAdd(String key, String... value) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.sadd(key, value);
			logger.debug("setSetAdd {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setSetAdd {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long setSetObjectAdd(String key, Object... value) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			Set<byte[]> set = Sets.newHashSet();
			for (Object o : value){
				set.add(toBytes(o));
			}
			result = jedis.rpush(getBytesKey(key), (byte[][])set.toArray());
			logger.debug("setSetObjectAdd {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setSetObjectAdd {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static Map<String, String> getMap(String key) {
		Map<String, String> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				value = jedis.hgetAll(key);
				logger.debug("getMap {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getMap {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static Map<String, Object> getObjectMap(String key) {
		Map<String, Object> value = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				value = Maps.newHashMap();
				Map<byte[], byte[]> map = jedis.hgetAll(getBytesKey(key));
				for (Map.Entry<byte[], byte[]> e : map.entrySet()){
					value.put(StringUtils.toString(e.getKey()), toObject(e.getValue()));
				}
				logger.debug("getObjectMap {} = {}", key, value);
			}
		} catch (Exception e) {
			logger.warn("getObjectMap {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return value;
	}

	public static String setMap(String key, Map<String, String> value, int cacheSeconds) {
		String result = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)) {
				jedis.del(key);
			}
			result = jedis.hmset(key, value);
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setMap {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setMap {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static String setObjectMap(String key, Map<String, Object> value, int cacheSeconds) {
		String result = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))) {
				jedis.del(key);
			}
			Map<byte[], byte[]> map = Maps.newHashMap();
			for (Map.Entry<String, Object> e : value.entrySet()){
				map.put(getBytesKey(e.getKey()), toBytes(e.getValue()));
			}
			result = jedis.hmset(getBytesKey(key), (Map<byte[], byte[]>)map);
			if (cacheSeconds != 0) {
				jedis.expire(key, cacheSeconds);
			}
			logger.debug("setObjectMap {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("setObjectMap {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static String mapPut(String key, Map<String, String> value) {
		String result = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.hmset(key, value);
			logger.debug("mapPut {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("mapPut {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static String mapObjectPut(String key, Map<String, Object> value) {
		String result = null;
		Jedis jedis = null;
		try {
			jedis = getResource();
			Map<byte[], byte[]> map = Maps.newHashMap();
			for (Map.Entry<String, Object> e : value.entrySet()){
				map.put(getBytesKey(e.getKey()), toBytes(e.getValue()));
			}
			result = jedis.hmset(getBytesKey(key), (Map<byte[], byte[]>)map);
			logger.debug("mapObjectPut {} = {}", key, value);
		} catch (Exception e) {
			logger.warn("mapObjectPut {} = {}", key, value, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long mapRemove(String key, String mapKey) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.hdel(key, mapKey);
			logger.debug("mapRemove {}  {}", key, mapKey);
		} catch (Exception e) {
			logger.warn("mapRemove {}  {}", key, mapKey, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long mapObjectRemove(String key, String mapKey) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.hdel(getBytesKey(key), getBytesKey(mapKey));
			logger.debug("mapObjectRemove {}  {}", key, mapKey);
		} catch (Exception e) {
			logger.warn("mapObjectRemove {}  {}", key, mapKey, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static boolean mapExists(String key, String mapKey) {
		boolean result = false;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.hexists(key, mapKey);
			logger.debug("mapExists {}  {}", key, mapKey);
		} catch (Exception e) {
			logger.warn("mapExists {}  {}", key, mapKey, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static boolean mapObjectExists(String key, String mapKey) {
		boolean result = false;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.hexists(getBytesKey(key), getBytesKey(mapKey));
			logger.debug("mapObjectExists {}  {}", key, mapKey);
		} catch (Exception e) {
			logger.warn("mapObjectExists {}  {}", key, mapKey, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long del(String key) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(key)){
				result = jedis.del(key);
				logger.debug("del {}", key);
			}else{
				logger.debug("del {} not exists", key);
			}
		} catch (Exception e) {
			logger.warn("del {}", key, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static long delObject(String key) {
		long result = 0;
		Jedis jedis = null;
		try {
			jedis = getResource();
			if (jedis.exists(getBytesKey(key))){
				result = jedis.del(getBytesKey(key));
				logger.debug("delObject {}", key);
			}else{
				logger.debug("delObject {} not exists", key);
			}
		} catch (Exception e) {
			logger.warn("delObject {}", key, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static boolean exists(String key) {
		boolean result = false;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.exists(key);
			logger.debug("exists {}---{}", key,result);
		} catch (Exception e) {
			logger.warn("exists {}", key, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static boolean existsObject(String key) {
		boolean result = false;
		Jedis jedis = null;
		try {
			jedis = getResource();
			result = jedis.exists(getBytesKey(key));
			logger.debug("existsObject {}", key);
		} catch (Exception e) {
			logger.warn("existsObject {}", key, e);
		} finally {
			returnResource(jedis);
		}
		return result;
	}

	public static Jedis getResource() throws JedisException {
		Jedis jedis = null;
		try {
			jedis = jedisPool.getResource();
//			logger.debug("getResource.", jedis);
		} catch (JedisException e) {
			logger.warn("getResource.", e);
			returnBrokenResource(jedis);
			throw e;
		}
		return jedis;
	}

	public static void returnBrokenResource(Jedis jedis) {
		if (jedis != null) {
			jedisPool.returnBrokenResource(jedis);
		}
	}

	public static void returnResource(Jedis jedis) {
		if (jedis != null) {
			jedisPool.returnResource(jedis);
		}
	}

	public static byte[] getBytesKey(Object object){
		if(object instanceof String){
    		return StringUtils.getBytes((String)object);
    	}else{
    		return ObjectUtils.serialize(object);
    	}
	}

	public static byte[] toBytes(Object object){
    	return ObjectUtils.serialize(object);
	}

	public static Object toObject(byte[] bytes){
		return ObjectUtils.unserialize(bytes);
	}

}
```
实际上需要调整的部分并不多，只需要将JedisPool换成JedisSentinelPool，其他操作部分基本可以不变。
