1.启动服务命令

startup.sh

```shell
#!/bin/bash

app_file_name=$1
path=/opt/apps/env/$1
app_port=$2
profile=$3

cd $path

chmod 755 $1.jar

echo "---->>>开始启动服务"

nohup /opt/app/jdk1.8.0_240/bin/java -Xmx1024m -Xms1024m -Xmn2000m -jar $app_file_name.jar --spring.profiles.active=$profile --server.port=$app_port >$app_file_name.log 2>&1 &

pird=`ps aux|grep $app_file_name|grep -v grep|grep -v build.sh|grep -v startup.sh|grep $app_port|awk '{print $app_port}'`

echo "---->>>启动的服务pid:"$pird

if [ -n "$pird" ];then
        echo "----找到启动服务----:"$pird
        echo "---->>>启动成功"
        exit 0
fi
echo "---->>>未找到服务，启动失败"
exit 500

```

2.停止服务命令

```shell
#!/bin/bash

app_name=$1
path=/opt/apps/env/$1

if [ ! -d $path ];then
        echo "---->>>应用根目录不存在！新建应用根目录！"
        mkdir $path
        chmod -R 755 $path
fi

pird=`ps aux|grep $app_name|grep -v grep|awk '{print $2}'`

echo "---->>>pird:"$pird

if [ -n "$pird" ];then
        echo "---->>>找到启动的服务:"$pird
        kill -9 $pird
fi

echo "---->>>将原文件删除"

rm -rf $path/$app_name.jar

```

日志输出

```shell
# 输出到标准输出
 >> system.out.log &
# 输出到黑洞
  >/dev/null 2>&1 &
```

