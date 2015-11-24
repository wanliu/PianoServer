#= require _common/event

class @EditItemPoster extends @HuEvent
  events:
    'click .remove-icon': 'removeItemPoster'

  constructor: (@element, @container, @url) ->
    super(@element)

    @filename = @$().data('filename')
    token = $('meta[name="csrf-token"]').attr('content')

    @$uploader = new qq.FileUploader({
      element: @element.find('.upload-btn')[0],
      action: @url,
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploaded.bind(@)
    })

  onUploaded: (id, filename, responseJSON) ->
    @container.send('poster:replace', [ @filename, responseJSON.filename ])
    @$().find('.item-poster').attr('src', responseJSON.url)
    @filename = responseJSON.filename

  removeItemPoster: () ->
    dataConfirmModal.confirm({
      title: '删除提示',
      text: '确认删除此图片吗?'
      commit: '删除',
      cancel: '取消',
      onConfirm: () =>
        index = @$().index('.edit-item-poster')
        @container.send('poster:remove', [ @filename ])
        @$().remove()
    })

