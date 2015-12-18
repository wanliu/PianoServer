#= require _common/event
class @CombinationImages extends @HuEvent

  events:
    "error": "onLoadFailed"

  constructor: (@element, @imageList, @options = { size: { width: 50, height: 50}}) ->

    super(@element)
    if @$().attr('src')?
      @tryCombinationImages()
    # $(@element).load(function())

  onLoadFailed: (e) ->
    @tryCombinationImages()

  tryCombinationImages: () ->
    count = 0
    checkCombination = () =>
      count++
      @combinationImages() if count >= $(@imageList).length

    $(@imageList).one "load", ->
      checkCombination()
    .each () ->
      $(this).load() if this.complete

    # $(@imageList).each (i, elem) =>
    #   elem.onload = elem.onerror = () =>


  combinationImages: () ->
    @$imageList ||= $(@imageList)
    rows        = cols = @current_vector(@$imageList.length)
    space       = if @$imageList.length then 1 else 0
    width       = @options["size"]["width"]
    height      = @options["size"]["height"]
    sub_width   = width / cols
    sub_height  = height / rows
    real_width  = (width - ((cols + 1) * space)) / cols
    real_height = (height - ((rows + 1) * space)) / rows
    # size        = "#{real_width}x#{real_height}"

    @$canvas ||= $("<canvas width=\"#{width}\" height=\"#{height}\" /> ")
    @$().parent().html(@$canvas)
    @ctx ||= @$canvas.get(0).getContext("2d")
    # @ctx.rect(0,0,@$canvas.width(), @$canvas.height());
    @ctx.fillStyle = "#cccccc"
    @ctx.fillRect(0,0,@$canvas.width(), @$canvas.height())
    # @$imageList.each (i, img) =>
    for i in [0...rows*cols]
      img = @$imageList[i]
      if img? and $(img).is("img")
        x = (i % cols) * sub_width + space
        y = Math.floor(i / rows) * sub_height + space

        @ctx.drawImage(img, x, y, real_width, real_height)

  current_vector: (counts) ->
    vector = Math.ceil(Math.sqrt(counts))
    if vector < 3 then (if vector > 1 then vector else  1) else 3
