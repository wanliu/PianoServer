$ () ->
  $('.js-buy-now').click (event) ->
    if $(@).hasClass('disabled')
      return
    cartableType = $(@).data('cartableType')
    cartableId = $(@).data('cartableId')
    properties = ($(@).data('properties') || {})
    quantity = $('.cart_item_quantity').val() || 1
    csrfToken = $('meta[name=csrf-token]').attr('content')

    queryString = $.param({
      cart_item: {
        orderable_type: cartableType,
        orderable_id: cartableId,
        properties: properties,
        quantity: quantity
      }
    })

    action = '/orders/buy_now_confirm?' + queryString

    $buyNowForm = $("""
      <form action="#{action}" accept-charset="UTF-8" style="display: none;" method="post">
        <input name="utf8" type="hidden" value="✓">
        <input type="hidden" name="authenticity_token" value="#{csrfToken}">
      </form>
    """)

    $('body').append($buyNowForm);
    $buyNowForm.submit()