class @CategoryForm
  constructor: (@container, @$element) ->
    @container.setForm(@) if @container?

  changeCategory: (id, is_leaf) ->
    $button = @$element.find('input[type=submit]')
    $input = @$element.find('input[name=category_id]')

    if is_leaf
      $button.removeAttr('disabled')
    else
      $button.attr('disabled', 'disabled')

    id = '' if id == null
    $input.val(id)
