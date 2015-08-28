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
      $promotion.trigger("click")
