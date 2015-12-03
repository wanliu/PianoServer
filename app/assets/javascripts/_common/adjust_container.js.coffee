
adjust = (elem, options = null) ->
  { step, padding } = options || $(elem).data('adjust') || {}
  step = step || parseInt($(elem).attr('adjust-step')) || 0;
  padding = padding || parseInt($(elem).attr('adjust-padding')) || 0;
  $(elem).data('adjust', {step: step, padding: padding})
  containerWidth = $(elem).parent().width();

  $(elem).width(Math.floor(containerWidth / step) * step + padding);

$.fn.adjustContainer = (options) ->
  $(@).each (i, elem) ->
    adjust(elem, options)

window.adjustContainer = (options = {}) =>
  $('.adjust-container').each (i, elem) ->
    adjust(elem, options)


$ ->
  $(window).on 'resize', (e) ->
    window.adjustContainer()

