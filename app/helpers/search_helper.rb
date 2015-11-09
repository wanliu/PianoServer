module SearchHelper

  def search_form(url, *args)
    options = args.extract_options!

    search_obj = OpenStruct.new({ q: options[:value] })
    options.merge!({
      class: "form-inline",
      method: :get
    })

    input_options = options.delete(:input)
    group_options = options.delete(:group)

    input_options[:class] = [input_options[:class]] + [ "form-control" ]


    form_tag url, options do
      input_group group_options do
        search_field_tag(:q, options[:value], input_options) +
        addon do
          icon :search
        end
      end
    end
  end
end
