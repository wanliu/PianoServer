
class @OrderItem
	constructor: (@element, @parent) ->
		@$().click(@onClick.bind(@))

	$: () ->
		$(@element)

	onClick: () ->
		$(@parent).trigger('item:select', @element)
