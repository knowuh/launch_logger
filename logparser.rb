#!/usr/bin/env ruby
require 'uri'
require 'nokogiri'
require 'net/http'
require 'pry'
require 'json'
require 'active_support/inflector'
require 'memoist'

class Offering
  HOST = "http://rites-investigations.concord.org"

  attr_accessor :id
  attr_accessor :name
  attr_accessor :type
  attr_accessor :class_id
  
  def initialize(att)
    self.id       = att[:id]
    self.name     = att[:name]
    self.type     = att[:type]
    self.class_id = att[:class_id]
  end

  class << self
    extend Memoist
    def get_xml_resource(type,id)
      endpoint = type.downcase.pluralize
      url      = "#{Offering::HOST}/#{endpoint}/#{id}.xml"
      uri      = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      body     = response.body
      return Nokogiri::XML(body)
    end

    def find(id)
      xml_doc = self.get_xml_resource('portal/offering',id)
      
      class_id           = xml_doc.xpath('//clazz-id').text
      runnable_type      = xml_doc.xpath('//runnable-type').text
      runnable_id        = xml_doc.xpath('//runnable-id').text
      runnable_name      = self.get_xml_resource(runnable_type,runnable_id).xpath('//name').text
      return self.new(
        :name     => runnable_name,
        :type     => runnable_type,
        :id       => runnable_id,
        :class_id => class_id
      )
    end
    memoize :find
  end
end

class Launch
  LAUNCH_REGEX = /"(?<url>.*offerings\/(?<offering_id>[0-9]+)\.jnlp[^"]*)"\s+for\s+(?<ip>[0-9|.]*)\s+at\s+(?<timestamp>\d{4}-\d{2}\-\d{2}\s+\d{1,2}:\d{1,2}:\d{1,2})/
  attr_accessor :timestamp
  attr_accessor :ip
  attr_accessor :url
  attr_accessor :offering

  def initialize(hash)
    self.timestamp = hash[:timestamp]
    self.url       = hash[:url]
    self.ip        = hash[:ip]
    self.offering  = Offering.find(hash[:offering_id])
  end

  def to_hash
    {self.timestamp =>
      {
        :url           => self.url,
        :ip            => self.ip,
        :offering_name => self.offering.name,
        :offering_id   => self.offering.id,
        :offering_type => self.offering.type,
        :class_id      => self.offering.class_id
      }
    }
  end
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

file_names = ARGV
file_names.each do |filename|
  launches = parse_log(filename)
  puts "found #{launches.size} launches in #{filename}"
  outfilename = "#{filename}.json"
  File.open(outfilename,"w") do |file|
    file.puts launches.map { |l| l.to_hash }.to_json
  end
end

