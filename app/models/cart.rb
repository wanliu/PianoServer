class Cart < ActiveRecord::Base
  has_many :items, class_name: 'CartItem', dependent: :destroy, autosave: true

  def combine(another_cart)
    another_cart.items.each do |item|
      exsited_item = items.find_by(cartable_type: item.cartable_type, cartable_id: item.cartable_id)
      if exsited_item.present?
        exsited_item.quantity += item.quantity
        exsited_item.save
        item.destroy
      else
        self.items << item 
      end
    end
  end

  def items_count
    items.pluck(:quantity).reduce(:+) || 0
  end
end
