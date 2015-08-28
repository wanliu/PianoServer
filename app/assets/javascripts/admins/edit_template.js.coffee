#= require _common/event
#= require ace-rails-ap
#= require ./edit_template_toolbar_variable

EditTemplateToolbarVariable = @EditTemplateToolbarVariable

class @EditTemplate extends @Event

  LiquidMode = ace.require("ace/mode/liquid").Mode
  events:
    'submit >form': 'onSave'

  constructor: (@element, @name, @options ={}) ->
    super(@element)
    editor = @$().find('.source-editor')
    @editor = ace.edit(@name)
    @editor.getSession().setMode(new LiquidMode());
    @editor.setOptions({
      enableBasicAutocompletion: true
    });

    @url = @options['url']


    @$content = @$().find('.template_content')
    @$progress = @$().find('.progress')

    @variableToolbar = new EditTemplateToolbarVariable(@$().find('.variables'))
    @bindUploadButton()

  bindUploadButton: () ->
    token = $('meta[name="csrf-token"]').attr('content')

    @$upload = @$().find('.btn-upload')
    @$uploader = new qq.FileUploader({
      element: @$upload[0],
      action: @url + "/upload",
      uploadButtonText: '上传',
      dragText: '拖动到这里上传',
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploader.bind(@),
      onProgress: @onProgress.bind(@)

    })

  onSave: (e) ->
    @$content.val(@editor.getValue())

  onUploader: (id, filename, json) ->
    $(json.html).appendTo(@$().find('.file-list'))
    @$progress.hide();
    # @setImage(responseJSON.url)
    # $(@$uploader._listElement).empty()

  onProgress: (id, fileName, loaded, total) ->
    percent = Math.round(loaded / total * 100, 0) + '%'
    if loaded > 0
      @$progress.show()

    @$progress.find('.progress-bar').width(percent).text(percent)

