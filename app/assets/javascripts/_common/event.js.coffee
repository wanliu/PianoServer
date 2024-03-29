#= require ./element

class @HuEvent extends @Element
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
      target.bind(event, name, @[value].bind(@))

  unbindAllEvents: () ->
    for event, value of @events
      [event, name] = event.split(' ')
      target = if name? then @$().find(name) else @$()
      target.unbind(event)

  send: (event, data) ->
    @$().trigger(event, data)

  on: (event, handle) ->
    @$().on(event, handle)

