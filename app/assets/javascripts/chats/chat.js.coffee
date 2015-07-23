#= require lib/user-socket
#= require lib/metadata
class @Chat

    @defaultsOptions: {
        sendBtn: null,
        isMessageScroll: true,
        maxMessageGroup: 10,
        earlyTime: 0,
        avatarDefault: '/assets/avatar.gif'
    }

    constructor: (@element, @channelId, @options = {} ) ->
        @options = Object.assign(@options, Chat.defaultsOptions)
        console.warn('must set sentBtn param in options') unless @options.sendBtn?
        @sendBtn = @options.sendBtn
        @$messageList = $(@options.messageList)
        @userSocket = window.userSocket
        
        @boundOnMessage = @onMessage.bind(@)
        @userSocket.onPersonMessage(@boundOnMessage)
        @metadata = window.metadata

        $(document).bind 'page:before-unload', =>
            @_clearEventListners()

        @earlyTime = @options.earlyTime

    setSendBtn: (btnElement) ->
        @sendBtn = $(btnElement)
        @sendBtn.bind(@_sendMsg.bind(@))

    send: (msg) ->

    resetScroll: () ->
        ele = @$messageList[0]
        clientHeight = ele.clientHeight
        scrollHeight = ele.scrollHeight
        offset = scrollHeight - clientHeight
          
        ele.scrollTop = offset if offset > 0

    loadMoreMessage: () ->

    getHistoryMessage: (start = @earlyTime) ->
        type = if start == 0 then 'index' else 'time'
        @userSocket.emit 'getChannelMessage', {
            'channelId': chatChannelId,
            'type': tyep,
            'start': start
        }, (err, messages) =>
            return if err || messages.length == 0
                
            for message in messages
                @_insertMessage(messages[i])

            if messages.length < Chat.defaultsOptions.maxMessageGroup
                # $list.find('.load-more').remove();
            else
                @earlyTime = messages[0].time
                @_insertLoadMore()

    onMessage: (err, messages) ->

    # private 
    _sendMsg: (msgData) ->

    _insertMessage: (message) ->
        {senderId, content, senderAvatar, senderLogin} = message
        toAddClass = if @_isOwnMessage(message) then 'you' else 'me'

        template = """->HTML
            <div class="chat #{toAddClass}">
                <img src="#{avatar}" />
                <h2>#{username}</h2>
                <div class="bubble #{toAddClass}">
                    <p>#{content}</p>
                </div>
            </div>
        """

        $(template).appendTo(@$messageList) if @$messageList?
        @resetScroll() if @options.isMessageScroll

    _isOwnMessage: (message) ->
        metadata.user.id == message.senderId
        
    _insertLoadMore: () ->


    _clearEventListners: () ->
        @userSocket.offPersonMessage(@boundOnMessage)





