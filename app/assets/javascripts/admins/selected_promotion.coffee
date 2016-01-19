#= require _common/event
class @SelectedItem extends @HuEvent
  events:
    'click .remove-item': 'removeSelectedItem'

  constructor: (@container, @id, @title) ->
    template = """
      <li class="selected-item" id="#{@id}">
        <div class="item-name">#{@title}</div>
        <div class="remove-item">
          <span class="glyphicon glyphicon-remove"></span>
        </div>
      </li>
    """

    element = $(template).appendTo(@container)
    super(element)

  removeSelectedItem: (e) ->
    $selected = $(e.currentTarget).parent()
    selector = [".item-set-variable .item[data-id=", @id, "]"].join("")
    $item = $(selector)

    $selected.slideUp 250, () =>
      $selected.remove()
      @removeItemId(@id)
      $item.removeClass('active') if $item.length > 0

  removeItemId: (id) ->
    $ids = $('#variable_items_string')
    ids = $ids.val().split(',')
    index = ids.indexOf(id)

    if (index > -1)
      ids.splice(index, 1)
      $ids.val(ids.join(','))


class @SelectedPromotion extends @HuEvent

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
