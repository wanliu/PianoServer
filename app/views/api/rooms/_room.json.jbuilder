json.(room, :id, :name, :messages)
json.owner [room.owner], partial: "api/users/user"
json.target [room.target], partial: "api/users/user"
json.messages room.messages, partial: "api/messages/message", as: :message
