#= require _common/event
#= ./modal_base
class @PromotionVariableModal extends @ModalBase

  events:
    'click .promotion': 'onSelectedItem'
    'click .save': 'onSave'

  constructor: (@element, @url) ->
    super(@element)

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
