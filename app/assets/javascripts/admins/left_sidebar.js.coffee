class @LeftSideBar
  constructor: (@element, @container = window) ->
    @bindResizeEvent(@container)
    @$().click ()=>
      @toggleSlide() if $(@container).width() < 768

  $: () ->
    $(@element)

  bindResizeEvent: (container) ->
    $(window).resize (e) =>
      @onResize(e)

  onResize: () ->
    windowWidth = $(@container).width()
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
