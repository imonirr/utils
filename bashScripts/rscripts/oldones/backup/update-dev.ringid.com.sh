#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color]'

LOGFILE="$HOME/Scripts/logs/pushRingToDev.log"
projectDir="$HOME/Projects/ringIDWeb"
defaultBranch="master"
developBranch="develop"
useRepo=${1:-$defaultBranch}

src="$HOME/Projects/ringIDWeb/webapp/"
destination="ringdev:/var/www/html"

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
#echo -e "${PURPLE}Create & Checkout${NC} Branch ${GREEN} ${releaseBranch} ${NC}" | tee -a $LOGFILE 
#git checkout -b $releaseBranch $developBranch


#6 Prepare for production
# change website address
#echo -e "${PURPLE}Set Server${NC} to ${GREEN} dev.ringid.com ${NC}" | tee -a $LOGFILE
#sed -i 's/localhost:8080/dev.ringid.com/' $projectDir/webapp/app/config/settings.constant.js
# remove digest debug
find ${projectDir}/webapp/app -type f -name '*.js' -exec grep -l 'DIGEST_DEBUG_START' {} \; | xargs sed -i -e '/DIGEST_DEBUG_START/,/DIGEST_DEBUG_END/d' 
# change http to https
# change http to https
sed -i -e 's/http:/https:/' $projectDir/webapp/app/config/settings.constant.js
sed -i -e 's/http:/https:/' $projectDir/webapp/index.html
sed -i -e 's/http:/https:/' $projectDir/webapp/faq.html
sed -i -e 's/http:/https:/' $projectDir/webapp/faq-mobile.html
sed -i -e 's/http:/https:/' $projectDir/webapp/privacy.html
sed -i -e 's/http:/https:/' $projectDir/webapp/privacy-mobile.html
sed -i -e 's/http:/https:/' $projectDir/webapp/terms.html
sed -i -e 's/http:/https:/' $projectDir/webapp/home.html
sed -i -e 's/http:/https:/' $projectDir/webapp/not-found.html
### change ws to wss
sed -i -e 's/ws:/wss:/' $projectDir/webapp/app/config/settings.constant.js

# remove api.dashboard dependency from main module
sed -i -e '/ringid.api.dashboard/d' $projectDir/webapp/app/app.module.js

#7 remove ringlogger
echo -e "${PURPLE}Remove ${NC} ${GREEN} RingLogger ${NC}" | tee -a $LOGFILE
cd $projectDir/webapp/app
find -type f -name "*.js" -exec sed -i '/RingLogger/d' {} +

#8 Run build script
echo -e "Move to webapp and ${PURPLE}Grunt ${NC} ${GREEN} Build ${NC}" | tee -a $LOGFILE
cd $projectDir/webapp
grunt build

# uglify custom uglifier
echo -e "RUNNING CUSTOM UGLIFIER" | tee -a $LOGFILE
ruby ~/Scripts/uglify.rb "$projectDir/webapp/js/app.min.js"

#synch repo from local to remote
echo -e "${PURPLE}Synch${NC} Local ${GREEN} $src ${NC} to ${RED} $destination ${NC}" | tee -a $LOGFILE
rsync -avzP --no-g --no-o --delete --exclude-from "$HOME/Scripts/assets/exclude-files.txt" $src $destination  | tee -a $LOGFILE

# end logging
echo "`date +%H:%M:%S` : ^^^^^^^^^^^^^End Work^^^^^^^^^^^^^^^" | tee -a $LOGFILE
echo " " | tee -a $LOGFILE
