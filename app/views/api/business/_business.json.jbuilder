json.(business, :id, :client_script, :title, :action, :type, :started_at,
  :image, :resolved_at, :created_at, :updated_at)
json.started_by [business.started_by], :partial => "api/users/user" if business.started_by.present?
json.resolved_by [business.resolved_by], :partial => "api/users/user" if business.resolved_by.present?

json.matchers business.matchers, partial: "api/users/user", as: :user
json.participants business.participants, partial: "api/users/user", as: :user
json.items business.items, partial: "api/items/item", as: :item

json.matchers_count business.matchers.count
json.participants_count business.participants.count
