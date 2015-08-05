class WanliuUserTable < TableCloth::Base
  # Define columns with the #column method
  column :id, :login, :email, :realname, :telephone, :business_type, :shop_id, :shop_name, :created_at, :updated_at

  column :id do |object|
    [object.id, {class: "user-#{object.id}" }]
  end
  actions do
    action {|object| link_to "import", import_admins_accounts_path(object.id), method: 'put', remote: true }
  end

end
