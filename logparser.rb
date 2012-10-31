#!/usr/bin/env ruby


# local requires
require './offering.rb'
require './launch.rb'

# class LaunchList
  
  def sort_and_select(list,field)
    by_field = list.group_by { |item| item.send field }
    sorted   = by_field.sort_by { |k,v| v.size }.reverse
    sorted.slice(0,5).map { |i| [i[0],i[1].size]}
  end

  def parse_log(filename)
    file = File.new(filename)
    launches = []
    file.each do |line| 
      matches = line.match(Launch::LAUNCH_REGEX)
      if matches
        launches.push(Launch.new(matches))
      end
    end
    return launches
  end
# end

file_names = ARGV
file_names.each do |filename|
  launches = parse_log(filename)
  puts "found #{launches.size} launches in #{filename}"
  outfilename = "#{filename}.csv"
  File.open(outfilename,"w") do |file|
    launches.each do |launch|
      file.puts launch.as_csv
    end
    # file.puts launches.each { |l| l.as_json }
  end
end

