class AdjustPromotionImage

	constructor: () ->
		$(window).resize(@onResize.bind(@))
		$(window).on('adjust:image', @onResize.bind(@))
		@onResize()

	onResize: () ->
		@recalcWidth();

	recalcWidth: () ->
		image = $('.promotions-list .promotion:first .promotion-image')
		$('.promotions-list .promotion-image').height(image.width() || 200)



adjustImage = null

$ ->
	adjustImage ||= new AdjustPromotionImage
