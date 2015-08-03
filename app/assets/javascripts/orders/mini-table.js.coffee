#= require './table'
#
class @MiniTable

  constructor: (@element, @target, @order) ->
    @isVisible = false
    @$().bind 'click', @toggleShow.bind(@)

  $: () ->
    $(@element)

  toggleShow: () ->
    @table ||= new OrderTable(@target, @order)
    $content = $('.main-content')
    $list = $content.find('.chat-list')
    $fixedBottom = $('.navbar-fixed-bottom')

    if (@isVisible)
      @isVisible = false
      $content.removeClass('show-order-items')
      $fixedBottom.slideDown(() ->
        $list.css({
          'overflow': 'auto',
          'bottom': '55px'
        })
      )

      # $(@target).slideUp(() ->
      #   $fixedBottom.slideDown(() ->
      #     $list.css({
      #       'overflow': 'auto',
      #       'bottom': '55px'
      #     })
      #   )
      # )

    else
      @isVisible = true
      $content.addClass('show-order-items')
      $fixedBottom.slideUp(() ->
        $list.css({
          'overflow': 'hidden',
          'bottom': '0'
        })
      )

      # $(@target).slideDown(() ->
      #   $fixedBottom.slideUp(() ->
      #     $list.css({
      #       'overflow': 'hidden',
      #       'bottom': '0'
      #     })
      #   )
      # )

  send: (event, data) ->
    if @table?
      @table.send(event, data)
