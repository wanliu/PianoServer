#= ./modal_base

class @PromotionVariableModal extends @ModalBase

  events:
    'click .promotion': 'onSelectedItem'
    'click .save': 'onSave'
    'change input[name=q]': 'onVariableNameChange'

  constructor: (@element, @url, @$variableList) ->
    super(@element, @url, @$variableList)

    @$selected = @$().find('.selected')

  onSelectedItem: (e) ->
    id = $(e.currentTarget).find('.id').text()
    title = $(e.currentTarget).find('.title').text()

    $(e.currentTarget).addClass('active').siblings().removeClass('active')
    @$selected.find('.id').text(id)
    @$selected.find('.title').text(title)
    @$().find('#variable_promotion_id').val(id)

  onSave: (e) ->
    promotion_id = @$().find('#variable_promotion_id').val()
    name = @$selected

    $.ajax
      type: "POST",
      url: @url,
      data: @$().find('.modal-body>form').serialize(),
      dataType: 'json',
      success: (data) =>
        @$().modal('hide')
        @variableCRUD('add', data)

  onVariableNameChange: (e) ->
    name = $.trim($(e.target).val())
    url = [@url, '/search_promotion'].join('')

    if (name.length > 0)
      $.get url, { inline: true, q: name }, (json) =>
        @unbindAllEvents()
        promotions = json.promotions
        htmlAry = []

        for promotion in promotions
          htmlAry.push(promotion.html) if promotion.html?

        @$().find('.promotion-list .list-group').html(htmlAry.join(''))
        @bindAllEvents()
