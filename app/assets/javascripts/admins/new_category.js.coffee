#= require _common/event
#= require admins/edit_category
EditShopCategory = @EditShopCategory

class @NewShopCategory extends @HuEvent
  events:
    'click': 'onClick',
    'click a': 'onClickTitle',
    'keypress .title-input': 'enterTitle',
    'blur .title-input': 'leaveEdit'

  constructor: (@element, @category, @url) ->
    super
    @$img = @$().find('form input[name="category_img"]')
    @$input = @$().find('.title-input')

  onClickTitle: (e) ->
    e.preventDefault()

    if $(window).width() < 768
      edit_url = @url + '/edit'
      Turbolinks.visit(edit_url)
    else
      @$title = $(e.currentTarget).find('h2').hide()
      @$input.show()
        .focus()

  enterTitle: (e) ->
    if e.which == 13
      title = @$input.val()

      return if title.length == 0

      $.post(@url, {
        parent_id: @category.id,
        shop_category: {
          title: title,
          image_url: @$img.val()
        }
      }).success (data) =>
        category = @$().before($(data.html)).prev()
        @$input.val('')
        new EditShopCategory(category, data.status)

  leaveEdit: () ->
    @$input.hide()
    @$title.show()

  onClick: (e) ->
    if $(window).width() < 768
      Turbolinks.visit(@url + '/new')
