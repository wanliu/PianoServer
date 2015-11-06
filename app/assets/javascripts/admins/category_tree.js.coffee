#= require _common/event


CategoryPropertiesEdit = @CategoryPropertiesEdit

class @CategoryTree extends @HuEvent

  constructor: (@$element, @url) ->
    super(@$element)
    @$element.on 'click', '.category-item>.glyphicon-chevron-right', @onClickChevron.bind(@)
    @$element.on 'click', '.category-item', @onClickItem.bind(@)
    @$activeItem = $(null)

  onClickChevron: (e) ->
    $item = $(e.target).parent('.category-item')
    categoryId = $item.attr('data-category-id')

    isChildrenFetched = $item.attr('data-children-fetched')
    isLeaf = $item.attr('data-is-leaf')
    isFetching = $item.attr('data-is-fetching')

    if isLeaf == 'true' || isChildrenFetched == 'true' || isFetching == 'true'
      e.preventDefault()
    else
      @fetchChildren($item)

    $item.toggleClass('open')
    $(".list-group[data-parent-id=#{categoryId}]").slideToggle()

  onClickItem: (e) ->
    @$activeItem.removeClass('active')
    $item = if $(e.target).is('.category-item') then $(e.target) else $(e.target).parent('.category-item')
    @$activeItem = $item.addClass('active')

    categoryId = $item.attr('data-category-id')

    editUrl = "#{@url}/categories/#{categoryId}/edit"
    sortUrl = "#{@url}/categories/#{categoryId}/resort"
    $.get editUrl, (data) =>
      $('.category-right').html(data.edit_html)
      new CategoryPropertiesEdit($('.category-edit'), sortUrl: sortUrl);


  fetchChildren: ($item) ->
    $item.attr('data-is-fetching', 'true')
    categoryId = $item.attr('data-category-id')
    childrenUrl = "#{@url}/categories/#{categoryId}/children"

    $.get childrenUrl, (data) =>
      $item.removeAttr('data-is-fetching')
      $children = $(".list-group[data-parent-id=#{categoryId}]")
      $children.html('')
      $item.attr('data-children-fetched', 'true')

      categories = data.children
      categories.forEach (category) =>
        $children.append(category.html)

