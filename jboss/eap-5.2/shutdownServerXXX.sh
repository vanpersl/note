#!/bin/bash

name=$(id |awk -F'[()]' '{print $2}')
if [ a${name} = aroot ]
then
echo "This please do not start/shutdown server using Root!!"
exit
fi

servName=ServerXXX

scriptName=`basename $0`

dirPath=`dirname $0`

cd $dirPath


Log="../log/shutdown_"$servName"_"`date +%Y%m%d%H%M`".log"


echo -e "--------------------The script of $0 is running.--------------------"|tee -a $Log
echo -e "----------------------------`date`-------------------------\n"|tee -a $Log

pid=`ps -ef|grep $servName|grep java |grep classpath|awk '{print $2}'`

for((i=1;i<5;i++));do

	pid=`ps -ef|grep $servName|grep java |grep classpath|awk '{print $2}'`
	if [[ "a" != "a${pid}" ]]
	then
	  if [ $i -eq 4 ]
		then
			echo -e "The server of $servName whose pid is $pid is still running, will be killed  ."|tee -a $Log
			echo -e "ps -ef | grep "jboss[^0-9]*${pid}" | awk '{print "kill -9", $2}' | sh\n"
			ps -ef | grep "jboss[^0-9]*${pid}" | awk '{print "kill -9", $2}' | sh
			sleep 3
	  fi
	  if [ $i -lt 4 ]
		then
			echo -e "The server of $servName whose pid is $pid will be shutdown for $i time."|tee -a $Log
			echo -e "ps -ef | grep jboss[^0-9]*${pid} | awk {print kill,$2} | sh\n"
			ps -ef | grep "jboss[^0-9]*${pid}" | awk '{print "kill",$2}' | sh
			echo -e "Sleep 15 secs\n" |tee -a $Log
			sleep 15
	  fi		
	else
        echo -e "The $servName is not running!\n" |tee -a $Log
        break
	fi
done

echo -e "The stopping of $servName is finished.\n"|tee -a $Log
echo -e "--------------------------------`date`-------------------------------"|tee -a $Log
echo -e "--------------------The script of $0 is finished.--------------------\n\n"|tee -a $Log
