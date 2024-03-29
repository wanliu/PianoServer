module Shops::Admin::ItemHelper
  COLORS_GROUP = %w(primary success info warning danger default)

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
    object_name = object.is_a?(ActiveRecord::Base) ? object.class.name.underscore : object
    property_name = "property_#{property.name}"
    case property.prop_type
    when "string"
      text_field object_name, property_name, class: 'form-control'
    when "number"
      number_field object_name, property_name, class: 'form-control'
    when "boolean", "bool"
      radio_toggle object_name, property_name
    when "date", "datetime"
      exterior_name = property.exterior.nil? ? "exterior_date_select_editor" : "exterior_#{property.exterior}_editor"

      render exterior_name, with: property, locals: {
        object: object,
        object_name: object_name,
        property_name: property_name,
        property: property
      }
      # date_picker object_name, property_name
    when "map", "stock_map", "sale_map"
      exterior_name = property.exterior.nil? ? "exterior_dropdown_editor" : "exterior_#{property.exterior}_editor"

      render exterior_name, with: property, locals: {
        object: object,
        object_name: object_name,
        property_name: property_name,
        property: property
      }
    else
      text_field object_name, property_name, class: 'form-control'
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

  def radio_toggle(object_name, name, options = {class: 'toggle-checkbox'})
    raw <<-HTML
      <label class="toggle-box">
        #{check_box object_name, name, options}
        <div class="track">
          <div class="handle"></div>
        </div>
      </label>
    HTML
  end

  def date_picker(object_name, name, options = {})
    id = [object_name, name].join('_')
    raw <<-HTML
      <div class='input-group date' id='#{id}'>
        #{text_field object_name, name, class: 'form-control'}
        <span class="input-group-addon">
          <span class="glyphicon glyphicon-calendar"></span>
        </span>
      </div>
      <script type="text/javascript">
        $('##{id}').datetimepicker({
          format: "YYYY-MM-DD HH:mm:ss"
        });
      </script>
    HTML
  end

  def multi_set_select(object_name, name, property, options = {})
    set = (property.data || {})['map']

    item_class = options[:item_class] || "col-lg-2 col-md-3 col-sm-4 col-xs-6"

    # @template_object = b.instance_variable_get(:@template_object)
    # @object_name = b.instance_variable_get(:@object_name)
    # @method_name = b.instance_variable_get(:@method_name)
    # @template_object.text_field(@object_name, @method_name + "[#{b.value}][value]", class: 'form-control') -->

    #TODO: 实现 edit in place
    # item[property_milk_level][]
    output = collection_check_boxes(object_name, name, collection_options_for_map(set), :id, :value, include_hidden: true) do |b, *args|
      raw <<-HTML
        <div class="#{item_class}" >
          <div class="input-group">
            <label class="input-group-addon">
              #{b.check_box}
            </label>
            #{b.label class: 'form-control'}
          </div>
        </div>
      HTML
    end
    raw "<div class=\"row\">#{output}</div>"
  end

  def multi_set_select_and_title(object, name, property, options = {})
    set = (property.data || {})['map']

    item_class = options[:item_class] || "col-lg-2 col-md-3 col-sm-4 col-xs-6"

    output = collection_check_box_map(set, object, name).map do |item|
      fields_for "item[#{name}][]", item do |sub|
        raw <<-HTML
          <div class="#{item_class}" >
            <div class="input-group">
              <label class="input-group-addon">
                #{sub.check_box :check, class: 'check-inventory'}
              </label>
              #{sub.text_field :title, class: 'form-control'}
            </div>
          </div>
        HTML
      end
    end.join

    raw "<div class=\"row items\">#{output}</div>"
  end

  def label_color(name)
    "label-#{COLORS_GROUP[name.each_byte.to_a.sum %  6]}"
  end

  def sa_item_inventory_config_path(shop_name, item)
    method_name =  item.persisted? ? :shop_admin_item_path : :shop_admin_items_path
    File.join send(method_name, shop_name, item.sid), "inventory_config"
  end

  private

  def collection_options_for_map(map)
    map.map do |k, v|
      OrderStruct.new key: k, check: v
    end
  end

  def collection_map(set)
    set.map do |k, v|
      OrderStruct.new key: k, check: k, title: v
    end
  end

  def collection_check_box_map(set, object, name)
    set.map do |key, title|
      item_check = check_options(object, name, key)["check"] || true
      item_title = check_options(object, name, key)["title"] || title
      OrderStruct.new key: key, check: item_check, title: item_title
    end
  end

  def check_options(object, name, key)
    (object.send(name) || {})[key] || {}
  end
end

class OrderStruct < OpenStruct

  def to_param
    key
  end
end
