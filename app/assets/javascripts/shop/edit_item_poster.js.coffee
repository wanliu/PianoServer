#= require _common/event

class @EditItemPoster extends @HuEvent
  events:
    'click .remove-icon': 'removeItemPoster'

  constructor: (@container, @action, @$container, @filename, @url) ->
    @element = @createElement()

    super(@element)

    token = $('meta[name="csrf-token"]').attr('content')

    @$uploader = new qq.FileUploader({
      element: @element.find('.upload-btn')[0],
      action: @action,
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploaded.bind(@)
    })

  createElement: () ->
    template = """
      <div class="col-xs-4 col-sm-4 col-md-4 col-lg-3 edit-item-poster">
        <div class="thumbnail">
          <img src="#{@url}" class="item-poster">
          <div class="remove-icon">
            <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
          </div>
          <div class="plus-icon">+</div>
          <div class="upload-btn"></div>
        </div>
      </div>
    """

    $(template).prependTo(@$container)

  onUploaded: (id, filename, responseJSON) ->
    @container.replaceFilename(@filename, filename)
    @filename = filename

    @element.find('.item-poster').attr('src', responseJSON.url)

  removeItemPoster: () ->
    dataConfirmModal.confirm({
      title: '删除提示',
      text: '确认删除此图片吗?'
      commit: '删除',
      cancel: '取消',
      onConfirm: () =>
        @container.removeFilename(@filename)
        @element.remove()
    })


