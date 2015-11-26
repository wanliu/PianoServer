#= require _common/event

class @CategoryContainer extends @HuEvent
  constructor: (@element, @length) ->
    super(@element)
    @itemWidth = 290
    @element.width(@itemWidth * @length)
    @wrapper = @$().parents(".category-wrap")
    @$leftBtn = @element.prev()
    @$rightBtn = @element.next()
    @bindPrevBtnClickEvent()
    @bindNextBtnClickEvent()

    @getCols()
    @currentLevel = 1

    @on('level:change', @levelChanged.bind(@))
    $(window).bind('resize', @resizeHandler.bind(@))

  getCols: () ->
    width = $(window).width()

    if width >= 1200
      @cols = 3
    else if width >= 992
      @cols = 2
    else
      @cols = 1

  resizeHandler: () ->
    @getCols()

    diff = @lastCols - @cols
    @lastCols = @cols

    return if diff == 0

    @scrollContainer(diff)

  bindPrevBtnClickEvent: () ->
    @$leftBtn.bind('click', @scrollLeft.bind(@))

  bindNextBtnClickEvent: () ->
    @$rightBtn.bind('click', @scrollRight.bind(@))

  scrollLeft: () ->
    return if @scroll

    @scroll = true
    currentLeft = @currentLeft()

    if currentLeft < 0
      @scrollContainer(-1)

  scrollRight: () ->
    return if @scroll

    @scroll = true
    currentLeft = @currentLeft()

    if currentLeft > @getWrapperWidth() - @$().width()
      @scrollContainer(1)

  getWrapperWidth: () ->
    @wrapper.width()

  scrollContainer: (diff) ->
    return if diff == 0

    @element.stop(true, true).animate({
      'margin-left': '-=' + diff * @itemWidth
    }, 250, () =>
      @scroll = false
      @changeMaxLevelIndex()
    )

  resetPosition: () ->
    @element.animate({
      'margin-left': 0
    }, 250, () =>
      @$leftBtn.removeClass('btn-visible')
      @$rightBtn.removeClass('btn-visible')
    )

  changeMaxLevelIndex: () ->
    if @minLevel() > 0
      @$leftBtn.addClass('btn-visible')
    else
      @$leftBtn.removeClass('btn-visible')

    if @maxLevel() < @currentLevel
      @$rightBtn.addClass('btn-visible')
    else
      @$rightBtn.removeClass('btn-visible')

  levelChanged: (e, level) ->
    diff = level - @currentLevel

    @currentLevel = level

    if level <= @cols
      @resetPosition()
    else
      @scrollContainer(diff)

  currentLeft: () ->
    parseInt(@$().css('marginLeft'))

  maxLevel: () ->
    @minLevel() + @cols

  minLevel: () ->
    Math.abs(@currentLeft()) / @itemWidth





