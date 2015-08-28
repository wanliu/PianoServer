#= require _common/event
#= require ace-rails-ap
#= require ./edit_template_toolbar_variable

EditTemplateToolbarVariable = @EditTemplateToolbarVariable

class @EditTemplate extends @Event

  LiquidMode = ace.require("ace/mode/liquid").Mode
  events:
    'submit >form': 'onSave'
    'click .panel-heading': 'togglePanelBody'

  constructor: (@element, @name, @options ={}) ->
    super(@element)
    editor = @$().find('.source-editor')
    @editor = ace.edit(@name)
    @editor.getSession().setMode(new LiquidMode());
    @editor.setOptions({
      enableBasicAutocompletion: true
    });

    @url = @options['url']


    @$content = @$().find('.template_content');

    @variableToolbar = new EditTemplateToolbarVariable(@$().find('.variables'))
    @bindUploadButton()

  bindUploadButton: () ->
    token = $('meta[name="csrf-token"]').attr('content')

    @$upload = @$().find('.btn-upload')
    @$uploader = new qq.FileUploader({
      element: @$upload[0],
      action: @url + "/upload",
      uploadButtonText: '上传',
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploader.bind(@)
    })

  onSave: (e) ->
    @$content.val(@editor.getValue())

  onUploader: (id, filename, responseJSON) ->
    # @setImage(responseJSON.url)
    # $(@$uploader._listElement).empty()

  togglePanelBody: (e) ->
    $target = $(e.target)

    if $target.is('input')
      return false;

    unless $target.is('.panel-heading')
      $target = $target.parents('.panel-heading:first')

    $target.toggleClass('down').siblings().slideToggle()
