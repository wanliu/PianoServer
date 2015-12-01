#= require _common/event
#= require _common/fileuploader

TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'
ANIMATION_ENDS  = 'webkitAnimationEnd oanimationend oAnimationEnd msAnimationEnd Animation'

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
    @$progress = @$().find('.progress')

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
      onComplete: @onUploader.bind(@),
      onProgress: @onProgress.bind(@)
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
    # @enterAnimation(e,()=>
    #   Turbolinks.visit(@url)
    # )
    Turbolinks.visit(@url)

  enterAnimation: (e,fn) ->
    if $(e.target).is('.thumbnail>img')
      if @thumbnailClickable(e) && !$('.animate-mask')[0]

        reference       = @$().children('.box')
        orginTop        = reference.offset().top
        orginLeft       = reference.offset().left
        referenceHeight = reference.height()
        referenceWidth  = reference.width()
        screenWith      = $(window).width()
        screenheight    = $(window).height()
        maskHeight      = referenceHeight - 100
        maskWidth       = maskHeight
        maskTop         = orginTop  + (referenceHeight - maskHeight) / 2 + 5
        maskLeft        = orginLeft + (referenceWidth  - maskHeight) / 2 + 5

        $('body').append('<div class="animate-mask"></div>')

        mask = $('.animate-mask')
        mask
          .css({
            'left'    : maskLeft   + 'px'
            'top'     : maskTop    + 'px'
            'width'   : maskWidth  + 'px'
            'height'  : maskHeight + 'px'
          })
          .one(TRANSITION_ENDS, fn)

        reference.css({
          'opacity'   : 0
          'visibility': 'hidden'
          'transform' : 'scale(0.8)'
        }).addClass('animated')

        setTimeout () =>
          mask.css({
            'opacity' : 0.8
            'left'    : 0
            'top'     : 0
            'width'   : screenWith   + 'px'
            'height'  : screenheight + 'px'
          })
        , 10

      else
        @$()
          .addClass('animate-shiver')
          .one(ANIMATION_ENDS, () ->
            $(@).removeClass('animate-shiver')
          )

  onPress: () ->
    $('#category-modal').data({'url': @url, 'status': @status, related: @}).modal("show")

  thumbnailClickable: (e) ->
    $(e.target).parent('.thumbnail').attr('data-limited-depth') is 'false'

  onUploader: (id, filename, responseJSON) ->
    @setImage(responseJSON.url)
    $(@$uploader._listElement).empty()
    @$progress.hide()

  onProgress: (id, fileName, loaded, total) ->
    percent = Math.round(loaded / total * 100, 0) + '%'
    if loaded > 0
      @$progress.show()

    @$progress.find('.progress-bar').width(percent).text(percent)

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

# $(document).on('page:change', (event) =>
#   mask = $('.animate-mask')

#   if mask[0]
#     reference = $('.animated')
#     reference.css({'transform' : 'scale(1)'})

#     maskWidth   = reference.width()  - 50
#     maskHeight  = reference.height() - 50
#     maskTop     = reference.offset().top  + 30
#     maskLeft    = reference.offset().left + 30

#     mask.css({
#       'left'    : maskLeft   + 'px'
#       'top'     : maskTop    + 'px'
#       'width'   : maskWidth  + 'px'
#       'height'  : maskHeight + 'px'
#     })

#     mask.one('transitionend', ()=>
#       mask.remove()
#       reference.css({
#         'visibility' : 'visible'
#         'opacity'    : 1
#       }).removeClass('animated')

#     )
# )
