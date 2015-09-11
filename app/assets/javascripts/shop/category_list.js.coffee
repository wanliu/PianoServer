class @CategoryList

  constructor: (@container, @element, @categories, @level) ->
    @generateCategoryItems(@categories)
    @element.data('category-list', @)

  generateCategoryItems: (categories) ->
    @element.html('')

    for category in categories
      @generateCategoryItem(category).appendTo(@element)

    @bindClickEvent()

  generateCategoryItem: (category) ->
    { id, name, is_leaf } = category

    if is_leaf
      template = """
        <li class="list-group-item" category-id="#{id}">
          #{name}
        </li>
      """
    else
      template = """
        <li class="list-group-item has-children" category-id="#{id}">
          #{name}
          <span class="children"></span>
        </li>
      """

    $(template)

  bindClickEvent: () ->
    @element.find('.list-group-item').bind('click', @clickHandler.bind(@))

  clickHandler: (e) ->
    $target = $(e.currentTarget)

    $target.addClass('active').siblings().removeClass('active')
    category_id = $target.attr('category-id')
    selector = ['.list-group.level', @level+1].join('')

    @container.loadCategoryData(category_id, (data) =>
      @container.categoryChanged(data, @level)
    )

  resetContent: (data) ->
    @generateCategoryItems(data)

  emptyContent: () ->
    @element.html('')


