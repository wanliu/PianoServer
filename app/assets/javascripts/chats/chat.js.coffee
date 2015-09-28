#= require lib/user-socket
#= require lib/metadata
#= require lib/pastemedia

DAYS = 24 * 3600 * 1000

TABLE_REGEXP = /^\<table\>*.?\<\/table\>$/m

class @Chat

  @defaultOptions: {
    sendBtn: null,
    isMessageScroll: true,
    maxMessageGroup: 10,
    earlyTime: 0,
    avatarDefault: '/assets/ava1tar.gif',
    displayUserName: false,
    miniTimeGroupPeriod: 1000 * 180
    # autoEnter: true
  }

  constructor: (@element, @channelId, @options = {} ) ->
    @options = $.extend(Chat.defaultOptions, @options)
    console.warn('must set sentBtn param in options') unless @options.sendBtn?
    @sendBtn = @options.sendBtn
    @textElement = @options.textElement || "input[name='chat-text']"
    @$messageList = $(@options.messageList || ".message-list")
    @$chatContainer = $(@options.container || ".chat-list")
    @$chatWrap = $(@options.container || ".chat-body")
    @userSocket = window.userSocket

    @boundOnMessage = @onMessage.bind(@)
    @userSocket.onPersonMessage(@boundOnMessage)
    @metadata = window.metadata
    @ownerChannelId = @options.userChannelId || @userSocket.getUserChannelId()
    @table = @options.table
    @greetings = @options.greetings

    $(document).bind 'page:before-unload', =>
      @_clearEventListners()

    @$chatContainer.bind('scroll', @_clearBubbleTipOnScrollBottom.bind(@))

    @earlyTime = @options.earlyTime
    @setSendBtn(@sendBtn)

    @getHistoryMessage(0, @_loadMoreProcess)

    @bindAllEvents()

    setTimeout () =>
      @$().trigger('chat:init', @userSocket)
    , 10

    setTimeout () =>
      @_insertGreetingMessage() if @greetings? and @greetings.length > 0
    , 1500

  $: () ->
    $(@element)

  on: (event_name, callback) ->
    @$().on('chat:' + event_name, callback)

  bindAllEvents: () ->
    $(@textElement).on 'keyup', (e) =>
      if e.which == 13 and e.ctrlKey
        $(@sendBtn).trigger('click')
      else if e.which == 13
        count = Math.min($(@textElement).val().split("\n").length, 5)
        $(@textElement).attr("rows", count)

    $.pastemedia (type, data) =>
      switch type
        when "image"
          @_sendImageMsg(data)
        when "text"
          if TABLE_REGEXP.test(data)
            @_sendTableMsg(data)
        else
          @clearText()


  setSendBtn: (btnElement) ->
    @sendBtn = $(btnElement)
    @sendBtn.click(@_sendMsg.bind(@))

  getText: () ->
    @$textElement ||= $(@textElement)
    @$textElement.val()

  clearText: () ->
    @$textElement ||= $(@textElement)
    @$textElement.val('')

  send: (msg) ->

  enter: () ->
    chatChannelId = 'p' + (@ownerChannelId + @channelId).replace(/p/g, ':')
    $(document).trigger('inchats:enter', chatChannelId)

  leave: () ->
    chatChannelId = 'p' + (@ownerChannelId + @channelId).replace(/p/g, ':')
    $(document).trigger('inchats:leave', chatChannelId)

  autoScroll: (direction = 'down') ->
    $inner = @$chatContainer.find('.chat-inner')

    if direction == 'down'
      $inner.scrollTop(@$messageList.innerHeight())
    else
      $inner.scrollTop(0)

  getHistoryMessage: (start = @earlyTime, callback) ->
    type = if start == 0 then 'index' else 'time'
    @userSocket.emit 'getChannelMessage', {
      'channelId': @channelId,
      'type': type,
      'start': start,
      'step': @options.maxMessageGroup
    }, (err, messages) =>
      return if err || messages.length == 0

      messages.reverse()

      @_batchInsertMessages(messages, 'up')
      # for message in messages
      #     @_insertMessage(message, 'up')

      # if messages.length < @options.maxMessageGroup
      #     @$messageList.find('.load-more').remove();
      # else

      @earlyTime = messages[messages.length - 1].time

      callback.call(@, messages) if $.isFunction(callback)

  setTable: (@table) ->

  onMessage: (message) ->
    unless @_isEnter
      @_isEnter = true
      @chatChannelId = message.channelId
      @enter()

    @_emitReadEvent()

    if message.type == 'command'
      @onCommand(message)
    else
      @_insertMessage(message)

  onCommand: (message) ->
    command = JSON.parse(message.content)

    if command.command == 'order' and @table?
      @table.send('order', command)
    else if command.command == 'order-address' and @table?
      @table.send('order-address', command)

  onHistoryMessage: () ->
    @getHistoryMessage @earlyTime, @_loadMoreProcess

  # private
  _sendMsg: () ->
    text = @getText()
    @sendBtn.blur()

    if text.length > 0

      if @metadata.debug
        @_insertMessage(text);
      else
        @userSocket.publish(@channelId, {
          'content': text,
          # 'promotionId': promotionId,
          'attachs': {}
        }, (err) =>
          @clearText() unless err?
        )
      $(@textElement).attr('rows', 1)

  _sendImageMsg: (src) ->
    @userSocket.publish(@channelId, {
      'type': 'image',
      'content': '',
      'attachs': {
        1: {
          type: 'image/jpeg',
          value: src
        }
      }
    }, (err) =>
        @clearText() unless err?
    )

  _sendTableMsg: (table) ->
    @userSocket.publish(@channelId, {
      'type': 'table',
      'content': table
    }, (err) =>
      @clearText() unless err?
    )


  _insertItemMessage: (message, direction = 'down') ->
    {id, senderId, content, senderAvatar, senderLogin, type, time} = message

    if type == 'command'
      return @onCommand(message)

    try
      if $("div[data-message-id=#{id}]").length > 0
        $("div[data-message-id=#{id}] p.content").text(content)
        return

      context = @_prepareTemplateContext(message)

      if type == 'normal'
        if message.attachs
          attach = message.attachs[Object.keys(message.attachs)[0]]
          if attach && attach.type && attach.type.indexOf('image') == 0
            type = 'image'
        else
          type = 'text'

      template = switch(type)
                   when 'text'
                     @_buildTextMessage(content, context)
                   when 'image'
                     @_buildImageMessage(content, message.attachs, context)
                   else
                     @_buildTextMessage(content, context)

      if @$messageList?
        $elem = if direction == 'down'
                  $(template).appendTo(@$messageList)
                else
                  $(template).prependTo(@$messageList)
        if type == 'image'
          @_bindImageEvents($elem)

      @lastTime = time
    catch e
      console.error(e.stack)

  _prepareTemplateContext: (message)  ->
    {id, senderId, content, senderAvatar, senderLogin, type, time} = message

    toAddClass = if @_isOwnMessage(message) then 'you' else 'me'

    senderAvatar = @options.avatarDefault if senderAvatar == '' or senderAvatar?
    senderName = if @options.displayUserName then "<h2>#{senderLogin}</h2>" else ''
    prefixSection = if @lastTime? and Math.abs(time - @lastTime) > @options.miniTimeGroupPeriod
                      diffDay = Math.floor((time - @lastTime) / DAYS)
                      time = new Date(time)
                      timeStr = if diffDay > 0
                                  "#{time.getFullYear()}-#{time.getMonth()}-#{time.getDate()} #{time.getHours()}:#{time.getMinutes()}"
                                else
                                  "#{time.getHours()}:#{time.getMinutes()}"
                      """
                      <div class="time"><p class="text-center">#{timeStr}</p></div>
                      """
                    else
                      ''
    {prefixSection, senderAvatar, senderName, toAddClass, id, senderId, content, senderLogin, type, time}

  _buildTextMessage: (text = null, context = {}) ->
    {prefixSection, senderAvatar, senderName, toAddClass, id, senderId, content, senderLogin, type, time} = context

    """
      #{prefixSection}
      <div class="chat #{toAddClass}" data-message-id="#{id}">
        <img src="#{senderAvatar}" />
        #{senderName}
        <div class="bubble #{toAddClass}">
          <p class="content">#{text || content}</p>
        </div>
      </div>
    """

  _buildImageMessage: (text, images, context) ->
    {prefixSection, senderAvatar, senderName, toAddClass, id, senderId, content, senderLogin, type, time} = context

    $images = ["""<img src="#{image.value}" alt=#{key} />""" for key, image of images]

    """
      #{prefixSection}
      <div class="chat #{toAddClass}" data-message-id="#{id}">
        <img src="#{senderAvatar}" />
        #{senderName}
        <div class="bubble #{toAddClass}">
          <p class="content">#{text || content}</p>
          <div class="msg-images">
            #{$images.join('')}
          </div>
        </div>
      </div>
    """

  _buildTableMessage: (table, context) ->


  _bindImageEvents: (elem) ->
    $(elem).find(".msg-images>img").click () =>
      index = 0;
      items = $('.message-list .msg-images>img').map (i, ele) =>
        index = i if $(ele).is(elem)

        {
          src: $(ele).attr('src'),
          w: $(ele).width(),
          h: $(ele).height()
        }

      @_buildPSWPImage(items, index)

  # hammer = new Hammer($img[0])
  # hammer.on('pan', openingImage)

  # _buildPinchZoomImage: (elem) ->
  #   new RTP.PinchZoom(@popupImage, {});

  #   hammertime = new Hammer(elem, {});
  #   hammertime.get('pinch').set({
  #       enable: true
  #   })
  #   posX = 0
  #   posY = 0
  #   scale = 1
  #   last_scale = 1
  #   last_posX = 0
  #   last_posY = 0
  #   max_pos_x = 0
  #   max_pos_y = 0
  #   transform = ""
  #   el = elem

  #   hammertime.on 'doubletap pan pinch panend pinchend', (ev) ->
  #     # doubletap
  #     if ev.type == "doubletap"
  #       transform =
  #         "translate3d(0, 0, 0) " +
  #         "scale3d(2, 2, 1) "
  #       scale = 2
  #       last_scale = 2
  #       try
  #         if window.getComputedStyle(el, null).getPropertyValue('-webkit-transform').toString() != "matrix(1, 0, 0, 1, 0, 0)"
  #           transform =
  #             "translate3d(0, 0, 0) " +
  #             "scale3d(1, 1, 1) "
  #           scale = 1
  #           last_scale = 1
  #       catch err
  #         el.style.webkitTransform = transform
  #         transform = ""

  #     # pan
  #     if scale != 1
  #       posX = last_posX + ev.deltaX
  #       posY = last_posY + ev.deltaY
  #       max_pos_x = Math.ceil((scale - 1) * el.clientWidth / 2)
  #       max_pos_y = Math.ceil((scale - 1) * el.clientHeight / 2)
  #       if posX > max_pos_x
  #         posX = max_pos_x

  #       if posX < -max_pos_x
  #         posX = -max_pos_x

  #       if posY > max_pos_y
  #         posY = max_pos_y

  #       if posY < -max_pos_y
  #         posY = -max_pos_y


  #     # pinch
  #     if ev.type == "pinch"
  #       scale = Math.max(.999, Math.min(last_scale * (ev.scale), 4))

  #     if ev.type == "pinchend"
  #       last_scale = scale

  #     # panend
  #     if ev.type == "panend"
  #       last_posX = if posX < max_pos_x then posX else max_pos_x
  #       last_posY = if posY < max_pos_y then posY else max_pos_y

  #     if scale != 1
  #       transform =
  #         "translate3d(" + posX + "px," + posY + "px, 0) " +
  #         "scale3d(" + scale + ", " + scale + ", 1)"

  #     if transform
  #       el.style.webkitTransform = transform

  _buildPSWPImage: (items, index) ->
    pswpElement = $('.pswp')[0]
    options = {
        index: index # start at first slide
    }

    gallery = new PhotoSwipe( pswpElement, PhotoSwipeUI_Default, items, options);
    gallery.init();

  _insertMessage: (message, direction = 'down') ->
    @_insertItemMessage(message, direction)

    isVisible = @_checkIsVisible(true)

    if !@_isOwnMessage(message) && (@_checkChatContentIsOverlayed() || !isVisible)
      @_insertBubbleTip(message)

    if @_checkChatContentIsOverlayed() || (isVisible && @options.isMessageScroll)
      @autoScroll(direction)

    #@autoScroll(direction) if @options.isMessageScroll

  _insertGreetingMessage: () ->
    if @greetings?
      @_insertMessage({
        id: ~(new Date),
        senderId: 0,
        content: @greetings,
        senderAvatar: @options.avatarDefault,
        senderLogin: '商店',
        time: new Date()
      })

  _batchInsertMessages: (messages, direction = 'down') ->
    for message in messages
      @_insertItemMessage(message, 'up')

    # @autoScroll(direction) if @options.isMessageScroll

  _checkIsVisible: (isInsert) ->
    $inner = @$chatContainer.find('.chat-inner')
    chatContainer = $inner[0]
    $lastItem = $inner.find('.chat:last')
    $prev = $lastItem.prev()
    lastItemHeight = $inner.find('.chat:last').height()
    lastTimeHeight = $prev.is('.time') ? $prev.height() + 10 : 0
    scrollHeight = chatContainer.scrollHeight
    clientHeight = chatContainer.clientHeight
    scrollTop = chatContainer.scrollTop

    if isInsert
      clientHeight + scrollTop >= scrollHeight - (lastItemHeight + lastTimeHeight + 70)
    else
      clientHeight + scrollTop >= scrollHeight - 70

    # return clientHeight + scrollTop  >= scrollHeight - (isInsert ? lastItemHeight + 20 : 20)

  _checkChatContentIsOverlayed: () ->
    @table.chatContentOverlayed

  _insertBubbleTip: (message) ->
    $tip = @$chatWrap.find('.bubble-tip')
    {content, senderLogin} = message

    if @bubbleTimeout
      clearTimeout(@bubbleTimeout)
      @bubbleTimeout = null

    if $tip.length == 0
      $tip = $('<div class="bubble-tip"><div class="tip-text"></div></div>')
        .prependTo(@$chatWrap)

    $tip.find('.tip-text').text(senderLogin + '说：' + content)

    @bubbleTimeout = setTimeout(() =>
      $tip.remove()
    , 2000)

  _clearBubbleTipOnScrollBottom: () ->
    if @_checkIsVisible(false)
      @_clearBubbleTip()

  _clearBubbleTip: () ->
    @$chatContainer.find('.bubble-tip').remove()

  _isOwnMessage: (message) ->
    @metadata.chatId == message.senderId.toString();

  _insertLoadMore: () ->
    $more = $('<div class="load-more">查看更多消息</div>').prependTo(@$messageList)

    $more.click () =>
      @_removeLoadMore()
      $('<div class="record-loading"><span class="loading-icon"/>正在加载聊天记录</div>').prependTo(@$messageList)
      @getHistoryMessage(@earlyTime, @_loadMoreProcess)


  _removeLoadMore: () ->
    @$messageList.find('.load-more').remove()


  _clearEventListners: () ->
    @userSocket.offPersonMessage(@boundOnMessage)

  _loadMoreProcess: (messages) ->
    @$messageList.find('.record-loading').remove()
    if messages.length < @options.maxMessageGroup
      @_removeLoadMore()
    else
      @_insertLoadMore()

  _emitReadEvent: () ->
    @userSocket.emit 'readChannel', {
      'channelId': @channelId
    }, () =>
      senderId = @channelId.replace('p', '')
      window.noticeCenter.removeNotice(senderId)



