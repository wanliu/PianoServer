#= require _common/event

class @CategoryKeyword extends @HuEvent
  constructor: (@element, @container) ->
    super(@element)
    @container.setKeyword(@) if @container?
    @on('q:changed', @qChanged.bind(@))

  qChanged: (e, q) ->
    ruturn unless q.length

    template = """
      #{q}
      <span class="glyphicon glyphicon-remove remove-icon" aria-hidden="true"></span>
    """
    @$().html(template).css('display', 'inline-block')

    @$().find('.remove-icon').click(() =>
      @$().html('').hide()
      @container.send('q:empty') if @container?
    )
