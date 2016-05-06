module GiftHelper
  def gift_json(items)
    gifts = items.reduce({}) do |gs, item|
      gs[item.id] = 
      if item.cartable.try(:gifts).present?
        item.cartable.gifts.reduce({}) do |gs_inner, gift|
          quantity = gift.available_quantity(item.quantity)

          if quantity > 0
            if gs_inner[gift.id].present?
              gs_inner[gift.id][:quantity] += quantity 
            else
              gs_inner[gift.id] = {
                avatar_url: gift.avatar_url,
                composed_title: "#{gift.present.title} #{gift.properties_title}",
                quantity: quantity,
                id: gift.id,
                item_id: gift.item_id,
                present_id: gift.present_id
              }
            end
          end
          gs_inner
        end
      else
        {}
      end
      gs
    end

    gifts.to_json.html_safe
  end
end