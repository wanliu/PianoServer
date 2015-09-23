#= require _common/event
#= require ./category_list
#= require ./category_container
#= require ./category_breadcrumb

class @CategoryListWrap extends @Event
  constructor: (@element, @url, @length) ->
    super(@element)

    @categoryLists = for level in [1..@length]
      @generateCategoryList(level)

    @loadCategoryData(null, (data) =>
      @categoryChanged(data, 0)
    )

    @box = new CategoryContainer(@element)

  generateCategoryList: (level) ->
    levelClass = ['level', level].join('')

    template = """
      <div class="category-list-item">
        <ul class="list-group #{levelClass}">
        </ul>
      </div>
    """
    $list = $(template).appendTo(@element)
    $element = $list.find('.list-group')

    new CategoryList(@, $element, [], level)

  loadCategoryData: (category_id, callback) ->
    data = {}
    data['category_id'] = category_id if category_id?
    @category_id = category_id

    $.ajax({
      url: @url,
      data: data,
      dataType: 'json',
      success: (datas) =>
        @send('category:changed', category_id)
        callback.call(@, datas) if $.isFunction(callback)
    })

  categoryChanged: (data, level, is_leaf) ->
    if $.isArray(data)
      @resetListsContent(data, level)
    else
      { categories, items } = data
      @resetListsContent(categories, level)
      @items.resetContent(items) if @items?

    @form.changeCategory(@category_id, is_leaf) if @form?

  resetListsContent: (data, level) ->
    if level == @length
      @changeBreadcrumb() if @breadcrumb?
      return @levelCount = level

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

    @changeBreadcrumb() if @breadcrumb?

  changeBreadcrumb: () ->
    $activeItems = @element.find('.list-group-item.active')
    paths = for item, index in $activeItems
      $item = $(item)
      categoryName = $item.text()
      categoryId = $item.attr('category-id')
      is_leaf = !$item.hasClass('has-children')

      {
        name: categoryName,
        id: categoryId,
        is_leaf: is_leaf
      }

    @breadcrumb.resetContent(paths)

  setBreadcrumb: (breadcrumb) ->
    @breadcrumb = breadcrumb

  setCategoryItems: (items) ->
    @items = items

  setForm: (form) ->
    @form = form















