class CombinationImagesJob < ActiveJob::Base
  queue_as :default

  def perform(record, image_urls, options)
    puts '=' * 100
    puts image_urls
    # pp image_urls
    # Do something later
  end
end
