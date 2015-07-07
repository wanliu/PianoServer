class Scroller
  constructor: (@options = {}) ->
    @options.scrollBottom ||= 95;
    $(document).scroll(@onScroll.bind(@))
    $(window).on('mousewheel', @onScroll.bind(@))
    @onScroll()

  onScroll: (e) ->
    windowHeight   = $(window).height()
    currentPostion = $(document).scrollTop()
    maxHeight      = $(document).innerHeight()
    minValue       = maxHeight - (currentPostion + windowHeight) 
    $(document).trigger('scroll:bottom') if minValue <= @options.scrollBottom

$ ->
  new Scroller()
