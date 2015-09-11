#= require ./category_list

class @CategoryListWrap
  constructor: (@$container, @$breadcrumb) ->
    @categoryLists = for level in [1..4]
      @generateCategoryList(level)

    @length = 4
    @$leftBtn = @$container.prev()
    @$rightBtn = @$container.next()

    @bindPrevBtnClickEvent()
    @bindNextBtnClickEvent()

    @loadCategoryData(null, (data) =>
      @categoryChanged(data, 0)
    )

    @initColNumAndCurrentMax()
    $(window).bind('resize', @resizeHandler.bind(@))

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

    new CategoryList(@, $element, [], level)

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
    #@changeBreadcrumb()

  resetListsContent: (data, level) ->
    # 如果是最后一级分类点击则不作任何操作
    return if level == @length

    @levelCount = level + 1

    # 重新生成分类数据
    for categoryList in @categoryLists
      _level = categoryList.level

      continue if _level <= level

      if _level == @levelCount
        categoryList.resetContent(data)
      else
        categoryList.emptyContent(data)

    @currentLevel = @levelCount - 1

    if @levelCount > @col
      if data.length > 0
        @scrollRight()
      else if @levelCount = @col + 1
        @resetPosition()
    else
      @currentLevel = @levelCount
      @resetPosition()

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
    )

  bindPrevBtnClickEvent: () ->
    @$leftBtn.bind('click', @scrolleLeft.bind(@))

  bindNextBtnClickEvent: () ->
    @$rightBtn.bind('click', @scrollRight.bind(@))

  scrolleLeft: () ->
    @$container.animate({
      'margin-left': '+=290'
    }, 250, () =>
      @currentLevel -= 1
      @$rightBtn.addClass('btn-visible')

      if @currentLevel <= @col
        @$leftBtn.removeClass('btn-visible')

      @currentLevelChanged()
    )

  scrollRight: () ->
    @$container.animate({
      'margin-left': '-=290'
    }, 250, () =>
      @currentLevel += 1
      @$leftBtn.addClass('btn-visible')

      if @currentLevel > @col
        @$rightBtn.removeClass('btn-visible')

      @currentLevelChanged()
    )

  resetPosition: () ->
    @$container.animate({
      'margin-left': '0'
    }, 250, () =>
      @$rightBtn.removeClass('btn-visible')
      @$leftBtn.removeClass('btn-visible')
    )

  resizeHandler: () ->
    width = $(window).width()

    if width >= 1200
      @col = 3
    else if width >= 992
      @col = 2
    else
      @col = 1

    @currentLevel = 1 if not @currentLevel
    return if not @lastCol?

    diffCol = @col - @lastCol
    @lastCol = @col

    return if diffCol == 0

    @$container.animate({
      'margin-left': '+=' + diffCol * 290
    }, 250, () =>

    )

  initColNumAndCurrentMax: () ->
    @resizeHandler()
    @levelCount = 1
    @currentLevel = 1

  currentLevelChanged: () ->
    if @levelCount > @col
      if @currentLevel == @levelCount
        @$rightBtn.removeClass('btn-visible')
    else
      if @currentLevel < @col
        @$leftBtn.removeClass('btn-visible')

















