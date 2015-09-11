class EsCategoriesSyncJob < ActiveJob::Base
  queue_as :default

  def perform(overwrite_model="overwrite")
    EsCategoriesSync.sync(overwrite_model)
  end
end
