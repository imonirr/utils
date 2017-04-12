#! /usr/bin/ruby -w
# Script to remove unused parts and partial minification of frontend js application
#
$charMap =[*('A'..'Z')]

$miniMap = []
$stringList = []
$regex = Regexp.new('(?=[A-Z])[A-Z_0-9]{4,}\b')

def readStringList
  file = File.open('all-constants.txt').read

  # check for encoding issues
  if ! file.valid_encoding?
      file = file.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
  end

  #counter = 0
  file.each_line do |line|
    #counter = counter + 1
    #if counter > 100
      #break;
    #end
    if line.strip.length > 4
      keywords = line.strip.scan($regex)
      #puts (line.strip)
      #puts keywords
      #puts '###########################################################################'
      keywords.each do |keyword|
        if not $stringList.include? (keyword)
          $stringList.push(keyword.strip)
        end
      end
    end
  end
  $stringList = $stringList.sort{|x, y| x.length <=> y.length}.reverse
  puts $stringList.length

  output = File.open('constants-list.txt', 'w+')
  $stringList.each do |keyword|
    output.puts(keyword)
  end

end


readStringList()

