#= require _common/event

class @CategoryPropertiesEdit extends @HuEvent

  constructor: (@element) ->
  #   super(@element)
  #   @width = @$().outerWidth()
  #   @top = @$().offset().top
  #   $(window).resize(@onResize.bind(@))
  #   $(window).scroll(@onScroll.bind(@))

  #   @onScroll()

  # onResize: (e) ->
  #   @$().width('auto')
  #   setTimeout () =>
  #     @width = @$().width()
  #   , 100

  # onScroll: (e) ->
  #   scrollY = $(window).scrollTop()
  #   position = @$().css('position')

  #   if position != 'fixed' && scrollY > @top
  #     @$().css({
  #       position: 'fixed',
  #       width: @width,
  #       top: 60
  #     });
  #   else if position == 'fixed' && scrollY < @top
  #     @$().css({
  #       position: 'static',
  #       width: 'auto',
  #       top: 'auto'
  #     });
