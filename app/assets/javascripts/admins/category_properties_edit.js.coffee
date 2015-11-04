#= require _common/event

class @CategoryPropertiesEdit extends @HuEvent
  @defaultOptions = {
    lineHeight: ">li",
    items: "li:not(.property-inherits)",
    disableItems: ".property-inherits",
    propertyList: ".property-list"
  }

  constructor: (@element, @options = {}) ->
    super(@element)
    throw new Error("missing options.sortUrl params") unless @options.sortUrl?

    @options = $.extend(@options, CategoryPropertiesEdit.defaultOptions)

    @$propertyList = @$().find(@options.propertyList)
    @$propertyList.sortable({
      update: @sortUpdate,
      items: @options.items,
      start: @sortStart,
      stop: @sortStop,
      revert: true
    })
    @$propertyList.disableSelection();
    # @$propertyList.find(".property-inherits").disableSelection();

  sortStart: (e, ui) =>
    @$propertyList.find(@options.disableItems).addClass("disabled")

  sortStop: (e, ui) =>
    @$propertyList.find(@options.disableItems).removeClass("disabled")

  sortUpdate: (e, ui) =>
    height = @$propertyList.find(@options.lineHeight).outerHeight();
    { position, originalPosition } = ui;
    index = Math.round((position.top - originalPosition.top) / height)
    $item = $(ui.item)
    property_id = $item.data('id')
    $.ajax({
      url: @options.sortUrl,
      type: "PUT",
      data: { index: index , property_id: property_id }
    }).error () =>
      @$propertyList.sortable("cancel")
      $item.effect("highlight", {color: "#FFB0B9"})

