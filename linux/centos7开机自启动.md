```
1. chmod +x /etc/rc.d/rc.local
2. 将命令写到 /etc/rc.d/rc.local 这个文件中
3. reboot
```

添加开机自启脚本

在centos7中增加脚本有两种常用的方法，以脚本autostart.sh为例：
\#!/bin/bash
\#description:开机自启脚本
/usr/local/tomcat/bin/startup.sh #启动tomcat

方法一

1、赋予脚本可执行权限（/opt/script/autostart.sh是你的脚本路径）
chmod +x /opt/script/autostart.sh

2、打开/etc/rc.d/rc.local或/etc/rc.local文件，在末尾增加如下内容
su - user -c '/opt/script/autostart.sh'

3、在centos7中，/etc/rc.d/rc.local的权限被降低了，所以需要执行如下命令赋予其可执行权限
chmod +x /etc/rc.d/rc.local

方法二

1、将脚本移动到/etc/rc.d/init.d目录下
mv /opt/script/autostart.sh /etc/rc.d/init.d

2、增加脚本的可执行权限
chmod +x /etc/rc.d/init.d/autostart.sh

3、添加脚本到开机自动启动项目中
cd /etc/rc.d/init.d
chkconfig --add autostart.sh
chkconfig autostart.sh on