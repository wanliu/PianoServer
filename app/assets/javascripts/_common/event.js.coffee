#= require ./element

class @Event extends @Element
  constructor: (@element) ->
    super(@element)
    @bindAllEvents()

    setTimeout () =>
      @send('init', @)
    , 10

  bindAllEvents: () ->
    for event, value of @events
      [event, name] = event.split(' ')
      target = if name? then @$().find(name) else @$()
      target.on(event, name, @[value].bind(@))

  unbindAllEvents: () ->
    for event, value of @events
      [event, name] = event.split(' ')
      target = if name? then @$().find(name) else @$()
      target.off(event)

  send: (event, data) ->
    @$().trigger(event, data)

  on: (event, handle) ->
    @$().on(event, handle)

