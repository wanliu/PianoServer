#= require _common/event

class @CategoryTree extends @Event

  constructor: (@element, @url) ->
    super(@element)
    @tree = {}
    @addNodes(@$().find('.list-group-item'))

  addNodes: ($items) ->
    $items.each (index, item) =>
      categoryId = $(item).data('categoryId')
      unless @findById(categoryId)?
        @addNode(categoryId, new CategoryNode(item, @, @url))

  addNode: (categoryId, node) ->
    @tree[categoryId] = node

  # onClickItem: (e) ->
  #   e.preventDefault()
  #   $elem = $(e.currentTarget)
  #   categoryId = $elem.data('categoryId')

  #   if $elem.hasClass('open')
  #     @hideChildren($elem, categoryId)
  #   else
  #     @loadChildren($elem, categoryId)

  # loadChildren: (e, categoryId) ->
  #   childUrl = @url + '/categories/' + categoryId
  #   $.get childUrl, (data) =>
  #     categories = data.categories
  #     categories.map (c) =>
  #       $(e).after(c.html)
  #     $(e).addClass('open')

  # hideChildren: (e, categoryId) ->
  #   @$().find('.parent-' + categoryId).remove()
  #   $(e).removeClass('open')

  findById: (categoryId) ->
    @tree[categoryId]

  removeById: (categoryId) ->
    @tree[categoryId]?$().remove()
    delete @tree[categoryId]

class @CategoryNode extends @Event

  events:
    'click': 'onClickItem'

  constructor: (@element, @tree, @url) ->
    super(@element)

    @children = []
    @categoryId = $(@element).data('categoryId')
    @addChildren()

  onClickItem: (e) ->
    e.preventDefault()
    $elem = $(e.currentTarget)
    categoryId = $elem.data('categoryId')

    if $elem.hasClass('open')
      @hideChildren($elem, categoryId)
    else
      @loadChildren($elem, categoryId)

  loadChildren: (e, categoryId) ->
    childUrl = @url + '/categories/' + categoryId
    $.get childUrl, (data) =>
      categories = data.categories
      categories.map (c) =>
        $child = $(e).after(c.html)

      @addChildren()

      $(e).addClass('open')

  hideChildren: (e, categoryId) ->
    for node in @children
      node.hide()

    # @removeChildren()
    # @$().find('.parent-' + categoryId).remove()
    $(e).removeClass('open')

  removeChildren: () ->
    for node in @children
      node.remove()

  remove: () ->
    @removeChildren()
    @tree.removeById(@categoryId)

  hide: () ->
    @$().hide()

  show: () ->
    @$().show()

  addChildren: ($items = $('.parent-' + @categoryId)) ->
    $items.each (index, item) =>
      categoryId = $(item).data('categoryId')
      unless @tree.findById(categoryId)?
        @addChild(categoryId, new CategoryNode(item, @tree, @url))

  addChild: (categoryId, node) ->
    @children.push(node)
    @tree.addNode(categoryId, node)

