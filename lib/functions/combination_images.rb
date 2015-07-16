module CombinationImages

  def composite_images(filename, image_urls, options = { "size" => { "width" => 100, "height" => 100}})

    rows       = cols = current_vector(image_urls.count)
    space      = 1
    width      = options["size"]["width"]
    height     = options["size"]["height"]
    sub_width  = (width + space) / rows
    sub_height = (height + space) / cols
    size       = "#{sub_width}x#{sub_height}"

    images = image_urls.map do |url| 
      MiniMagick::Image.new(url) do |b|
        b.resize size
      end
    end

    i = 0
    results = concat_images images do |c|
      x = (i / rows) * sub_width + space
      y = (i % cols) * sub_height + space
      # c.resize   "#{width}x#{height}"
      c.compose  "Over"    # OverCompositeOp
      c.geometry "+#{x}+#{y}" # copy second_image onto first_image from (20, 20)      

      puts "x = #{x}, y = #{y}, resize = #{size}, geometry = +#{x}+#{y}"
      i += 1
    end
    results.write(filename)
  end

  def composite_images2(filename, image_urls, options = { "size" => { "width" => 100, "height" => 100}})

    rows       = cols = current_vector(image_urls.count)
    space      = 1
    width      = options["size"]["width"]
    height     = options["size"]["height"]
    sub_width  = (width + space) / rows
    sub_height = (height + space) / cols
    size       = "#{sub_width}x#{sub_height}"

    MiniMagick::Tool::Montage.new do |montage|
      image_urls.each do |url|
        montage << url
      end
      montage.tile "#{rows}x#{cols}"
      montage.geometry "#{size}+#{space}+#{space}"
      # montage.background "#dddddd"
      montage << filename
    end
  end

  def concat_images(images, &block)
    images.inject do |result, image|
      # image.resize size
      result.composite image, &block
    end
  end

  def current_vector(counts)
    vector = Math.sqrt(counts).ceil
    vector < 3 ? (vector > 1 ? vector :  1) : 3
  end  
end
