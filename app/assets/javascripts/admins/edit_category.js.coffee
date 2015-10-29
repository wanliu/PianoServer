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

  constructor: (@element, @url) ->
    super
    @hammer = new Hammer.Manager(@$()[0])
    @hammer.add(new Hammer.Press())
    @$img = @$().find('form input[name="shop_category_img"]')
    @$input = @$().find('.title-input')
    @shopCategoryId = @$().data('shopCategoryId')
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
    @enterAnimation(e,()=>
      Turbolinks.visit(@url)
    )
    # if $(e.target).is('.thumbnail>img') 

    #   if @thumbnailClickable(e)
    #     _url = @url
        
    #     setTimeout () =>
    #       Turbolinks.visit(_url)
    #     , 400
        
    #     @$()
    #       .addClass('animate-scale-enter')
    #       .one(@animationend(), () -> 
    #         $(@).removeClass('animate-scale-back')
    #       )
    #   else
    #     @$()
    #       .addClass('animate-shiver')
    #       .one(@animationend(), () -> 
    #         $(@).removeClass('animate-shiver')
    #       )

  enterAnimation: (e,fn) ->
    if $(e.target).is('.thumbnail>img')
      if @thumbnailClickable(e)

        reference       = @$().children('.box')

        orginTop        = reference.offset().top
        orginLeft       = reference.offset().left

        referenceHeight = reference.height()
        referenceWidth  = reference.width()

        screenWith      = $(window).width()
        screenheight    = $(window).height()

        maskHeight      = referenceHeight
        maskWidth       = maskHeight

        maskTop         = orginTop  + (referenceHeight - maskHeight) / 2
        maskLeft        = orginLeft + (referenceWidth  - maskHeight) / 2


        $('body').append('<div class="animate-mask"></div>')
        @$().animate({'opacity':0})

        $('.animate-mask').css({
          'z-index': 999,
          'opacity': 0.5,
          'left'   : maskLeft   + 'px',
          'top'    : maskTop    + 'px',
          'width'  : maskWidth  + 'px',
          'height' : maskHeight + 'px'
        });

        $('.animate-mask').animate({
          'left'   : 0,
          'top'    : 0,
          'opacity': 0.8,
          'width'  : screenWith  + 'px',
          'height' : screenheight + 'px'
        });

        # fn()
      else
        @$()
          .addClass('animate-shiver')
          .one(@animationend(), () -> 
            $(@).removeClass('animate-shiver')
          )


  animationend: () -> 
    ['animationend','webkitAnimationEnd','oanimationend','MSAnimationEnd'].join(' ')

  onPress: () ->
    $('#category-modal').data('url', @url).modal("show")

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

$(document).on('page:change', (event) ->
  $('.animate-scale-enter')
    .removeClass('animate-scale-enter')
    .addClass('animate-scale-back')
)