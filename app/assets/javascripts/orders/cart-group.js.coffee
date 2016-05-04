class @CartGroup
  @calculateGroupTotal: ($group) ->
    if !($group instanceof jQuery)
      $group = $($group)

    saleableSelected = _.filter $group.find('.cart-item.saleable'), (item) ->
      $(item).find('.avatar :checkbox').prop('checked')

    totals = _.reduce(saleableSelected, (mem, item) ->
      $quantity = $(item).find('.quantity')

      quantityVal = $quantity.val() || $quantity.text()
      quantity = parseInt(quantityVal, 10)
      total = parseFloat($(item).data('total'), 10)

      mem.quantity || (mem.quantity = 0)
      mem.total || (mem.total = 0)
      
      mem.quantity += quantity
      mem.total += total
      return mem
    , {})

    $group.find('.footer .total-quantity')
      .text(totals.quantity || 0)

    $group.find('.footer .total-total')
      .text((totals.total || 0)
      .toFixed(2))

    if isNaN(totals.quantity) || totals.quantity == 0
      $group.find('.cart-submit')
        .attr('type','button')
        .css('opacity', 0.5)
    else
      $group.find('.cart-submit')
        .attr('type','submit')
        .css('opacity', 1)

  @changeQuantity: (quantityInput, quantity, reflect) ->
    $cartItem = $(quantityInput)
      .closest('.cart-item')

    # // ===========================================
    # // ============/===============================
    $btnMinus = $cartItem.find('span.btn-minus')
    $alert = $cartItem.find('tr.error, .alert')

    $group = $(quantityInput).parents('.cart-group')

    if (+quantity > 1)
      $btnMinus.addClass('glyphicon-minus')
    else
      $btnMinus.removeClass('glyphicon-minus')

    cartItemId = $cartItem.data('cartItemId')
    request = $.post('/cart_items/' + cartItemId, {
      _method: 'PATCH',
      cart_item: {
        quantity: quantity,
      }
    })

    request.done (data, xhr, status) ->
      $subTotal = $cartItem.find('.subtotal')
      $subTotal.text(parseFloat(data.sub_total).toFixed(2))
      $cartItem.data('total', data.sub_total)

      $('.cart-item-count').text(data.ccount)

      $(document).trigger('cart_quantity_changed', [ data.ccount ])

      CartGroup.rerenderGifts({gifts: data.gifts, el: $cartItem});
      CartGroup.calculateGroupTotal($group)

      if !reflect
        $alert.hide()

    request.fail (data, xhr, status) ->
      # // usually caused by the lack of inventory
      quanOpt = data.responseJSON && data.responseJSON.quantity

      if quanOpt
        maxQuan = quanOpt[0]
        $alert.find('.max-quantity').text(maxQuan)
        $alert.show()

        if quantityInput.is('input') 
          quantityInput.val(maxQuan)
        else
          quantityInput.text(maxQuan)

        CartGroup.changeQuantity(quantityInput, maxQuan, true)

  @rerenderGifts: (options) ->
    itemId = options.el.data('cartItemId')
    $giftTr = options.el.siblings('[data-cart-item-id=' + itemId + ']')
    gifts = options.gifts
    giftTemplate = _.template($("#cart-item-gifts-template").html())

    return if !gifts

    html = _.reduce(gifts, (htm, gift) ->
      htm += giftTemplate(gift)
    , '')

    $giftTr.find('td').html(html)
    $giftTr.show()