#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color]'

LOGFILE="$HOME/Scripts/pushRingToDev.log"
projectDir="$HOME/Projects/ringIDWeb"
defaultBranch="master"
developBranch="develop"
useRepo=${1:-$defaultBranch}

src="$HOME/Projects/ringIDWeb/webapp/"
destination="ringdev:/var/www/html"

#start logging
echo " " | tee -a $LOGFILE
echo "`date +%H:%M:%S` : ###############Starting Work########" | tee -a $LOGFILE

#1 go to project dir
echo -e "${PURPLE}Moving${NC} to ${GREEN} $projectDir ${NC}" | tee -a $LOGFILE
cd $projectDir >> $LOGFILE

#2 checkout specified branch
echo -e "${PURPLE}Checkout${NC} Branch ${GREEN} $developBranch ${NC}" | tee -a $LOGFILE
git checkout $developBranch | tee -a $LOGFILE

#3 discard any local changes to the branch
echo -e "${PURPLE}Reset${NC} Branch ${GREEN} $developBranch ${NC} to HEAD Discard local changes" | tee -a $LOGFILE
git reset --hard origin/$developBranch

#4 Take latest pull
echo -e "${PURPLE}Pulling${NC} Latest Changes for Branch ${GREEN} $developBranch ${NC}" | tee -a $LOGFILE
git pull origin $developBranch | tee -a $LOGFILE


#5 create release branch
appVersion="$(grep  "appVersion\s=\s'\([0-9\.]*\)';" ${projectDir}/webapp/Gruntfile.js | sed "s/var\sappVersion\s=\s'\([0-9\.]*\)';/\1/"  | xargs)"
releaseBranch='release-'$appVersion
echo -e "${PURPLE}Create & Checkout${NC} Branch ${GREEN} ${releaseBranch} ${NC}" | tee -a $LOGFILE 
git checkout -b $releaseBranch $developBranch



#6 Prepare for production
echo -e "${PURPLE}Set Server${NC} to ${GREEN} dev.ringid.com ${NC}" | tee -a $LOGFILE
sed -i 's/localhost:8080/dev.ringid.com/' $projectDir/webapp/app/config/settings.constant.js

#7 Run build script
echo -e "Move to webapp and ${PURPLE}Grunt ${NC} ${GREEN} Build ${NC}" | tee -a $LOGFILE
cd $projectDir/webapp
grunt build

#8 commit build version to release branch 
echo -e "${PURPLE}Commit ${NC} build to ${GREEN} ${releaseBranch} ${NC}" | tee -a $LOGFILE
cd $projectDir
git add .
git commit -m "Build Version:${appVersion}"


#9 Merge release branch to master
echo -e "${PURPLE}Merge  ${NC} ${GREEN} $releaseBranch ${NC} to ${GREEN} ${defaultBranch} ${NC}" | tee -a $LOGFILE
git checkout $defaultBranch
git merge -Xtheirs $releaseBranch


#10 Tag Release branch
echo -e "${PURPLE}Tag${NC} Release ${GREEN} ${appVersion} ${NC}" | tee -a $LOGFILE
git tag $releaseBranch 


#11 push production ready master to server
echo -e "${PURPLE}Push ${NC} ${GREEN} ${NC}  branch ${GREEN} ${defaultBranch} ${NC} to git server" | tee -a $LOGFILE
git push origin $defaultBranch

#synch repo from local to remote
echo -e "${PURPLE}Synch${NC} Local ${GREEN} $src ${NC} to ${RED} $destination ${NC}" | tee -a $LOGFILE
rsync -avzP --no-g --no-o --delete --exclude-from "$HOME/Scripts/exclude-files.txt" $src $destination  | tee -a $LOGFILE

# end logging
echo "`date +%H:%M:%S` : ^^^^^^^^^^^^^End Work^^^^^^^^^^^^^^^" | tee -a $LOGFILE
echo " " | tee -a $LOGFILE
