#! /usr/bin/env ruby

require './build-methods.rb'

# DEFAULTS
_PROTOCOL = (ARGV[1] ? ARGV[1] : 'nonssl')
_TARGET =  (ARGV[0] ? ARGV[0] : 'dev')
_APIVERSION = (ARGV[2] ? ARGV[2] : (_TARGET == 'live' ? '138': '139'))
_TASK = (ARGV[3] ? ARGV[3] : (_TARGET == 'live' ? 'build': 'stage'))
_BRANCH = (ARGV[4] ? ARGV[4] : 'develop')



# HANDLE USER INPUTS
#puts "\nUpdating default target: ".yellow + _TARGET.blue 
TARGET = _TARGET
#TARGET = prompt(_TARGET,  "To select default just press ENTER or your desired TARGET(dev/live): ".yellow)
puts "1# Selected TARGET::".yellow + TARGET.red 

#puts "\nUpdating default PROTOCOL!: ".yellow + _PROTOCOL.blue 
PROTOCOL = _PROTOCOL
#PROTOCOL = prompt(_PROTOCOL, "To select default just press ENTER or your desired PROTOCOL(ssl/nonssl): ".yellow)
puts "2# Selected PROTOCOL:".yellow + PROTOCOL.red 

puts "\nUpdating default APIVERSION: ".yellow + _APIVERSION.blue 
APIVERSION = prompt(_APIVERSION, "To select default just press ENTER or your desired APIVERSION(138/139): ".yellow)
puts "3# Selected APIVERSION:".yellow + APIVERSION.to_s.red 

puts "\nUpdating default task: ".yellow + _TASK.blue 
TASK = prompt(_TASK, "To select default just press ENTER or your desired TASK(dev/stage/build): ".yellow)
puts "4# Selected Grunt TASK:".yellow + TASK.red + "\n"

puts "\nUpdating default branch: ".yellow + _BRANCH.blue 
BRANCH = prompt(_BRANCH, "To select default just press ENTER or your desired branch(develop/worker_st): ".yellow)
puts "5# Selected BRANCH:".yellow + BRANCH.red + "\n"


projectDir = Dir.home + "/Projects/gitserver" # + (TARGET === 'live' ? 'ringlive' : 'ringdev')
updating = (PROTOCOL == 'ssl' ? 'https://' : 'http:/' ) + '192.168.1.117:8888'
puts  ("###############  UPDATING : ".green + updating.red + "  at:" + Time.now.strftime("%m/%d/%Y %H:%M").green  +  "  ########".green)


#1 go to project dir
puts "1# Moving to ".light_blue + "#{projectDir}".red + " Directory"
Dir.chdir(projectDir)

##2 checkout specified branch
puts "2# Take Latest code from branch: ".light_blue + " #{BRANCH}".red 
latestBranch(BRANCH) 

##3 create release branch
appVersion = updateAppVersion(projectDir, APIVERSION)
puts "App Version: #{appVersion}".yellow

# fix api url
fixAPIUrls(projectDir)

# remove api.dashboard dependency from main module
cmd = "sed -i -e '/ringid.api.dashboard/d' #{projectDir}/webapp/app/app.module.js"
`#{cmd}`

# enable PROTOCOL
puts "Enable ".light_blue + "PROTOCOL:"  + PROTOCOL.red
#toggleProtocol(projectDir, PROTOCOL, TARGET)


##8 Run build script

Dir.chdir("#{projectDir}/webapp/")
cmd = "npm install"
output = `#{cmd}`
puts output.pink
puts "5# Grunt ".light_blue + TASK.red
cmd =  "grunt #{TASK}"
buildoutput = `#{cmd}`
puts buildoutput.pink



#sh ringserver.sh
## end logging
puts  ("###############  END UPDATE: ".green + updating.red + "  at:" + Time.now.strftime("%m/%d/%Y %H:%M").green  +  "  ########".green)

