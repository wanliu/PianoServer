#= require _common/event
class @ModalBase extends @HuEvent

  constructor: (@element, @url, @variableList) ->
    super(@element)

  destroy: () ->
    @unbindAllEvents()
    @$().find('.modal-body').html('')

  variableCRUD: (op, data) ->
    return if !@variableList || @variableList.length == 0

    {id, name} = data
    templateVariables = @variableList.data('plugin')

    if templateVariables
      methodName = [op, 'Variable'].join('')
      templateVariables[methodName](id, name)


