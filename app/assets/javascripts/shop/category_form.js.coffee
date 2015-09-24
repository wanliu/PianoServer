#= require _common/event

class @CategoryForm extends @Event
  constructor: (@element, @container) ->
    super(@element)
    @container.setForm(@) if @container?
    @on('category:change', @changeCategory.bind(@))

  changeCategory: (e, id, is_leaf) ->
    $button = @$().find('input[type=submit]')
    $input = @$().find('input[name=category_id]')

    if is_leaf
      $button.removeAttr('disabled')
    else
      $button.attr('disabled', 'disabled')

    id = '' if id == null
    $input.val(id)
