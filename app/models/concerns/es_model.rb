module ESModel
  extend ActiveSupport::Concern

  ES_NAMESPACE = ENV['ES_NAMESPACE'] || Settings.elasticsearch.namespace

  included do
    names = [table_name, Settings.elasticsearch.environment || Rails.env]
    names.unshift(ES_NAMESPACE) unless ES_NAMESPACE.blank?
    index_name names.join('_')
  end
end
