class @SideMenu
  constructor: (@$containment) ->
    @element = $('<div class="side-menu"></div>').appendTo($containment)
    @groups = []

  insertGroup: (name, title) ->
    @groups.push({
      title: title,
      name: name,
      route: '/' + name,
      routeAnchor: '#' + name,
      sections: []
    })

  insertSection: (groupName, route, name, title) ->
    group = @_lookupGroup(groupName)

    if group
      group.sections.push({
        title: @title,
        name: @name,
        route: @route,
        routeAnchor: '#' + @name
      })

  generateMenuDOMFragment: () ->
    return if @groups.length == 0

    for group in @groups
      { route, name, title, sections } = group

      if sections.length > 0
        templates = [ '<li id="group-#{name}">#{name}</li>', '<li><ul class="menu-sections>"' ]

        for section in sections
          { route, name, title } = section

          template = """
            <li id="section-#{name}">
              <a href="/#{route}">#{title}</a>
            </li>
          """

          templates.push(template)

        templates.push('</ul></li>')
        $(templates.join('')).appendTo(@$containment)

      else
        template = """
          <li id="group-#{name}">
            <a href="/#{route}">#{title}</a>
          </li>
        """
        $(template).appendTo(@$containment)

    @highlightPath()

  highlightPath: () ->
    pathname = location.pathname
    index = pathname.lastIndexOf('/')
    name = pathname.slice(index+1)

    for group in groups
      if group.name == name
        selector = ['[group-name=', name, ']'].join('')
        @$containment.find(selector).addClass('active')
      else
        selector = ['[group-name=', name, ']'].join('')
        @$containment.find(selector).removeClass('active')

        if group.sections.length > 0
          for section in group.sections
            selector = ['[section-name=', name, ']'].join('')
            if section.name == name
              @$containment.find(selector).addClass('active')
            else
              @$containment.find(selector).removeClass('active')

  removeGroup: (groupName) ->
    group = @_lookupGroup(groupName)

    if group
      index = @groups.indexOf(group)
      @groups.splice(index, 1)
      selector = ['li:eq(', index, ')'].join('')
      $element = @$containment.find(selector)

      if $element.length > 0
        $element.remove()

  _lookupGroup: (groupName) ->
    for group in @groups
      return group if group.name == groupName

    return null

  refreshMenu: () ->
    @$containment.html('')

    @generateMenuDOMFragment()
