#= require _common/event
TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'

class @LeftSideBar extends @Event
  constructor: (@element, @navbar, @container, @options = {}) ->
    super
    @bindResizeEvent()
    @$().click ()=>
      @toggleSlide() if $(window).width() < 768

    @width = @options["width"] || $(@element).outerWidth()
    @toggleBackground = @options["toggleBackground"] || "#122048"
    @originBackground = @options["originBackground"] || @$().css('backgroundColor')

    @$container = $(@container)
    @$navbar = $(@navbar)
    @hammer = new Hammer.Manager(document.body)
    @hammer.add(new Hammer.Pan({ threshold: 0, pointers: 0 }));
    # @hammer.add(new Hammer.Swipe({
    #   direction: Hammer.DIRECTION_ALL
    # })).recognizeWith(@hammer.get('pan'));

    @hammer.on("panright", @slideOpen.bind(@))
    @hammer.on("panleft", @slideClose.bind(@))
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

  close: () ->
    @$().css({left: -300})
    @$container.css('minWidth', 'auto')
    @$container.css('marginLeft', 0)
    @$navbar.css('minWidth', 'auto')
    @$navbar.css('marginLeft', 0)
    @$().width(@width)
    @$().css('backgroundColor', @originBackground)


  show: () ->
    @isShow = true
    @$().css({left: 0})
    @$().width(300);
    @originWidth = @$container.outerWidth()
    @$container.css('marginLeft', 300)
    @$container.css('minWidth', @originWidth)
    @$navbar.css('marginLeft', 300)
    @$navbar.css('minWidth', @originWidth)

    @$().css('backgroundColor', @toggleBackground)


  hide: () ->
    @isShow = false
    @$().css({left: -300})
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
