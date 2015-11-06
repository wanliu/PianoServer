module SearchHelper

  def search_form(url, *args)
    options = args.extract_options!

    search_obj = OpenStruct.new({ q: options[:value] })
    options.merge!({
      class: "form-inline",
      method: :get
    })

    form_tag url, options do
      input_group do
        search_field_tag(:q, options[:value], class: "form-control") +
        addon do
          icon :search
        end
      end
    end
  end
end
