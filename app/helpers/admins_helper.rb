module AdminsHelper

  def admins_object(object)
    [ :admins, *@parents, object ]
  end
end
