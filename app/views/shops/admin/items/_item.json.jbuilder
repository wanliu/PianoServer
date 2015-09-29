json.(item, *item.attributes.keys)
json.image_url item.image.url(:avatar)
json.shop_category_title item.shop_category.try(:title)
