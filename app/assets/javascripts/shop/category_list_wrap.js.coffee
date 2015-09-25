#= require _common/event
#= require ./category_list
#= require ./category_container
#= require ./category_breadcrumb

class @CategoryListWrap extends @HuEvent
  constructor: (@element, @url, @length, @pagination) ->

    super(@element)

    @categoryLists = for level in [1..@length]
      @generateCategoryList(level)

    if @pagination?
      page = @pagination.page
      per = @pagination.per
      @params = { page: page, per: per }

      @pagination.on('page:change', (e, page) =>
        @loadPageData(page)
      )
    else
      @params = {}

    @box = new CategoryContainer(@element)
    @on('category:change', @categoryChanged.bind(@))
    @on('category:empty', @categoryEmptyed.bind(@))

    @loadFirstLevelCategory()

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

  categoryChanged: (e, category_id, level, is_leaf) ->
    @loadCategoryData(category_id, (data) =>
      @categoryDataChanged(data, category_id, level, is_leaf)
    )

  loadFirstLevelCategory: () ->
    @loadCategoryData(null, (data) =>
      @categoryDataChanged(data, null, 0, false)
    )

  categoryEmptyed: (e) ->
    @loadFirstLevelCategory()

  loadCategoryData: (category_id, callback) ->
    if category_id
      @params['category_id'] = category_id
    else
      delete @params['category_id']

    @loadData(callback)

  loadPageData: (page) ->
    @params['page'] = page
    @loadData((data) =>
      @pageDataChanged(data)
    )

  loadData: (callback) ->
    $.ajax({
      url: @url,
      data: @params,
      dataType: 'json',
      success: (datas) =>
        callback.call(@, datas) if $.isFunction(callback)
    })

  pageDataChanged: (data) ->
    { items, meta } = data
    @items.send('items:change', [ items ]) if @items?

    { page, per } = @params
    @pagination.setup(page, per, meta.count)

  categoryDataChanged: (data, category_id, level, is_leaf) ->
    if @url.indexOf('items') > -1
      { categories, items, meta } = data
      @resetListsContent(categories, level)

      @items.send('items:change', [ items ]) if @items?
      { page, per } = @params
      @pagination.setup(page, per, meta.count)
    else
      @resetListsContent(data, level)
      @form.send('category:change', [ category_id, is_leaf ]) if @form?

  resetListsContent: (data, level) ->
    if level == @length
      @levelCount = level
    else
      @levelCount = level + 1

      # 重新生成分类数据
      for categoryList in @categoryLists
        _level = categoryList.level

        continue if _level <= level

        if _level == @levelCount
          categoryList.send('categories:change', [ data ])
        else
          categoryList.send('categories:empty')

      level = @levelCount if data.length > 0

      @box.send('level:change', [ level ])

    @changeBreadcrumb() if @breadcrumb?

  changeBreadcrumb: () ->
    $activeItems = @$().find('.list-group-item.active')

    paths = for item, index in $activeItems
      $item = $(item)
      categoryName = $item.text()
      categoryId = $item.attr('category-id')
      level = $item.attr('level')
      is_leaf = !$item.hasClass('has-children')

      {
        name: categoryName,
        id: categoryId,
        is_leaf: is_leaf,
        level: level
      }

    @breadcrumb.send('breadcrumb:change', [ paths ])

  setBreadcrumb: (breadcrumb) ->
    @breadcrumb = breadcrumb

  setCategoryItems: (items) ->
    @items = items

  setForm: (form) ->
    @form = form















