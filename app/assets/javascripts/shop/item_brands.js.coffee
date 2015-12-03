#= require _common/event

class @ItemBrands extends @HuEvent
  constructor: (@element, @container) ->
    super(@element)
    @on('brands:change', @changeBrands.bind(@))
    @container.setBrands(@)

  generateBrands: (brands) ->
    return unless brands.length

    for brand in brands
      { name, image } = brand

      template = """
        <div class="item-brand">
          <img src="#{image.url}">
          <div class="brand-name">
            #{name}
          </div>
        </div>
      """

      $(template).appendTo(@$())

  changeBrands: (e, brands) ->
    @$().html('')

    @generateBrands(brands)

