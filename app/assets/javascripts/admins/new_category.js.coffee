#= require _common/event
#= require admins/edit_category
EditShopCategory = @EditShopCategory

class @NewShopCategory extends @HuEvent
  events:
    'click': 'onClick',
    'click a>h2': 'onClickTitle',
    'keypress .title-input': 'enterTitle',
    'blur .title-input': 'leaveEdit'

  constructor: (@element, @category, @url) ->
    super
    @$img = @$().find('form input[name="category_img"]')
    @$input = @$().find('.title-input')

  onClickTitle: (e) ->
    e.preventDefault()

    @$title = $(e.target).hide()
    @$input.show()
      .focus()

  enterTitle: (e) ->
    if e.which == 13
      $.post(@url, {
        parent_id: @category.id,
        shop_category: {
          title: @$input.val(),
          image_url: @$img.val()
        }
      }).success (data) =>
        category = @$().before($(data.html)).prev()
        @$input.val('')
        new EditShopCategory(category)

  leaveEdit: () ->
    @$input.hide()
    @$title.show()

  onClick: (e) ->

