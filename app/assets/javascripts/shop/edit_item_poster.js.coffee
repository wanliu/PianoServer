#= require _common/event

class @EditItemPoster extends @Event
  events:
    'click .remove-icon': removeItemPoster

  constructor: (@container, @imgId, @imgUrl) ->
    @element = @createElement()
    super(element)

  createElement: () ->
    template = """
      <div class="thumbnail edit-poster">
        <img src="#{@imgUrl}">
        <div class="remove-icon"></div>
      </div>
    """

    $(template).appendTo(@container)

  removeItemPoster: () ->


