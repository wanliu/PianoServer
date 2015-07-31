#= require './table'
#
class @MiniTable

  constructor: (@element, @target, @order) ->
    @isVisible = false
    @$().bind 'click', @toggleShow.bind(@)

  $: () ->
    $(@element)

  toggleShow: () ->
    @table ||= new OrderTable(@target, @order)
    $list = $('.chat-list')

    if (@isVisible)
      @isVisible = false
      $(@target).slideUp()
      $list.css('overflow', 'auto')
    else
      @isVisible = true
      $(@target).slideDown()
      $list.css('overflow', 'hidden')

  send: (event, data) ->
    if @table?
      @table.send(event, data)
