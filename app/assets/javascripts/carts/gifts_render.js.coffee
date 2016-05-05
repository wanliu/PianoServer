# cartGroupGifts structure有三层，
# 第一层为商店，不同的商店对应的Group不同。第二层为商品。第三层为赠品。
# {
#   "1":  #shop(supplier) id
#   { "45": #item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   "46": #item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   },
#   "2":  #shop(supplier) id
#   { "47": #item id
#     { # gift_id: gift properties 
#       "3": {avatar_url: 'xxx', title: 'xxxx', quantity: '1'},
#       "4": {avatar_url: 'xxx', title: 'xxxx', quantity: '2'}
#     },
#   },
#   { "48": #item id
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
    supplierIds = _.keys @cartGroupGifts

    @mapStructure = _.reduce(supplierIds, (mapStructure, supplierId) =>
      groupGifts = @cartGroupGifts[supplierId]

      if !_.isEmpty groupGifts
        mapStructure[supplierId] = @mergeReduce(groupGifts)

      mapStructure
    , {})

    @maped = true

  mergeReduce: (obj) ->
    values = _.values(obj)

    _.reduce(values, (result, gifts) ->
      return result if _.isEmpty(gifts)

      _.each gifts, (gift, giftId) ->
        return if _.isEmpty(gift)

        if result[giftId]
          result[giftId]["quantity"] += gift["quantity"]
        else
          result[giftId] = gift

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
        supplierId: supplierId,
        gifts: groupGifts
      })

  renderSingleGroupGifts: (options) ->
    supplierId = options.supplierId
    gifts = _.sortBy options.gifts, (gift) ->
      return gift.id

    $supplierGroup = @el.find('.cart-group[data-supplier-id=' + supplierId + ']')
    $gifts = $supplierGroup.find('.mobile-cart-gifts')

    _.each gifts, (gift) =>
      html = @template(gift)
      $gifts.append(html)

    $gifts.parent('.mobile-gifts').show()