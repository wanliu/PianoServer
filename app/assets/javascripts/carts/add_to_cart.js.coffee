$ ()->
  $('body').on 'click', '.add-to-cart', (event) ->
    cartableType = $(@).data('cartableType')
    cartableId   = $(@).data('cartableId')
    properties   = $(@).data('properties') || {}
    $quantityInput = $(@).parents('form').find('input.cart_item_quantity')
    quantity = if $quantityInput.length
      $quantityInput.val() || 1
    else
      1

    promoise = $.post('/cart_items', {
      cart_item: {
        cartable_type: cartableType,
        cartable_id: cartableId,
        properties: properties,
        quantity: quantity
      }
    })

    promoise.done((data, status, xhr) ->
      itemId = data.id
      $item = $('.cart-item-list').children("li[data-item-id=#{itemId}]")

      if $item.length
        $item.find('span.quantity').text(data.quantity)
      else if $('.cart-item-list').children("li[data-item-id=#{itemId}]").length < 4
        $divider = $('.cart-item-list .divider')

        unless $divider.length
          $divider = $('<li role="separator" class="divider"></li>')
          $('.cart-item-list').prepend($divider)

        item = data
        html = """
          <li class='cart-item' data-item-id='#{ item.id }'>
            <a href=#{ item.url }>
              <div class="media">
                <div class="media-left">
                  <img src="#{ item.avatar_url }" class='cart-item-image' />
                </div>
                <div class="media-body">
                  <h4 class="media-heading">#{ item.title || "" }</h4>
                  <p>x <span class="quantity">#{ item.quantity }</span></p>
                  <p class="price">#{ item.price }</p>
                </div>
              </div>
            </a>
          </li>
        """

        $divider.before(html)

      $('.cart-item-count').text(data.items_count)
    )

    promoise.fail((data, status, xhr) ->
      # TODO fail to add to cart
    )
