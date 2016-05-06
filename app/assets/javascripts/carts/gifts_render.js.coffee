# cartGroupGifts structure有三层，
# 第一层为商店，不同的商店对应的Group不同。第二层为商品。第三层为赠品。
# {
#   "1":  #shop(supplier) id
#   { "45": #car_item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   "46": #cart_item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   },
#   "2":  #shop(supplier) id
#   { "47": #cart_item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   },
#   { "48": #cart_item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   }
# }


class @GiftsRender
  constructor: (options) ->
    @maped = false

    @cartGroupGifts = options.cartGroupGifts
    @el = options.el
    @template = options.giftTemplate
    @mapGifts()

  # 将同一个supplier下面的赠品合并数量，以方便渲染
  mapGifts: (options) ->
    supplierIds = if options && options.supplierIds
      options.supplierIds
    else
      _.keys @cartGroupGifts

    @mapStructure || (@mapStructure = {})

    newMapStructure = _.reduce(supplierIds, (mapStructure, supplierId) =>
      groupGifts = @cartGroupGifts[supplierId]

      if !_.isEmpty groupGifts
        mapStructure[supplierId] = @mergeReduce(groupGifts)

      mapStructure
    , {})

    _.extend @mapStructure, newMapStructure

    @maped = true

  mergeReduce: (obj) ->
    values = _.values(obj)

    _.reduce(values, (result, gifts) ->
      return result if _.isEmpty(gifts)

      _.each gifts, (gift, giftId) ->
        return if _.isEmpty(gift)
        presentId = gift.present_id

        if result[presentId]
          result[presentId]["quantity"] += gift["quantity"]
        else
          result[presentId] = _.clone gift

      result
    , {})


  render: (options) ->
    supplierIds = options && options.supplierIds 
    if _.isEmpty(supplierIds)
      supplierIds = _.keys(@mapStructure)

    _.each supplierIds, (supplierId) =>
      groupGifts = @mapStructure[supplierId]
      return if _.isEmpty(groupGifts)

      @renderSingleGroupGifts({
        supplierId: supplierId
      })

  renderSingleGroupGifts: (options) ->
    supplierId = options.supplierId
    gifts = @mapStructure[supplierId]
    gifts = _.sortBy gifts, (gift) ->
      return gift.id

    $supplierGroup = @el.find('.cart-group[data-supplier-id=' + supplierId + ']')
    $gifts = $supplierGroup.find('.mobile-cart-gifts')
    $gifts.html('')

    _.each gifts, (gift) =>
      html = @template(gift)
      $gifts.append(html)

    $gifts.parent('.mobile-gifts').show()

  # if new gifts data coming
  # modify @cartGroupGifts structure
  # modify @mapStructure based on the changes on @cartGroupGifts
  # rerender specific group gifts
  changeItemGifts: (options) ->
    supplierId = options["supplier_id"]
    itemId = options["cart_item_id"]
    gifts = options.gifts
    itemGifts = @cartGroupGifts[supplierId][itemId]

    _.each gifts, (gift) ->
      giftItem = itemGifts[gift.id.toString()] || itemGifts[gift.id]

      if giftItem
        giftItem["quantity"] = gift.quantity
      else
        itemGifts[gift.id.toString()] = _.clone gift

    @mapGifts({ supplierIds: [supplierId] })
    @renderSingleGroupGifts({ supplierId: supplierId })

  giftsExisted: (options) ->
    supplierId = options["supplier_id"]
    itemId = options["item_id"]

    supplierId &&
      itemId && 
      @cartGroupGifts[supplierId][itemId] &&
      options.gifts({
        supplier_id: supplierId,
        item_id: itemId
      })

# class @GiftsRenderTrigger
#   constructor: (options) ->
#     @giftRender = options.giftRender

#   onGiftChange: (options) ->
