@Ajax = (element, options = {}, args...) ->
  sendElement = $(element);
  originCallback = options['beforeSend']
  options['beforeSend'] = (jqXHR, settings ) =>
    jqXHR['element'] = sendElement
    $(document).trigger('ajax:beforeSend', jqXHR, settings)
    originCallback(jqXHR, settings) if $.isFunction(originCallback)

  $.ajax(options, args...)

$(document).ajaxStart (event) =>
  AjaxStatusProcess('ajaxStart', event)

$(document).on 'ajax:beforeSend', (event, jqXHR) ->
  AjaxStatusProcess('beforeSend', event, jqXHR)

$(document).ajaxComplete (event, jqXHR, ajaxOptions ) ->
  AjaxStatusProcess('ajaxComplete', event, jqXHR, ajaxOptions)

$(document).ajaxError (event, jqXHR, ajaxSettings, thrownError ) ->
  AjaxStatusProcess('ajaxError', event, jqXHR, ajaxSettings, thrownError)

$(document).ajaxSuccess ( event, jqXHR, ajaxOptions, data) ->
  AjaxStatusProcess('ajaxSuccess', event, jqXHR, ajaxOptions, data)

$(document).ajaxSend ( event, jqXHR, ajaxOptions) ->
  AjaxStatusProcess('ajaxSend', event, jqXHR, ajaxOptions)

@Ajax.default_options = {
  container: '.navbar',
  sending: '保存中...',
  success: '保存成功!',
  containerHeight: 50
}

$prompt = null
SuccessTPL = "<div class=\"success\">\n  <h3 class=\"text-center\">$message</h3>\n</div>";
ErrorTPL = "<div class=\"error\">\n  <h1 class=\"text-center\">$message</h1>\n</div>";

AjaxStatusProcess = (type, event, jqXHR, args...) ->
  { container, sending, containerHeight, success } = Ajax.default_options

  if jqXHR? and jqXHR.element?
    $fromElement = $(jqXHR.element)
    # do something
    switch type
      when 'ajaxStart', 'beforeSend'
        disable($fromElement)
        $prompt ||= $(container).find('.ajax-prompt')
        $prompt = $("<span class=\"ajax-prompt label label-warning\">#{sending}</span>").appendTo($(container)) unless $prompt.length
        [ w, h ] = [$prompt.width(), $prompt.height()]

        $prompt
          .text(sending)
          .css(
            position: 'absolute',
            top: (containerHeight - h) / 2,
            left: '50%',
            marginLeft: -(w/2)
          )
          .show()
      when 'ajaxSuccess'
        context = {
          message: success
        };

        $prompt ||= $(container).find('.global-ajax-success')
        $success =
          if $(".global-ajax-success").length
            $(".global-ajax-success")
          else
            $("<div class=\"global-ajax-success\" />").appendTo("body")

        $success.html(SuccessTPL.replace(/\$(\w+)/, (m, key) ->
          context[key]
        ))

        $success
          .css(
            position: 'fixed',
            top: 0,
            left: '50%',
            width: 300,
            marginLeft: -150,
            height: 70,
            zIndex: 1053,
            color: 'white',
            backgroundColor: '#5cb85c',
            opacity: 0.95,
            borderBottomLeftRadius: 30,
            borderBottomRightRadius: 30
          )
          .fadeIn()
          .delay(3000)
          .fadeOut()

      when 'ajaxComplete'
        enable($fromElement)
        $prompt.hide()
      when 'ajaxError'
        [settings, thrownError] = args
        context = {
          message: thrownError
        };

        $error =
          if $(".global-ajaxError").length
            $(".global-ajaxError")
          else
            $("<div class=\"global-ajaxError\" />").appendTo("body")

        $error.html(ErrorTPL.replace(/\$(\w+)/, (m, key) ->
          context[key];
        ))

        $error.css({
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          zIndex: 1053,
          color: 'white',
          backgroundColor: '#D41B1B',
          opacity: 0.95
        }).fadeIn().delay(3000).fadeOut();
      else
        ;

    console.log $fromElement


parseAjaxConfig = (element) ->

disable = (element) ->
  if $(element).is(':input')
    $(element).attr('disabled', true)
  else
    $(element).addClass("disabled")

enable = (element) ->
  if $(element).is(':input')
    $(element).attr('disabled', false)
  else
    $(element).removeClass("disabled")
