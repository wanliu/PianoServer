#= require './table'
#
class @MiniTable

  @defaultOptions = {
    mdscreenWidth: 1200
  }

  constructor: (@element, @target, @order) ->
    @isVisible = false
    $(window).on('resize', @_resizeHandler.bind(@))
    @$().on 'click', @toggleShow.bind(@)

    @table ||= new OrderTable(@target, @order)

    $(document).on 'table:change', (e, table) =>
      @setTable(table)

    @_checkWindowWidth()

  $: () ->
    $(@element)

  setTable: (@table) ->

  toggleShow: () ->
    width = $(window).width()
    $fixedBottom = $('.navbar-fixed-bottom')

    unless width < MiniTable.defaultOptions.mdscreenWidth
      return

    if @isVisible
      @_hideOrderItems(true)
      $fixedBottom.slideDown()
      @isVisible = false
    else
      @_showOrderItems(true)
      @_hideChatScroll()
      $fixedBottom.slideUp()
      @isVisible = true

  send: (event, data) ->
    if @table?
      @table.send(event, data)

  _resizeHandler: (event) ->
    width = $(event.target).width()

    if (width >= MiniTable.defaultOptions.mdscreenWidth)
      @_showChatScroll()
      @_showOrderItems(false)
    else
      @_hideChatScroll()

  _checkWindowWidth: () ->
    width = $(window).width()

    if (width >= MiniTable.defaultOptions.mdscreenWidth)
      @_showOrderItems()
    else
      @_addClickListener()

  _showOrderItems: (shouldAnimate) ->
    $mainContent = $('.main-content').addClass('show-order-items')
    $tableWrap = $mainContent.find('.order-table-wrap')

    if shouldAnimate
      $tableWrap.slideDown()
    else
      $tableWrap.show()

  _hideOrderItems: (shouldAnimate) ->
    $mainContent = $('.main-content')
    $tableWrap = $mainContent.find('.order-table-wrap')

    if shouldAnimate
      $tableWrap.slideUp(() ->
        $mainContent.removeClass('show-order-items')
      )
    else
      $tableWrap.hide(() ->
        $mainContent.removeClass('show-order-items')
      )



    @_showChatScroll()
    @chatContentOverlayed = false

  _showChatScroll: () ->
    $('.chat-list .chat-inner').css('overflow', 'auto')

  _hideChatScroll: () ->
    $('.chat-list .chat-inner').css('overflow', 'hidden')
    @chatContentOverlayed = true



