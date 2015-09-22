TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'

class @LeftSideBar
  constructor: (@element, @container, @options = {}) ->
    @bindResizeEvent()
    @$().click ()=>
      @toggleSlide() if $(window).width() < 768

    @width = @options["width"] || $(@element).outerWidth()

    @$container = $(@container)
    @hammer = new Hammer.Manager(document.body)
    @hammer.add(new Hammer.Pan({ threshold: 0, pointers: 0 }));
    # @hammer.add(new Hammer.Swipe({
    #   direction: Hammer.DIRECTION_ALL
    # })).recognizeWith(@hammer.get('pan'));

    @hammer.on("panright", @slideOpen.bind(@))
    @hammer.on("panleft", @slideClose.bind(@))
    @$().on(TRANSITION_ENDS, @onTransEnd.bind(@))

  $: () ->
    $(@element)

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
    @$().width(@width)

  close: () ->
    @$().css({left: -300})
    @$container.css('minWidth', 'auto')
    @$container.css('marginLeft', 0)
    @$().width(@width)


  show: () ->
    @isShow = true
    @$().css({left: 0})
    @$().width(300);
    @originWidth = @$container.outerWidth()
    @$container.css('marginLeft', 300)
    @$().css('backgroundColor', '#222222')
    @$container.css('minWidth', @originWidth)


  hide: () ->
    @isShow = false
    @$().css({left: -300})
    @$container.css('marginLeft', 0)
    @$().css('backgroundColor', 'white')

  onTransEnd: (show) ->
    if @isShow
      $("body").css('overflow', 'hidden')
    else
      @$().width(@width)
      @$container.css('minWidth', 'auto')
      $("body").css('overflow', 'auto')
