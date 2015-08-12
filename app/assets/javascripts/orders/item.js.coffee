#= require _common/hammer

class @OrderItem
  constructor: (@element, @parent, @itemId = $(@element).data('itemId')) ->
    @$().click(@onClick.bind(@))
    @$().bind('item:price:change', @onPriceChange.bind(@))
    @$().bind('item:amount:change', @onAmountChange.bind(@))
    @$().bind('item:add', @onAddChange.bind(@))
    @$().bind('item:remove', @onRemoveChange.bind(@))
    @$().bind('item:replace', @onReplaceChange.bind(@))

    hammer = new Hammer.Manager(@$()[0])
    hammer.add(new Hammer.Swipe({
      direction: Hammer.DIRECTION_HORIZONTAL,
      velocity: 0.1
    }))
    hammer.on('swipeleft', @onSwipeLeft.bind(@))
    hammer.on('swiperight', @onSwipeRight.bind(@))
    hammer.on('dragleft dragright', @onDrag.bind(@))

  $: () ->
    $(@element)

  onClick: () ->
    $(@parent).trigger('item:select', @element)

  onPriceChange: (e, newVal) ->
    # @$().find('.order-item-price .edit-item-right').text('对方将价格修改为' + newVal)

  onAmountChange: (e, newVal) ->
    # @$().find('.order-item-amount .edit-item-right').text('对方将数量修改为' + newVal)

  onAddChange: (e, data) ->

  onRemoveChange: (e, data) ->
    @$().addClass('order-item-remove').effect('pulsate', times: 3, duration: 1500)

  onReplaceChange: (e, data) ->
    {key, src, dest} = data
    $item = @$().find(".#{key}");
    $value = @$().find(".#{key}>.text")
    prefix = switch key
             when 'price', 'sub_total'
               '￥'
             when 'amount'
               'x'

    $value
      .text(prefix + dest)

    if +src > +dest
      arrow = '↓'
      direction = 'down'
      changeClass = 'change-down'
      animateClass = 'fadeOutDown'
    # else if +src == +dest
    #   arrow = '&#45;'
    else
      arrow = '↑'
      direction = 'up'
      changeClass = 'change-up'
      animateClass = 'fadeOutUp'
    # arrow = if +src > +dest then '&darr;' else '&uarr;'

    $title = $value.next('.title')
    $title
      .text(arrow)
      .removeClass('fadeOutUp fadeOutDown')
      .addClass("animated #{animateClass}")

    $item
      .removeClass('change-down change-up')
      .addClass(changeClass)
      .stop(true, true)
      .effect('pulsate', times: 3, duration: 1500)

    @$().addClass('order-item-modify')
  send: (event, args...) ->
    @$().trigger(event, args...)

  onSwipeLeft: (e) ->
    e.preventDefault()
    @$().addClass('swipeleft')

  onSwipeRight: (e) ->
    e.preventDefault()
    @$().removeClass('swipeleft')

  onDrag: () ->
    return false

