
#!/bin/bash

app_name=$1

pid=`ps aux|grep $app_name|grep -v grep|awk '{print $2}'`

echo "---->>>pid:"$pid

if [ -n "$pid" ];then
        echo "---->>>find pid:"$pid
        echo "---->>>kill pid:"$pid
        kill -9 $pid
        exit 0
fi

echo "---->>>can't find pid, stop failed"
