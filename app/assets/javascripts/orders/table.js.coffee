#= require ./item
#= require _common/event
#= require _common/popup

Popup = @Popup
class @OrderTable extends @Event
  @defaultOptions = {
    maxDelaySyncMs: 300,
    maxWaitAccpetingMS: 1500
  }

  constructor: (@element, @order, @options = {}) ->
    super(@element)
    @$items = @$().find('.item-list > .list-group-item')
    @items = for item in @$items
      new OrderItem(item, @element)

    @orderId = @order.id
    @options = $.extend({}, OrderTable.defaultOptions, @options)
    @itemList = @$().find('.item-list')
    @patch = []
    @bindAllEvents()

  bindAllEvents: () ->
    @itemList.on('click', @onClicked.bind(@))
    @itemList.on('change', 'input[name=amount]',@amountChanged.bind(@))
    @itemList.on('change', 'input[name=price]', @priceChanged.bind(@))
    @$().on('change', 'input[name=total]', @totalChanged.bind(@))
    @itemList.on('keyup', 'input[name=amount]', @amountChanged.bind(@))
    @itemList.on('keyup', 'input[name=price]', @priceChanged.bind(@))
    @$().on('click', '.payment-menu li', @changePayment.bind(@))
    @$().on('click', '.order-item-amount .btn-minus', @amountDecreased.bind(@))
    @$().on('click', '.order-item-amount .btn-plus', @amountIncreased.bind(@))
    @$().on('click', '.order-item-price .btn-minus', @priceDecreased.bind(@))
    @$().on('click', '.order-item-price .btn-plus', @priceIncreased.bind(@))
    @$().on('click', '.order-total-edit .btn-minus', @totalDecreased.bind(@))
    @$().on('click', '.order-total-edit .btn-plus', @totalIncreased.bind(@))
    @$().on('click', '.remove-item-icon', @removeItem.bind(@))

    captureOrderChangeBound = @captureOrderChange.bind(@)
    releaseOrderChangeBound = @releaseOrderChange.bind(@)
    @$().on('mousedown', '.btn-agrees',captureOrderChangeBound)
    @$().on('mouseup', '.btn-agrees', releaseOrderChangeBound)
    @$().on('touchstart', '.btn-agrees', captureOrderChangeBound)
    @$().on('touchend', '.btn-agrees', releaseOrderChangeBound)
    @$().on('click', '.btn-disagrees', @rejectOrderChanges.bind(@))
    @$().on('click', '.order-table-total', @changeOrderTotal.bind(@))

    @$().bind('add', @onAddChange.bind(@))
    @$().bind('remove', @onRemoveChange.bind(@))
    @$().bind('replace', @onReplaceChange.bind(@))
    # @$().bind('order:total:change', )

    @on 'init', () =>
      $.ajax({
        url: "/orders/#{@orderId}/diff",
        type: 'GET',
        dataType: 'json'
      }).success (data) =>
        diffs = data.diff
        @parseDiff(diffs)
        @checkDiff(diffs)

    @on 'order', @onOrderCommand.bind(@)

  unbindAllEvents: () ->
    @itemList.off('click')
    @itemList.off('change', 'input[name=amount]')
    @itemList.off('change', 'input[name=price]')
    @$().off('change', 'input[name=total]')
    @itemList.off('keyup', 'input[name=amount]')
    @itemList.off('keyup', 'input[name=price]')
    @$().off('click', '.payment-menu li')
    @$().off('click', '.order-item-amount .btn-minus')
    @$().off('click', '.order-item-amount .btn-plus')
    @$().off('click', '.order-item-price .btn-minus')
    @$().off('click', '.order-item-price .btn-plus')
    @$().off('click', '.order-total-edit .btn-minus')
    @$().off('click', '.order-total-edit .btn-plus')
    @$().off('click', '.remove-item-icon' )

    @$().off('mousedown', '.btn-agrees')
    @$().off('mouseup', '.btn-agrees')
    @$().off('touchstart', '.btn-agrees')
    @$().off('touchend', '.btn-agrees')
    @$().off('click', '.btn-disagrees')
    @$().off('click', '.order-table-total')

    @$().unbind('add')
    @$().unbind('remove')
    @$().unbind('replace')
    # @$().bind('order:total:change', )
    @$().off('init')
    @$().off('order')

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

    unless $target.is('li')
      $target = $target.parents('li:first')

    $target.toggleClass('open')

    # @changeRadiusStyles($target)

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

  totalDecreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=total]')
    total = $.trim($input.val())
    reg = /^[1-9]\d*(.\d{1,2})?$/

    if (!reg.test(total) || +total <= 1)
      return

    total = +total - 1
    $input.val(total).change()

  totalIncreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=total]')
    total = $.trim($input.val())
    reg = /^[1-9]\d*(.\d{1,2})?$/

    unless (reg.test(total))
      return

    total = +total + 1
    $input.val(total).change()

  totalChanged: (event) ->
    $input = $(event.target)
    total = $input.val()

    @pushTableOp('replace', '/total', total)

  amountDecreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=amount]')
    amount = $.trim($input.val())
    reg = /^[1-9]\d*$/

    if (!reg.test(amount) || +amount <= 1)
      return

    amount = +amount - 1
    $input.val(amount).change()

  amountIncreased: (event) ->
    event.stopPropagation()
    $target = $(event.target)
    $group = $target.parents('.input-group:first')
    $input = $group.find('input[name=amount]')
    amount = $.trim($input.val())
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
    price = $.trim($input.val())
    reg = /^[1-9]\d*(.\d{1,2})?$/

    if (!reg.test(price) || +price <= 1)
      return
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
    price = $.trim($input.val())
    # reg = /^[1-9]\d*(.\d{1,2})?$/

    # if (!reg.test(price) || +price <= 1)
    #   return

    price = +price + 1 + '.0'
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

  onAddChange: (e, data) ->

  onRemoveChange: (e, data) ->

  onReplaceChange: (e, data) ->
    {key, src, dest} = data
    if key == 'total'
      $total = @$().find('.total')
      $value = $total.find('.text')
      $value.text(dest)

      $title = $value.next('.title')

      if +src > +dest
        arrow = '↓'
        direction = 'down'
        changeClass = 'change-down'
        animateClass = 'fadeOutDown'
      # else if +src == +dest
      #   arrow = '&#45;'
      else
        arrow = '↑'
        direction = 'up'
        changeClass = 'change-up'
        animateClass = 'fadeOutUp'

      $title
        .text(arrow)
        .removeClass('fadeOutUp fadeOutDown')
        .addClass("animated #{animateClass}")

      $total
        .removeClass('change-down change-up')
        .addClass(changeClass)
        .stop(true, true)
        .effect('pulsate', times: 3, duration: 1500)

  captureOrderChange: (e) ->
    e.preventDefault()
    unless @inAccepting
      @inAccepting = true
      $.post("/orders/#{@orderId}/accept")
        .success () =>
          @showPopup()

          @ensureTickId = setTimeout () =>
            @inAccepting = false
            $.post "/orders/#{@orderId}/ensure", (json) =>
              @unbindAllEvents()
              this.hideConsultButtons();

              $('.order-table').html(json.html) if json.html?
              @closePopup()

          , @options.maxWaitAccpetingMS + 500
        .fail () =>
          @closePopup()

  releaseOrderChange: (e) ->
    if @inAccepting
      @closePopup()

      $.post "/orders/#{@orderId}/cancel", (data) =>

  rejectOrderChanges: () ->
    $.post "/orders/#{@orderId}/reject", { inline: true }, (json) =>
      @unbindAllEvents()
      $('.order-table').html(json.html) if json.html?
      @hideConsultButtons()

  showPopup: (options) ->
    @popup = Popup.show """
      <h3>正在同意订单修改</h3>
      <h1>&nbsp;</h1>
    """, options
    count = 0;
    maxCount =  @options.maxWaitAccpetingMS / 1000
    startTime = (new Date()).getTime()
    @acceptTickId = setInterval () =>
      @popup.setHtml """
        <h3>正在同意订单修改</h3>
        <h1 class="text-center">#{Math.round(maxCount - count)}</h1>
      """
      time = (new Date()).getTime()
      count = if count >= maxCount then count else (time - startTime) / 1000
    , 500
    @popup

  closePopup: () ->
    @inAccepting = false
    @popup.close() if @popup?
    clearInterval(@acceptTickId)
    clearTimeout(@ensureTickId)

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

  pushRemoveItemOp: (itemId) ->
    path = "/items/#{itemId}"
    @pushOp('remove', path, null)

  indexOf: (item) ->
    $(".item-list .list-group-item").index(item)

  parseDiff: (diffs) ->
    for [op, path, src, dest] in diffs

      [itemObj, key] = @parsePath(path)
      switch op
        when '+'
          @send('item:add', {key: key, src: src, dest: dest})
        when '-'
          itemObj.send('item:remove', {key: key, src: src, dest: dest})
        when '~'
          itemObj.send('item:replace', {key: key, src: src, dest: dest})


  parsePath: (path) ->
    ITEMS_REG = /items\[(\d+)\](?:\.(\w+))?/
    if ITEMS_REG.test(path)
      [_, index, key] = ITEMS_REG.exec(path)
      [@items[+index], key]
    else
      [this, path]

  onOrderCommand: (e, command) ->
    if command.diff?
      @parseDiff(command.diff)
      @showConsultButtons()

    else if command.accept?
      switch command.accept
        when 'accepting'
          @showPopup(modal: true)
          $('.chat-order')
            .effect('pulsate', times: 3, duration: 1500)
        when 'cancel'
          @closePopup()
        when 'accept'
          @closePopup()
          @resetTable()

        else
          @closePopup()
          @resetTable()

  changeOrderTotal: (e) ->
    $target = $(e.target)

    if @isEditField($target)
      return

    unless $target.is('li')
      $target = $target.parents('li:first')

    $target.toggleClass('open').prev().toggleClass('radius-bottom')

  checkDiff: (diffs) ->
    if diffs.length > 0
      @showConsultButtons()

  showConsultButtons: () ->
    @$().find('.buttons-execute')
        .hide()
        .next()
        .show()

  hideConsultButtons: () ->
    @$().find('.buttons-execute')
        .show()
        .next()
        .hide()

  resetTable: () ->
    @unbindAllEvents()
    @hideConsultButtons()

    $.get "/orders/#{@orderId}", {inline: true}, (json) =>
      $('.order-table').html(json.html) if json.html?

  removeItem: () ->
    confrimation = confirm(' 您确定删除者这个商品项吗?')

    if confrimation == true
      $li = $(event.target).parents('.list-group-item:first')
      item_id = $li.attr('item-id')
      index = @indexOf($li)

      @pushRemoveItemOp(index)


