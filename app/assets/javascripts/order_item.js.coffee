class OrderItem
  constructor: (@el, @options = {}) ->
    @options.image ||= ''
    @options.title ||= ''
    @options.price ||= 0.0
    @options.amount ||= 0
    @options.inventory ||= 0
    @_init(@el)

  _init: (el)->
