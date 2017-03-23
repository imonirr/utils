#! /bin/bash

projectDir="$HOME/Projects/ringIDWeb"
serverDir="$HOME/Projects/UDPServer/dist/"
loadbalancerDir="$HOME/Projects/loadbalancer/dist/"

#0 kill all previous instance of the server
sudo killall java

#9 start ringserver
#cd $HOME/Projects/
#ant -f UDPServer -Dnb.internal.action.name=rebuild clean jar
cd $serverDir
#java -jar dist/UDPServer.jar </dev/null &>/dev/null &
java -Xmx1000m -jar UDPServer.jar </dev/null &>/dev/null &

cd $loadbalancerDir
java -Xmx1000m -jar LoadbalancerForUDPServer.jar </dev/null &>/dev/null &



