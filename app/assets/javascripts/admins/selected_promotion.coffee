#= require _common/event
class @SelectedPromotion extends @Event

  events:
    'click .remove-promotion': 'removeSelectedItem'

  constructor: (@container, id, title) ->
    template = """
      <li class="selected-promotion" id="#{id}">
        <div class="promotion-name">#{title}</div>
        <div class="remove-promotion">
          <span class="glyphicon glyphicon-remove"></span>
        </div>
      </li>
    """

    element = $(template).appendTo(@container)
    super(element)

  removeSelectedItem: (e) ->
    $selected = $(e.currentTarget).parent()
    pid = $selected.attr('id')
    selector = [".promotion-set-variable .promotion[data-id=", pid, "]"].join("")
    $promotion = $(selector)

    if $promotion.length > 0
      $selected.slideUp 250, () ->
        $(this).remove()
        $promotion.removeClass('active') if $promotion.length > 0

    removePromotionId: (id) ->
      $ids = $('#variable_promotion_string')
      ids = @$ids.val().split(',')
      index = ids.indexOf(id)

      if (index > -1)
        ids.splice(index, 1)
        $ids.val(ids.join(','))
