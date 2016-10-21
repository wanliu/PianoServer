module BirthdayPartyHelper
  def birthday_party_path(birthday_party, bless_id=nil)
    birthday_party_id = if birthday_party.is_a? BirthdayParty
      birthday_party.id
    else
      birthday_party
    end

    path = "/cake_party/#/party/#{birthday_party_id}"

    if bless_id.present?
      path << "#bless:{bless_id}#"
    end

    path
  end
end
