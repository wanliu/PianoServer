#= require _common/event

class @ItemSearch extends @HuEvent
  events:
    'click .btn-search': 'searchItems'

  constructor: (@element, @container) ->
    super(@element)
    @on('q:empty', @qEmpty.bind(@))

  searchItems: (e) ->
    $input = @$().find('input')
    q = $.trim($input.val())

    return unless q.length

    $input.val('')

    @container.send('q:changed', [q]) if @container
    @keyword.send('q:changed', [q]) if @keyword

  qEmpty: () ->
    @container.send('q:empty')

  setKeyword: (category_keyword) ->
    @keyword = category_keyword
