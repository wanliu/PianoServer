class @CategoryBreadcrumb
  constructor: (@container, @$element) ->
    @container.setBreadcrumb(@) if @container?
    @$element.on('click', 'a', @onClick.bind(@))
    @$element.on('click', '.remove-icon', @emptyCategory.bind(@))

  onClick: (e) ->
    $target = $(e.currentTarget)
    categoryId = $target.attr('category-id')
    $parent = $target.parent()
    level = $parent.index() + 1
    is_leaf = !$target.hasClass('has-children')

    @container.loadCategoryData(categoryId, (data) =>
      @container.categoryChanged(data, level, is_leaf)
    )

  emptyCategory: (e) ->
    e.stopPropagation()

    @container.loadCategoryData(null, (data) =>
      @container.categoryChanged(data, 0, false)
    )

  resetContent: (paths) ->
    return @$element.html('').hide() if paths.length == 0

    length = paths.length

    contents = for path, index in paths
      { id, name, is_leaf } = path
      classStr = @getClassStr(index, length, is_leaf)

      if index == length - 1
        """<li #{classStr}>#{name}</li>"""
      else
        """<li #{classStr}>
          <a href="javascript:void(0)" category-id="#{id}">#{name}</a>
        </li>"""

    contents.push('<span class="glyphicon glyphicon-remove remove-icon"></span>')
    @$element.html(contents).css('display', 'inline-block')


  getClassStr: (index, length, is_leaf) ->
    classes = []

    classes.push('active') if index == length - 1
    classes.push('has-children') unless is_leaf

    classStr = if classes.length > 0 then ['class="', classes.join(' '), '"'].join('') else ''



