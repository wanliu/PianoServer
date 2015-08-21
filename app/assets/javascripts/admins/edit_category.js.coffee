#= require _common/event
#= require _common/fileuploader
class @EditCategory extends @Event
  events:
    'click': 'onClick'
    'click .thumbnail>h2': 'onClickTitle'
    'keypress .title-input': 'enterTitle',
    'blur .title-input': 'leaveEdit'
    'click input[name="file"]': 'onClickUploader'
    'click .uploader-btn': 'onClickUploader'

  constructor: (@element, @url) ->
    super
    @$img = @$().find('form input[name="category_img"]')
    @$input = @$().find('.title-input')
    @categoryId = @$().data('categoryId')
    @url = @$().find('.thumbnail').data('link')
    token = $('meta[name="csrf-token"]').attr('content')

    @$uploader = new qq.FileUploader({
      element: @$().find('.uploader-btn')[0],
      action: @url + "/upload_image",
      customHeaders: { "X-CSRF-Token": token },
      multiple: false,
      template: """
        <div class="qq-uploader">
          <div class="qq-upload-drop-area"><span>{dragText}</span></div>
          <div class="qq-upload-button">
            <span class="button-icon glyphicon glyphicon-picture"></span>
          </div>
          <ul class="qq-upload-list"></ul>
        </div>
      """,
      onComplete: @onUploader.bind(@)
    })

  onClickTitle: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @$title = $(e.target).hide()
    @$input
      .show()
      .focus()

  onClick: (e) ->
    Turbolinks.visit(@url) if $(e.target).is('.thumbnail>img')

  onUploader: (id, filename, responseJSON) ->
    @setImage(responseJSON.url)
    $(@$uploader._listElement).empty()

  enterTitle: (e) ->
    if e.which == 13
      $.ajax({
        url: @url,
        type: 'PUT',
        data: {
          parent_id: @categoryId,
          category: {
            title: @$input.val(),
            image_url: @$img.val()
          }
        }
      }).success (data) =>
        @leaveEdit()
        @setTitle(data.title)


  leaveEdit: () ->
    @$input.hide()
    @$title.show()

  onClickUploader: (e) ->
    e.stopPropagation()

  setTitle: (title) ->
    @$input.val(title)
    @$title.text(title)

  setImage: (url) ->
    @$img.val(url)
    @$().find('.thumbnail>img').attr('src', url)
