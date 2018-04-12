JBOSS_HOME=/opt/app/jboss-eap-5.2/jboss-as
JAVA_HOME=/opt/app/jboss-eap-5.2/jdk1.6.0_22
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME
export PATH
export CLASSPATH
export JBOSS_HOME
name=$(id |awk -F'[()]' '{print $2}')

if [ a${name} = aroot ]
then
        echo "This please do not using Root start/stop server!!"
        exit
fi
SER_PATH=$(dirname $0)
if [ ${SER_PATH:0:1} == . ]
then
SER_PATH=${SER_PATH/./$(pwd)}
fi
if [ -x "$SER_PATH" ]; then
echo "rm -rf $SER_PATH/../tmp/*"
rm -rf $SER_PATH/../tmp/*
echo "rm -rf $SER_PATH/../data/*"
rm -rf $SER_PATH/../data/*
echo "rm -rf $SER_PATH/../work/*"
rm -rf $SER_PATH/../work/*
fi
nohup /opt/app/jboss-eap-5.2/jboss-as/bin/run.sh -c ServerXXX -g xxxcluster -Djava.awt.headless=true -Djboss.service.binding.set=ports-01 -b 127.0.0.1  -Djava.rmi.server.hostname=127.0.0.1 -Dremoting.bind_by_host=false -Djboss.messaging.ServerPeerID=3 -Djboss.default.jgroups.stack=tcp -Dorg.jboss.logging.provider=slf4j -Djboss.mod_cluster.proxyList=  > /opt/app/jboss-eap-5.2/jboss-as/server/ServerXXX/bin/startServer.log &
