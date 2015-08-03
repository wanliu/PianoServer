#= require ./event

class @Popup extends @Event
  constructor: (@element) ->
    super(@element)
    @recalcLayout()

  setHtml: (html) ->
    @$().html(html)
    @recalcLayout()

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

  @show: (html) ->
    container = "<div class=\"popup-container\">#{html}</div>"
    $html = $(container).appendTo('body');
    new Popup($html)


