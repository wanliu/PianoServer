class Suggestion < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  validates :title, uniqueness: true

  scope :avaliable, lambda { where(check: true) }

  def self.es_index_setting
    {
      index: {
        analysis: {
          analyzer: {
            pinyin_analyzer: {
              tokenizer: "my_pinyin",
              filter: ["word_delimiter"]
            },
            first_pinyin_analyzer: {
              tokenizer: "first_pinyin",
              filter: ["word_delimiter", "first_pinyin_edgeNGram"]
            }
          },
          tokenizer: {
            my_pinyin: {
              type: "pinyin",
              first_letter: "none",
              padding_char: " "
            },
            first_pinyin: {
              type: "pinyin",
              first_letter: "only",
              padding_char: ""
            }
          },
          filter: {
            first_pinyin_edgeNGram: {
              type: "edgeNGram",
              max_gram: 4
            }
          }
        }
      }
    }
  end

  settings(self.es_index_setting) do
    mappings dynamic: 'true' do
      indexes :title,
        type: 'string',
        analyzer: 'ik',
        fields: {
          pinyin: {
            type: 'string',
            analyzer: 'pinyin_analyzer',
            term_vector: "with_positions_offsets"
          },
          first_lt: {
            type: 'string',
            analyzer: 'first_pinyin_analyzer',
            term_vector: "with_positions_offsets"
          }
        }
      indexes :count, type: 'long'
    end
  end

  def self.item_suggest(query)
    query_params = {
      query: {
        filtered: {
          query: {
            bool: {
              should: [
                { match: {title: query} }
              ],
              minimum_should_match: 1
            }
          },
          filter: {
            term: {check: true}
          }
        }
      },
      # sort: {count: {order: 'asc'}}
    }

    # min_score = Settings.elasticsearch.item_min_score
    # if min_score.present?
    #   query_params[:min_score] = min_score
    # end

    # 搜索内容只有字母的时候
    # ①只有声母
    # ②声母韵母都有
    if /[a-z]+/.match query
      if /[(a|o|e|i|u|ü|v)]/.match query
        pinyin = query.gsub /[(b|p|m|f|d|t|n|l|g|k|h|j|q|x|zh|ch|sh|r|z|c|s|w|y)]/ do |i|
          " #{i}"
        end
        pinyin = pinyin.gsub(" z ", " z")
          .gsub(" c ", " c")
          .gsub(" s ", " s")
          .gsub(" n ", "n ")
          .gsub(" g ", "g ")
          .gsub(/\W+g\z/, "g")
          .gsub(/\W+n\z/, "n")
          .strip

        query_params[:query][:filtered][:query][:bool][:should].push({ match: {"title.pinyin" => pinyin} })
      else
        query_params[:query][:filtered][:query][:bool][:should].push({ match: {"title.first_lt" => query} })
      end
    end

    search(query_params).records
  end
end
