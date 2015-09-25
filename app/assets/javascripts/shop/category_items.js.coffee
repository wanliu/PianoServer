##= require _common/event

class @CategoryItems extends @HuEvent
  constructor: (@container, @element, @options = {}) ->
    super(@element)
    @container.setCategoryItems(@) if @container?
    @refreshTable()

  generateCategoryItems: (items) ->
    for item in items
      @generateCategoryItem(item)

    @refreshTable()

  refreshTable: () ->
    @$().parents('table').table()

  bindEditCategory: () ->
    @$().find('.edit').bind('click', @onEditCategory.bind(@))

  generateCategoryItem: (item, index) ->
    { id, image_url, title, category_id, shop_category_title, price, public_price, inventory, on_sale } = item

    template = """
      <tr data-item-index="#{index}" data-item-id="#{id}" >
        <td class="title"><img src="#{image_url}" alt="product image" class='item-image' />#{ title }</td>
        <td>#{ shop_category_title }</td>
        <td>#{ public_price }</td>
        <td>#{ price }</td>
        <td>#{ inventory }</td>
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

  resetContent: (data) ->
    @$().html('')
    @generateCategoryItems(data)
    @bindEditCategory()

  onEditCategory: (e) ->
    e.preventDefault()

    $tr = $(e.target).parents("tr");
    item = $tr.data()
    id = $tr.data('itemId')
    url = @options.url.replace(/\$(\w+)/, (match, m) => item[m]) + "edit"

    Turbolinks.visit(url)
