#= require _common/event
#= require _common/fileuploader
class @EditShopCategory extends @HuEvent
  events:
    'click': 'onClick'
    'click .thumbnail>h2': 'onClickTitle'
    'keypress .title-input': 'enterTitle',
    'blur .title-input': 'leaveEdit'
    'click input[name="file"]': 'onClickUploader'
    'click .uploader-btn': 'onClickUploader'
    'click .btn-opened': 'hideCategory'
    'click .btn-closed': 'showCategory'

  constructor: (@element, @status) ->
    super(@element)
    @hammer = new Hammer.Manager(@$()[0])
    @hammer.add(new Hammer.Press())
    @$img = @$().find('form input[name="shop_category_img"]')
    @$input = @$().find('.title-input')
    @shopCategoryId = @$().data('shopCategoryId')
    @url = @$().find('.thumbnail').data('link')
    token = $('meta[name="csrf-token"]').attr('content')

    unless @status
      @element.find('.toggle-button').addClass('closed')

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

    @hammer.on('press', @.onPress.bind(@))

  onClickTitle: (e) ->
    return if $(window).width() < 768

    e.preventDefault()
    e.stopPropagation()

    @$title = $(e.target).hide()
    @$input
      .val(@$title.text())
      .show()
      .focus()
      .select()

  onClick: (e) ->
    if $(e.target).is('.thumbnail>img')

      if @thumbnailClickable(e)
        Turbolinks.visit(@url)
        @$()
          .addClass('animate-reversal-enter')
          .one(@animationend(), () ->
            $(@).removeClass('animate-reversal-back')
          )
      else
        @$()
          .addClass('animate-shiver')
          .one(@animationend(), () ->
            $(@).removeClass('animate-shiver')
          )

  animationend: () ->
    ['animationend','webkitAnimationEnd','oanimationend','MSAnimationEnd'].join(' ')

  onPress: () ->
    $('#category-modal').data({'url': @url, 'status': @status, related: @}).modal("show")

  thumbnailClickable: (e) ->
    $(e.target).parent('.thumbnail').attr('data-limited-depth') is 'false'

  onUploader: (id, filename, responseJSON) ->
    @setImage(responseJSON.url)
    $(@$uploader._listElement).empty()

  enterTitle: (e) ->
    if e.which == 13
      $.ajax({
        url: @url,
        type: 'PUT',
        data: {
          parent_id: @shopCategoryId,
          shop_category: {
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

  showCategory: (e) ->
    $target = $(e.currentTarget)

    $.ajax({
      url: @url + '/update_status',
      type: 'PUT',
      dataType: 'json',
      data: {
        shop_category: {
          status: true
        }
      },
      success: () =>
        @status = true
        $target.parent().removeClass('closed')
    })

  hideCategory: (e) =>
    $target = $(e.currentTarget)

    $.ajax({
      url: @url + '/update_status',
      type: 'PUT',
      dataType: 'json',
      data: {
        shop_category: {
          status: false
        }
      },
      success: () =>
        @status = false
        $target.parent().addClass('closed')
    })

$(document).on('page:change', (event) ->
  $('.animate-reversal-enter')
    .removeClass('animate-reversal-enter')
    .addClass('animate-reversal-back')
)
