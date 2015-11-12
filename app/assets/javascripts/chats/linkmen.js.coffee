class @Linkmen
  constructor: (@element) ->
    @loadChats()

  loadChats: () ->
    $.ajax(
      url: '/chats',
      type: 'GET',
      dataType: 'json',
      success: (json) =>
        @chats = json.chats
        @other_sides = json.other_sides
        @retrieveLastMsgs()
    )

  retrieveLastMsgs: () ->
    @channelIds = []

    @channelIds = for other_side in @other_sides
      'p' + other_side.id

    window.userSocket.emit('getLastMsg', {channelIds: @channelIds}, (err, data) =>
      return if err

      @handleResponseData(data)
    )

  lookupOtherside: (target_id) ->
    for other_side in @other_sides
      return other_side if other_side.id == target_id

    return null

  lookupChat: (target_id) ->
    for chat in @chats
      continue if chat.owner_id == chat.target_id
      return chat if chat.target_id == target_id || chat.owner_id == target_id

    return null

  handleResponseData: (data) ->
    @sortedArray = []

    for channelId in @channelIds
      target_id = parseInt(channelId.replace('p', ''))
      other_side = @lookupOtherside(target_id)
      chatData = @lookupChat(target_id)
      time = Date.parse(chatData.updated_at)
      message = '暂无聊天记录'

      continue if not other_side or not chatData

      chat_username = other_side.nickname
      chat_avatar = other_side.avatar_url

      if data[channelId]
        record = data[channelId]
        time = record.time
        message = @getMessage(record)

      @insertObject({
        id: chatData.id,
        time: time,
        message: message,
        avatar: chat_avatar,
        username: chat_username
      })

    @generateDomFragment()

  insertObject: (object) ->
    if @sortedArray.length == 0
      @sortedArray.push(object)
    else
      for obj, index in @sortedArray
        if object.time < obj.time
          target_index = index
          break

      @sortedArray.splice(target_index, 0, object)

  getMessage: (record) ->
    { content, attachs } = record

    message = ''

    if content.length > 0
      message = content.replace(/(<\/?(?!br)[^>\/]*)\/?>/gi,'')
            .replace(/<(\/*br\/*)>/gi, '[换行]')

    for key, attach of attachs
      if attach.type && attach.type.indexOf('image') == 0
        message += '[图片]'

    message

  generateDomFragment: () ->
    for object in @sortedArray.reverse()
      {id, time, message, avatar, username} = object
      formatTime = window.fromNow(time)

      template = """
        <a href="/chats/#{id}" class="chat-item">
          <div class="avatar-container">
            <img src="#{avatar}" class="chat-item-avatar">
          </div>
          <h4>
            #{username}
            <div class="format-time">#{formatTime}</div>
          </h4>
          <p class="last-message">#{message}</p>
      </a>
      """

      $(template).appendTo(@element)
