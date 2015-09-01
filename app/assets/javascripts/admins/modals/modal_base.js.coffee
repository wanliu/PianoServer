#= require _common/event
class @ModalBase extends @Event

  constructor: (@element, @url) ->
    super(@element)

  destroy: () ->
    @unbindAllEvents()
    @$().find('.modal-body').html('')



