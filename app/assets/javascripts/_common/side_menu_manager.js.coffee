#= require ./side_menu
TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'

class @SideMenuManager
  constructor: (@element) ->
    @$window = $(window)
    @menus = []
    @resizeHandler()
    $(window).bind 'resize', @resizeHandler.bind(@)

    @element.on 'click', (e) =>
      $target = $(e.target)
      if $target.parents('.menu-container').length == 0
        @_hide()

    $('.menu-overlayer').on 'click', @_layoutClick.bind(@)

    $(window).on 'touchmove', (e) =>
      if @isVisible
        e.preventDefault()

  resizeHandler: () ->
    if @$window.width() > 768
      @_hide()
      @_destroyHammer()
    else
      @_initHammer()
      $('body').width(@$window.width())

  addMenu: (menu) ->
    if menu instanceof SideMenu
      @menus.push(menu)

  showMenu: (menu) ->
    @_show()

    for _menu in @menus
      if _menu == menu
        _menu.setVisible(true)
      else
        _menu.setVisible(false)

  hideMenu: (menu) ->
    @_hide()
    menu.setVisible(false)

  _show: () ->
    @isVisible = true
    $('.menu-overlayer').show()
    $('.menu-container').addClass('show-left-bar')
    $('.main-navbar').addClass('show-left-bar')
    $('.main-container').addClass('show-left-bar')
    $('.link-table-container').addClass('show-left-bar')

  _hide: () ->
    @isVisible = false
    $('.menu-overlayer').hide()
    $('.menu-container').removeClass('show-left-bar')
    $('.main-navbar').removeClass('show-left-bar')
    $('.link-table-container').removeClass('show-left-bar')
    $('.main-container').removeClass('show-left-bar')

    $('body').width(@$window.width() - 1)
    $('body').width(@$window.width())

  _open: () ->
    @_show() if @$window.width() <= 768 and !@isVisible

  _close: () ->
    @_hide() if @$window.width() <= 768 and @isVisible

  toggleMenu: (menuName) ->
    menu = if menuName then @_lookupMenu(menuName) else @menus[@menus.length - 1]

    return if not menu

    if @isVisible
      @hideMenu(menu)
    else
      @showMenu(menu)

  removeMenu: (menuName) ->
    menu = @_lookupMenu(menuName)

    if menu
      menu.destroy()
      index = @menus.indexOf(menu)
      @menus.splice(index, 1)

  _lookupMenu: (name) ->
    for menu in @menus
      return menu if menu.name == name

    return null

  _layoutClick: () ->
    @_hide()

  _initHammer: () ->
    return if @hammer

    @hammer = new Hammer.Manager(document.body)
    @hammer.add(new Hammer.Swipe({
      direction: Hammer.DIRECTION_HORIZONTAL,
      velocity: 0.1,
      threshold: 1,
      pointers: 1
    }))
    @hammer.on "swiperight", @_open.bind(@)
    @hammer.on "swipeleft", @_close.bind(@)

  _destroyHammer: () ->
    if @hammer && @hammer.destroy
      @hammer.destroy()
      @hammer = null

  # _recalculateZIndex: (menu) ->
  #   index = @menus.indexOf(menu)

  #   for _menu, i in @menus
  #     if i < index
  #       _menu.setZIndex(_menu.zIndex + 1)
  #     else if i == index
  #       _menu.setZIndex(1)
