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
      badgeStr = @_generateBadgeElement(dataOptions)

      if sections.length > 0
        template = """
          <li id="#{routeAnchor}" class="group-item">
            <span href="javascript:void(0);" class="group-title">#{iconStr}#{title}</span>
            #{badgeStr}
        """

        templates = [ template, '<ul class="nav menu-sections">' ]

        for section in sections
          { route, name, title, routeAnchor, dataOptions } = section

          iconStr = @_generateIconElement(dataOptions)
          badgeStr = @_generateBadgeElement(dataOptions)

          template = """
            <li id="#{routeAnchor}">
              <a href="#{route}">#{iconStr}#{title}#{badgeStr}</a>
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
              <a href="#{route}">#{iconStr}#{title}#{badgeStr}</a>
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
      iconStr = ['<span class="icon-wrap"><span class="', iconClass,
        '" arial-hidden="true"></span></span>'].join('')
    else
      iconStr = ''

    iconStr

  _generateBadgeElement: (options) ->
    { has_quantity, quantity } = options
    badgeStr = if has_quantity then ['<span class="badge">', quantity, '</span>'].join('') else ''

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

  updateQuantity: (name, diff) ->
    group = @_lookupGroup(name)

    return if not group or not group.dataOptions.has_quantity

    quantity = group.dataOptions.quantity + diff

    quantity = 0 if quantity < 0

    sel = [ 'li#group-', name, ' .badge'].join('')
    @$containment.find(sel).text(quantity)

    group.dataOptions.quantity = quantity

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

