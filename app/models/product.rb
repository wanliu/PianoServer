require 'elasticsearch/persistence/model'
require 'bigdecimal'

class Product
  include Elasticsearch::Persistence::Model
  # include ActiveModel::SerializerSupport

  gateway.client = Elasticsearch::Client.new url: 'http://192.168.0.20:9200/', log: true

  index_name "pm_products_production"

  attribute :id, Fixnum
  attribute :name, String, mapping: { analyzer: 'ik' }
  attribute :price, BigDecimal
  attribute :avatar, String
  attribute :status, Fixnum

  def image
    @avatar = self.avatar
    { 
      avatar_url: @avatar + '!avatar',
      preview_url: @avatar
    }
  end

  def self.suggest(query)
    self.search(query: {
      bool: {
        must: [
          { match: { name: query }},
          { bool: {
              should: [
                { range: {
                    status: {
                      from: 1,
                      to: 1
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    })
  end
end
