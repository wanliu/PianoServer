#= ./modal_base

class @PromotionSetVariableEditModal extends @ModalBase

  events:
    'click .promotion': 'toggleSelectedItem'
    'click .save': 'onSave'
    'keyup input[name=q]': 'onVariableNameChange'

  constructor: (@element, @url, $variableList) ->
    super(@element, @url, $variableList)

    @$seleteds = @$().find('.selected-promotions')
    @$list = @$().find('.promotion-set-variable .list-group')
    @$ids = @$().find('#variable_promotion_string')
    @handleSortable()

  toggleSelectedItem: (e) ->
    $target = $(e.currentTarget)
    id = $target.find('.id').text()
    title = $target.find('.title').text()

    if ($target.hasClass('active'))
      @$seleteds.find('li#' + id).slideUp 250, () ->
        $(this).remove()
        $target.removeClass('active')

      @removePromotionId(id);
    else
      $target.addClass('active')

      new SelectedPromotion(@$seleteds, id, title)

      @addPromotionId(id)

  addPromotionId: (id) ->
    ids = @$ids.val()

    if ids == ''
      @$ids.val(id)
    else
      @$ids.val([ids, id].join(','))

  removePromotionId: (id) ->
    ids = @$ids.val().split(',')
    index = ids.indexOf(id)

    if (index > -1)
      ids.splice(index, 1)
      @$ids.val(ids.join(','))

  onSave: (e) ->
    url = @url.replace('/edit', '')

    $.ajax
      type: "PUT",
      url: url,
      data: @$().find('.modal-body>div>form').serialize(),
      dataType: 'json',
      success: (data) =>
        @$().modal('hide')
        @variableCRUD('update', data)
      error: (jqXHR, textStatus, errorThrown) =>
        json = eval("(" + jqXHR.responseText + ")");
        fields = json.errors.fields

        @hanldeErrors(fields)

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

  hanldeErrors: (fields) ->
    $fieldName = @$().find('.field-name')
    $promotions = @$().find('.field-promotions')

    if fields['name']?
      $fieldName.addClass('has-error').find('.help-block').text(fields['name'])
    else
      $fieldName.removeClass('has-error').find('.help-block').text('')

    if fields['promotion_string']?
      $promotions.addClass('has-error').find('.help-block').text(fields['promotion_string'])
    else
      $promotions.removeClass('has-error').find('.help-block').text('')

  handleSortable: () ->
    $ids = @$ids

    @$().find('ul.selected-promotions').sortable({
      update: (e, ui) ->
        ids = []
        $(this).find('li').map(() ->
          ids.push($(this).attr('id'))
        )

        $ids.val(ids.join(','))
    })

