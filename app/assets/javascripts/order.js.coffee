class Order
  constructor: (@options = {}) ->
    @options.buyer ||= ''
    @options.provider ||= ''
    @options.seller ||= ''
    @options.reciption ||= ''
    @options.items ||= []
    @options.isBuyer ||= true
    @_init()

  _init ->
    
    

  destroy ->
