#= require './table'
#
class @MiniTable

  @defaultOptions = {
    mdscreenWidth: 1200
  }

  constructor: (@element, @target, @order) ->
    @isVisible = false
    $(window).on('resize', @_resizeHandler.bind(@))

    @_checkWindowWidth()

  $: () ->
    $(@element)

  toggleShow: () ->
    @table ||= new OrderTable(@target, @order)
    $fixedBottom = $('.navbar-fixed-bottom')

    if (@isVisible)
      @isVisible = false
      @_hideOrderItems()
      $fixedBottom.slideDown()
    else
      @isVisible = true
      @_showOrderItems()
      $fixedBottom.slideUp()


  send: (event, data) ->
    if @table?
      @table.send(event, data)

  _resizeHandler: (event) ->
    width = $(event.target).width()

    if (width >= MiniTable.defaultOptions.mdscreenWidth)
      @_removeClickListener()
      @_showChatScroll()
    else
      @_addClickListener()
      @_hideChatScroll()

  _addClickListener: () ->
    unless @_clickLinstenerAdded
      @$().on 'click', @toggleShow.bind(@)
      @_clickLinstenerAdded = true

  _removeClickListener: () ->
    if @_clickLinstenerAdded
      @$().off 'click', @toggleShow.bind(@)
      @_clickLinstenerAdded = true

  _checkWindowWidth: () ->
    width = $(window).width()

    if (width >= MiniTable.defaultOptions.mdscreenWidth)
      @_showOrderItems()
    else
      @_addClickListener()

  _showOrderItems: () ->
    $('.main-content').addClass('show-order-items')

  _hideOrderItems: () ->
    $('.main-content').removeClass('show-order-items')

  _showChatScroll: () ->
    $('.chat-list .chat-inner').css('overflow', 'auto')

  _hideChatScroll: () ->
    $('.chat-list .chat-inner').css('overflow', 'hidden')



