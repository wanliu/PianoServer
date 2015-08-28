#= require _common/event
#= ./modal_base
class @PromotionVariableModal extends @ModalBase

  events:
    'click .promotion': 'onSelectedItem'
    'click .save': 'onSave',
    'change #variable_name': 'onVariableNameChange'

  constructor: (@element, @url) ->
    super(@element, @url)

    @$selected = @$().find('.selected');

  onSelectedItem: (e) ->
    id = $(e.currentTarget).find('.id').text()
    title = $(e.currentTarget).find('.title').text()

    $(e.currentTarget).addClass('active').siblings().removeClass('active')
    @$selected.find('.id').text(id)
    @$selected.find('.title').text(title)
    @$().find('#variable_promotion_id').val(id)

  onSave: (e) ->
    $.post @url, @$().find('.modal-body>form').serialize(), (e) =>
      console.log(e)

  onVariableNameChange: (e) ->
    name = $.trim($(e.target).val())
    url = [@url, '/search_promotion'].join('')

    if (name.length > 0)
      $.get url, { inline: true, q: name }, (json) =>
        @unbindAllEvents()
        @$().find('.modal-body').html(json.html) if json.html?
        @bindAllEvents()


