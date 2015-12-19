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
    record.update_attributes image: { avatar_url: File.join(asset_path, path_2_url(output_filename)).to_s }
    record.create_status state: :done

  rescue Exception => ex
    puts ex.message
    puts ex.backtrace.join("\n")
  end

  def output_file(record)
    time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
    FileUtils.mkdir_p  Rails.root.join('public/generatings')
    name = Dir::Tmpname.make_tmpname(dom_id(record) + '_' + time_str, '.jpg')
    fullname = Rails.root.join 'public/generatings', name
    puts "generating image file #{fullname}..."
    fullname
  end

  def download_images(image_urls)
    require 'rest-client'

    dest_path  = Dir::Tmpname.create('combination_images') do |path|
                   FileUtils.mkdir_p path
                 end

    image_urls.map do |url|
      path = nil

      begin
        puts "downloading #{url}"
        image = RestClient.get url, :accept => 'image/jpg; image/png; image/gif'
        tmp = Tempfile.new(['download' , get_extname(url, image.headers[:content_type])], dest_path)
        ObjectSpace.undefine_finalizer(tmp)
        puts "to #{tmp.path}"
        tmp.binmode
        tmp.write image
        # tmp.close
        path = tmp.path
      rescue Exception => ex
        path = nil
      end
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
end
