module SearchHelper

  def search_form(url, *args)
    options = args.extract_options!

    search_obj = OpenStruct.new({ q: options[:value] })
    options.merge!({
      class: "form-inline",
      method: :get
    })

    form_tag url, options do
      search_field_tag(:q, options[:value], class: "form-control") +
      submit_tag(:search, class: "btn btn-primary")
    end
  end
end
