
class @OrderItem
  constructor: (@element, @parent, @itemId = $(@element).data('itemId')) ->
    @$().click(@onClick.bind(@))
    @$().bind('item:price:change', @onPriceChange.bind(@))
    @$().bind('item:amount:change', @onAmountChange.bind(@))

  $: () ->
    $(@element)

  onClick: () ->
    $(@parent).trigger('item:select', @element)

  onPriceChange: (e, newVal) ->


  onAmountChange: (e, newVal) ->
