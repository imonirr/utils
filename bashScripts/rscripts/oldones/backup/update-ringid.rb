#! /usr/bin/env ruby
require './build-methods.rb'

# DEFAULTS
# HANDLE USER INPUTS
_TARGET =  (ARGV[0] ? ARGV[0] : 'dev')
puts "\nUpdating default target: ".yellow + _TARGET.blue 
TARGET = prompt(_TARGET,  "To select default just press ENTER or your desired TARGET(dev/live): ".yellow)

_PROTOCOL = (ARGV[1] ? ARGV[1] : 'ssl')
puts "\nUpdating default PROTOCOL!: ".yellow + _PROTOCOL.blue 
PROTOCOL = prompt(_PROTOCOL, "To select default just press ENTER or your desired PROTOCOL(ssl/nonssl): ".yellow)

#_APIVERSION = (ARGV[2] ? ARGV[2] : (TARGET == 'live' ? '138': '139'))
_APIVERSION = (TARGET == 'live') ? '140' : '141'
puts "\nUpdating default APIVERSION: ".yellow + _APIVERSION.blue 
APIVERSION = prompt(_APIVERSION, "To select default just press ENTER or your desired APIVERSION(140/141): ".yellow)

_TASK = (ARGV[3] ? ARGV[3] : (TARGET == 'live' ? 'build': 'stage'))
puts "\nUpdating default Grunt TASK: ".yellow + _TASK.blue 
TASK = prompt(_TASK, "To select default just press ENTER or your desired TASK(dev/stage/build): ".yellow)

_BRANCH = (ARGV[4] ? ARGV[4] : 'develop')
puts "\nUpdating default branch: ".yellow + _BRANCH.blue 
BRANCH = prompt(_BRANCH, "To select default just press ENTER or your desired branch(develop/worker_st): ".yellow)

puts "SELECTED: ".light_blue
puts "TARGET: ".light_blue + TARGET.green
puts "PROTOCOL: ".light_blue + PROTOCOL.to_s.green 
puts "APIVERSION: ".light_blue + APIVERSION.to_s.green 
puts "Grunt TASK: ".light_blue + TASK.green + "\n"
puts "BRANCH: ".light_blue + BRANCH.green + "\n\n"

projectDir = Dir.home + "/Projects/" + (TARGET === 'live' ? 'ringlive' : 'ringdev')
scriptsDir = Dir.home + "/Projects/Scripts/"
updating = (PROTOCOL == 'ssl' ? 'https://' : 'http:/' ) + (TARGET == 'live' ? 'www.ringid.com' : 'dev.ringid.com')
puts  ("###############  UPDATING : ".light_blue + updating.green + "  at:".light_blue + Time.now.strftime("%m/%d/%Y %H:%M").light_blue  +  "  ########".light_blue)

#1 go to project dir
puts "\n1# Moving to ".light_blue + "#{projectDir}".green + " Directory".light_blue
Dir.chdir(projectDir)

##2 checkout specified branch
puts "\n2# Take Latest code from branch: ".light_blue + " #{BRANCH}".green 
latestBranch(BRANCH) 

##3 create release branch
#puts "\n3# UPDATE API VERSION AND APP VERSION: ".light_blue 
puts "\n3# BUILD CODE for ".light_blue  + "#{TARGET}".green
appVersion = updateAppVersion(projectDir, APIVERSION)

# FIX API URL NO MORE NEEDED. using Auth api call to set
if (TARGET == 'live')
  ## fix api url
  fixAPIUrls(projectDir)
  releaseBranch='release-' + appVersion + '-at-TIME=' +  Time.now.strftime("%m/%d/%Y-%Hhour%Mminute")
  puts "4# Create & Checkout".light_blue + " Branch " + " #{releaseBranch} ".green 
  cmd = "git checkout -b #{releaseBranch} #{BRANCH}"
  output = `#{cmd}`
  puts output.pink
else 
  puts "\nSKIPPING STEP 4#(Creating Release Branch)  FOR dev.ringid.com\n".light
end 


# NO MORE NEEDED remove api.dashboard dependency from main module
#puts "Remove ".light_blue + "ringid.api.dashboard".red + " module from ".light_blue + "app.module.js".green
#cmd = "sed -i -e '/ringid.api.dashboard/d' #{projectDir}/webapp/app/app.module.js"
#`#{cmd}`

# enable PROTOCOL
puts "Enable PROTOCOL:".light_blue  + PROTOCOL.green
toggleProtocol(projectDir, PROTOCOL, TARGET)


#install grunt plugins
Dir.chdir("#{projectDir}/webapp/")
cmd = "npm install"
output = `#{cmd}`

if TARGET == 'live' || TASK == 'build'
  # initiate grunt build
  puts "Grunt buildinit".light_blue
  Dir.chdir(projectDir + '/webapp/')
  cmd = "grunt buildinit"
  output = `#{cmd}`
  puts output.pink
  Dir.chdir(projectDir)
  # remove digest debug
  puts "Remove ".light_blue + "DIGEST_DEBUG".red 
  #cmd =  "find #{projectDir}/webapp/app -type f -name '*.js' -exec grep -l 'DIGEST_DEBUG_START' {} \\; | xargs sed -i -e '/DIGEST_DEBUG_START/,/DIGEST_DEBUG_END/d'"
  cmd =  "sed -i -e '/DIGEST_DEBUG_START/,/DIGEST_DEBUG_END/d' #{projectDir}/webapp/scripts/dist/app.js"
  `#{cmd}`

  # remove ringlogger
  puts "Remove ".light_blue + " RingLogger ".red 
  #cmd = "find #{projectDir}/webapp/app/ -type f -name '*.js' -exec sed -i '/RingLogger/d' {} +"
  cmd = "sed -i -e '/RingLogger/d' #{projectDir}/webapp/scripts/dist/app.js" 
  `#{cmd}`

  # TODO
  # remove 'use strict'

else
  puts "\nSKIPPING STEP 4#(removing debug code) for dev.ringid.com\n".light
  puts "ENABLING DEBUG BY  CREATING: ".light_blue + 'developer.config.js'.green + ' from '.light_blue + 'developer.config.dist.js'.red
  puts "Enabling all debug tags".light_blue
  cmd = "cp #{projectDir}/webapp/app/developer.config.dist.js #{projectDir}/webapp//app/developer.config.js"
  `#{cmd}`
  cmd = "sed -i -e 's/false/true/g' #{projectDir}/webapp//app/developer.config.js" 
  `#{cmd}`
end

##8 Run build script
#installed above
Dir.chdir("#{projectDir}/webapp/")
#cmd = "npm install"
#output = `#{cmd}`
#puts output.pink
puts "Grunt ".light_blue + TASK.green
cmd =  "grunt #{TASK}"
buildoutput = `#{cmd}`
puts buildoutput.pink

#9 uglify custom uglifiero
#if TASK == 'build'
  #appMinScript = "#{projectDir}/webapp/js/app.min.js"
  #puts "6# RUNNING CUSTOM UGLIFIER on ".light_blue + appMinScript.red
  #minifyScript(scriptsDir, appMinScript)
#else 
  #puts 'SKIPPING STEP 6#(CUSTOM UGLIFIER ON CONSTANT STRINGS) '.yellow
#end


if TARGET == 'live'
  #10 commit build version to release branch 
  puts "Commit ".light_blue + " build to " + "#{releaseBranch}".green
  Dir.chdir("#{projectDir}")
  cmd = 'git add .'
  `#{cmd}`
  cmd = "git commit -m 'Build Version:#{appVersion}'"
  `#{cmd}`


  #11 Merge release branch to master
  puts "7# Merge  #{releaseBranch}".light_blue + " to " + " MASTER ".green
  latestBranch('master')
  cmd = "git merge -X theirs #{releaseBranch}"
  output = `#{cmd}`
  puts output.pink


  #12 Tag Release branch
  puts "Tag ".light_blue + " Release with : " + "#{releaseBranch}".green
  cmd = "git tag #{releaseBranch}"
  `#{cmd}`
  cmd = "git push origin --tags"
  `#{cmd}`

  #13 push production ready master to server
  puts "Push updated ".light_blue + " MASTER ".green + " branch to git server".light_blue
  cmd = "git push origin master"
  `#{cmd}`
else
  puts 'SKIPPING STEP 7#(MERGE latest DEVELOP WITH MASTER) '.light
end

src = projectDir + "/webapp/" #   Dir.home + "/Projects/ringIDWeb/webapp/"
destination = TARGET == 'live' ? "ringlive:/home/samir/ringidweb_payload/" : "ringdev:/var/www/html"
excludeFiles =  TARGET == 'live' ? scriptsDir + "assets/exclude-files.txt" : scriptsDir + "assets/exclude-files-dev.txt"

#20synch repo from local to remote
puts "20# FINAL: Synch ".light_blue + " #{src} ".green + " to " + " #{destination} ".red
#cmd = "rsync -avzP --no-g --no-o --delete --exclude-from #{excludeFiles} #{src} #{destination}"
cmd = "rsync -avzP --no-g --no-o --exclude-from #{excludeFiles} #{src} #{destination}"
#puts cmd.pink
output = `#{cmd}`
puts output.pink

#if TARGET == 'live' && ARGV[4] == 'true'
  #puts "30# GO TO RINGLIVE AND PUSH CODE TO PRODUCTION SERVER: ".red 
  #cmd = "ssh ringlive 'cd ~/Scripts; ./pushRingToLive.sh;'"
  #output = `#{cmd}`
  #puts output.pink
#end 

## end logging
puts  ("###############  END UPDATE: ".light_blue + updating.red + "  at:" + Time.now.strftime("%m/%d/%Y %H:%M").light_blue  +  "  ########".light_blue)

