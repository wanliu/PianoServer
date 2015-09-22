class @CategoryContainer
  constructor: (@$containment) ->
    @$leftBtn = @$containment.prev()
    @$rightBtn = @$containment.next()

    @bindPrevBtnClickEvent()
    @bindNextBtnClickEvent()

    @getCols()
    @maxLevelIndex = @cols
    @currentLevel = 1

    # $(window).bind('resize', @handleResizeEvent.bind(@))

  getCols: () ->
    width = $(window).width()

    if width >= 1200
      @cols = 3
    else if width >= 992
      @cols = 2
    else
      @cols = 1

  handleResizeEvent: () ->
    @getCols()

    @lastCols ||= @cols
    diff = @lastCols - @cols

    return if diff == 0

    @scrollContainer(diff)

  bindPrevBtnClickEvent: () ->
    @$leftBtn.bind('click', @scrolleLeft.bind(@))

  bindNextBtnClickEvent: () ->
    @$rightBtn.bind('click', @scrollRight.bind(@))

  scrolleLeft: () ->
    @maxLevelIndex -= 1
    @scrollContainer(-1)

  scrollRight: () ->
    @maxLevelIndex += 1
    @scrollContainer(1)

  scrollContainer: (diff) ->
    return if diff == 0

    @$containment.stop(true, true).animate({
      'margin-left': '-=' + diff * 290
    }, 250, () =>
      @changeMaxLevelIndex()
    )

  resetPosition: () ->
    @$containment.animate({
      'margin-left': 0
    }, 250, () =>
      @maxLevelIndex = @cols
      @$leftBtn.removeClass('btn-visible')
      @$rightBtn.removeClass('btn-visible')
    )

  changeMaxLevelIndex: () ->
    if @maxLevelIndex > @cols
      @$leftBtn.addClass('btn-visible')
    else
      @$leftBtn.removeClass('btn-visible')

    if @maxLevelIndex < @currentLevel
      @$rightBtn.addClass('btn-visible')
    else
      @$rightBtn.removeClass('btn-visible')

  resetBtnStatus: () ->
    @$rightBtn.removeClass('btn-visible')

    if @currentLevel <= @cols
      @$leftBtn.removeClass('btn-visible')
    else
      @$leftBtn.addClass('btn-visible')

  changeCurrentLevel: (level) ->
    diff = level - @maxLevelIndex

    @currentLevel = level

    if level < @cols
      @resetPosition()
    else if diff > 0
      @scrollContainer(diff)
      @maxLevelIndex += diff







