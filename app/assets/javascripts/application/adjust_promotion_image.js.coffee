class AdjustPromotionImage

	constructor: () ->
		$(window).resize(@onResize.bind(@))
		$(window).on('adjust:image', @onResize.bind(@))
		@onResize()

	onResize: () ->
		@recalcWidth()

	recalcWidth: () ->
    $promotions = $('.promotions-list .promotion')

    for promotion in $promotions
      @resetImageScale(promotion)

  resetImageScale: (promotion) ->
    $promotion = $(promotion)
    $image = $promotion.find('.promotion-image')
    width = $promotion.width()
    imageWidth = $image.width()
    imageHeight = $image.height()

    $image.css({
      width: width,
      height: width
    })

    # $image.parent().height(width)

    # if imageHeight == 0
    #   $image.height(imageWidth)
    # else
    #   if imageWidth >= imageHeight
    #     _height = Math.floor(width * imageHeight / imageWidth)
    #     marginTop = (width - _height) / 2
    #     $image.css({
    #       width: width,
    #       height: _height,
    #       marginLeft: 0,
    #       marginTop: marginTop
    #     })
    #   else
    #     _width = Math.floor(width * imageWidth / imageHeight)
    #     marginLeft = (width - _width) / 2
    #     $image.css({
    #       width: _width,
    #       height: width,
    #       marginLeft: marginLeft,
    #       marginTop: 0
    #     })

adjustImage = null

$ ->
	adjustImage ||= new AdjustPromotionImage

$(document).on 'page:load', () ->
  adjustImage && adjustImage.onResize()
