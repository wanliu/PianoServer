#= require ./element

class @Event extends @Element
  constructor: (@element) ->
    super(@element)

    setTimeout () =>
      @send('init', @)
    , 10

  send: (event, data) ->
    @$().trigger(event, data)

  on: (event, handle) ->
    @$().on(event, handle)
