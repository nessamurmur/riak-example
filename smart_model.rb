require 'bundler/setup'
require 'riak'
require 'json'

class SmartModel < DumbModel

  client[bucket.name].enable_index!

  def self.find_by(key, value, &block)
    results = client.search(bucket.name, "#{key}:#{value}")
    document = block_given? ? block.call(results) : results["docs"].first
    new(document)
  end

  def save
    client.index(bucket.name, attributes)
  end

  def delete
    client.remove(bucket.name, {id: id})
  end
end
