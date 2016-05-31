module GiftHelper
  def gift_json(items)
    gifts = items.reduce({}) do |gs, item|
      shop_item = item.cartable

      gs[item.id] = if shop_item.is_a? Item
        shop_item.eval_available_gifts(item.quantity)

        shop_item.available_gifts.reduce({}) do |inner_gifts, gift|
          if inner_gifts[gift.id].present?
            inner_gifts[gift.id][:quantity] += gift.available_quantity 
          else
            inner_gifts[gift.id] = {
              avatar_url: gift.avatar_url,
              composed_title: truncate("#{gift.present.title} #{gift.properties_title}", length: 15),
              quantity: gift.available_quantity,
              id: gift.id,
              item_id: gift.item_id,
              present_id: gift.present_id
            }
          end
          inner_gifts
        end
      else
        {}
      end
      gs
    end

    gifts.to_json.html_safe
  end
end