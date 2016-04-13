class @GiftCollection
  constructor: (@options) ->
    _.extend @, @options

    @gitfItemModify = null
    @giftItemCreate = null

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

  setModalForCreate: (data) ->
    @giftItemCreate = data

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

    $.post(@giftCreateUrl, {
      gift: {
        present_id: @giftItemCreate.id,
        quantity: quantity,
        total: total
      }
    }).done (data, status, xhr) =>
      @gifts.unshift(data)
      @$modalCreater.modal('hide')

      html = @giftTemplate(data).replace('88888888', data.id)
      $('table.gifts tbody').prepend(html)

  saveGift: (event) =>
    quantity = @$modalModifier.find('input.quantity').val()
    total = @$modalModifier.find('input.total').val()
    updateUrl = @giftUpdateUrl.replace('88888888', @gitfItemModify.id)

    $.post(updateUrl, {
      _method: 'PATCH',
      gift: {
        quantity: quantity,
        total: total
      }
    }).done (data, status, xhr) =>
      @gitfItemModify.quantity = data.quantity
      @gitfItemModify.total = data.total

      html = @giftTemplate(data).replace('88888888', data.id)
      $('table.gifts tbody').find('tr[data-gift-id=' + data.id + ']')
        .replaceWith(html)

      @setModalForMofify()

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

    if _.keys(data.stocks).length > 1
      _.each data.properties_setting, (prop) =>
        return if prop.prop_type != "stock_map"

        html = prop.title + ':' +
          _.reduce(prop.data.map, (raw, key, value) ->
            return raw + "<button type='button' class='btn btn-default'>" + value + "</button>"
        , '')

        @$modalCreater.find('.properties-select').append(html)