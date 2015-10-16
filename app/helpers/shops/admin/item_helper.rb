module Shops::Admin::ItemHelper
  def new_step1_shopitems_path(*args)
    new_step1_shop_admin_items_path(*args)
  end

  def new_step2_shopitems_path(*args)
    with_category_shop_admin_items_path(*args)
  end

  def property_edit(object, property)
    unit_for_if(property) do
      propert_input_tag(object, property)
    end
  end

  def propert_input_tag(object, property)
    property_name = "property_#{property.name}"
    case property.prop_type
    when "string"
      text_field object, property_name, class: 'form-control'
    when "number"
      number_field object, property_name, class: 'form-control'
    when "boolean", "bool"
      radio_toggle object, property_name
    when "date"
      date_picker object, property_name
    when "datetime"
      date_picker object, property_name
    when "map"
      multi_set_select object, property_name, property
    else
      text_field object, property_name, class: 'form-control'
    end
  end

  def unit_for_if(property, &block)
    if property.unit_type
      s '<div class="input-group">'
        s(yield) + s("<span class=\"input-group-addon\">#{property.unit_type}</span>")
      s '</div>'
    else
      s yield
    end
    nil
  end

  def s(string)
    safe_concat(string)
  end

  def radio_toggle(object, name, options = {class: 'toggle-checkbox'})
    raw <<-HTML
      <label class="toggle-box">
        #{check_box object, name, options}
        <div class="track">
          <div class="handle"></div>
        </div>
      </label>
    HTML
  end

  def date_picker(object, name, options = {})
    id = [object, name].join('_')
    raw <<-HTML
      <div class='input-group date' id='#{id}'>
        #{text_field object, name, class: 'form-control'}
        <span class="input-group-addon">
          <span class="glyphicon glyphicon-calendar"></span>
        </span>
      </div>
      <script type="text/javascript">
        $('##{id}').datetimepicker();
      </script>
    HTML
  end

  def multi_set_select(object, name, property)
    set = (property.data || {})['map']

    # @template_object = b.instance_variable_get(:@template_object)
    # @object_name = b.instance_variable_get(:@object_name)
    # @method_name = b.instance_variable_get(:@method_name)
    # @template_object.text_field(@object_name, @method_name + "[#{b.value}][value]", class: 'form-control') -->

    #TODO: 实现 edit in place
    output = collection_check_boxes(object, name, collection_options_for_map(set), :id, :value) do |b, *args|
      raw <<-HTML
        <div class="col-sm-2" >
          <div class="input-group">
            <span class="input-group-addon">
              #{b.check_box}
            </span>
            #{b.label class: 'form-control'}
          </div>
        </div>
      HTML
    end
    raw "<div class=\"row\">#{output}</div>"
  end

  private

  def collection_options_for_map(map)
    map.map do |k, v|
      OpenStruct.new id: k, value: v
    end
  end
end
