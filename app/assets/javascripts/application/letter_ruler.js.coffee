#= require _common/event
#= require lib/jquery.hammer

class @LetterRuler extends @HuEvent

  @defaultOptions = {
    letter: '.letter',
    scrollContainer: '.scroll-container',
    markTemplate: "<div class=\"letter-mark\"></div",
    zIndex: 1032
  }

  constructor: (@element, @options = {}) ->
    super(@element)

    @options = $.extend({}, @options, LetterRuler.defaultOptions)
    @options.top ?= 51
    @options.bottom ?= 0
    @target = @options.target;

    # @$().hammer().on("pan", @onPanMove)
    # @$().hammer({direction: Hammer.DIRECTION_VERTICAL})
    #   .on("panmove", @onPanMove)
    #   .on("panend", (e) =>
    #     $(@options['scrollContainer']).css({
    #       overflowY: 'auto'
    #     })
    #     # @onPanMove(e)
    #   )

    @$().on('touchstart', (e) =>
      e.preventDefault()
      $(@options['scrollContainer']).css({
        overflowY: 'hidden'
      })
      $(@letterMark).show() if @letterMark

    ).on('touchmove', (e) =>
      oe = e.originalEvent
      @onPanMove(e, oe.touches[0])
      # console.log(e)
      # point = g.pointers[0]
    ).on('touchend', (e) =>
      $(@options['scrollContainer']).css({
        overflowY: 'auto'
      })
      $(@letterMark).hide() if @letterMark
    )

    # @$().hammer({direction: Hammer.DIRECTION_VERTICAL})
    #   .on("panmove", (e) =>
    #     g = e.gesture
    #     @onPanMove(e, g.pointers[0])
    #   )
    #   .on("panend", (e) =>
    #     $(@options['scrollContainer']).css({
    #       overflowY: 'auto'
    #     })
    #     # @onPanMove(e)
    #   )

    @initial();

  initial: () ->
    @$().css({
      position: 'fixed',
      right: 0,
      bottom: @options.bottom,
      top: @options.top,
      padding: 2,
      zIndex: @options.zIndex,
      width: '1.5em'
    });
  show: () ->
    @$().show()

  hide: () ->
    @$().hide()

  build: (target) ->
    @target = target
    $target = $(@target)
    @$letters = $target.find(@options["letter"])
    letter_length = @$letters.length
    if letter_length > 0
      # $(@options['scrollContainer']).css({
      #   overflowY: 'hidden'
      # });
      @$().empty()
      for i in [0..letter_length]
        $letter = $(@$letters[i])
        $letterAncor = $("<div class='letter-item #{$letter.text()}' >#{$letter.text()} </div>")
        $letterAncor.appendTo(@$())
          .height(@$().height() / letter_length)

  onPan: (e) =>

  onPanMove: (e, point) =>
    e.preventDefault();

    $letters = @$().find('.letter-item')


    for letter in $letters
      {top, left} = $(letter).offset()
      # console.log(point, top, left)
      if point.clientY >= top and point.clientY < top + $(letter).outerHeight()
        lt = $(letter).text().trim()
        if @oldLetter != lt
          @oldLetter = lt
          @send('scroll.letter_ruler', @oldLetter)
          @letterMark ||= $(".letter-mark")[0] || $(@options["markTemplate"]).appendTo("body")
          $(@letterMark).text(@oldLetter)
            .css({
              position: 'fixed'
              fontSize: 48,
              left: "50%",
              top: "50%",
              padding: 15;
              lineHeight: "50px",
              marginTop: -39,
              marginLeft: -39,
              height: 78,
              width: 78,
              color: "white",
              textAlign: "center",
              backgroundColor: "#000",
              zIndex: @options.zIndex + 1,
              opacity: 0.3,
              borderRadius: 8
            })


