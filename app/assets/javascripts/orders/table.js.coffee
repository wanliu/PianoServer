#= require ./item
#
class @OrderTable
	constructor: (@element) ->
		@$items = @$().find('.item-list > .list-group-item')
		for item in @$items
			new OrderItem(item, @element)

		@$().find('.item-list').on('click', @onClicked.bind(@))

	$: () ->
		$(@element)

	onClicked: (event) ->
    event.stopPropagation()

    $target = $(event.target)

    if @isEditField($target)
    	return

    if @isItemImage($target)
    	# show the item detail
    	return

    if @isRemoveBtn($target)
    	@removeItem($target.parents('li:first'))
	    return

    if (!$target.is('li'))
    	$target = $target.parents('li:first')

    $target.toggleClass('open')

    index = $target.index()
    $parent = $target.parent()
    length = $parent.find('li').length

    if (length == 1)
    	toggleSingleItem(parent)
    	return

    if (index == 0)
	    @toggleFirstItem($parent, $target)
	    return

    if (index == length - 1)
	    @toggleLastItem($parent, $target)
   		return

   	else
  		toggleMidItem($target)

  isEditField: (target) ->
  	target.is('.edit-fieldset') or target.parents('.edit-fieldset').length > 0

  isRemoveBtn: (target) ->
  	target.is('.remove-btn')

  isItemImage: (target) ->
  	target.is('img')

  toggleSingleItem: (parent) ->
  	parent.prev().toggleClass('radius-bottom')
  	parent.next().toggleClass('radius-top')

  toggleFirstItem: (parent, target) ->
  	parent.prev().toggleClass('radius-bottom')
	  target.next().toggleClass('radius-top')

	toggleLastItem: (parent, target) ->
		parent.next().toggleClass('radius-top')
		target.prev().toggleClass('radius-bottom')

	toggleMidItem: (target) ->
		target.prev().toggleClass('radius-bottom')
		target.next().toggleClass('radius-top')

  removeItem: (el) ->
	  itemId = el.attr('item-id')
	  orderId = el.parent().attr('order-id')

	  # send request to remove item
	  el.remove()

