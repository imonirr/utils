#! /usr/bin/ruby -w
# Script to remove unused parts and partial minification of frontend js application
#

$miniMap = []
$stringList = []
#scriptsDir = Dir.home + "/Projects/Scripts/"

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

  def light
    colorize(37)
  end
end

def prompt(default, *args)
  print(*args)
  result = gets.chomp.strip
  return result.empty? ? default : result
end

def updateAppVersion (projectDir, apiVersion)
    appVersion = ''
    newAppVersion = ''
    oldApiVersion = ''
    newApiVersion = '"apiVersion":' + apiVersion.to_s
    new_contents = ''

    gruntfile = "#{projectDir}/webapp/Gruntfile.js"
    settingsFile = "#{projectDir}/webapp/app/config/settings.constant.js"
    regexAppVersion = Regexp.new("appVersion\s*=\s*['|\"]([0-9]+\.[0-9]+\.([0-9]+))\['|\"]")
    regexApiVersion = Regexp.new("['|\"]apiVersion['|\"]\s*:\s*([0-9]+)")

    if File.file?(gruntfile) 
      file = File.open(gruntfile).read 
      if ! file.valid_encoding?
          file = file.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      end
      file.each_line do |line|
        matching =  line.strip.match(regexAppVersion)
        if matching
          appVersion = matching[1]
          newAppVersion = appVersion.sub(matching[2], (matching[2].to_i + 1).to_s)
          puts "Javascript Application version :".light_blue + appVersion.red + '  UPDATED TO :'.light_blue + newAppVersion.green + " in " + "#{File.basename(gruntfile)}".yellow

          # UPDATE app release version
          new_contents = file.gsub(appVersion, newAppVersion)
          File.open(gruntfile, "w") {|f| 
            f.write(new_contents)
          }
          break;
        end
      end
    else
      puts "ERROR File:#{gruntfile} Not found".red
      abort
    end



    # UPDATE app apiVersion
    if File.file?(settingsFile) 
      file = File.open(settingsFile).read

      if ! file.valid_encoding?
          file = file.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      end
      file.each_line do |line|
        matching =  line.strip.match(regexApiVersion)
        if matching
          oldApiVersion =  matching[0]
          puts  "API Version :".light_blue + oldApiVersion.red + ' UPDATED to:'.light_blue + apiVersion.green + " in " + "#{File.basename(settingsFile)}".yellow
          break;
        end
      end

      new_contents = file.gsub(oldApiVersion, newApiVersion)
      File.open(settingsFile, "w") {|f| 
        f.write(new_contents)
      }
    else
      puts "ERROR File:#{settingsFile} Not found".red
      abort
    end
    return newAppVersion
end


def latestBranch(branchName)
  puts "Checkout Branch ".light_blue + " #{branchName}".green
  #puts exec("git checkout -f #{branchName}")
  cmd = "git fetch origin"
  output = `#{cmd}`
  puts output.pink
  cmd = "git checkout -f #{branchName} "
  output = `#{cmd}`
  puts output.pink

  #3 discard any local changes to the branch
  puts "Reset Branch ".light_blue + " #{branchName}  ".green + " to remote. Discard local changes".light_blue
  cmd = "git reset --hard origin/#{branchName}"
  output = `#{cmd}`
  puts output.pink
  cmd = "git clean -d -f"
  output = `#{cmd}`
  puts output.pink

  ##4 Take latest pull
  puts "Pulling Latest Changes for Branch :".light_blue + "#{branchName}".green
  cmd =  "git pull origin #{branchName}"
  output = `#{cmd}`
  puts output.pink
end


def replaceString(files, replace, replaceWith) 
  fileList = Array(files)
  puts "REPLACE: ".light_blue + "#{replace}".red + " WITH ".light_blue + "#{replaceWith}".green 
  fileList.each do |fileToChange|
    if File.file?(fileToChange)
      puts "#{File.basename(fileToChange)}".yellow
      file = File.open(fileToChange).read
      # check for encoding issues
      if ! file.valid_encoding?
          file = file.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
      end

      new_contents = file.gsub(replace, replaceWith)
      File.open(fileToChange, 'w') { |f| 
        f.write(new_contents)
      }
    else
      puts "ERROR File:#{fileToChange} not found".red
      abort
    end
  end
end


def toggleProtocol (projectDir, enable, target)
  settingsFile = "#{projectDir}/webapp/app/config/settings.constant.js"
  workerFile = "#{projectDir}/webapp/app/init-worker.js"
  chatWorkerFile = "#{projectDir}/webapp/app/chat/services/chat.connector.js"

  fileList = [
        "#{projectDir}/webapp/app/config/settings.constant.js",
        "#{projectDir}/webapp/index.html",
        "#{projectDir}/webapp/dash.html",
        "#{projectDir}/webapp/features.html",
        "#{projectDir}/webapp/faq.html",
        "#{projectDir}/webapp/faq-mobile.html",
        "#{projectDir}/webapp/privacy.html",
        "#{projectDir}/webapp/privacy-mobile.html",
        "#{projectDir}/webapp/terms.html",
        "#{projectDir}/webapp/home.html",
        "#{projectDir}/webapp/not-found.html",
        "#{projectDir}/webapp/player/embed.html"
  ]

  if enable && enable == 'ssl'
    replaceString(fileList, 'http:', 'https:')
    replaceString(settingsFile, 'ws:', 'wss:')
    replaceString(workerFile, 'ws:', 'wss:')
    replaceString(chatWorkerFile, 'ws:', 'wss:')
    replaceString(settingsFile, /secure\s*:\s*\w+,/, 'secure:true,')
  else 
    replaceString(fileList, 'https:', 'http:')
    replaceString(settingsFile, 'wss:', 'ws:')
    replaceString(workerFile, 'wss:', 'ws:')
    replaceString(chatWorkerFile, 'wss:', 'ws:')
    replaceString(settingsFile, /secure\s*:\s*\w+,/, 'secure:false,')
  end

  if target && target == 'live'
    replaceString(settingsFile, /analytics\s*:\s*\w+,/, 'analytics:true,')
    replaceString(settingsFile, /debugEnabled\s*:\s*\w+,/, 'debugEnabled:false,')
  else
    replaceString(settingsFile, /analytics\s*:\s*\w+,/, 'analytics:false,')
    replaceString(settingsFile, /debugEnabled\s*:\s*\w+,/, 'debugEnabled:true,')
  end
end 


def fixAPIUrls (projectDir)
  settingsFile = "#{projectDir}/webapp/app/config/settings.constant.js"
  #if target == 'live'
  if File.file?(settingsFile) 
    file = File.open(settingsFile).read
    puts "Replacing ".light_blue + "http://dev".red + " with ".light_blue + "http://".green  + " in ".light_blue + "#{File.basename(settingsFile)}".yellow
    new_contents = file.gsub('http://dev', 'http://')
    File.open(settingsFile, 'w') { |f| 
      f.write(new_contents)
    }
  else
    puts "ERROR File:#{settingsFile} Not found".red
    abort
  end
  #end
end

def readStringList(scriptsDir)
  file = File.open(scriptsDir + 'assets/constants-list.txt').read
  file.each_line do |line|
    if(line.strip.length > 4)
      $stringList.push(line.strip)
    end
  end
  $stringList = $stringList.sort{|x, y| x.length <=> y.length}.reverse
end


def generateMiniMap(howMany)
  i = 0
  remainder = 0
  result = 0
  charMap =[*('A'..'Z')]
  while i < howMany
    $miniMap[i] = ''
    remainder = i%26
    result = i/26

    $miniMap[i] += charMap[remainder]
    while result> 0
      remainder = result % 26
      result = result / 26
      #puts 'i=' + $i.to_s + ' $remainder=' + $remainder.to_s + '$result=' + $result.to_s
      $miniMap[i] += charMap[remainder]
    end
    $miniMap[i] = $miniMap[i].reverse;

    #puts '$i=' + $i.to_s + '  min:' + $miniMap[$i].to_s
    i= i + 1
  end
end


def minifyScript (scriptsDir, minifyFile)
  readStringList(scriptsDir)
  generateMiniMap($stringList.length)

  scriptFile = File.open(minifyFile).read
  logFile = File.open(scriptsDir + 'logs/uglify-log.txt', 'w+')

  # check for encoding issues
  if ! scriptFile.valid_encoding?
      scriptFile = scriptFile.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  end

  minified_script = scriptFile;
  $stringList.each_with_index do |bigVar, index|
    minified_script = minified_script.gsub(bigVar, $miniMap[index])
    logFile.puts '#index=' + index.to_s + '    #replace: ' + bigVar + '  #with : ' + $miniMap[index].to_s
    #puts '#index=' + index.to_s + '    #replace: ' + bigVar + '  #with : ' + $miniMap[index].to_s
  end
  File.open(minifyFile, 'w') {|file| file.puts minified_script}
end


#minifyScript(ARGV[0])
