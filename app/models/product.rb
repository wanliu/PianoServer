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
  attribute :category_name, String
  attribute :creator_id, Fixnum
  attribute :custom_special, Boolean
  attribute :image_urls, Array
  attribute :additional_fields, Hash

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

  def self.with_category_brands(categories = [], brands = [])
    # query = {
    #   query: {
    #     filtered: {
    #       filter: {
    #         bool: {
    #           must: {
    #             range: {
    #               status: {
    #                 gt: 0
    #               }
    #             },
    #             term: {
    #               category_id: categories
    #             },
    #             term: {
    #               brand_id: brands,
    #             }
    #           ]
    #         }
    #       }
    #     }
    #   },
    #   size: 0
    # }
    query = {
      query: {
        filtered: {
          filter: {
            bool: {
              must: [
                {
                  terms: {
                    category_id: categories,
                    execution: "bool",
                    _cache: true
                  },
                }, {
                  terms: {
                    brand_id: brands,
                    execution: "bool",
                    _cache: true
                  }
                },
                # range: {
                #   status: {
                #     gt: 0
                #   }
                # }
              ]
            }
          }
        }
      },
      size: 0
    }


    aggs = {
      aggs: {
        all_category: {
          terms: {
            field: "category_id",
            order: {
              _term: "asc"
            }
          },
          aggs: {
            all_brands: {
              terms: {
                field: "brand_id"
                # include: brands
              },
              aggs: {
                all_products: {
                  top_hits: {
                    sort: [ "name" ],
                    _source: {
                      include: [
                        :id, :avatar, :name, :price, :category_id, :brand_id, :status, :created_at, :updated_at
                      ]
                    },
                    size: 100
                  }
                }
              }
            }
          }
        }
      }
    }

    search query.merge(aggs)
    # search aggs
  end
end
