class Category < ActiveRecord::Base
  HashEx = ActiveSupport::HashWithIndifferentAccess

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  acts_as_tree :cache_depth => true

  belongs_to :upper, class_name: "Category", foreign_key: 'upper_properties_id'
  belongs_to :brand

  has_and_belongs_to_many :properties

  def with_upper_properties(inhibit = true)
    cond_string = [ "u.rk = 1", inhibit ? "u.state = 0" : nil ].compact.join(" and ")

    # | id | name                      | title          | summary | unit_type | prop_type | state | upperd | category_id | ancestry_depth | rk |
    # |----|---------------------------|----------------|---------|-----------|-----------|-------|--------|-------------|----------------|----|
    # | 4  | factory                   | 生产厂家       |         |           | string    | 0     | f      | 5           | 3              | 1  |
    # | 4  | factory                   | 生产厂家       |         |           | string    | 0     | t      | 3           | 1              | 2  |
    # | 5  | production_license_number | 生产许可证编号 |         |           | number    | 0     | t      | 3           | 1              | 1  |
    # | 6  | shelf_life                | 保质期         |         | 天        | days      | 1     | f      | 5           | 3              | 1  |
    # | 6  | shelf_life                | 保质期         |         | 天        | days      | 0     | t      | 4           | 2              | 2  |

    query = <<-SQL
      WITH
        uppers AS (
          SELECT  p.*,
            cp.state,
            c.id as category_id,
            c.ancestry_depth as ancestry_depth,
            c.ancestry_depth < ? as upperd,
            ROW_NUMBER() OVER(PARTITION BY p.name
                                         ORDER BY c.ancestry_depth DESC) AS rk
          FROM "properties" p
            INNER JOIN "categories_properties" cp
              ON "cp"."property_id" = "p"."id"
              INNER JOIN "categories" c
                ON "c"."id" = "cp"."category_id"
                WHERE (cp.category_id in (?)) )
      SELECT u.*
          FROM uppers u
          WHERE #{cond_string}
    SQL

    Property.find_by_sql [query.squish, ancestry_depth, sort_ancestor_ids]
  end

  def definition_properties
    @defintion_properties ||= HashEx[with_upper_properties.map do |property|
      _hash = {
        name: property.name,
        title: property.title,
        type: property.prop_type,
        value: property.data.try(:[], "value"),
      }

      _hash["unit_type"] = property.data["unit_type"] if property.data.try :has_key?, "unit_type"
      _hash["unit_id"] = property.data["unit_id"] if property.data.try :has_key?, "unit_id"
      _hash["default"] = property.data["default"] if property.data.try :has_key?, "default"
      _hash["validates"] = property.data["validate_rules"] if property.data.try :has_key?, "validate_rules"

      case property.prop_type
      when "map"
        _hash["map"] = property.data["map"]
        _hash["group"] = property.data["group"] if property.data.try :has_key?, "group"
      end

      [property.name, _hash]
    end]
  end

  def item_desc
    lookup_path = item_desc_lookup_path

    if lookup_path.present?
      File.read(lookup_path)
    else
      ""
    end
  end

  def item_desc=(content)
    unless File.exist? item_desc_dir
      FileUtils.mkdir_p item_desc_dir
    end

    File.write item_desc_path, content
  end

  def item_desc_lookup_path
    cate_with_template = path.reverse_order.find do |cate|
      File.exists? cate.item_desc_path
    end

    cate_with_template.item_desc_path if cate_with_template.present?
  end

  def item_desc_path
    "#{item_desc_dir}/#{id}.txt"
  end

  def item_desc_dir
    "#{Rails.root}/.sites/system/category_item_descriptions"
  end

  def inhibit_count
    Category.joins(:properties).where("categories_properties.category_id = ? and categories_properties.state = 1", id).count
  end

  def sort_ancestor_ids
    upper.blank? ? [id] : [*upper.ancestor_ids, upper.id, id]
  end

  def upper
    super || parent
  end

  def title
    super || name
  end

  # 伪代码 展开分类显示
  def open
    true
  end

  def is_leaf
    !has_children?
  end
end
