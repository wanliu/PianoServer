#= require lib/jquery.path
$ ()->
  $('body').on 'click', '.add-to-cart', (event) ->
    cartableType = $(@).data('cartableType')
    cartableId   = $(@).data('cartableId')
    moveable     = $(@).data('moveable')
    properties   = $(@).data('properties') || {}
    target       = if $(window).width() < 768 then $('.navbar-toggle') else $('.mycart')
    $quantityInput = $(@).parents('form').find('input.cart_item_quantity')
    quantity = if $quantityInput.length
      $quantityInput.val() || 1
    else
      1

    p1 = $(moveable).offset()
    p2 = $(target).offset()


    path = {
      start: {
        x: p1.left,
        y: p1.top,
        # length: 0.707
      },
      end: {
        x: p2.left + 20,
        y: p2.top + 20,
        angle: 315.012,
        # length: 0.707
      }
    };

    $(moveable).clone().appendTo('body').css({
      position: 'absolute',
      left: p1.left,
      top: p1.top,
      width: $(moveable).width(),
      height: $(moveable).height(),
      zIndex: 1040,
      opacity: 1
    }).animate({
      path : new $.path.bezier(path),
      width: 10,
      height: 10
      opacity: 0,
    }, () ->
      $(target)
        .stop(true, true)
        .animate({ top: -15 }, 50)
        .animate({ top: 15 }, 30)
        .animate({ top: -15 }, 60)
        .animate({ top: 15 }, 40)
        .animate({ top: -15 }, 60)
        .animate({ top: 15 }, 30)
        .animate({ top: 0 }, { duration: 70, easing: 'easeOutBounce'})
      # $(target).effect("bounce", { left: 15 })
      @remove()
    )

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
      $(document).trigger('cart_quantity_changed', [ quantity ])
    )

    promoise.fail((data, status, xhr) ->
      # TODO fail to add to cart
    )
