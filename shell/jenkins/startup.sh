#!/bin/bash

app_root_path=$1
app_name=$2
app_port=$3
profile=$4

cd $app_root_path

chmod 755 $app_root_path/$app_name.jar

echo "---->>>begin startup service..."

nohup java -Xmx1024m -Xms1024m -Xmn2000m -jar $app_name.jar --spring.profiles.active=$profile --server.port=$app_port >$app_file_name.log 2>&1 &

pid=`ps aux|grep $app_name|grep -v grep|grep -v startup.sh|grep -v startup.sh|grep $app_port|awk '{print $app_port}'`

echo "---->>>started service pid is:"$pid

if [ -n "$pid" ];then
        echo "---->>>find pid is:"$pid
        echo "---->>>started service sucess."
        exit 0
fi
echo "---->>>can't find service，startup service failed"
exit 500
