#= require ./item
#= require _common/event

class @OrderTable extends @Event
  @defaultOptions = {
    maxDelaySyncMs: 800
  }

  constructor: (@element, @orderId = $(@element).data('orderId'), @options = {}) ->
    super(@element)
    @$items = @$().find('.item-list > .list-group-item')
    @items = for item in @$items
      new OrderItem(item, @element)

    @options = $.extend({}, OrderTable.defaultOptions, @options)
    @itemList = @$().find('.item-list')
    @itemList.on('click', @onClicked.bind(@))
    @itemList.on('change', 'input[name=amount]',@amountChanged.bind(@))
    @itemList.on('change', 'input[name=price]', @priceChanged.bind(@))
    @itemList.on('keyup', 'input[name=amount]', @amountChanged.bind(@))
    @itemList.on('keyup', 'input[name=price]', @priceChanged.bind(@))
    @$().on('click', '.payment-menu li', @changePayment.bind(@))
    @$().on('click', '.order-item-amount .btn-minus', @amountDecreased.bind(@))
    @$().on('click', '.order-item-amount .btn-plus', @amountIncreased.bind(@))
    @$().on('click', '.order-item-price .btn-minus', @priceDecreased.bind(@))
    @$().on('click', '.order-item-price .btn-plus', @priceIncreased.bind(@))
    @patch = []
    @on 'init', () =>
      $.ajax({
        url: "/orders/#{@orderId}/diff",
        type: 'GET',
        dataType: 'json'
      }).success (data) =>
        @parseDiff(data.diff)

    @on 'order', @onOrderCommand.bind(@)

  $: () ->
    $(@element)

  onClicked: (event) ->
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

    @changeRadiusStyles($target)

  changeRadiusStyles: (target) ->
    index = target.index()
    parent = target.parent()
    length = parent.find('li').length

    if (length == 1)
      @toggleSingleItem(parent)
      return

    if (index == 0)
      @toggleFirstItem(parent, target)
      return

    if (index == length - 1)
      @toggleLastItem(parent, target)
      return

    else
      @toggleMidItem(target)

  amountDecreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=amount]')
    amount = $input.val()
    reg = /^[1-9]\d*$/

    unless (reg.test(amount))
      return

    amount = +amount - 1
    $input.val(amount).change()

  amountIncreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=amount]')
    amount = $input.val()
    reg = /^[1-9]\d*$/

    unless (reg.test(amount))
      return

    amount = +amount + 1
    $input.val(amount).change()

  amountChanged: (event) ->
    $input = $(event.target)
    amount = $input.val()
    # $parent = $input.parent()
    # $range = $parent.find('input[type=range]')
    # max = $range.attr('max')
    # reg = /^[1-9]\d*$/

    # unless (reg.test(amount))
    #   return

    # if (+amount > +max)
    #   alert('库存不足!')
    #   return

    #$range.val(amount)
    $(event.currentTarget).trigger('item:amount:change', amount)

    $item = $(event.currentTarget).parents('.list-group-item')
    @pushItemOp 'replace', @indexOf($item), 'amount', amount

  priceDecreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=price]')
    price = $input.val()
    # reg = /^[1-9]\d*(.\d{1,2})?$/

    # unless (reg.test(price))
    #   return

    price = +price - 1 + '.0'
    $input.val(price).change()

  priceIncreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=price]')
    price = $input.val()
    # reg = /^[1-9]\d*(.\d{1,2})?$/

    # unless (reg.test(price))
    #   return

    price = (+price + 1) + '.0'
    $input.val(price).change()

  priceChanged: (event) ->
    $this = $(event.target)
    price = $this.val()
    # $parent = $this.parent()
    # $range = $parent.find('input[type=range]')
    # max = $range.attr('max')
    # reg = /^[1-9]\d*(.\d{1,2})?$/

    # unless (reg.test(price))
    #   return

    # if (+price > +max)
    #   alert('你设置的价格超出了合理范围')
    #   return

    #$range.val(price)
    $(event.currentTarget).trigger('item:price:change', price)

    $item = $(event.currentTarget).parents('.list-group-item')
    @pushItemOp 'replace', @indexOf($item), 'price', price

  changePayment: (e) ->
    $target = $(e.currentTarget)

    if ($target.hasClass('selected'))
      return;

    $target.addClass('selected').siblings().removeClass('selected');
    text = $target.find('a').text()
    $target.parents('.dropdown:first').find('.button-text').text(text);

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

    @changeRadiusStyles(el)

    # send request to remove item
    el.remove()

  pushOp: (op, path, value) ->
    # hash = {}
    # hash[op] = path
    # hash['value'] = value
    last = @patch[@patch.length - 1]
    if last and last['path'] == path
      last['value'] = value
    else
      @patch.push(op: op, path: path, value: value)

    unless @delaySyncId?
      delay = () =>
        queue = []
        queue.push(@patch.shift()) for ele in @patch

        $.ajax({
          url: "/orders/#{@orderId}",
          type: 'PATCH',
          dataType: 'json',
          contentType: 'application/json',
          data: JSON.stringify({patch: queue})
        }).success (data) =>
          queue.splice(0)
          clearTimeout(@delaySyncId)
          @delaySyncId = null
          @parseDiff(data.diff)
          delay() if @patch.length

      @delaySyncId = setTimeout(delay, @options.maxDelaySyncMs)

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

  onOrderCommand: (e, command) ->
    if command.diff?
      @parseDiff(command.diff)
