json.(category, :id, :title)
json.html render partial: "category_by_parent", object: category, locals: {child: category, parent: @category} , formats: [ :html ]
