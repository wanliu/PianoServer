module AfterRegistersHelper
  PREFIX = "http://neil-img.b0.upaiyun.com/"

  def render_table(groups, &block)
    displays = {
      groups: {},
      categories: {},
      brands: {}
    }

    is_display = proc {|key | displays[key] }
    set_display = proc {|key | displays[key] = true }
    mark_display = proc do |value, *args|
      key = args.map(&:to_s).join('_')
      if is_display.call(key)
        nil
      else
        set_display.call(key)
        value
      end
    end

    index = 0
    groups.each_with_index.map do |group, g_index|
      group["categories"].each_with_index.map do |category, c_index|
        category["brands"].each_with_index.map do |brand, b_index|
          brand["products"].map do |product|
            yield(
              mark_display.call(group, :groups, g_index, group),
              mark_display.call(category, :groups, g_index, :categories, c_index),
              mark_display.call(brand, :groups, g_index, :categories, c_index, :brands, b_index),
              product,
              index+=1
            )
          end.join().html_safe
        end.join().html_safe
      end.join().html_safe
    end.join().html_safe
  end

  def icon_url(url)
    case url
    when NilClass
      blank_image_url
    when String, Symbol
      if url.start_with?(PREFIX)
        url += "!avatar"
      else
        url
      end
    else
      blank_image_url
    end
  end

  def blank_image_url
    asset_url("gray_blank.gif")
  end
end
