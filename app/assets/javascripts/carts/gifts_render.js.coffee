# cartGroupGifts structure有三层，
# 第一层为商店，不同的商店对应的Group不同。第二层为cart_item。第三层为赠品。
# 详见页末测试

class @GiftsRender
  constructor: (options) ->
    @maped = false

    { @cartGroupGifts, @el, @giftTemplate } = options

    @checkStatus = {}

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
        checkedGroupGifts = @getCheckedGroupGifts(supplierId, groupGifts)
        mapStructure[supplierId] = @mergeReduce(checkedGroupGifts)

      mapStructure
    , {})

    _.extend @mapStructure, newMapStructure

    @maped = true

  getCheckedGroupGifts: (supplierId, groupGifts) ->
    clonedGroupGifts = {}

    for cartItemId, gifts of groupGifts
      if @checkStatus[supplierId] && @checkStatus[supplierId][cartItemId] && @checkStatus[supplierId][cartItemId]["checked"] == false
        # next 
      else
        clonedGroupGifts[cartItemId] = _.clone groupGifts[cartItemId]

    clonedGroupGifts

  mergeReduce: (groupGifts) ->
    values = _.values(groupGifts)

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

    return unless @el

    $supplierGroup = @el.find('.cart-group[data-supplier-id=' + supplierId + ']')
    $gifts = $supplierGroup.find('.mobile-cart-gifts')
    $gifts.html('')

    _.each gifts, (gift) =>
      html = @giftTemplate(gift)
      $gifts.append(html)

    if gifts.length > 0
      $gifts.parent('.mobile-gifts').show()
    else
      $gifts.parent('.mobile-gifts').hide()

  # if new gifts data coming
  # modify @cartGroupGifts structure
  # modify @mapStructure based on the changes on @cartGroupGifts
  # rerender specific group gifts
  changeItemGifts: (options) ->
    supplierId = options["supplier_id"]
    itemId = options["cart_item_id"]
    gifts = options.gifts
    itemGifts = @cartGroupGifts[supplierId][itemId] = {}

    _.each gifts, (gift) ->
      itemGifts[gift.id.toString()] = _.clone gift

    @mapGifts({ supplierIds: [supplierId] })
    @renderSingleGroupGifts({ supplierId: supplierId })

  changeCartItemCheckStatus: (options) ->
    supplierId = options.supplierId
    cartItemIds = options.cartItemIds || _.keys @cartGroupGifts[supplierId]

    unless @checkStatus[supplierId]
      @checkStatus[supplierId] = {}

    _.each cartItemIds, (cartItemId) =>
      @checkStatus[supplierId][cartItemId] = { checked: options.status }

    @mapGifts({ supplierIds: [supplierId] })
    @renderSingleGroupGifts({ supplierId: supplierId })

  giftsExisted: (options) ->
    supplierId = options["supplier_id"]
    itemId = options["item_id"]

    supplierId &&
      itemId && 
      @cartGroupGifts[supplierId][itemId] &&
      options.gifts



# datastructure transform tests here
# cartGroupGifts = {
#   1: { # supplier id is 1
#     10: { # cart_item id is 10
#       33: { avatar_url: 'avatar_url', present_id: 123, quantity: 1}, #gift id is 33
#       55: { avatar_url: 'avatar_url', present_id: 156, quantity: 2}
#     },
#     11: {
#       78: { avatar_url: 'avatar_url', present_id: 123, quantity: 1},
#       98: { avatar_url: 'avatar_url', present_id: 188, quantity: 2}
#     }
#   }
#   2: {
#     12: {
#       33: { avatar_url: 'avatar_url', present_id: 123, quantity: 1},
#       55: { avatar_url: 'avatar_url', present_id: 156, quantity: 2}
#     },
#     13: {
#       78: { avatar_url: 'avatar_url', present_id: 123, quantity: 1},
#       98: { avatar_url: 'avatar_url', present_id: 188, quantity: 2}
#     }
#   }
# }


# mapStructure = {
#   1: { # supplier id is 1
#     123: {avatar_url: 'avatar_url', present_id: 123, quantity: 2}, # present id is 123
#     156: {avatar_url: 'avatar_url', present_id: 156, quantity: 2},
#     188: {avatar_url: 'avatar_url', present_id: 188, quantity: 2}
#   }
#   2: {
#     123: {avatar_url: 'avatar_url', present_id: 123, quantity: 2},
#     156: {avatar_url: 'avatar_url', present_id: 156, quantity: 2},
#     188: {avatar_url: 'avatar_url', present_id: 188, quantity: 2}
#   }
# }

# newComingGift = {
#   supplier_id: 1
#   cart_item_id: 10,
#   gifts: [
#     { avatar_url: 'avatar_url', present_id: 123, quantity: 5, id: 33}, 
#     { avatar_url: 'avatar_url', present_id: 156, quantity: 10, id: 55}
#   ]
# }

# cartGroupGiftsChanged = {
#   1: {
#     10: {
#       33: { avatar_url: 'avatar_url', present_id: 123, quantity: 5, id: 33},
#       55: { avatar_url: 'avatar_url', present_id: 156, quantity: 10, id: 55}
#     },
#     11: {
#       78: { avatar_url: 'avatar_url', present_id: 123, quantity: 1},
#       98: { avatar_url: 'avatar_url', present_id: 188, quantity: 2}
#     }
#   }
#   2: {
#     12: {
#       33: { avatar_url: 'avatar_url', present_id: 123, quantity: 1},
#       55: { avatar_url: 'avatar_url', present_id: 156, quantity: 2}
#     },
#     13: {
#       78: { avatar_url: 'avatar_url', present_id: 123, quantity: 1},
#       98: { avatar_url: 'avatar_url', present_id: 188, quantity: 2}
#     }
#   }
# }

# render = new @GiftsRender({
#   cartGroupGifts: cartGroupGifts,
#   el: null,
#   giftTemplate: () -> "template"
# })

# console.assert _.isEqual(render.mapStructure, mapStructure), 
#   '....mapGifts failed test....'

# render.changeItemGifts(newComingGift)
# console.assert _.isEqual(render.cartGroupGifts, cartGroupGiftsChanged),
#   '....changeItemGifts failed test....'