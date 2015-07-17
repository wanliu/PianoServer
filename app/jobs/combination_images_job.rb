require 'functions/combination_images'

class CombinationImagesJob < ActiveJob::Base
  include ActionView::RecordIdentifier
  include CombinationImages

  queue_as :default

  MAX_MATRIX = 3

  def perform(record, image_urls, options)
    output_filename = output_file(record)
    image_files = download_images(image_urls)
    composite_images3 output_filename, image_files, options
    asset_path = options["asset_path"] || "/"
    url = File.join(asset_path, path_2_url(output_filename))
    pp url
    record.update_attributes image: { avatar_url: File.join(asset_path, path_2_url(output_filename)) }

  rescue Exception => ex
    puts ex.message
    puts ex.backtrace.join("\n")
  end

  def output_file(record)
    time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
    FileUtils.mkdir_p  Rails.root.join('public/assets/generatings')
    name = Dir::Tmpname.make_tmpname(dom_id(record) + '_' + time_str, '.jpg')
    fullname = Rails.root.join 'public/assets/generatings', name
    puts "generating image file #{fullname}..."
    fullname
  end

  def download_images(image_urls)
    require 'rest-client'

    dest_path  = Dir::Tmpname.create('combination_images') do |path|
                   FileUtils.mkdir_p path
                 end

    image_urls.map do |url|
      puts "downloading #{url}"
      image = RestClient.get url, :accept => 'image/jpg; image/png; image/gif'
      tmp = Tempfile.new(['download' , get_extname(url, image.headers[:content_type])], dest_path)
      ObjectSpace.undefine_finalizer(tmp)
      puts "to #{tmp.path}"
      tmp.binmode
      tmp.write image
      # tmp.close
      tmp.path
    end
  end

  def get_extname(url, content_type)
    extname = File.extname(url)
    if extname.blank?
      case content_type
      when /image\/jp[e]g/
        '.jpg'
      when /image\/gif/
        '.gif'
      when /image\/png/
        '.png'
      else
        ''
      end
    else
      extname
    end
  end

  def path_2_url(filepath)
    path = Pathname.new(filepath)
    path.relative_path_from(Rails.root.join('public'))
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
