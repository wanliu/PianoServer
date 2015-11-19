require 'elasticsearch/persistence/model'
require 'bigdecimal'

class Product
  include Elasticsearch::Persistence::Model
  # include ESModel

  gateway.client = Elasticsearch::Client.new url: Settings.elasticsearch.url, log: true

  ES_NAMESPACE = ENV['ES_NAMESPACE'] || Settings.elasticsearch.namespace

  names = ["products", Settings.elasticsearch.environment || Rails.env]
  names.unshift(ES_NAMESPACE) unless ES_NAMESPACE.blank?
  index_name names.join('_')

  attribute :id, Fixnum
  attribute :name, String, mapping: { analyzer: 'ik' }
  attribute :price, BigDecimal
  attribute :avatar, String
  attribute :status, Fixnum
  attribute :brand_id, Fixnum
  attribute :brand_name, String
  attribute :category_id, Fixnum
  attribute :creator_id, Fixnum
  attribute :custom_special, Boolean
  attribute :image_urls, Array
  attribute :additional_fields, Hash

  def image
    @avatar = Flf.avatar
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
