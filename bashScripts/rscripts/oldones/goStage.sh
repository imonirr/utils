#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color]'

projectDir="$HOME/Projects/ringstage"
defaultBranch="stage"
#useRepo=${1:-$defaultBranch}
#gruntTask=${1:-$defaultBranch}

src="$projectDir/public/ringid.com/"
destination="ringdev:/var/www/pro.ringid.com"

echo " " | tee -a $LOGFILE
echo "`date +%H:%M:%S` : ###############Starting Work########" 

#1 go to project dir
echo -e "${PURPLE}Moving${NC} to ${GREEN} $projectDir ${NC}" 
cd $projectDir

#2 checkout specified branch
echo -e "${PURPLE}Checkout${NC} Branch ${GREEN} $defaultBranch ${NC}" 
git fetch 
git checkout -f stage

#3 discard any local changes to the branch
echo -e "${PURPLE}Reset${NC} Branch ${GREEN} $defaultBranch ${NC} to HEAD Discard local changes"
git reset --hard origin/stage
git clean -d -f

#4 Take latest pull
echo -e "${PURPLE}Pulling${NC} Latest Changes for Branch ${GREEN} $defaultBranch ${NC}" 
git pull origin stage

#npm install
grunt stage && \
#synch repo from local to remote
echo -e "${PURPLE}Synch${NC} Local ${GREEN} $src ${NC} to ${RED} $destination ${NC}"  && \
rsync -avzP --no-g --no-o --delete --exclude-from "$HOME/Projects/Scripts/assets/exclude-files.txt" $src $destination  

# end logging
echo "`date +%H:%M:%S` : ^^^^^^^^^^^^^End Work^^^^^^^^^^^^^^^" 
