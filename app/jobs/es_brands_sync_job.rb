class EsBrandsSyncJob < ActiveJob::Base
  queue_as :default

  def perform(overwrite_model="overwrite")
    EsBrandsSync.sync(overwrite_model)
  end
end
