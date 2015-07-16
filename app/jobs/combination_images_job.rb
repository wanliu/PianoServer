require 'functions/combination_images'

class CombinationImagesJob < ActiveJob::Base
  include ActionView::RecordIdentifier
  include CombinationImages

  queue_as :default

  MAX_MATRIX = 3

  def perform(record, image_urls, options)
    time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
    FileUtils.mkdir_p  Rails.root.join('public/assets/generatings')
    file = Tempfile.new([dom_id(record) + '_' + time_str, '.jpg'], Rails.root.join('public/assets/generatings'))
    puts "generating image file #{file.path}..."

    composite_images file.path, image_urls, options
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace.join("\n")
  end

  # def composite_images(filename, image_urls, options)

  #   rows = cols = current_vector(image_urls.count)

  #   width = options["size"]["width"]
  #   height = options["size"]["height"]
    
  #   space = 1
  #   sub_width = (width + space) / rows
  #   sub_height = (height + space) / cols

  #   images = urls[1..(rows*cols)].map do |url| 
  #     MiniMagick::Image.new(url) do |b| 
  #       b.resize "#{sub_width}x#{sub_height}"
  #     end
  #   end

  #   i = 0
  #   results = concat_images images do |c|
  #   # results = images.inject(images.first) do |result, image|
  #   #   result.composite image do |c|
  #     x = (i / rows) * sub_width + space
  #     y = (i % cols) * sub_height + space
  #     c.compose "Over"    # OverCompositeOp
  #     c.geometry "+#{x}+#{y}" # copy second_image onto first_image from (20, 20)      

  #     puts "x = #{x}, y = #{y}, resize = #{sub_width}x#{sub_height}, geometry = +#{x}+#{y}"
  #     i += 1
  #     # end
  #   end
  #   results.write(filename)
  # end

  # def concat_images(images, &block)
  #   images.inject(images.first) do |result, image|
  #     result.composite image, &block
  #   end
  # end

  # def current_vector(counts)
  #   vector = Math.sqrt(counts).ceil
  #   vector < 3 ? (vector > 1 ? vector :  1) : 3
  # end
end
