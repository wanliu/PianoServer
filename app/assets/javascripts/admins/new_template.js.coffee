#= require ./edit_template

class @NewTemplate extends @EditTemplate
  events:
    'submit #edit-new-template': 'onSave',
    'show.bs.tab .preview-template-tab': 'preview',
    'click .preview': 'clickPreview',
    'ajax:success #edit-new-template': 'success',
    'ajax:error #edit-new-template': 'error'

  success: (e, data, status, xhr) ->
    $('#new-template').before(data)

    @editor.setValue('')
    @editor.resize(true)
    $('#new-template').hide()

    $('#new-template input.template-filename').val('views/undefined.html.liquid')
    $('#new-template input.template_content').val('')

  error: (e, data, status, xhr) ->
