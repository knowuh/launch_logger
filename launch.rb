# encoding: utf-8
require 'pry'
require 'json'
require 'time'
require './offering.rb'

class Launch
  LAUNCH_REGEX = /"(?<url>.*offerings\/(?<offering_id>[0-9]+)\.jnlp[^"]*)"\s+for\s+(?<ip>[0-9|.]*)\s+at\s+(?<timestamp>\d{4}-\d{2}\-\d{2}\s+\d{1,2}:\d{1,2}:\d{1,2})/
  attr_accessor :timestamp
  attr_accessor :ip
  attr_accessor :url
  attr_accessor :offering_name
  attr_accessor :offering_id
  attr_accessor :offering_type
  attr_accessor :class_id
  attr_accessor :hash_id


  def initialize(hash)
    self.timestamp = Time.parse(hash[:timestamp]).strftime('%Y-%m-%dT%H:%M:%S.%3N')
    self.url       = hash[:url]
    self.ip        = hash[:ip]
    offering       = Offering.find(hash[:offering_id])
    
    self.offering_id   = offering.id
    self.offering_name = offering.name
    self.offering_type = offering.type
    self.class_id      = offering.class_id
    self.hash_id       = "#{self.timestamp}-#{self.url}-#{self.ip}".hash
  end

  def hash
    self.hash_id.hash
  end

  def as_hash
    {
      'timestamp'     => self.timestamp,
      'hash_id'       => self.hash_id,
      'url'           => self.url,
      'ip'            => self.ip,
      'offering_name' => self.offering_name,
      'offering_id'   => self.offering_id,
      'offering_type' => self.offering_type,
      'class_id'      => self.class_id
    }
  end

  def as_json
    self.as_hash.to_json
  end

  def as_csv
    pairs = self.as_hash.map do |key,value|
      "#{key}=\"#{value}\""
    end
    pairs.join(", ")
  end
end