#=require ./modal_base

class @ItemVariableModal extends @ModalBase

  events:
    'click .item': 'onSelectedItem'
    'click .save': 'onSave'
    'keyup input[name=q]': 'onVariableNameChange'

  constructor: (@element, @url, @$variableList) ->
    super(@element, @url, @$variableList)

    @$selected = @$().find('.selected')

  onSelectedItem: (e) ->
    id = $(e.currentTarget).find('.id').text()
    title = $(e.currentTarget).find('.title').text()

    $(e.currentTarget).addClass('active').siblings().removeClass('active')
    @$selected.find('.id').text(id)
    @$selected.find('.title').text(title)
    @$().find('#variable_item_id').val(id)

  onSave: (e) ->
    item_id = @$().find('#variable_item_id').val()
    name = @$selected

    $.ajax
      type: "POST",
      url: @url,
      data: @$().find('.modal-body>form').serialize(),
      dataType: 'json',
      success: (data) =>
        @$().modal('hide')
        @variableCRUD('add', data)
      error: (jqXHR, textStatus, errorThrown) =>
        json = eval("(" + jqXHR.responseText + ")");
        fields = json.errors.fields

        @hanldeErrors(fields)

  onVariableNameChange: (e) ->
    name = $.trim($(e.target).val())
    url = [@url, '/search_item'].join('')

    if (name.length > 0)
      $.get url, { inline: true, q: name }, (json) =>
        @unbindAllEvents()
        items = json.items
        htmlAry = []

        for item in items
          htmlAry.push(item.html) if item.html?

        @$().find('.promotion-list .list-group').html(htmlAry.join(''))
        @bindAllEvents()

  hanldeErrors: (fields) ->
    $fieldName = @$().find('.field-name')
    $promotions = @$().find('.field-promotion')

    if fields['name']?
      $fieldName.addClass('has-error').find('.help-block').text(fields['name'])
    else
      $fieldName.removeClass('has-error').find('.help-block').text('')

    if fields['promotion_id']?
      $promotions.addClass('has-error').find('.help-block').text(fields['promotion_id'])
    else
      $promotions.removeClass('has-error').find('.help-block').text('')
