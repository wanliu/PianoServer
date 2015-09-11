json.children @categories, partial: 'category', as: :category
json.edit_html render partial: "category_edit", object: @category, locals: {category: @category, industry: @industry } , formats: [ :html ]
