json.extract! @item, *(@item.attribute_names - ["income_price"])
json.stocks @item.stocks_with_index