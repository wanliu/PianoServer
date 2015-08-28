#= require ./edit_template

class @NewTemplate extends @EditTemplate
  events:
    'submit >form': 'onSave',
    'show.bs.tab .preview-template-tab': 'preview',
    'click .preview': 'clickPreview',
    'ajax:success >form': 'success',
    'ajax:error >form': 'error'

  success: (e, data, status, xhr) ->
    $('#new-template').before(data)

    @editor.setValue('')
    @editor.resize(true)
    $('#new-template').hide()

    $('#new-template input.template-filename').val('views/undefined.html.liquid')
    $('#new-template input.template_content').val('')

  error: (e, data, status, xhr) ->
