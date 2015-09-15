#= require ./category_list

class @CategoryListWrap
  constructor: (@$container, @$form) ->
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
    # 如果是最后一级分类点击则不作任何操作
    return @lastLevelPicked if level == @length

    @resetListsContent(data, level)
    @changeCategory(data)
    #@changeBreadcrumb()

  resetListsContent: (data, level) ->
    @levelCount = level + 1

    # 重新生成分类数据
    for categoryList in @categoryLists
      _level = categoryList.level

      continue if _level <= level

      if _level == @levelCount
        categoryList.resetContent(data)
      else
        categoryList.emptyContent(data)

  changeCategory: (data) =>
    if @levelCount > @col
      @currentLevel = @levelCount - 1

      if data.length > 0
        @scrollRight()
      else if @levelCount = @col + 1
        @currentLevel = @col
        @resetPosition()
    else
      @currentLevel = @col
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

      loadCategoryData(cateId, (data) =>
        changeCategory(data)
      )
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
      @currentLevelChanged()
    )

  scrollRight: () ->
    @$container.animate({
      'margin-left': '-=290'
    }, 250, () =>
      @currentLevel += 1
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

    if @lastCol?
      diffCol = @col - @lastCol
    else
      diffCol = 0

    @lastCol = @col

    return if @levelCount <= @col or diffCol == 0

    marginLeft = parseInt(@$container.css('margin-left'))
    min = Math.min(0, marginLeft + diffCol * 290)

    @$container.animate({
      'margin-left': min
    }, 250, () =>
      @currentLevelChanged()
    )

  initColNumAndCurrentMax: () ->
    @resizeHandler()
    @levelCount = 1
    @currentLevel = 1

  currentLevelChanged: () ->
    if @levelCount > @col
      if @currentLevel < @levelCount
        @$rightBtn.addClass('btn-visible')

      if @currentLevel > @col
        @$leftBtn.addClass('btn-visible')

        if @currentLevel == @levelCount
          @$rightBtn.removeClass('btn-visible')
      else
        @$leftBtn.removeClass('btn-visible')
    else
      @$leftBtn.removeClass('btn-visible')
      @$rightBtn.removeClass('btn-visible')

  lastLevelPicked: () ->
    @currentLevel = @levelCount = @length

    @currentLevelChanged()

















