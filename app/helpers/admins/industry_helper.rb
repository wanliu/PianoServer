module Admins::IndustryHelper

  def toggle_arrow(category, open = false)
    if category.children.empty?
      raw "<span></span>"
    else
      icon open ? :'chevron-down' : :'chevron-right'
    end
  end

  def child_depth(category)
    category.depth - 1
  end
end
