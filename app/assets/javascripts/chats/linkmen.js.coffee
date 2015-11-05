class @Linkmen
  constructor: (@element, @channelIds) ->
    @retrieveLastMsgs()

  retrieveLastMsgs: () ->
    channelIds = for channelId in @channelIds
      'p' + channelId

    window.userSocket.emit('getLastMsg', {channelIds: channelIds}, (err, data) =>
      return if err

      @handleResponseData(data)
    )

  handleResponseData: (data) ->
    @element.find('.chat-item').each((index, target) =>
      $this = $(target)
      channelId = 'p' + $this.data('targetId')
      updatedAt = $this.data('updatedAt')
      $time = $this.find('.format-time')
      $message = $this.find('.last-message')
      _data = data[channelId]
      imageCount = 0
      message = ''
      timeDesc = ''

      if (_data)
        {time, content, attachs, senderLogin, senderId} = _data

        timeDesc = @_genereateTimeDesc(time)

        if +senderId < 0
          senderLogin += -1 * senderId

        if content.length > 0
          message = content

        for key of attachs
          message += '[图片]'

      else
        timeDesc = @_genereateTimeDesc(Date.parse(updatedAt))
        message = '暂无聊天记录'

      $time.text(timeDesc)
      $message.text(message)
    )

  _genereateTimeDesc: (time) ->
    date = new Date(time)
    timeDesc = [date.getFullYear(), '-', @_formatValue(date.getMonth()+1), '-', @_formatValue(date.getDate()), ' ',
      @_formatValue(date.getHours()), ':', @_formatValue(date.getMinutes()), ':', @_formatValue(date.getSeconds())].join('')
    timeDesc

  _formatValue: (value) ->
    return if value < 10 then '0' + value else value
