#= require _common/event

class @ItemBrands extends @HuEvent
  constructor: (@element, @container) ->
    super(@element)
    @on('brands:change', @changeBrands.bind(@))
    @container.setBrands(@)

  generateBrands: (brands) ->
    return unless brands.length

    for brand in brands
      { name, image, chinese_name } = brand

      brand_name = if name.length then [name, chinese_name].join('/') else chinese_name

      template = """
        <div class="item-brand">
          <img src="#{image.url}">
          <div class="brand-name">
            #{brand_name}
          </div>
        </div>
      """

      $(template).appendTo(@$())

  changeBrands: (e, brands) ->
    @$().html()

    @generateBrands(brands)
