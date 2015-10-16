#= require ./event

class @Popup extends @HuEvent
  constructor: (@element, @options = {}) ->
    super(@element)
    @modal = @options['modal'] || false
    @addModal() if @modal
    @recalcLayout()

  setHtml: (html) ->
    @$().html(html)
    @addModal() if @modal
    @recalcLayout()

  addModal: () ->
    $backdrop = $('<div class="popup-modal"></div>').appendTo(@$())
    $backdrop.css({
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: '#000',
      opacity: 0.3
    })
    $backdrop

  recalcLayout: () ->
    @applyStyle()
    height = $(window).height();
    width = $(window).width();
    popupWidth = @$().outerWidth(true)
    popupHeight = @$().outerHeight(true)

    left = (width - popupWidth) / 2
    top = (height - popupHeight) / 2

    @$().css(top: top, left: left)

  applyStyle: () ->
    @$().css(position: 'absolute', zIndex: 1070)

  show: () ->
    @$().show()
    @recalcLayout()

  close: () ->
    @$().remove();

  @show: (html, options) ->
    container = "<div class=\"popup-container\">#{html}</div>"
    $html = $(container).appendTo('body');
    new Popup($html, options)


