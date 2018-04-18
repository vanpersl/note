
目录
- [1、创建目录]()
- [2、创建jboss账户]()
- [3、上传jboss安装包]()
- [4、创建server]()
 
先使用root账户登录目标服务器

# 1、创建目录
 

```sh
# 创建jboss安装目录、日志文件输出目录
mkdir /opt/app
mkdir /opt/applog
# 目录授权
chmod -Rv 774 /opt/app
chmod -Rv 774 /opt/applog
```

# 2、创建jboss账户
 
```sh
# 创建jboss用户
useradd jboss
#修改jboss的用户密码
passwd jboss
```


# 3、上传jboss安装包
 

在上传jboss包前需要将jboss-eap-5.2.zip这个安装包上传到127.0.0.1的/opt/app目录下，然后在127.0.0.1执行上传指令

```sh
# 上传包至127.0.0.2的/opt/app目录
scp /opt/app/jboss-eap-5.2.zip root@127.0.0.2:/opt/app
```

在127.0.0.2执行如下指令
```sh
# 进入/opt/app目录
cd /opt/app
# 切换到jboss用户
su jboss
# 解压安装包
unzip jboss-eap-5.2.zip
```

# 4、创建server
 
```sh
# 进入server目录
cd /opt/app/jboss-eap-5.2/jboss-as/server/
# 将安装包里自带的server改成目标server的名称
mv ServerXXX ServerXX2
 ```

# 5、相关目录授权
 
```sh
# 切换到root账号
su root
# 目录授权
chmod -Rv 774 /opt/app/
chmod -Rv 774 /opt/applog/
chmod -Rv 774 /opt/app/jboss-eap-5.2/jdk1.6.0_22/
chmod -Rv 774 /opt/app/jboss-eap-5.2/jdk1.6.0_43/
chmod -Rv 774 /opt/app/jboss-eap-5.2/jboss-as/
```

# 6、修改start/shutdown脚本
 

路径为：/opt/app/jboss-eap-5.2/jboss-as/server/ServerXX2/bin/

shutdownServerXX2.sh
startServerXX2.sh

# 7、修改log4j配置
 

路径为：/opt/app/jboss-eap-5.2/jboss-as/server/ServerXX2/conf/

jboss-log4j.xml


# 8、测试server是否配置成功
 
```sh
# 切换到jboss用户
su jboss
# 执行启动脚本
sh /opt/app/jboss-eap-5.2/jboss-as/server/ServerXX2/bin/startServerXX2.sh
# 查看启动日志
tail -f /opt/applog/ServerXX2/server.log
```
观察日志中是否有异常信息，如果启动正常则表示server安装配置成功。
