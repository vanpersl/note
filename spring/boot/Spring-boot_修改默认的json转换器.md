title: SpringBoot使用FastJson
date: 2018-03-27
tags:
categories: SpringBoot
permalink: xxx

阿里巴巴FastJson是一个Json处理工具包，包括“序列化”和“反序列化”两部分，它具备如下特征： 
速度最快，测试表明，fastjson具有极快的性能，超越任其他的Java Json parser。包括自称最快的JackJson； 
功能强大，完全支持Java Bean、集合、Map、日期、Enum，支持范型，支持自省；无依赖，能够直接运行在Java SE 5.0以上版本；支持Android；开源 (Apache 2.0)

另外一点，SpringBoot默认json转换器为Jackson

---

摘要: 原创出处 https://blog.csdn.net/gelusheng123456/article/details/79683090 「note」欢迎转载，保留摘要，谢谢！

**本文主要基于 Spring boot 2.0.0* 版本** 

- [1. 依赖](https://github.com/vanpersl/note/blob/master/Spring/boot/Spring-boot_%E4%BF%AE%E6%94%B9%E9%BB%98%E8%AE%A4%E7%9A%84json%E8%BD%AC%E6%8D%A2%E5%99%A8.md#1-%E4%BE%9D%E8%B5%96)
- [2. 修改默认转换器](
https://github.com/vanpersl/note/blob/master/Spring/boot/Spring-boot_%E4%BF%AE%E6%94%B9%E9%BB%98%E8%AE%A4%E7%9A%84json%E8%BD%AC%E6%8D%A2%E5%99%A8.md#2-%E6%A0%B9%E6%8D%AE%E7%B4%A2%E5%BC%95index%E6%B3%A8%E5%85%A5)


```xml
    <bean id="employee" class="www.csdn.spring.cust.Employee">  
        <constructor-arg value="qiao" />  
        <constructor-arg value="20" />  
        <constructor-arg ref="dept" />  
        <constructor-arg value="nv" />  
    </bean>  
```

下面的是常用的spring构造函数的注入方式
# 1. 依赖
```xml
<!-- fastjson -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.15</version>
</dependency>
```

# 2. 修改默认转换器

```Java
package cn.aduu.config;

import com.alibaba.fastjson.serializer.SerializerFeature;
import com.alibaba.fastjson.support.config.FastJsonConfig;
import com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

import java.util.ArrayList;
import java.util.List;

/**
 * @author zh
 * @ClassName cn.aduu.config.FastJsonConfiguration
 * @Description
 */
@Configuration
public class FastJsonConfiguration extends WebMvcConfigurerAdapter {

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        FastJsonHttpMessageConverter fastConverter = new FastJsonHttpMessageConverter();
        FastJsonConfig fastJsonConfig = new FastJsonConfig();
        fastJsonConfig.setSerializerFeatures(SerializerFeature.PrettyFormat);
        //处理中文乱码问题
        List<MediaType> fastMediaTypes = new ArrayList<>();
        fastMediaTypes.add(MediaType.APPLICATION_JSON_UTF8);
        fastConverter.setSupportedMediaTypes(fastMediaTypes);
        fastConverter.setFastJsonConfig(fastJsonConfig);
        converters.add(fastConverter);
    }

}
```
