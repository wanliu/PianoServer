#= require _common/event
TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'

class @LeftSideBar extends @HuEvent
  constructor: (@element, @navbar, @container, @options = {}) ->
    super
    @bindResizeEvent()

    @width = @options["width"] || $(@element).outerWidth()
    @toggleBackground = @options["toggleBackground"] || "#122048"
    @originBackground = @options["originBackground"] || @$().css('backgroundColor')
    @slideWidth = @options["slideWidth"] || 200
    @slideLeft = @options["slideLeft"] || 240

    @$container = $(@container)
    @$().click ()=>
      @toggleSlide() if $(window).width() < 768

    @$navbar = $(@navbar)
    @hammer = new Hammer.Manager(document.body)
    # @hammer.add(new Hammer.Pan({ threshold: 0, pointers: 0 }));
    # @hammer.add(new Hammer.Swipe({
    #   direction: Hammer.DIRECTION_ALL
    # })).recognizeWith(@hammer.get('pan'));

    # @hammer.on("panright swiperight", @slideOpen.bind(@))
    # @hammer.on("panleft swipeleft", @slideClose.bind(@))

    @hammer.add(new Hammer.Swipe({
      direction: Hammer.DIRECTION_HORIZONTAL,
      velocity: 0.1,
      threshold: 1
    }))
    @hammer.on("swiperight", @slideOpen.bind(@))
    @hammer.on("swipeleft", @slideClose.bind(@))

    @$().on(TRANSITION_ENDS, @onTransEnd.bind(@))

  bindResizeEvent: (  ) ->
    $(window).resize (e) =>
      @onResize(e)

  onResize: () ->
    windowWidth = $(window).width()
    if windowWidth > 768
      @open()
    else
      @close()

  slideOpen: () ->
    @show() if $(window).width() < 768

  slideClose: () ->
    @hide() if $(window).width() < 768

  toggleSlide: () ->
    left = parseInt(@$().css('left'))
    if left == 0
      @hide()
    else
      @show()

  open: () ->
    @$().css({left: 0})
    @$container.css('minWidth', 'auto')
    @$container.css('marginLeft', 0)
    @$navbar.css('minWidth', 'auto')
    @$navbar.css('marginLeft', 0)
    @$().width(@width)
    @$().css('backgroundColor', @originBackground)


  close: () ->
    @$().css({left: -@slideLeft})
    @$container.css('minWidth', 'auto')
    @$container.css('marginLeft', 0)
    @$navbar.css('minWidth', 'auto')
    @$navbar.css('marginLeft', 0)
    @$().width(@width)
    @$().css('backgroundColor', @originBackground)


  show: () ->
    @isShow = true
    @$().css({left: 0})
    @$().width(@slideWidth);
    @originWidth = @$container.outerWidth()
    @$container.css('marginLeft', @slideWidth)
    @$container.css('minWidth', @originWidth)
    @$navbar.css('marginLeft', @slideWidth)
    @$navbar.css('minWidth', @originWidth)

    @$().css('backgroundColor', @toggleBackground)


  hide: () ->
    @isShow = false
    @$().css({left: -@slideLeft})
    @$container.css('marginLeft', 0)
    @$navbar.css('marginLeft', 0)
    @$().css('backgroundColor', @originBackground)

  onTransEnd: (show) ->
    if @isShow
      $("body").css('overflow', 'hidden')
    else
      @$().width(@width)
      @$container.css('minWidth', 'auto')
      @$container.css('minWidth', 'auto')
      $("body").css('overflow', 'auto')
