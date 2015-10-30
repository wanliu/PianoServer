#= require _common/event
class @TemplateVariable extends @HuEvent

  events:
    # 'click .edit-icon': 'editVariable'
    'click .remove-icon': 'removeVariable'
    'click': 'insertVariable'

  constructor: (@element, @subject_id, @template_id) ->
    super(@element)
    @variable_id = @$().attr('variable-id')

  editVariable: (e) ->
    e.stopPropagation()

  removeVariable: (e) ->
    e.stopPropagation()

    url = ['/admins/subjects/', @subject_id, '/templates/blob/', @template_id,
      '/variables/', @variable_id].join('')

    $item = @$()

    dataConfirmModal.confirm({
      title: '删除提示',
      text: '确认删除此参数吗?'
      commit: '删除',
      cancel: '取消',
      onConfirm: () ->
        $.ajax({
          url: url,
          type: 'DELETE',
          dataType: 'json',
          success: () =>
            $item.remove()
          ,
          error: (errors) =>
            alert(errors)
        })
    })

  insertVariable: (e) ->

  update: (name) ->
    @$().find('.variable_name').text(name)

  destroy: () ->
    @unbindAllEvent()

    @element.remove()
