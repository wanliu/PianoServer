#= require _common/event

class @CategoryTree extends @Event

  constructor: (@$element, @url) ->
    super(@$element)
    @$element.on('click', '.category-item', @onClickItem.bind(@))

  onClickItem: (e) ->
    e.preventDefault()

    $item = $(e.target)
    categoryId = $item.attr('data-category-id')

    isChildrenFetched = $item.attr('data-children-fetched')
    isLeaf = $item.attr('data-is-leaf')

    # if isLeaf == 'true' || isChildrenFetched == 'true'
    #   e.preventDefault()
    # else
    @fetchChildren($item)

    $item.toggleClass('open')
    $(".list-group[data-parent-id=#{categoryId}]").toggle()

  fetchChildren: ($item) ->
    categoryId = $item.attr('data-category-id')
    childUrl = @url + '/categories/' + categoryId

    $.get childUrl, (data) =>

      isChildrenFetched = $item.attr('data-children-fetched')
      isLeaf = $item.attr('data-is-leaf')

      unless isLeaf == 'true' || isChildrenFetched == 'true'
        categories = data.children
        categories.forEach (category) =>
          $(".list-group[data-parent-id=#{categoryId}]").append(category.html)
          $item.attr('data-children-fetched', 'true')

      $('.category-right').html(data.edit_html)

