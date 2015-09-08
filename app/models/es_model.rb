require 'elasticsearch/persistence/model'
require 'bigdecimal'

class ESModel
  include Elasticsearch::Persistence::Model
  # include ActiveModel::SerializerSupport

  gateway.client = Elasticsearch::Client.new url: Settings.elasticsearch.url, log: true

  # index_name Settings.elasticsearch.index_name
end
