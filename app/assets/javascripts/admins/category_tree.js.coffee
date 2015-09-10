#= require _common/event

class @CategoryTree extends @Event

  constructor: (@$element, @url) ->
    super(@$element)
    @$element.on('click', '.category-item', @onClickItem.bind(@))

  onClickItem: (e) ->
    $item = $(e.target)
    categoryId = $item.attr('data-category-id')

    isChildrenFetched = $item.attr('data-children-fetched')
    isLeaf = $item.attr('data-is-leaf')

    if isLeaf == 'true' || isChildrenFetched == 'true'
      e.preventDefault() 
    else
      @fetchChildren($item)

    $item.toggleClass('open')
    $(".list-group[data-parent-id=#{categoryId}]").toggle()

  fetchChildren: ($item) ->
    categoryId = $item.attr('data-category-id')
    childUrl = @url + '/categories/' + categoryId

    $.get childUrl, (data) =>
      categories = data.categories
      categories.forEach (category) =>
        $(".list-group[data-parent-id=#{categoryId}]").append(category.html)
        $item.attr('data-children-fetched', 'true')