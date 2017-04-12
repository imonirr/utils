#! /usr/bin/ruby -w
# Script to remove unused parts and partial minification of frontend js application
#
$charMap =[*('A'..'Z')]

$miniMap = []
$stringList = []


def readStringList
  file = File.open('app-constants-list.txt').read
  file.each_line do |line|
    if(line.strip.length > 6)
      $stringList.push(line.strip)
    end
  end
  $stringList = $stringList.sort{|x, y| x.length <=> y.length}.reverse
  puts $stringList
end

def generateMiniMap(howMany)
  i = 0
  remainder = 0
  result = 0
  while i < howMany
    $miniMap[i] = ''
    remainder = i%26
    result = i/26

    $miniMap[i] += $charMap[remainder]
    while result> 0
      remainder = result % 26
      result = result / 26
      #puts 'i=' + $i.to_s + ' $remainder=' + $remainder.to_s + '$result=' + $result.to_s
      $miniMap[i] += $charMap[remainder]
    end
    $miniMap[i] = $miniMap[i].reverse;

    #puts '$i=' + $i.to_s + '  min:' + $miniMap[$i].to_s
    i= i + 1
  end
end


def minifyScript
  $scriptFile = File.read(ARGV[0])

  if ! $scriptFile.valid_encoding?
      $scriptFile = $scriptFile.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  end


  minified_script = $scriptFile;
  $stringList.each_with_index do |bigVar, index|
    minified_script = minified_script.gsub(bigVar, $miniMap[index])
    puts '#index=' + index.to_s + '    #replace: ' + bigVar + '  #with : ' + $miniMap[index].to_s
  end
  File.open(ARGV[0], 'w') {|file| file.puts minified_script}
end

readStringList()

generateMiniMap($stringList.length)

#minifyScript()
