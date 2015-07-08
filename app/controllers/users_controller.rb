class UsersController < ApplicationController
  def anonymous
    anonymous_id = "-w#{Time.now.to_i}.#{rand(10000)}"
    anonymous_token = JWT.encode({id: anonymous_id}, User::JWT_TOKEN)

    render json: { id: anonymous_id, chat_token: anonymous_token }
  end
end
