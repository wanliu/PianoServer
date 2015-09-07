#= require _common/event
class @SelectedPromotion extends @Event

  events:
    'click .remove-promotion': 'removeSelectedItem'

  constructor: (@container, @id, @title) ->
    template = """
      <li class="selected-promotion" id="#{@id}">
        <div class="promotion-name">#{@title}</div>
        <div class="remove-promotion">
          <span class="glyphicon glyphicon-remove"></span>
        </div>
      </li>
    """

    element = $(template).appendTo(@container)
    super(element)

  removeSelectedItem: (e) ->
    $selected = $(e.currentTarget).parent()
    selector = [".promotion-set-variable .promotion[data-id=", @id, "]"].join("")
    $promotion = $(selector)

    $selected.slideUp 250, () =>
      $selected.remove()
      @removePromotionId(@id)
      $promotion.removeClass('active') if $promotion.length > 0

  removePromotionId: (id) ->
    $ids = $('#variable_promotion_string')
    ids = $ids.val().split(',')
    index = ids.indexOf(id)

    if (index > -1)
      ids.splice(index, 1)
      $ids.val(ids.join(','))
