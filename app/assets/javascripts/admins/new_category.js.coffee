#= require _common/event
class @NewCategory extends @Event
  events:
    'click': 'onClick'
    'click a>h2': 'onClickTitle'

  constructor: (@element, @category, @url) ->
    super
    @$img = @$().find('form input[name="category_img"]')

  onClickTitle: (e) ->
    @$title = $(e.target).hide()
    @$input = $("""
      <input type="text" name="name" class="title-input" placeholder="分类名称" />
    """)
      .appendTo(@$().find('.thumbnail'))
      .focus()

    @$input
      .on 'keypress', (e) =>
        if e.which == 13
          $.post(@url, {
            parent_id: @category.id,
            category: {
              name: @$input.val(),
              image_url: @$img.val()
            }
          }).success (data) =>
            @$().before($(data.html))

    @$input.blur () =>
      # @$title.text(@$input.val())
      @$input.remove()
      @$title.show()

  onClick: (e) ->

