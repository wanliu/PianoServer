#= require _common/event
#= require utils/parseUrl

class @Paginate extends @HuEvent

  constructor: (@element, @page = 1, @per, @count, @options = { replaceState: false }) ->
    super
    @init()

  init: () ->
    @page = +@page
    @size = @options["size"] || 5
    @parseURL ||= window.parseURL
    @getQueryVars ||= window.getQueryVars
    @refresh()

  bindAllEvents: () ->
    @$().bind 'click', 'a', @onClickPage.bind(@)

  refresh: () ->
    paginate = if @last() <= 1
                ""
              else
                [ @leftSection()..., @itemsSection()..., @rightSection()...].join('')

    @$().html(paginate)
    # @bindAllEvents()

  rightSection: () ->
    section = []
    if @page + 1 <= @last()
      section.push @nextButton()
      section.push @lastButton()

      # if @page < @last()
    section

  leftSection: () ->
    section = []
    if @page - 1 >= 1
      # if @page > 1
      section.push @firstButton()
      section.push @previousButton()

    section

  itemsSection: (size = @size) ->
    min = Math.max(@page - size, 1)
    max = Math.min(@page + size, @last())


    items = [ @_ifLessBlank(size) ,
              (@pageButton(i) for i in [min..max])...,
              @_ifLargeBlank(size) ]

  blankButton: () ->
    """
      <li>
        <span>...<span class="sr-only">(current)</span></span>
      </li>
    """

  pageButton: (page, title = page, isActive = false) ->
    """
      <li #{@_activeClass(page)}>
        <a rel="next" href="/kimi/admin/items?page=#{page}">#{title}</a>
      </li>
    """

  nextButton: () ->
    @pageButton(@page + 1 , "下一页 ›")

  previousButton: () ->
    @pageButton(@page - 1 , "‹ 上一页")

  firstButton: () ->
    @pageButton(1, '« 最前')

  lastButton: () ->
    @pageButton(@last(), '最后 »')

  last: () ->
    Math.ceil(@count / @per)

  onClickPage: (e) ->
    e.preventDefault()
    return if $(e.target).parents('li').hasClass('active')

    query = @parseQueryString($(e.target).attr("href"))
    @page = +query["page"] || 1
    @refresh()
    @send('page:change', @page)

  parseQueryString: (string) ->
    url = @parseURL(string)
    @getQueryVars(url.search)

  setup: (page, @per, @count) ->
    @page = page
    @refresh()

  _activeClass: (page) =>
      if +@page == page then "class=\"active\" " else ""

  _ifLessBlank: (size) =>
    if +@page - size > 1 then @blankButton() else ''

  _ifLargeBlank: (size) =>
    if +@page + size < @last() then @blankButton() else ''
