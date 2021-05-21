#!/bin/bash

shell_root_path=/home/user/
app_name=ball-buyer
app_root_path=/opt/apps
app_root_name=ball-buyer-backend
server_ip=192.168.1.2


mvn clean package -DskipTests

echo "停止服务..."
ssh root@server_ip "sh $shell_root_path/shutdown.sh $app_name"


echo "上传jar包..."
scp target/$app_name-1.0.0-SNAPSHOT.jar root@server_ip:$app_root_path/$app_root_name

echo "重命名jar包..."
ssh root@server_ip "mv -f $app_root_path/$app_root_name/$app_name-1.0.0-SNAPSHOT.jar $app_root_path/$app_root_name/$app_name.jar"

echo "启动服务..."
ssh root@server_ip "sh $shell_root_path/startup.sh $app_root_path/$app_root_name $app_name '8090' 'dev'"
