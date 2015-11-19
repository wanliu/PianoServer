#= require _common/event
#= require _common/paginate

class @CategoryItems extends @HuEvent
  constructor: (@element, @container, @options = {}) ->
    super(@element)
    @container.setCategoryItems(@) if @container?
    @refreshTable()

    @on('items:change', @itemsChanged.bind(@))

  generateCategoryItems: (items) ->
    for item in items
      @generateCategoryItem(item)

    @refreshTable()

  refreshTable: () ->
    $table = @$().parents('table').table()
    table = $table.data('table')
    table.refresh()

  bindEditCategory: () ->
    @$().find('.edit').bind('click', @onEditCategory.bind(@))

  bindAllEvents: () ->
    @$().on('change', '.toggle-checkbox', @toggleItemState.bind(@))

  generateCategoryItem: (item, index) ->
    { sid, image_url, title, category_id, shop_category_title, price, public_price, on_sale, current_stock } = item

    template = """
      <tr data-item-index="#{index}" data-item-sid="#{sid}" >
        <td class="title"><img src="#{image_url}" alt="product image" class='item-image' />#{ title }</td>
        <td>#{ shop_category_title }</td>
        <td>#{ public_price }</td>
        <td>#{ price }</td>
        <td>#{ current_stock }</td>
        <td>
          <div class="btn-group">
            <button class="btn btn-link edit"><span class="glyphicon glyphicon-edit"></span></button>
          </div>
          <label class="toggle-box">
            <input type="checkbox" name="on_sale" class="toggle-checkbox">
            <div class="track">
              <div class="handle"></div>
            </div>
          </label>
        </td>
      </tr>
    """

    $item = $(template).appendTo(@$())
    $item.find('.toggle-checkbox').attr('checked', 'checked') if on_sale

  itemsChanged: (e, data) ->
    @$().html('')
    @generateCategoryItems(data)
    @bindEditCategory()

  onEditCategory: (e) ->
    e.preventDefault()

    $tr = $(e.target).parents("tr")
    item = $tr.data()
    sid = $tr.data('itemSid')
    url = @options.url.replace(/\$(\w+)/, (match, m) => item[m]) + "edit"

    Turbolinks.visit(url)

  toggleItemState: (e) ->
    e.stopPropagation()

    $target = $(e.target)
    $tr = $target.parents("tr:first")
    item = $tr.data()
    sid = $tr.data('itemSid')
    on_sale = $target.prop('checked')
    sid = $tr.data('itemSid')
    url = @options.url.replace(/\$(\w+)/, (match, m) => item[m]) + 'change_sale_state'

    $.ajax({
      url: url,
      type: 'PUT',
      data: {
        item: {
          on_sale: on_sale
        }
      },
      dataType: 'json',
      success: () =>
    })


