#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color]'

projectDir="$HOME/Projects/gitserver"
serverDir="$HOME/Projects/UDPServer"
developBranch="develop"

#0 kill all previous instance of the server
sudo killall java
sh ringserver.sh

#1 go to project dir
echo - "`date +%H:%M:%S` : ###############${GREEN}Updating server at http://192.168.1.117:8888${NC}########" 
echo -e "${PURPLE}Moving${NC} to ${GREEN} $projectDir ${NC}" 
cd $projectDir 

##2 checkout specified branch
echo -e "${PURPLE}Checkout${NC} Branch ${GREEN} $developBranch ${NC}" 
git checkout -f $developBranch 

##3 discard any local changes to the branch
git reset --hard origin/$developBranch

##4 Take latest pull
echo -e "${PURPLE}Pulling${NC} Latest Changes for Branch ${GREEN} $developBranch ${NC}" 
git pull origin $developBranch 


##6 change website address
echo -e "${PURPLE}Build Start${NC}" 
sed -i 's/localhost:8080/192.168.1.117:8888/' $projectDir/webapp/app/config/settings.constant.js

# create developer.config.js
echo -e "${GREEN}Enable Debugging${NC}" 
cp $projectDir/webapp/app/developer.config.dist.js $projectDir/webapp/app/developer.config.js
# enable all logging
sed -i 's/false/true/' $projectDir/webapp/app/developer.config.js
echo -e "${PURPLE}Build End${NC}" 

##8 Run dev script
cd $projectDir/webapp
npm install 
grunt stage

##9 generate new apidoc
npm run-script docgen
echo -e "${PURPLE}Install npm packages and Generate APIDoc${NC}" 
echo -e "`date +%H:%M:%S` : ^^^^^^^^^^^^^${GREEN}End Work${NC}^^^^^^^^^^^^^^^" 




