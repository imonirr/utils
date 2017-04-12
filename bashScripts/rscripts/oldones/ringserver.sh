#! /bin/bash

#serverDir="$HOME/Assets/UDP/UDPServer/dist/"
#loadbalancerDir="$HOME/Assets/UDP/loadbalancer/dist/"

#serverdir="$HOME/Projects/UDPServer/"
#loadbalancerdir="$HOME/Projects/loadbalancer/dist/"
#0 kill all previous instance of the server
#sudo killall java

#9 start ringserver
#cd $HOME/Projects/
#ant -f UDPServer -Dnb.internal.action.name=rebuild clean jar
#echo 'Starting UDPServer'
#cd $serverdir
#java -jar dist/UDPServer.jar </dev/null &>/dev/null &
#java -Xmx1000m -jar dist/UDPServer.jar </dev/null &>/dev/null &
#echo 'Starting Loadbalancer'
#cd $loadbalancerdir
#java -Xmx1000m -jar LoadbalancerForUDPServer.jar </dev/null &>/dev/null &
RING_SERVER_HOME="$HOME/Projects/UDPServer"


LOAD_BALANCER_HOME="$HOME/Projects/loadbalancer"

LOAD_BALANCER="ant -f $LOAD_BALANCER_HOME/ -Dnb.internal.action.name=run run"
RING_SERVER="ant -f $RING_SERVER_HOME/ -Dnb.internal.action.name=run run"


$RING_SERVER < /dev/null &> /dev/null &

$LOAD_BALANCER < /dev/null &> /dev/null &






