#= require _common/event
#= ./modal_base
class @PromotionSetVariableModal extends @ModalBase

  events:
    'click .promotion': 'toggleSelectedItem'
    'click .save': 'onSave'
    'change input[name=q]': 'onVariableNameChange'

  constructor: (@element, @url, $variableList) ->
    super(@element, @url)

    @$seleteds = @$().find('.selected-promotions')
    @$list = @$().find('.promotion-set-variable .list-group')
    @$ids = @$().find('#variable_promotion_string')

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
    $.ajax
      type: "POST",
      url: @url,
      data: @$().find('.modal-body>div>form').serialize(),
      dataType: 'json',
      success: (data) =>
        @$().modal('hide')
        @$().find('.modal-body').html('')

        {id, name} = data
        templateVariables = @$variableList.data('plugin')
        templateVariables.addVariable(id, name)

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

