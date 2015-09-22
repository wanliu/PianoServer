#= require ./category_list
#= require ./category_container

class @CategoryListWrap
  constructor: (@$container, @$form) ->
    @length = 5

    @categoryLists = for level in [1..@length]
      @generateCategoryList(level)

    @loadCategoryData(null, (data) =>
      @categoryChanged(data, 0)
    )

    @$container.width(290 * @length)
    @box = new CategoryContainer(@$container)

  generateCategoryList: (level) ->
    levelClass = ['level', level].join('')

    template = """
      <div class="category-list-item">
        <ul class="list-group #{levelClass}">
        </ul>
      </div>
    """
    $list = $(template).appendTo(@$container)
    $element = $list.find('.list-group')

    new CategoryList(@, $element, [], level, @$form)

  loadCategoryData: (category_id, callback) ->
    data = {}
    data['category_id'] = category_id if category_id?

    $.ajax({
      url: '/categories',
      data: data,
      dataType: 'json',
      success: (datas) =>
        callback.call(@, datas) if $.isFunction(callback)
    })

  categoryChanged: (data, level) ->
    @resetListsContent(data, level)

  resetListsContent: (data, level) ->
    return @levelCount = level if level == @length

    @levelCount = level + 1

    # 重新生成分类数据
    for categoryList in @categoryLists
      _level = categoryList.level

      continue if _level <= level

      if _level == @levelCount
        categoryList.resetContent(data)
      else
        categoryList.emptyContent()

    if data.length > 0
      @box.changeCurrentLevel(@levelCount)
    else
      @box.changeCurrentLevel(level)

    # @changeBreadcrumb()

  changeBreadcrumb: () ->
    $activeItems = @$container.find('.list-group-item.active')
    pathNames = for item, index in $activeItems
      $item = $(item)
      categoryName = $item.text()
      categoryId = $item.attr('category-id')

      if index == $activeItems.length - 1
        """
          <li class="active">#{categoryName}</li>
        """
      else
        """
          <li><a href="javascript:void(0)" category-id="#{categoryId}">#{categoryName}</a></li>
        """

    @$breadcrumb.html(pathNames.join(''))

    @$breadcrumb.find('a').bind('click', (e) =>
      $target = $(e.currentTarget)
      cateId = $target.attr('category-id')
      $parent = $target.parent()
      level = $parent.index() + 1
      selector = ['.list-group-item[category-id=', cateId, ']'].join('')
      @$container.find(selector).trigger('click')
    )

















