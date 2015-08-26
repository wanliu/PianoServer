#= require './event'

class @Modal extends @Events

  constructor: (@element, @options) ->
    @remote = @options['remote']


  loadRemoteHtml: () ->
    if @remote?
      @$().find('.modal-body').load(@remote)
