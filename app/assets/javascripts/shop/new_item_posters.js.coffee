#= require ./edit_item_poster
#= require _common/event

class @NewItemPosters extends @HuEvent
  constructor: (@element, @container, @url) ->
    super(@element)

    token = $('meta[name="csrf-token"]').attr('content')

    @$uploader = new qq.FileUploader({
      element: @element.find('.upload-btn')[0],
      action: @url,
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploaded.bind(@)
    })

  onUploaded: (id, filename, responseJSON) ->
    @container.send('poster:add', [responseJSON.url, responseJSON.filename])


