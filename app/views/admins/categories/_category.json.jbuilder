json.(category, :id, :title)
json.html render partial: "admins/industries/category_item", locals: {category_item: category} , formats: [ :html ]
