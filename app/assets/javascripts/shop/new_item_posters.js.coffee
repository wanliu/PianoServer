#= require ./edit_item_poster

class @NewItemPosters
  constructor: (@element, @url, @$filenames) ->
    token = $('meta[name="csrf-token"]').attr('content')

    @$uploader = new qq.FileUploader({
      element: @element.find('.upload-btn')[0],
      action: @url,
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      onComplete: @onUploaded.bind(@)
    })

  onUploaded: (id, filename, responseJSON) ->
    _filename = responseJSON.filename

    @addFilename(_filename)

    $container = @element.parent()
    new EditItemPoster(this, @url, $container, _filename, responseJSON.url)

    $(@$uploader._listElement).empty()

  addFilename: (filename) ->
    names = $.trim(@$filenames.val())
    filenames = if names.length > 0 then [filename, names].join(',') else [filename, names].join('')
    @$filenames.val(filenames)

  removeFilename: (filename) ->
    filenames = $.trim(@$filenames.val()).split(',')
    index = filenames.indexOf(filename)

    if index > -1
      filenames.splice(index, 1)
      @$filenames.val(filenames.join(','))

  replaceFilename: (oldFilename, newFilename) ->
    filenames = $.trim(@$filenames.val()).split(',')
    index = filenames.indexOf(oldFilename)

    if index > -1
      filenames[index] = newFilename
      @$filenames.val(filenames.join(','))
