#= require _common/event

class @CategoryBreadcrumb extends @Event
  constructor: (@element, @container) ->
    super(@element)
    @container.setBreadcrumb(@) if @container?
    @on('breadcrumb:change', @resetContent.bind(@))

  bindAllEvents: () ->
    @$().find('a').bind('click', @onClick.bind(@))
    @$().find('.remove-icon').bind('click', @emptyCategory.bind(@))

  onClick: (e) ->
    e.stopPropagation()
    $target = $(e.target)
    categoryId = $target.attr('category-id')
    $parent = $target.parent()
    level = $parent.index() + 1
    is_leaf = !$parent.hasClass('has-children')

    @container.send('category:change', [ categoryId, level, is_leaf ]) if @container?

  emptyCategory: (e) ->
    e.stopPropagation()
    @container.send('category:empty') if @container?

  resetContent: (e, paths) ->
    return if not paths?

    length = paths.length

    return @$().html('').hide() if length == 0


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
    @unbindAllEvents()
    @$().html(contents).css('display', 'inline-block')
    @bindAllEvents()

  getClassStr: (index, length, is_leaf) ->
    classes = []

    classes.push('active') if index == length - 1
    classes.push('has-children') unless is_leaf

    classStr = if classes.length > 0 then ['class="', classes.join(' '), '"'].join('') else ''



