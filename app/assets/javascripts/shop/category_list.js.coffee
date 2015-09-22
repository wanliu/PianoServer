class @CategoryList

  constructor: (@container, @element, @categories, @level, @$form) ->
    @generateCategoryItems(@categories)

  generateCategoryItems: (categories) ->
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
    $submit = @$form.find('input[type=submit]')
    $input = @$form.find('input[name=category_id]')

    if $target.hasClass('has-children')
      $submit.attr('disabled', 'disabled')
    else
      $submit.removeAttr('disabled')
      $input.val(category_id)

    @container.loadCategoryData(category_id, (data) =>
      @container.categoryChanged(data, @level)
    )

  resetContent: (data) ->
    @element.html('')

    @generateCategoryItems(data)

  emptyContent: () ->
    @element.html('')


