#= require './table'
#
class @MiniTable

  constructor: (@element, @target, @order) ->

    @$().bind 'click', @toggleShow.bind(@)

  $: () ->
    $(@element)

  toggleShow: () ->
    @table ||= new OrderTable(@target, @order)
    $(@target).slideToggle()

  send: (event, data) ->
    if @table?
      @table.send(event, data)
