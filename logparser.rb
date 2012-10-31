#!/usr/bin/env ruby
# encoding: utf-8

require './launch_list.rb'

file_names = ARGV
launch_list = LaunchList.new

file_names.each do |filename|
  launch_list.parse_log(filename)
end
launch_list.most_popular.each { |i| puts "#{i[0]} → [#{i[1]}]" }
launch_list.write_file
