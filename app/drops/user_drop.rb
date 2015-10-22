class UserDrop < Liquid::Rails::Drop
  attributes :id, :username, :mobile, :image, :nickname, :sex

  def shop_id
    object.try(:shop_id)
  end
end
