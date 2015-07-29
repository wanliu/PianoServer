
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


  onAmountChange: (e, newVal) ->

  onAddChange: (e, data) ->

  onRemoveChange: (e, data) ->

  onReplaceChange: (e, data) ->
    {key, src, dest} = data
    $value = @$().find(".#{key}")
    $value
      .text(dest)
    arrow = if +src > +dest then '&darr;' else '&uarr;'

    $title = $value.next('.title')
    $title
      .html("<span class=\"label label-success\">#{arrow} 修改</span>")
      .effect('pulsate', times: 3, duration: 1500)

  send: (event, args...) ->
    @$().trigger(event, args...)

