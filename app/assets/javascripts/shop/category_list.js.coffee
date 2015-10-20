#= require _common/event

class @CategoryList extends @HuEvent
  constructor: (@container, @element, @categories, @level) ->
    super(@element)
    @generateCategoryItems(@categories)
    @on('categories:change', @categoriesChanged.bind(@))
    @on('categories:empty', @emptyCategories.bind(@))

  generateCategoryItems: (categories) ->
    for category in categories
      @generateCategoryItem(category).appendTo(@$())

  generateCategoryItem: (category) ->
    { id, title, is_leaf } = category

    if is_leaf
      template = """<li class="list-group-item" category-id="#{id}">
        #{title}</li>"""
    else
      template = """
        <li class="list-group-item has-children" category-id="#{id}">
          #{title}<span class="glyphicon glyphicon-chevron-right children"></span>
        </li>"""

    $(template)

  bindAllEvents: () ->
    @$().on 'click', '.list-group-item', @clickHandler.bind(@)

  clickHandler: (e) ->
    $target = $(e.target)

    $target.addClass('active').siblings().removeClass('active')
    category_id = $target.attr('category-id')
    is_leaf = !$target.hasClass('has-children')

    @container.send('category:change', [ category_id, @level, is_leaf ])

  categoriesChanged: (e, data) ->
    @$().html('')

    @generateCategoryItems(data)

  emptyCategories: (e) ->
    @$().html('')


