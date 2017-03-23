#! /bin/bash

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color]'

# paths
cd $(dirname $0)/..
projectRoot=$(pwd)
RING_SERVER_HOME="${projectRoot}/servers/UDPServer/" 
serverConfig="${projectRoot}/servers/UDPServer/config.xml"
LOAD_BALANCER_HOME="${projectRoot}/servers/Loadbalancer/"

# LOAD_BALANCER="ant -f $LOAD_BALANCER_HOME/ -Dnb.internal.action.name=run run"
# RING_SERVER="ant -f $RING_SERVER_HOME/ -Dnb.internal.action.name=run run"
LOAD_BALANCER="cd ${LOAD_BALANCER_HOME} && sudo java -jar Loadbalancer.jar < /dev/null &> /dev/null &"
RING_SERVER="cd ${RING_SERVER_HOME} && java -Dlog4j.configurationFile=log4j2.xml -jar UDPServer.jar < /dev/null &> /dev/null &"

function runServers {
    echo -e "${PURPLE}Killing ${NC} all ${GREEN} Java ${NC} process"
    sudo killall java

    cd $LOAD_BALANCER_HOME && sudo java -jar Loadbalancer.jar < /dev/null &> /dev/null &
    echo -e "${GREEN}Start LoadBalancer: ${NC} ${PURPLE} $LOAD_BALANCER ${NC}"
    ranSuccessfully

    echo -e "${GREEN}Start UDPServer: ${NC} ${PURPLE} $RING_SERVER ${NC}"
    cd $RING_SERVER_HOME && java -Dlog4j.configurationFile=log4j2.xml -jar UDPServer.jar < /dev/null &> /dev/null &
    ranSuccessfully
}

function ranSuccessfully {
    pid=$! #stores executed process id in pid
    count=$(ps -A| grep $pid |wc -l) #check whether process is still running
    if [[ $count -eq 0 ]] #if process is already terminated, then there can be two cases, the process executed and stop successfully or it is terminated abnormally
    then
            if wait $pid; then #checks if process executed successfully or not
                    echo -e "${GREEN}SUCCESS${NC}"
            else                    #process terminated abnormally
                    echo -e "${RED}FAILED${NC} (returned $?)"
            fi
    else
            echo -e "${GREEN}SUCCESS${NC}"  #process is still running
    fi
}



if type -p java; then
    echo -e "Java executable in ${GREEN}PATH${NC}"
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo -e "Java executable in ${GREEN}${JAVA_HOME}${NC}"
    _java="$JAVA_HOME/bin/java"
else
    echo -e "no ${RED}Java${NC}"
fi

if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo -e "Version ${GREEN}$version${NC}"
    if [ ! -f "$serverConfig" ]; then
        echo -e "${RED}ERROR${NC} ${PURPLE} $serverConfig ${NC} not found use ${GREEN} $serverConfig.dist ${NC}"
    else
        runServers
    fi
fi
