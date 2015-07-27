class ContactTable < TableCloth::Base
  column :id, :name, :mobile, :message, :created_at

  column :id do |object|
    [object.id, class: "contact-#{object.id}" ]
  end

  actions do
    action {|object| link_to "处理", admins_contact_path(object), method: 'PUT', remote: true}
    # action(if: :valid?) {|object| link_to "Invalidate", invalidate_object_path(object) }
  end
end
