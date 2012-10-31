# encoding: utf-8

require 'active_support/inflector'
require 'memoist'
require 'uri'
require 'nokogiri'
require 'net/http'

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