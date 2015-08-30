#= require _common/event
#= require ace-rails-ap
#= require ./edit_template_toolbar_variable

EditTemplateToolbarVariable = @EditTemplateToolbarVariable

class @EditTemplate extends @Event

  LiquidMode = ace.require("ace/mode/liquid").Mode
  events:
    'submit #edit_template': 'onSave',
    'show.bs.tab .preview-template-tab': 'preview',
    'click .preview': 'clickPreview',
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

  clickPreview: (e) ->
    @element.find('.preview-template-tab').tab('show')

  preview: (e) ->
    source = @editor.getValue()
    parseUrl = @element.attr("data-preview-url")

    @element.find(".preview-template h3.panel-title").html(@fileTitle())
    $.get(parseUrl, {source: source})
      .success (data, status, xhr) =>
         @element.find('iframe').contents().find('body').html(data);

  fileTitle: () ->
    if @element.find(".edit-template h3.panel-title input").length > 0
      @element.find(".edit-template h3.panel-title input").val()
    else
      @element.find(".edit-template h3.panel-title").text()

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

  togglePanelBody: (e) ->
    $target = $(e.target)

    if $target.is('input')
      return false;

    $panel = $target.parents(".edit-template:first")

    $panel.toggleClass('down').find('.panel-body, .panel-footer').slideToggle()
