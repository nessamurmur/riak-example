require 'bundler/setup'
require 'riak'
require 'json'

class DumbModel

  attr_reader :id

  def self.client
    @client ||= Riak::Client.new
  end

  def self.bucket
    @bucket ||= client.bucket(name)
  end

  def initialize(opts={})
    @attributes = []
    opts.each_pair do |key, value|
      singleton_class.class_eval do; attr_accessor key.to_sym; end
      instance_variable_set("@#{key}", value)
      @attributes << key
    end
  end

  def self.find_or_create(key)
    obj = bucket.get_or_new(key)
    new(obj.data)
  end

  def save_with_key(key)
    obj = bucket.get_or_new(key)
    obj.data = attributes
    obj.content_type = "application/json"
    obj.store
  end

  def attributes
    Hash[@attributes.map { |name, _| [name, self.send(name)] }]
  end

  def client
    self.class.client
  end

  def bucket
    self.class.bucket
  end
end
