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
      @_hideLineItems(true)
      $fixedBottom.slideDown()
    else
      @_showLineItems(true)
      @_hideChatScroll()
      $fixedBottom.slideUp()

    @$().find('.order-toggle-button').toggleClass('toggle-up')

  send: (event, data) ->
    if @table?
      @table.send(event, data)

  _resizeHandler: (event) ->
    width = $(event.target).width()

    if (width >= MiniTable.defaultOptions.mdscreenWidth)
      @_showChatScroll()
      @_showLineItems(false)
      @$().removeClass('show-toggle-button')
    else
      @$().addClass('show-toggle-button')

      if @isVisible
        @$().find('.order-toggle-button').addClass('toggle-up')

  _checkWindowWidth: () ->
    width = $(window).width()

    if (width >= MiniTable.defaultOptions.mdscreenWidth)
      @_showLineItems(false)
    else
      @$().addClass('show-toggle-button')

  _showLineItems: (shouldAnimate) ->
    $mainContent = $('.chat-order-body').addClass('show-order-items')
    $tableWrap = $mainContent.find('.order-table-wrap')

    @isVisible = true

    if shouldAnimate
      $tableWrap.slideDown()
    else
      $tableWrap.show()

  _hideLineItems: (shouldAnimate) ->
    $mainContent = $('.chat-order-body')
    $tableWrap = $mainContent.find('.order-table-wrap')

    @isVisible = false

    @$().find('.order-toggle-button').addClass('toggle-up')

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



