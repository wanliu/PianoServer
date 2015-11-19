
adjust = (elem) ->
  step = parseInt($(elem).attr('adjust-step')) || 0;
  padding = parseInt($(elem).attr('adjust-padding')) || 0;
  containerWidth = $(elem).parent().width();

  $(elem).width(Math.floor(containerWidth / step) * step + padding);

window.adjustContainer = () =>
  $('.adjust-container').each (i, elem) ->
    adjust(elem)


$ ->
  $(window).on 'resize', (e) ->
    window.adjustContainer()

