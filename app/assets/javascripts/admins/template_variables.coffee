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
        <span class="variable_name">#{variable_name}</span>
        <div class="variable-tools">
          <a data-toggle="modal" data-target="#variable_editor_modal"
            data-link="/admins/subjects/#{@subject_id}/templates/#{@template_id}/variables/#{variable_id}"
            data-class="promotion_variable" data-op="edit" href="#">
            <span class="glyphicon glyphicon-pencil edit-icon" aria-hidden="true"></span>
          </a>
          <span class="glyphicon glyphicon-remove remove-icon" aria-hidden="true"></span>
        </div>
      </div>
    """

    $item = $(template).appendTo(@element)

    @itemList.push(new TemplateVariable($item, @subject_id, @template_id))

  removeVariable: (toRemoveId) ->
    toRemoveIndex = -1

    for item, index in @itemList
      if item.variable_id == toRemoveId.toString()
        toRemoveItem = item
        toRemoveIndex = index

        break

    if toRemoveIndex > -1
      toRemoveItem.destroy()
      @itemList.splice(toRemoveIndex, 1)

  updateVariable: (id, name) ->
    for item in @itemList
      if item.variable_id == id.toString()
        toUpdateItem = item
        break

    if toUpdateItem
      toUpdateItem.update(name)





