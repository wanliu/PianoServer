#= require ./event

class @SaveOnChange extends @HuEvent

  events:
    'change [save_on_change]': 'preformChange'

  constructor: (@formElement, @options = {url: null}) ->
    super(@formElement)
    @url = if @options.url? then @options.url else @$().attr('action')

  preformChange: (e) ->
    value = $(e.target).val()
    queryString = "#{$(e.target).attr('name')}=#{value}"
    $.ajax({
      url: @url,
      type: 'POST',
      data: queryString,
    }).then (e) =>
      console.log(value)

  onChangeSave: (e) ->
    console.log(e)
