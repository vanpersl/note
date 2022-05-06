自动装配，简单来说就是自动把第三方组件的Bean装载到Spring IOC器里面，不需要开发人员再去写Bean的装配配置。

在Spring Boot应用里面，只需要在启动类加上@SpringBootApplication注解就可以实现自动装配。

@SpringBootApplication是一个复合注解，真正实现自动装配的注解是@EnableAutoConfiguration。

![「面试普通人VS高手系列」Spring Boot中自动装配机制的原理](https://p6.toutiaoimg.com/origin/tos-cn-i-qvj2lq49k0/abcc56c2ab7e4dbcb6c265293d8c64d1?from=pc)



自动装配的实现主要依靠三个核心关键技术。

1. 引入Starter启动依赖组件的时候，这个组件里面必须要包含@Configuration配置类，在这个配置类里面通过@Bean注解声明需要装配到IOC容器的Bean对象。
2. 这个配置类是放在第三方的jar包里面，然后通过SpringBoot中的约定优于配置思想，把这个配置类的全路径放在classpath:/META-INF/spring.factories文件中。这样SpringBoot就可以知道第三方jar包里面的配置类的位置，这个步骤主要是用到了Spring里面的SpringFactoriesLoader来完成的。
3. SpringBoot拿到所第三方jar包里面声明的配置类以后，再通过Spring提供的ImportSelector接口，实现对这些配置类的动态加载。

在我看来，SpringBoot是约定优于配置这一理念下的产物，所以在很多的地方，都会看到这类的思想。它的出现，让开发人员更加聚焦在了业务代码的编写上，而不需要去关心和业务无关的配置。

其实，自动装配的思想，在SpringFramework3.x版本里面的@Enable注解，就有了实现的雏形。@Enable注解是模块驱动的意思，我们只需要增加某个@Enable注解，就自动打开某个功能，而不需要针对这个功能去做Bean的配置，@Enable底层也是帮我们去自动完成这个模块相关Bean的注入。

以上，就是我对Spring Boot自动装配机制的理解。