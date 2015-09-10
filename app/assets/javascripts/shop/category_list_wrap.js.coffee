#= require ./category_list

class @CategoryListWrap
  constructor: (@$container, @$breadcrumb) ->
    @categoryLists = for level in [1..4]
      @generateCategoryList(level)

    @$leftBtn = @$container.prev()
    @$rightBtn = @$container.next()

    @bindPrevBtnClickEvent()
    @bindNextBtnClickEvent()

    @loadCategoryData(null, (data) =>
      @categoryChanged(data, 0)
    )

  generateCategoryList: (level) ->
    levelClass = ['level', level].join('')

    template = """
      <div class="col-sm-3">
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
    @changeBreadcrumb()

  resetListsContent: (data, level) ->
    length = @categoryLists.length

    for categoryList in @categoryLists
      _level = categoryList.level

      if _level > level
        if _level == level + 1
          categoryList.resetContent(data)
        else
          categoryList.emptyContent(data)

    return @resetPosition() if level < length - 1

    return if level == length

    if data.length > 0
      @scrollRight()
    else
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
      cateId = $(e.currentTarget).attr('category-id')
      selector = ['.list-group-item[category-id=', cateId, ']'].join('')

      @$container.find(selector).trigger('click')
    )

  bindPrevBtnClickEvent: () ->
    @$leftBtn.bind('click', @scrollLeft.bind(@))

  bindNextBtnClickEvent: () ->
    @$rightBtn.bind('click', @scrollRight.bind(@))

  resetPosition: () ->
    @$container.animate({
      'margin-left': '0'
    }, 250, () =>
      @$rightBtn.removeClass('btn-visible')
      @$leftBtn.removeClass('btn-visible')
    )

  scrollLeft: () ->
    @$container.animate({
      'margin-left': '0'
    }, 250, () =>
      @$leftBtn.removeClass('btn-visible')
      @$rightBtn.addClass('btn-visible')
    )

  scrollRight: () ->
    @$container.animate({
      'margin-left': '-33.33%'
    }, 250, () =>
      @$rightBtn.removeClass('btn-visible')
      @$leftBtn.addClass('btn-visible')
    )

