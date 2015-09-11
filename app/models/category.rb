class Category < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ESModel

  acts_as_tree :cache_depth => true

  belongs_to :upper, class_name: "Category", foreign_key: 'upper_properties_id'

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

    Property.find_by_sql [query, ancestry_depth, sort_ancestor_ids]
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

  def depth_less_or_eq_to_3
    if parent.depth >= 3
      errors.add(:depth, "层级过多，最多只能有三级")
    end
  end
end
