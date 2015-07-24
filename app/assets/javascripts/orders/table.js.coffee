#= require ./item
#
class @OrderTable
	constructor: (@element) ->
		@$items = @$().find('.item-list > .list-group-item')
		for item in @$items
			new OrderItem(item, @element)

		@$().bind('item:select', @onSelected.bind(@))

	$: () ->
		$(@element)

	onSelected: (e, item) ->
		@$().find('.item-list > .list-group-item.open').removeClass('open')
		$(item).addClass('open')

