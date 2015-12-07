class @CountDown
  @DATE_UNIT = {
    DAY: 24 * 60 * 60 * 1000,
    HOUR: 60 * 60 * 1000,
    MINUTE: 60 * 1000,
    SECOND: 1000
  }

  constructor: (@element, @isLimit, @inventory, @status, @startTime, @endTime) ->
    @_changeClass()

    if @status == 'Finish'
        @_showFinishText()
    else
      if @isLimit
        @_addCountdownHandler()
      else
        @_showInventoryText()

  $: () ->
    $(@element)

  _addCountdownHandler: () ->
    intervalHandler = @_countdownHandler.bind(@)
    @_intervalMark = setInterval(intervalHandler, 1000)

  _removeCountdownHander: () ->
    if @_intervalMark
      clearInterval(@_intervalMark)
      @_intervalMark = null

  _changeClass: () ->
    toAddClass = switch @status
                  when 'Published' then 'not-started'
                  when 'Active' then 'started'
                  when 'Finish' then 'finished'

    @_applyClass(toAddClass)

  _applyClass: (toAddClass) ->
    @$().parent()
        .removeClass('not-started started finished')
        .addClass(toAddClass)

  _diff: (date1, date2) ->
    date2 - date1

  duration: (date1, date2) ->
    duration = @_diff(date1, date2)
    days = Math.floor(duration / CountDown.DATE_UNIT.DAY)
    sub = duration - days * CountDown.DATE_UNIT.DAY
    hours = Math.floor(sub / CountDown.DATE_UNIT.HOUR)
    sub -= hours * CountDown.DATE_UNIT.HOUR
    minutes = Math.floor(sub / CountDown.DATE_UNIT.MINUTE)
    sub -= minutes * CountDown.DATE_UNIT.MINUTE
    seconds = Math.floor(sub / CountDown.DATE_UNIT.SECOND)

    {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'times': duration
    }

  _countdownHandler: () ->
    now = new Date()

    diffStart = @_diff(@startTime, now)
    diffEnd = @_diff(now, @endTime)
    isStarted = diffStart > 0
    isEnd = diffEnd < 0
    prefix = null
    duration = null

    if diffStart == 0 || diffEnd == 0
      @_changeClass()

    if isEnd
      @status = 'Finish'
      @_showFinishText()
      return @_removeCountdownHander()

    if isStarted
      prefix = '距活动结束还有'
      duration = @duration(now, @endTime)
      return @_updateCountdownText(prefix, duration)
    else
      prefix = '距活动开始还有'
      duration = @duration(now, @startTime)

      if duration.times > 5 * CountDown.DATE_UNIT.MINUTE
        return @_showStartText()
      else
        return @_updateCountdownText(prefix, duration)

  _updateCountdownText: (prefix, duration) ->
    text = @_formatShortTime(duration)
    @$().text(prefix + text)

  _showStartText: () ->
    if @_hasShown
      return

    @_hasShown = true
    @$().text('活动开始时间: ' + @_formatFullyTime(@startTime))
    @_applyClass('not-started')

  _showFinishText: () ->
    @$().text('活动已结束')
    @_applyClass('finished')

  _showInventoryText: () ->
    @$().text('库存剩余' + @inventory + '件')
    @_applyClass('started')

  _formatFullyTime: (date) ->
    date = new Date(date)
    years = date.getFullYear()
    months = @_formatValue(date.getMonth() + 1)
    days = @_formatValue(date.getDate())
    hours = @_formatValue(date.getHours())
    minutes = @_formatValue(date.getMinutes())

    [[years, months, days].join('/'), [hours, minutes].join(':')].join(' ')

  _formatShortTime: (duration) ->
    days = @_format(duration, 'days')
    hours = @_format(duration, 'hours')
    minutes = @_format(duration, 'minutes')
    seconds = @_format(duration, 'seconds')

    [days, '天', [hours, minutes, seconds].join(':')].join('')


  _format: (duration, key) ->
    value = duration[key]

    @_formatValue(value)

  _formatValue: (value) ->
    return if value < 10 then '0' + value else value



