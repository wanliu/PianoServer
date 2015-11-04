#= require _common/event

class @EditItemPoster extends @HuEvent
  events:
    'click .remove-icon': 'removeItemPoster'

  constructor: (@element, @container, @url) ->
    super(@element)

    token = $('meta[name="csrf-token"]').attr('content')

    @$uploader = new qq.FileUploader({
      element: @element.find('.upload-btn')[0],
      action: @action,
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploaded.bind(@)
    })

  onUploaded: (id, filename, responseJSON) ->
    index = @$().index('.edit-item-poster')
    @container.send('poster:replace', [ index, filename ])
    @$().find('.item-poster').attr('src', responseJSON.url)

  removeItemPoster: () ->
    dataConfirmModal.confirm({
      title: '删除提示',
      text: '确认删除此图片吗?'
      commit: '删除',
      cancel: '取消',
      onConfirm: () =>
        @container.send('poster:remove', [ @filename ])
        @$().remove()
    })

