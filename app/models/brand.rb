class Brand < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel
  include PublicActivity::Model
  tracked

  paginates_per 100

  has_many :categories
  has_many :items
  belongs_to :category

  acts_as_punchable
  acts_as_taggable_on :states, :categories

  mount_uploader :image, ItemImageUploader

  attr_reader :title
  attr_accessor :total

  scope :search_by, -> (q) { where("name LIKE :query", {query: "%#{q}%"}) }

  def self.with_category(category_id, query = {}, &block)
    ids = [ category_id, *Category.find(category_id).descendants.pluck(:id) ]
    if block_given?
      yield ids, query
    else
      with_categories(ids, query)
    end
  end

  def self.with_categories(categories_ids, query = {})
    query = query.reverse_merge({
      query: {
        filtered: {
          filter: {
            bool: {
              must: [{
                terms: {
                  category_id: categories_ids,
                  execution: "bool",
                  _cache: true
                },
              }, {
                range: {
                  status: {
                    gt: 0
                  }
                }
              }]
            }
          }
        }
      },
      aggs: { all_brands: { terms: {field: "brand_id", size: 100}}}
    })

    results = Product.search(query)
    buckets = results.response.aggregations.all_brands.buckets

    ids = buckets.map { |b| "(#{b['key']}, #{b['doc_count']})" }.join(',')
    ids = ids.empty? ? "(0, 0)": ids
    sql = <<-SQL
      SELECT b.*, x.ordering total
      FROM brands b
      JOIN (
        VALUES
          #{ids}
      ) AS x (id, ordering) on b.id = x.id
      ORDER BY x.ordering desc
    SQL
    Brand.find_by_sql sql.squish
  end

  def self.with_labels(categories_ids, query = {})
    query = query.reverse_merge({
      query: {
        filtered: {
          filter: {
            bool: {
              must: [{
                terms: {
                  category_id: categories_ids,
                  execution: "bool",
                  _cache: true
                },
              }, {
                range: {
                  status: {
                    gt: 0
                  }
                }
              }]
            }
          }
        }
      },
      aggs: { all_brands: { terms: {field: "brand_id", size: 100}}}
    })

    results = Product.search(query)
    buckets = results.response.aggregations.all_brands.buckets

    ids = buckets.map { |b| [b['key'], b['doc_count']] }
    # ids = buckets.map { |b| "(#{b['key']}, #{b['doc_count']})" }.join(',')
    # ids = ids.empty? ? "(0, 0)": ids
    # sql = <<-SQL
    #   SELECT b.*, x.ordering total
    #   FROM brands b
    #   JOIN (
    #     VALUES
    #       #{ids}
    #   ) AS x (id, ordering) on b.id = x.id
    #   ORDER BY x.ordering desc
    # SQL
    Brand.where("id in (?)", ids.map {|id, count| id }).tagged_with(["关闭"], :exclude => true)
    # Brand.find_by_sql sql.squish
  end

  def self.top
    query = {
      aggs: { all_brands: { terms: {field: "brand_id", size: 100}}}
    }
    results = Product.search query
    buckets = results.response.aggregations.all_brands.buckets

    ids = buckets.map { |b| "(#{b['key']}, #{b['doc_count']})" }.join(',')
    sql = <<-SQL
      SELECT b.*, x.ordering total
      FROM brands b
      JOIN (
        VALUES
          #{ids}
      ) AS x (id, ordering) on b.id = x.id
      ORDER BY x.ordering desc
    SQL
    Brand.find_by_sql sql.squish
  end

  def title
    [name, chinese_name].compact.join('/')
  end

  def total
    read_attribute(:total)
  end
end
