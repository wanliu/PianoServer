#= require _common/event
#= require ace-rails-ap
#= require ./edit_template_toolbar_variable

EditTemplateToolbarVariable = @EditTemplateToolbarVariable

class @EditTemplate extends @Event

  LiquidMode = ace.require("ace/mode/liquid").Mode
  events:
    'submit >form': 'onSave'

  constructor: (@element, @name) ->
    super(@element)
    editor = @$().find('.source-editor')
    @editor = ace.edit(@name)
    @editor.getSession().setMode(new LiquidMode());
    @editor.setOptions({
      enableBasicAutocompletion: true
    });

    @$content = @$().find('.template_content');

    @variableToolbar = new EditTemplateToolbarVariable(@$().find('.variables'))

  onSave: (e) ->
    @$content.val(@editor.getValue())
