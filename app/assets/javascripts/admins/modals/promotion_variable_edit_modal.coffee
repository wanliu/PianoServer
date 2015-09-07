#= ./modal_base

class @PromotionVariableEditModal extends @ModalBase

  events:
    'click .save': 'onSave'
    'click .selected': 'showPromotions'
    'click .promotion': 'onSelectedItem'
    'change input[name=q]': 'onVariableNameChange'

  constructor: (@element, @url, @$variableList) ->
    super(@element, @url, @$variableList)
    @$selected = @$().find('.selected')

  onSave: () ->
    $.ajax
      type: 'PUT',
      url: @url.replace('/edit', ''),
      data: @$().find('.modal-body>form').serialize(),
      dataType: 'json',
      success: (data) =>
        @$().modal('hide')
        @variableCRUD('update', data)

  showPromotions: () ->
    @$().find('.list-group.selected').addClass('pressed')
    @$().find('.promotion-list').removeClass('hidden')

  onSelectedItem: (e) ->
    id = $(e.currentTarget).find('.id').text()
    title = $(e.currentTarget).find('.title').text()

    $(e.currentTarget).addClass('active').siblings().removeClass('active')
    @$selected.find('.id').text(id)
    @$selected.find('.title').text(title)
    @$().find('#variable_promotion_id').val(id)

  onVariableNameChange: (e) ->
    name = $.trim($(e.target).val())
    str = "variables"
    index = @url.indexOf(str)

    url = [@url.slice(0, index + str.length), '/search_promotion'].join('')

    if (name.length > 0)
      $.get url, { inline: true, q: name }, (json) =>
        @unbindAllEvents()
        promotions = json.promotions
        htmlAry = []

        for promotion in promotions
          htmlAry.push(promotion.html) if promotion.html?

        @$().find('.promotion-list .list-group').html(htmlAry.join(''))
        @bindAllEvents()


