json.(message, :id, :text, :read, :created_at, :updated_at)
json.from [message.from], :partial => "api/users/user"
