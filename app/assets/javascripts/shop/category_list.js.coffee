class @CategoryList

  constructor: (@container, @element, @categories, @level) ->
    @generateCategoryItems(@categories)

  generateCategoryItems: (categories) ->
    for category in categories
      @generateCategoryItem(category).appendTo(@element)

    @bindClickEvent()

  generateCategoryItem: (category) ->
    { id, title, is_leaf } = category

    if is_leaf
      template = """
        <li class="list-group-item" category-id="#{id}">
          #{title}
        </li>
      """
    else
      template = """
        <li class="list-group-item has-children" category-id="#{id}">
          #{title}
          <span class="glyphicon glyphicon-chevron-right children"></span>
        </li>
      """

    $(template)

  bindClickEvent: () ->
    @element.find('.list-group-item').bind('click', @clickHandler.bind(@))

  clickHandler: (e) ->
    $target = $(e.currentTarget)

    $target.addClass('active').siblings().removeClass('active')
    category_id = $target.attr('category-id')
    is_leaf = !$target.hasClass('has-children')

    @container.loadCategoryData(category_id, (data) =>
      @container.categoryChanged(data, @level, is_leaf)
    )

  resetContent: (data) ->
    @element.html('')

    @generateCategoryItems(data)

  emptyContent: () ->
    @element.html('')


