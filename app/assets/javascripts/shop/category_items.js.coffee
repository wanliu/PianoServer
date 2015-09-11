#= require _common/event

class @CategoryItems extends @Event

  constructor: (@element, @items) ->
    @element.html('')

    for item in @items
      @generateCategoryItem(item)

  generateCategoryItem: (item) ->
    { id, title, category_id, price, inventory, on_sale } = item

    template = """
      <tr>
        <td>#{ title }</td>
        <td>#{ category_id }</td>
        <td>#{ price }</td>
        <td>#{ inventory }</td>
        <td>
          <label class="toggle-box">
            <input type="checkbox" name="on_sale" class="toggle-checkbox">
            <div class="track">
              <div class="handle"></div>
            </div>
          </label>
        </td>
      </tr>
    """

    $item = $(template).appendTo(@element)

    $item.find('.toggle-checkbox').attr('checked', 'checked') if on_sale
