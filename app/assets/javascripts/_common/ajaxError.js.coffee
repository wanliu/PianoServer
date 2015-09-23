#= require lib/underscore
#= require lib/underscore-template

TPL = """
<div class="error">
  <h1 class="text-center">{{= message }}</h1>
</div>
"""

$ =>
  $(document).ajaxError (event, jqXHR, ajaxSettings, thrownError ) =>
    tpl = _.template(TPL)

    $error = if $(".global-ajaxError").length
               $(".global-ajaxError")
             else
               $("<div class=\"global-ajaxError\" />").appendTo("body")

    $error.html(tpl({message: thrownError}))
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
    }).fadeIn()
      .delay(5000)
      .fadeOut()

