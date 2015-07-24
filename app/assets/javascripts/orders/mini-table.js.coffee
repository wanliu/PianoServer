#= require './table'
#
class @MiniTable

	constructor: (@element, @target) ->

		@$().bind 'click', @toggleShow.bind(@)

	$: () ->
		$(@element)

	toggleShow: () ->
		@table ||= new OrderTable(@target)
		$(@target).slideToggle()
