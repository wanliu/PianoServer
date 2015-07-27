class @LeftSideBar
	constructor: (@element) ->
		$(window).resize(@onResize.bind(@))
		@$().click ()=>
			@toggleSlide() if $(window).width() < 768

	$: () ->
		$(@element)

	onResize: () ->
		windowWidth = $(window).width()
		if windowWidth > 768
			@show()
		else
			@hide()

	toggleSlide: () ->
		left = parseInt(@$().css('left'))
		if left == 0
			@hide()
		else
			@show()

	hide: () ->
		@$().animate({left: -240})

	show: () ->
		@$().animate({left: 0})
