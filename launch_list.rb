# encoding: utf-8

require './launch.rb'

class LaunchList
  attr_accessor :list

  def initialize
    self.list = []
  end

  def most_popular(field=:offering_name,limit=10)
    by_field = self.list.group_by { |item| item.send field }
    sorted   = by_field.sort_by { |k,v| v.size }.reverse
    return sorted.slice(0,limit).map { |i| [i[0],i[1].size]}
  end

  def parse_log(filename)
    file = File.new(filename)
    file.each do |line| 
      matches = line.match(Launch::LAUNCH_REGEX)
      if matches
        self.list.push(Launch.new(matches))
      end
    end
  end

  def write_file(format=:csv)
    outfilename = "report.#{format.to_s}"
    method = "as_#{format.to_s}".to_sym
    File.open(outfilename,"w") do |file|
      self.list.each do |launch|
        file.puts launch.send method
      end
    end
  end
end