#= require _common/event

class @ItemSearch extends @HuEvent
  events:
    'click .btn-search': 'searchItems'

  constructor: (@element, @container) ->
    super(@element)

  searchItems: (e) ->
    $input = @$().find('input')
    q = $.trim($input.val())

    return unless q.length

    @container.send('q:changed', [q]) if @container
