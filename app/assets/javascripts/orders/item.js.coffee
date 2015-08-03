
class @OrderItem
  constructor: (@element, @parent, @itemId = $(@element).data('itemId')) ->
    @$().click(@onClick.bind(@))
    @$().bind('item:price:change', @onPriceChange.bind(@))
    @$().bind('item:amount:change', @onAmountChange.bind(@))
    @$().bind('add', @onAddChange.bind(@))
    @$().bind('remove', @onRemoveChange.bind(@))
    @$().bind('replace', @onReplaceChange.bind(@))

  $: () ->
    $(@element)

  onClick: () ->
    $(@parent).trigger('item:select', @element)

  onPriceChange: (e, newVal) ->
    @$().find('.order-item-price .edit-item-right').text('对方将价格修改为' + newVal)

  onAmountChange: (e, newVal) ->
    @$().find('.order-item-amount .edit-item-right').text('对方将数量修改为' + newVal)

  onAddChange: (e, data) ->

  onRemoveChange: (e, data) ->

  onReplaceChange: (e, data) ->
    {key, src, dest} = data
    $item = @$().find(".#{key}");
    $value = @$().find(".#{key}>.text")
    prefix = switch key
             when 'price'
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

