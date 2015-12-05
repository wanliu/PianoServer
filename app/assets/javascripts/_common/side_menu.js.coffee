class @SideMenu
  constructor: (@$containment, @name) ->
    @element = $('<ul class="nav nav-sidebar side-menu"></ul>').appendTo(@$containment)
    @groups = []
    @isVisible = false

  insertPlainHTML: (fragment) ->
    @element.append(fragment)

  insertGroup: (name, title, dataOptions = {}) ->
    if name.substring(0, 1) == '/'
      name = name.slice(1)
    name = decodeURIComponent(name)

    @groups.push({
      title: title,
      name: name,
      route: '/' + name,
      routeAnchor: 'group-' + name.replace(/\//g, '-'),
      sections: [],
      dataOptions: dataOptions
    })

  insertSection: (groupName, route, name, title, dataOptions = {}) ->
    group = @_lookupGroup(groupName)

    if route.substring(0, 1) != '/'
      route = '/' + route

    if name.substring(0, 1) == '/'
      name = name.slice(1)
    name = decodeURIComponent(name)

    if group
      group.sections.push({
        title: title,
        name: name,
        route: route,
        routeAnchor: 'section-' + name.replace(/\//g, '-'),
        dataOptions: dataOptions
      })

  generateMenuDOMFragment: () ->
    return if @groups.length == 0

    for group in @groups
      { route, name, title, sections, routeAnchor, dataOptions } = group

      iconStr = @_generateIconElement(dataOptions)

      if sections.length > 0
        template = """
          <li id="#{routeAnchor}" class="group-item">
            <span href="javascript:void(0);" class="group-title">#{iconStr}#{title}</span>
        """

        templates = [ template, '<ul class="nav menu-sections">' ]

        for section in sections
          { route, name, title, routeAnchor, dataOptions } = section

          bindings = []
          for key, value of dataOptions
            continue if key == 'icon'

            str = """
              data-#{key}="#{value}"
            """
            bindings.push(str)

          binding_str = if bindings.length > 0 then bindings.join(' ') else ''

          iconStr = @_generateIconElement(dataOptions)

          template = """
            <li id="#{routeAnchor}">
              <a href="#{route}" #{binding_str}>#{iconStr}#{title}</a>
            </li>
          """

          templates.push(template)

        templates.push('</ul></li>')
        $(templates.join('')).appendTo(@element)

      else
        if dataOptions['qrode']
          template = """
            <li id="group-qrode" class="group-item">
              <a href="javascript:void(0);">#{iconStr}#{title}</a>
            </li>
          """
        else
          template = """
            <li id="#{routeAnchor}" class="group-item">
              <a href="#{route}">#{iconStr}#{title}</a>
            </li>
          """
        $(template).appendTo(@element)

    @_bindEvents()
    @_highlightPath()

  _generateIconElement: (options) ->
    {icon, iconClass } = options

    if icon?
      iconStr = ['<img src="', icon, '" class="group-icon">'].join('')
    else if iconClass
      iconClass = iconClass.join(' ') if Object.prototype.toString.call(iconClass) == '[object Array]'
      iconClass = [ 'menu-icon', iconClass ].join(' ')
      iconStr = ['<span class="', iconClass, '" arial-hidden="true"></span>'].join('')
    else
      iconStr = ''

    iconStr

  _bindEvents: () ->
    $('#group-qrode a').click(() ->
      $('#share-url-qrcode').modal()
    )

  _highlightPath: () ->
    pathname = location.pathname
    name = pathname.slice(1)
    name = decodeURIComponent(name)
    name = name.replace(/\//g, '-')

    if name.indexOf('@') > -1
      name = 'face'

    @$containment.find('li').removeClass('active')
    selector = ['#group-', name].join('')
    $selectedGroup = @$containment.find(selector)
    selector = ['#section-', name].join('')
    $selectedSection = @$containment.find(selector)

    if $selectedGroup.length > 0
      $selectedGroup.addClass('active')

    if $selectedSection.length > 0
       $selectedSection.addClass('active')

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

  setVisible: (visible) ->
    if visible
      @isVisible = true
      @element.show()
    else
      @isVisible = false
      @element.hide()

  destroy: () ->
    @element.remove()

