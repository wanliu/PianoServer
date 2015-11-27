#= require './new_item_posters'
#= require './edit_item_poster'
##= require _common/event

class @ItemPosters extends HuEvent
  constructor: (@element, @url, @$filenames) ->
    super(@element)
    $newPoster = @$().find('.new-item-poster')
    @$editPosters = @$().find('.edit-item-poster')

    new NewItemPosters($newPoster, this, @url)

    for $poster in @$editPosters
      $element = $($poster)
      filename = $element.data('filename')
      new EditItemPoster($element, this, @url)
      @addFilename(filename)

    @handleSortable()

    @on('poster:add', @newItemPoster.bind(@))
    @on('poster:remove', @removeItemPoster.bind(@))
    @on('poster:replace', @replaceItemPoster.bind(@))

  newItemPoster: (e, url, filename) ->
    template = """
      <div class="col-xs-4 col-sm-4 col-md-4 col-lg-3 edit-item-poster poster-item" data-filename="#{filename}">
        <div class="thumbnail">
          <img src="#{url}" class="item-poster">
          <div class="remove-icon">
            <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
          </div>
          <div class="plus-icon">+</div>
          <div class="upload-btn"></div>
          <div class="sortable-handler">
            <span class="glyphicon glyphicon-move" aria-hidden="true"></span>
          </div>
        </div>
      </div>
    """
    $element = $(template).prependTo(@$())
    new EditItemPoster($element, this, @url)
    @addFilename(filename)
    @rehandleSortable()

  addFilename: (filename) ->
    names = $.trim(@$filenames.val())
    filenames = if names.length > 0 then [filename, names].join(',') else [filename, names].join('')
    @$filenames.val(filenames)

  removeItemPoster: (e, filename) ->
    filenames = $.trim(@$filenames.val()).split(',')
    index = filenames.indexOf(filename)

    if index > -1
      filenames.splice(index, 1)
      @$filenames.val(filenames.join(','))

  replaceItemPoster: (e, oldFilename, newFilename) ->
    filenames = $.trim(@$filenames.val()).split(',')
    index = filenames.indexOf(oldFilename)

    if index > -1
      filenames[index] = newFilename
      @$filenames.val(filenames.join(','))

  handleSortable: () ->
    _this = this

    @$().sortable({
      items: '.poster-item:not(.new-item-poster)',
      handle: '.sortable-handler',
      update: (e, ui) ->
        filenames = []
        $(this).find('.edit-item-poster').map(() ->
          filenames.push($(this).data('filename'))
        )

        _this.$filenames.val(filenames.join(','))
    })
    @$().disableSelection()

  rehandleSortable: () ->
    @$().sortable('destroy')
    @handleSortable()


