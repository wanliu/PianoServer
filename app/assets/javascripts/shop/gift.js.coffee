class @GiftCollection
  constructor: (@options) ->
    _.extend @, @options

    @gitfItemModify = null
    @giftItemCreate = null
    @propertiesTotal = 0

    @fillInitialGifts()
    @bindEvents()

  fillInitialGifts: () ->
    html = _.reduce(@gifts, (str, gift) =>
      str += @giftTemplate(gift).replace('88888888', gift.id)
      return str
    , '')
    $('table.gifts tbody').html(html)

  bindEvents: () ->
    @$dropdown.on 'click', '.shop-item', @selectItem

    @$modalCreater.on 'hidden.bs.modal', @clearModalCreater
    @$modalCreater.on 'click', 'button.property',  @selectProperty
    @$modalCreater.find('button.create-gift').on 'click', @createGift

    @$modalModifier.on 'click', 'button.save-gift', @saveGift

    $('table.gifts tbody').on 'click', '.modify-gift', @modifyGift
    $('#gift-search').keyup @searchShopItem

  selectItem: (event) =>
    target = event.target || event.srcElement
    itemId = $(target).data('itemId')
    url = @itemShowUrl.replace('88888888', itemId)
    $.getJSON(url)
      .done (data, status, xhr) =>
        @setModalForCreate(data)

  selectProperty: (event) =>
    target = event.target || event.srcElement
    $properties = $(target).closest('.properties')
    $properties.find('button').removeClass('active')
    $(target).addClass('active')

    if $properties.find('button.active').length == @propertiesTotal
      @$modalCreater.find('input').removeAttr('disabled')


  setModalForCreate: (data) ->
    @giftItemCreate = data
    @$modalCreater.find('.errors')
      .html('')
      .hide()

    if data
      if data.images[0] && data.images[0].url
        @$modalCreater.find('img.avatar').attr('src', data.images[0].url)

      @renderItemStocks(data)
      
      @$modalCreater.modal('show')
    else
      @$modalCreater.find('img.avatar').attr('src', '')
      @$modalCreater.find('input').val('')

  createGift: (event) =>
    quantity = @$modalCreater.find('input.quantity').val()
    total = @$modalCreater.find('input.total').val()
    properties = @getGiftProperties()

    request = $.post(@giftCreateUrl, {
      gift: {
        present_id: @giftItemCreate.id,
        quantity: quantity,
        total: total,
        properties: properties
      }
    })

    request.done @createdGiftCallback
    request.fail @failCreateGiftCallback

  createdGiftCallback: (data, status, xhr) =>
    @gifts.unshift(data)
    @$modalCreater.modal('hide')

    html = @giftTemplate(data).replace('88888888', data.id)
    $('table.gifts tbody').prepend(html)

  failCreateGiftCallback: (data, status, xhr) =>
    @$modalCreater.find('.errors')
      .text(data.responseJSON.error)
      .show()

  getGiftProperties: () ->
    selectedProps = @$modalCreater.find('.properties button.active')
    _.reduce(selectedProps, (properties, btn) ->
      key = $(btn).data('propertyKey')
      value = $(btn).data('propertyValue')
      properties[key] = value
      properties
    , {})

  saveGift: (event) =>
    quantity = @$modalModifier.find('input.quantity').val()
    total = @$modalModifier.find('input.total').val()
    updateUrl = @giftUpdateUrl.replace('88888888', @gitfItemModify.id)

    request = $.post(updateUrl, {
      _method: 'PATCH',
      gift: {
        quantity: quantity,
        total: total
      }
    })

    request.done @updatedGiftCallback
    request.fail @failUpdateGiftCallback

  updatedGiftCallback: (data, status, xhr) =>
    @gitfItemModify.quantity = data.quantity
    @gitfItemModify.total = data.total

    html = @giftTemplate(data).replace('88888888', data.id)
    $('table.gifts tbody').find('tr[data-gift-id=' + data.id + ']')
      .replaceWith(html)

    @setModalForMofify()

  failUpdateGiftCallback: (data, status, xhr) =>
    @gitfItemModify.find('.errors')
      .text(data.responseJSON.error)
      .show()

  modifyGift: (event) =>
    target = event.target || event.srcElement
    giftId = $(target).data('giftId')
    gift = _.find @gifts, (item) ->
      item.id == giftId

    @setModalForMofify(gift)

  searchShopItem: (event) =>
    target = event.target || event.srcElement
    query = $(target).val()

    return if !query

    $.getJSON(@giftSearchUrl, { q: query })
      .done (data, status, xhr) =>
        @$dropdown.html('')

        _.each data, (item) =>
          html = @itemTemplate(item)
          @$dropdown.append(html)

  clearModalCreater: () =>
    @setModalForCreate()

  setModalForMofify: (data) ->
    @gitfItemModify = data
    @$modalModifier.find('.errors')
      .html('')
      .hide()

    if data 
      @$modalModifier.find('img.avatar').attr('src', data.cover_url)
      @$modalModifier.find('input.quantity').val(data.quantity)
      @$modalModifier.find('input.total').val(data.total)
      @$modalModifier.modal('show')
    else
      @$modalModifier.modal('hide')
      @$modalModifier.find('img.avatar').attr('src', '')
      @$modalModifier.find('input').val('')

  renderItemStocks: (data) ->
    @$modalCreater.find('.properties-select').html('')

    stocks_properties = _.filter data.properties_setting, (item) ->
      "stock_map" == item.prop_type

    @propertiesTotal = stocks_properties.length

    if _.keys(data.stocks).length > 1
      @$modalCreater.find('input').attr('disabled', 'disabled')

      _.each stocks_properties, (prop) =>
        html = @propertyRowTemplate(prop);
        $html = $(html)

        _.each prop.data.map, (value, title) =>
          property_html = @propertyColumnTemplate({
            key: prop.name,
            value: value,
            title: title })

          $html.find('.properties').append(property_html)

        @$modalCreater.find('.properties-select').append($html)