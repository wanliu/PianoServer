#= require ./item
#
class @OrderTable
  @defaultOptions = {
    maxDelaySyncMs: 300
  }

  constructor: (@element, @orderId = $(@element).data('orderId'), @options = {}) ->
    @$items = @$().find('.item-list > .list-group-item')
    @items = for item in @$items
      new OrderItem(item, @element)

    @options = $(@options, @defaultOptions)
    @itemList = @$().find('.item-list')
    @itemList.on('click', @onClicked.bind(@))
    @itemList.on('change', 'input[name=amount]',@amountChanged.bind(@))
    @itemList.on('change', 'input[name=price]', @priceChanged.bind(@))
    @patch = []

  $: () ->
    $(@element)

  onClicked: (event) ->
    event.stopPropagation()

    $target = $(event.target)

    if @isEditField($target)
      return

    if @isItemImage($target)
      # show the item detail
      return

    if @isRemoveBtn($target)
      @removeItem($target.parents('li:first'))
      return

    if (!$target.is('li'))
      $target = $target.parents('li:first')

    $target.toggleClass('open')

    index = $target.index()
    $parent = $target.parent()
    length = $parent.find('li').length

    if (length == 1)
      @toggleSingleItem($parent)
      return

    if (index == 0)
      @toggleFirstItem($parent, $target)
      return

    if (index == length - 1)
      @toggleLastItem($parent, $target)
      return

    else
      toggleMidItem($target)

  amountChanged: (event) ->
    $input = $(event.target)
    amount = $input.val()
    $parent = $input.parent()
    $range = $parent.find('input[type=range]')
    max = $range.attr('max')
    reg = /^[1-9]\d*$/

    unless (reg.test(amount))
      return

    if (+amount > +max)
      alert('库存不足!')
      return

    $range.val(amount)
    $(event.currentTarget).trigger('item:amount:change', amount)

    $item = $(event.currentTarget).parents('.list-group-item')
    @pushItemOp 'replace', @indexOf($item), 'amount', amount

  priceChanged: (event) ->
    $this = $(event.target)
    price = $this.val()
    $parent = $this.parent()
    $range = $parent.find('input[type=range]')
    max = $range.attr('max')
    reg = /^[1-9]\d*(.\d{1,2})?$/

    unless (reg.test(price))
      return

    if (+price > +max)
      alert('你设置的价格超出了合理范围')
      return

    $range.val(price)

    $item = $(event.currentTarget).parents('.list-group-item')
    @pushItemOp 'replace', @indexOf($item), 'price', price

  isEditField: (target) ->
    target.is('.edit-fieldset') or target.parents('.edit-fieldset').length > 0

  isRemoveBtn: (target) ->
    target.is('.remove-btn')

  isItemImage: (target) ->
    target.is('img')

  send: (event, args...) ->
    @$().trigger(event, args...)

  toggleSingleItem: (parent) ->
    parent.prev().toggleClass('radius-bottom')
    parent.next().toggleClass('radius-top')

  toggleFirstItem: (parent, target) ->
    parent.prev().toggleClass('radius-bottom')
    target.next().toggleClass('radius-top')

  toggleLastItem: (parent, target) ->
    parent.next().toggleClass('radius-top')
    target.prev().toggleClass('radius-bottom')

  toggleMidItem: (target) ->
    target.prev().toggleClass('radius-bottom')
    target.next().toggleClass('radius-top')

  removeItem: (el) ->
    itemId = el.attr('item-id')
    orderId = el.parent().attr('order-id')

    # send request to remove item
    el.remove()

  pushOp: (op, path, value) ->
    # hash = {}
    # hash[op] = path
    # hash['value'] = value
    @patch.push(op: op, path: path, value: value)
    clearTimeout(@delaySyncId ) if @delaySyncId?

    @delaySyncId = setTimeout () =>
      $.ajax({
        url: "/orders/#{@orderId}",
        type: 'put',
        data: { patch: @patch }
      }).success (data) =>
        @patch = []
        @parseDiff(data.diff)

    , @options.maxDelaySyncMs

  pushTableOp: (op, key, value) ->
    @pushOp(op, key, value)

  pushItemOp: (op, itemId, key, value) ->
    path = "/items/#{itemId}/#{key}"
    @pushOp(op, path, value)

  indexOf: (item) ->
    $(".item-list .list-group-item").index(item)

  parseDiff: (diffs) ->
    for [op, path, src, dest] in diffs

      [itemObj, key] = @parsePath(path)
      switch op
        when '+'
          @send('add', {key: key, src: src, dest: dest})
        when '-'
          itemObj.send('remove', {key: key, src: src, dest: dest})
        when '~'
          itemObj.send('replace', {key: key, src: src, dest: dest})


  parsePath: (path) ->
    ITEMS_REG = /items\[(\d+)\](?:\.(\w+))?/
    if ITEMS_REG.test(path)
      [_, index, key] = ITEMS_REG.exec(path)
      [@items[+index], key]







