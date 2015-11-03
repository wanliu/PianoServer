#= require _common/event

class @PropertySearch extends @HuEvent
  events:
    'keyup.input[name=q_cate]': 'queryChanged'

  constructor: (@element, @url) ->
    super(@element)
    @$dropdown = @$().find('.dropdown-menu')

  searchProperties: (q) ->
    $.ajax({
      type: 'GET',
      url: @url + '/properties/fuzzy_match',
      data: {
        'q': q
      },
      dataType: 'json',
      success: (json) =>
        @handleResponseData(json)
    })

  handleResponseData: (data) ->
    properties = data.properties

    if properties.length > 0
      @showMatchedProperties(properties)
    else
      @appendTipText()


  showMatchedProperties: (properties) ->
    for property in properties
      @showProperty(property)

    @bindClickEvent()

  appendTipText: () ->
    $('<li><h6 class="text-center">(已无可用属性)</h6></li>').appendTo(@$dropdown)

  showProperty: (property) ->
    template = """
      <li>
        <a href="javascript:void(0);" url="#{@url}" data-property-id="#{property.id}">
          #{property.title}
          <span class="label label-primary pull-right">创建</span>
        </a>
      </li>
    """
    $(template).appendTo(@$dropdown)

  queryChanged: (e) ->
    q = $(e.target).val()

    @$dropdown.find('li:not(.no-selected)').remove()
    @searchProperties(q)

  bindClickEvent: () ->
    @$dropdown.find('a').click((e) =>
      propertyId = $(e.currentTarget).data('propertyId')
      url = @url + '/add_property'

      $.ajax({
        type: 'POST',
        url: url,
        data: {
          property_id: propertyId
        },
        dataType: 'json',
        success: (json) =>
          $(json.html).appendTo($('.property-list'))
      })
    )
