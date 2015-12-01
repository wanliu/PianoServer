#= require ./side_menu
TRANSITION_ENDS = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'

class @SideMenuManager
  constructor: (@element) ->
    @menus = []
    @$container = $('.main-container')
    @$navbar = $('.main-navbar')
    @$layout = $('.menu-overlayer')
    @resizeHandler()
    $(window).bind 'resize', @resizeHandler.bind(@)

    @element.on('click', (e) =>
      $target = $(e.target)

      if $target.parents('.menu-container').length == 0
        @_hide()
    )

    @$layout.on('click', @_layoutClick.bind(@))

  resizeHandler: () ->
    if $(window).width() > 768
      @_hide()
      @_destroyHammer()
    else
      @_initHammer()

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
    #@element.css('left', 0)
    @$container.addClass('show-left-bar')
    @$navbar.addClass('show-left-bar').one TRANSITION_ENDS, ()=>
      @$layout.fadeIn(300, ()=>
        @isVisible = true
        console.log('123')
      )

  _hide: () ->
    #@element.css('left', -250)
    @$layout.hide()
    @$container.removeClass('show-left-bar')
    @$navbar.removeClass('show-left-bar').one TRANSITION_ENDS, ()=>
      @isVisible = false

  _open: () ->
    @_show() if $(window).width() <= 768 and !@isVisible

  _close: () ->
    @_hide() if $(window).width() <= 768 and @isVisible

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
    @hammer.on("swiperight", @_open.bind(@))
    @hammer.on("swipeleft", @_close.bind(@))

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
