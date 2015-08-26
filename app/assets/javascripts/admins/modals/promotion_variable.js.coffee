#= require _common/event
class @PromotionVariable extends @Event

  events:
    'click .promotion': 'selectedItem'

  constructor: (@element) ->
    super(@element)

    @$selected = @$().find('.selected');

  selectedItem: (e) ->
    id = $(e.currentTarget).find('.id').text()
    title = $(e.currentTarget).find('.title').text()

    $(e.currentTarget).addClass('active').siblings().removeClass('active')
    @$selected.find('.id').text(id)
    @$selected.find('.title').text(title)
    @$().find('#promotion_variable_promotion_id').val(id)


