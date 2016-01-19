#=require ./modal_base

class @ItemSetVariableModal extends @ModalBase

  events:
    'click .item': 'toggleSelectedItem'
    'click .save': 'onSave'
    'keyup input[name=q]': 'onVariableNameChange'

  constructor: (@element, @url, $variableList) ->
    super(@element, @url, $variableList)

    @$seleteds = @$().find('.selected-items')
    @$list = @$().find('.item-set-variable .list-group')
    @$ids = @$().find('#variable_items_string')

  toggleSelectedItem: (e) ->
    $target = $(e.currentTarget)
    id = $target.find('.id').text()
    title = $target.find('.title').text()

    if ($target.hasClass('active'))
      @$seleteds.find('li#' + id).slideUp 250, () ->
        $(this).remove()
        $target.removeClass('active')

      @removeItemId(id);
    else
      $target.addClass('active')

      new SelectedItem(@$seleteds, id, title)

      @addItemId(id)

  addItemId: (id) ->
    ids = @$ids.val()

    if ids == ''
      @$ids.val(id)
    else
      @$ids.val([ids, id].join(','))

  removeItemId: (id) ->
    ids = @$ids.val().split(',')
    index = ids.indexOf(id)

    if (index > -1)
      ids.splice(index, 1)
      @$ids.val(ids.join(','))

  onSave: (e) ->
    $.ajax
      type: "POST",
      url: @url,
      data: @$().find('.modal-body>div>form').serialize(),
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

        @$().find('.item-list .list-group').html(htmlAry.join(''))
        @bindAllEvents()

  hanldeErrors: (fields) ->
    $fieldName = @$().find('.field-name')
    $items = @$().find('.field-items')

    if fields['name']?
      $fieldName.addClass('has-error').find('.help-block').text(fields['name'])
    else
      $fieldName.removeClass('has-error').find('.help-block').text('')

    if fields['items_string']?
      $items.addClass('has-error').find('.help-block').text(fields['items_string'])
    else
      $items.removeClass('has-error').find('.help-block').text('')
