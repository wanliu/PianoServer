module CombinationImages

  def composite_images1(filename, image_paths, options = { "size" => { "width" => 100, "height" => 100}})

    rows       = cols = current_vector(image_paths.count)
    space      = 1
    width      = options["size"]["width"]
    height     = options["size"]["height"]
    sub_width  = (width + space) / rows
    sub_height = (height + space) / cols
    size       = "#{sub_width}x#{sub_height}"

    images = image_paths.map do |path| 
      MiniMagick::Image.new(path) do |b|
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

  def composite_images2(filename, image_paths, options = { "size" => { "width" => 100, "height" => 100}})
    rows       = cols = current_vector(image_paths.count)
    space      = 1
    width      = options["size"]["width"]
    height     = options["size"]["height"]
    sub_width  = (width + space) / rows
    sub_height = (height + space) / cols
    size       = "#{sub_width}x#{sub_height}"

    MiniMagick::Tool::Montage.new do |montage|
      image_paths.each do |path|
        montage << path
      end
      montage.tile "#{rows}x#{cols}"
      montage.geometry "#{size}+#{space}+#{space}"
      # montage << "-background #dddddd"
      montage << filename
    end
  end

  def composite_images3(filename, image_paths, options = { "size" => { "width" => 100, "height" => 100}})
    rows        = cols = current_vector(image_paths.count)
    space       = image_paths.count ? 1 : 0
    width       = options["size"]["width"]
    height      = options["size"]["height"]
    sub_width   = width / cols
    sub_height  = height / rows
    real_width  = (width - ((cols + 1) * space)) / cols
    real_height = (height - ((rows + 1) * space)) / rows
    size        = "#{real_width}x#{real_height}"

    MiniMagick::Tool::Convert.new do |convert|
      convert.size "#{width}x#{height}"
      convert.xc '#ddd'
      (rows * cols).times do |i|
        path = image_paths[i]
        x = (i % cols) * sub_width + space
        y = (i / rows) * sub_height + space
        convert << (path.nil? ? "xc:#ccc" : path)
        convert.geometry "#{size}+#{x}+#{y}"
        convert.composite
        # convert.draw "'image over #{x},#{y} #{sub_width},#{sub_width} #{path}'"
      end
      convert << filename
    end

    # alias composite_images composite_images3
    # alias_method :composite_images, :composite_images3
    # alias :comp
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
