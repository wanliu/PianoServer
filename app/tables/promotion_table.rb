class PromotionTable < TableCloth::Base
  # Define columns with the #column method
  column :id, :type, :title, :status, :product_id, :shop_id, :shop_name, :product_price, :created_at, :start_time

  # Columns can be provided a block
  #
  column :type do  |object|
    case object.type
    when 'promotions/discount'
      '折扣'
    when 'promotions/time_limited_sale'
      '限时'
    else
      '其它'
    end
  end
  # column :name do |object|
  #   object.downcase
  # end
  #
  # Columns can also have conditionals if you want.
  # The conditions are checked against the table's methods.
  # As a convenience, the table has a #view method which will return the current view context.
  # This gives you access to current user, params, etc...
  #
  # column :email, if: :admin?
  #
  # def admin?
  #   view.current_user.admin?
  # end
  #
  # Actions give you the ability to create a column for any actions you'd like to provide.
  # Pass a block with an arity of 2, (object, view context).
  # You can add as many actions as you want.
  # Make sure you include the actions extension.
  #
  # actions do
  #   action {|object| link_to "Edit", edit_object_path(object) }
  #   action(if: :valid?) {|object| link_to "Invalidate", invalidate_object_path(object) }
  # end
  #
  # If action provides an "if:" option, it will call that method on the object. It can also take a block with an arity of 1.
end
