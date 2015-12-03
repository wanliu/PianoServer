class RegionTable < TableCloth::Base
  # Define columns with the #column method
  column :id, :title, :name, :city_id, :parent_id, :created_at, :updated_at


  actions do
    action {|object| link_to "进入", edit_admins_region_path(object), class: "btn btn-primary" }

    action do |object|
      button_to( admins_region_path(object), {
        class: "btn btn-default",
        form: { style: 'display: inline'},
        remote: true,
        method: :put,
        data: { region: object.id },
        params: {
          "region[state]" => object.state == "open" ? "close" : "open"
        }
      }) do
        icon object.state == "open" ? 'eye-open' : 'eye-close'
      end
    end
    # action(if: :valid?) {|object| link_to "Invalidate", invalidate_object_path(object) }
  end
end
