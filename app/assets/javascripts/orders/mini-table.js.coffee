#= require './table'
#
class @MiniTable

  constructor: (@element, @target, @order) ->

    @$().bind 'click', @toggleShow.bind(@)

  $: () ->
    $(@element)

  toggleShow: () ->
    @table ||= new OrderTable(@target, @order)
    $list = $('.chat-list')

    if ($(@target).is(':visible'))
      $(@target).slideUp()
      $list.css('overflow', 'auto')
    else
      $(@target).slideToggle()
      $list.css('overflow', 'hidden')

  send: (event, data) ->
    if @table?
      @table.send(event, data)
