#= require _common/event
#= require ./template_variable

class @TemplateVariables

  constructor: (@element, @subject_id, @template_id) ->
    $items = @element.find('.variable-item')

    @itemList = for $item in $items
      new TemplateVariable($item, @subject_id, @template_id)

    $(@element).data('plugin', @)

  addVariable: (variable_id, variable_name) ->
    template = """
      <div class="variable-item" variable-id="#{variable_id}" >
        #{variable_name}
        <div class="variable-tools">
          <span class="glyphicon glyphicon-pencil edit-icon" aria-hidden="true"></span>
          <span class="glyphicon glyphicon-remove remove-icon" aria-hidden="true"></span>
        </div>
      </div>
    """

    $item = $(template).appendTo(@element)

    @itemList.push(new TemplateVariable($item, @subject_id, @template_id))

  removeVariable: (toRemoveId) ->
    toRemoveIndex = -1

    for item, index in itemList
      if item.variable_id == toRemoveId
        toRemoveItem = item
        toRemoveIndex = index

        break

    if index > -1
      toRemoveItem.destroy()
      @itemList.splice(toRemoveIndex, 1)






