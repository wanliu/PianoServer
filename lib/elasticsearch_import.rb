class ElasticsearchImport
  include Sidekiq::Worker

  def self.import(model)
    klass = model.classify.safe_constantize
    if klass.respond_to? :import
      klass.import force: true
    end
  end

  def perform(options)
    klass = options["class"].classify.safe_constantize
    ids = options["ids"]

    logger.info "import to es, class: #{options["class"]}"
    if klass.present? && klass.respond_to?(:import)
      if ids.present?
        logger.info "import to es, ids: #{ids.to_json}"
        klass.import query: -> { where(id: ids) }
      else
        klass.import
      end
    end
  end
end