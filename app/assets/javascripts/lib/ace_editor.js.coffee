$ ->
  $("[ace-editor-id]").editor()

save_editor = (e) =>
  $target = $(e.currentTarget)

  editor = $target.data('ace_edit')
  http_options = $target.data('http_options')
  http_options['data']['template']['content'] = editor.getValue();

  Ajax($target, http_options)


$.fn.editor = () ->
  $(this).each (i, elem) ->
    editor = $(this).data('ace_edit');
    http_options = $(this).data('http_options');
    button_name = $(elem).attr("save_button")
    $save_button = $("[name=#{button_name}]")

    if $save_button.length
      $save_button.data('ace_edit', editor)
      $save_button.data('http_options', http_options)
      $save_button.unbind 'click', save_editor
      $save_button.bind 'click', save_editor
