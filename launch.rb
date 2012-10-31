require 'pry'
require 'json'
require 'time'
class Launch
  LAUNCH_REGEX = /"(?<url>.*offerings\/(?<offering_id>[0-9]+)\.jnlp[^"]*)"\s+for\s+(?<ip>[0-9|.]*)\s+at\s+(?<timestamp>\d{4}-\d{2}\-\d{2}\s+\d{1,2}:\d{1,2}:\d{1,2})/
  attr_accessor :timestamp
  attr_accessor :ip
  attr_accessor :url
  attr_accessor :offering

  def initialize(hash)
    # self.timestamp = hash[:timestamp]
    self.timestamp = Time.parse(hash[:timestamp]).strftime('%Y-%m-%dT%H:%M:%S.%3N')
    self.url       = hash[:url]
    self.ip        = hash[:ip]
    self.offering  = Offering.find(hash[:offering_id])
  end

  def hash_id
    "#{self.timestamp}-#{self.url}-#{self.ip}"
  end

  def as_hash
    {
      'timestamp'     => self.timestamp,
      'hash_id'       => self.hash_id,
      'url'           => self.url,
      'ip'            => self.ip,
      'offering_name' => self.offering.name,
      'offering_id'   => self.offering.id,
      'offering_type' => self.offering.type,
      'class_id'      => self.offering.class_id
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