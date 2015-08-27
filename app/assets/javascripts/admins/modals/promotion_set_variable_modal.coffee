#= require _common/event
#= ./modal_base

class @PromotionSetVariableModal extends @ModalBase

  events:
    'click .promotion': 'toggleSelectedItem',
    'click .remove-promotion': 'removeSelectedItem'

  constructor: (@element, @url) ->
    super

    @$seleteds = @$().find('.selected-promotions')
    @$list = @$().find('.promotion-set-variable .list-group')
    @$ids = @$().find('#variable_promotion_string')

  toggleSelectedItem: (e) ->
    $target = $(e.currentTarget)
    id = $target.find('.id').text()
    title = $target.find('.title').text()

    if ($target.hasClass('active'))
      $target.removeClass('active')

      @$seleteds.find('li#' + id).remove();

      @removePromotionId(id);
    else
      $target.addClass('active')

      html = ['<li class="selected-promotion" id="', id,
        '" ><div class="promotion-name">', title, '</div><div class="remove-promotion">',
        '<span class="glyphicon glyphicon-remove"></span></div>', '</li>']

      $(html.join('')).appendTo(@$seleteds)

      @addPromotionId(id)

  removeSelectedItem: (e) ->
    $target = $(e.target)
    $selected = $target.parents('.selected-promotion:first')
    pid = $selected.attr('id')

    @$selected.slideUp 'fast', () =>
      @$selected.remove()

      @removePromotionId(pid)

      @$list.find('.promotion[data-id=' + pid +']').removeClass('active')


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

