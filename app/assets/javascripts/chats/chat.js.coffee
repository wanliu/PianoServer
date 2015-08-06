#= require lib/user-socket
#= require lib/metadata
class @Chat

  @defaultOptions: {
    sendBtn: null,
    isMessageScroll: true,
    maxMessageGroup: 10,
    earlyTime: 0,
    avatarDefault: '/assets/ava1tar.gif'
    # autoEnter: true
  }

  constructor: (@element, @channelId, @options = {} ) ->
    @options = $.extend(Chat.defaultOptions, @options)
    console.warn('must set sentBtn param in options') unless @options.sendBtn?
    @sendBtn = @options.sendBtn
    @textElement = @options.textElement || "input[name='chat-text']"
    @$messageList = $(@options.messageList || ".message-list")
    @$chatContainer = $(@options.container || ".chat-list")
    @$chatWrap = $(@options.container || ".main-content")
    @userSocket = window.userSocket

    @boundOnMessage = @onMessage.bind(@)
    @userSocket.onPersonMessage(@boundOnMessage)
    @metadata = window.metadata
    @ownerChannelId = @options.userChannelId || @userSocket.getUserChannelId()
    @table = @options.table

    $(document).bind 'page:before-unload', =>
      @_clearEventListners()

    @$chatContainer.bind('scroll', @_clearBubbleTipOnScrollBottom.bind(@))

    @earlyTime = @options.earlyTime
    @setSendBtn(@sendBtn)

    @getHistoryMessage(0, @_loadMoreProcess)

    setTimeout () =>
      @$().trigger('chat:init', @userSocket)
    , 10

  $: () ->
    $(@element)

  on: (event_name, callback) ->
    @$().on('chat:' + event_name, callback)

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
    $(document).trigger('inchats:enter', @chatChannelId)

  leave: () ->
    $(document).trigger('inchats:leave', @chatChannelId)

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

    if message.type == 'command'
      @onCommand(message)
    else
      @_insertMessage(message)

  onCommand: (message) ->
    command = JSON.parse(message.content)
    if command.command == 'order' and @table?
        @table.send('order', command)

  onHistoryMessage: () ->
    @getHistoryMessage @earlyTime, @_loadMoreProcess


  # private
  _sendMsg: () ->
    text = @getText()

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

  _insertItemMessage: (message, direction = 'down') ->
    {id, senderId, content, senderAvatar, senderLogin} = message

    if $("div[data-message-id=#{id}]").length > 0
      $("div[data-message-id=#{id}] p.content").text(content)
      return

    toAddClass = if @_isOwnMessage(message) then 'you' else 'me'

    senderAvatar = @options.avatarDefault if senderAvatar == '' or senderAvatar?

    template = """
      <div class="chat #{toAddClass}" data-message-id="#{id}">
        <img src="#{senderAvatar}" />
        <div class="bubble #{toAddClass}">
          <p class="content">#{content}</p>
        </div>
      </div>
    """

    if @$messageList?
      if direction == 'down'
        $(template).appendTo(@$messageList)
      else
        $(template).prependTo(@$messageList)

  _insertMessage: (message, direction = 'down') ->
    @_insertItemMessage(message, direction)

    isVisible = @_checkIsVisible(true)

    if !@_isOwnMessage(message) && (@_checkChatContentIsOverlayed() || !isVisible)
      @_insertBubbleTip(message)

    if @_checkChatContentIsOverlayed() || (isVisible && @options.isMessageScroll)
      @autoScroll(direction)

    #@autoScroll(direction) if @options.isMessageScroll

  _batchInsertMessages: (messages, direction = 'down') ->
    for message in messages
      @_insertItemMessage(message, 'up')

    # @autoScroll(direction) if @options.isMessageScroll

  _checkIsVisible: (isInsert) ->
    $inner = @$chatContainer.find('.chat-inner')
    chatContainer = $inner[0]
    lastItemHeight = $inner.find('.chat:last').height()
    scrollHeight = chatContainer.scrollHeight
    clientHeight = chatContainer.clientHeight
    scrollTop = chatContainer.scrollTop

    if isInsert
      clientHeight + scrollTop >= scrollHeight - (lastItemHeight + 70)
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



