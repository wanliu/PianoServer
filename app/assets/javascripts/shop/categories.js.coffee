class @Categories
  constructor: (@shop_name, @categoryContainer, @itemsContainer) ->
    @loadLevel1Categories(null)

    @bindSearchEvent()

  loadLevel1Categories: (category_id) ->
    @loadDataAndCallback(category_id, false, (data) =>
      @level1Callback(data)
      @changeCategoryPath()
    )

  loadLevel2Categories: (category_id, isLeaf) ->
    @loadDataAndCallback(category_id, isLeaf, (data) =>
      @level2Callback(data)
      @changeCategoryPath()
    )

  loadLevel3Categories: (category_id, isLeaf) ->
    @loadDataAndCallback(category_id, isLeaf, (data) =>
      @level3Callback(data)
      @changeCategoryPath()
    )

  loadLevel4Categories: (category_id, isLeaf) ->
    @loadDataAndCallback(category_id, isLeaf, (data) =>
      @level4Callback(data)
      @changeCategoryPath()
    )

  loadDataAndCallback: (category_id, isLeaf, callback) ->
    q = $.trim($('input[search-items]').val())
    url = ['/', @shop_name, '/admin/items/load_categories'].join('')
    data = { page: 1, per: 25 }
    data['category_id'] = category_id if category_id
    data['q'] = q if q.length > 0

    @currentCategoryId = category_id
    @isLeaf = isLeaf

    $.ajax
      url: url,
      type: 'GET',
      data: data,
      dataType: 'json',
      success: (data) =>
        $addBtn = @itemsContainer.find('.btn-add')

        if isLeaf
          $addBtn.show()
        else
          $addBtn.hide()

        callback.call(this, data) if $.isFunction(callback)

  level1Callback: (data) ->
    $level1 = @categoryContainer.find('.level1 .list-group')
    $level2 = @categoryContainer.find('.level2 .list-group')
    $level3 = @categoryContainer.find('.level3 .list-group')

    { categories, items } = data

    $level1.html('')

    for category in categories
      @generateListItem(category).appendTo($level1)

    @bindClickEvent($level1)

    $level2.html('')
    $level3.html('')

    @replaceItems(items)

  level2Callback: (data) ->
    $level2 = @categoryContainer.find('.level2 .list-group')
    $level3 = @categoryContainer.find('.level3 .list-group')

    { categories, items } = data

    $level2.html('')

    for category in categories
      @generateListItem(category).appendTo($level2)

    @bindClickEvent($level2)
    $level3.html('')

    @replaceItems(items)

  level3Callback: (data) ->
    $level3 = @categoryContainer.find('.level3 .list-group')

    { categories, items } = data

    $level3.html('')

    for category in categories
      @generateListItem(category).appendTo($level3)

    @bindClickEvent($level3)

    @replaceItems(items)

  level4Callback: (data) ->
    items = data.items

    @replaceItems(items)

  generateListItem: (category) ->
    { id, title, depth, is_leaf } = category
    desc = if is_leaf then 'on' else 'off'

    template = """
      <a href="javascript:void(0);" class="list-group-item" category-id="#{id}" depth="#{depth}" is-leaf="#{desc}">
        #{title}
      </a>
    """

    $(template)

  replaceItems: (items) ->
    @categoryItems = new CategoryItems(@itemsContainer.find('tbody'), items)

  bindClickEvent: ($element) ->
    $element.find('a.list-group-item').bind("click", @handleClickEvent.bind(@))

  handleClickEvent: (e) ->
    $target = $(e.currentTarget)
    categoryId = $target.attr('category-id')
    depth = $target.attr('depth')
    isLeaf = $target.attr('is-leaf') == 'on'

    $target.addClass('active').siblings().removeClass('active')

    switch depth
      when "1"
        @loadLevel2Categories(categoryId, isLeaf)
      when "2"
        @loadLevel3Categories(categoryId, isLeaf)
      else
        @loadLevel4Categories(categoryId, isLeaf)

  bindSearchEvent: () ->
    @itemsContainer.find('.btn-search').bind('click', @handleSearchEvent.bind(@))

  handleSearchEvent: (e) ->
    $target = $(e.currentTarget)
    $input = $target.prev()
    searchText = $.trim($input.val())

    return if searchText.length == 0

    @loadDataAndCallback(@currentCategoryId, @isLeaf, (data) =>
      @replaceItems(data.items)
    )

  changeCategoryPath: () ->
    $activeItems = @categoryContainer.find('.list-group-item.active')
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

    $path = @categoryContainer.find('.breadcrumb')
    $path.html(pathNames.join(''))

    $path.find('a').bind('click', (e) =>
      cateId = $(e.currentTarget).attr('category-id')
      selector = ['.list-group-item[category-id=', cateId, ']'].join('')

      @categoryContainer
        .find(selector)
        .trigger('click')
    )









