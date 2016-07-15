module BirthdayPartyHelper
  def birthday_party_path(birthday_party, virtual_present_name=nil)
    birthday_party_id = if birthday_party.is_a? BirthdayParty
      birthday_party.id
    else
      birthday_party
    end

    path = "/cake_party/#/party/#{birthday_party_id}"

    if virtual_present_name.present?
      path << "/##{virtual_present_name}"
    end

    path
  end
end