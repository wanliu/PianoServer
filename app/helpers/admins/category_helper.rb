module Admins::CategoryHelper


  def add_property_cateogry_path(*args)
    add_property_admins_industry_category_path *args
  end

  def property_category_path(*args)
    update_property_admins_industry_category_path(*args)
  end

  def remove_property_category_path(*args)
    remove_property_admins_industry_category_path(*args)
  end
end
