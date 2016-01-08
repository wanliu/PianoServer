class OneMoneyTable < TableCloth::Base

  COLUMNS = %w(name title description cover_url status created_at updated_at start_at end_at)
  column :id

  COLUMNS.each do |col_name|
    column col_name
    # column col_name do |object|
    #   object.send(col_name).value
    # end
  end

  actions do
    action {|object| link_to "编辑", edit_admins_one_money_path(object.id), class: "btn btn-primary" }
  end
end
