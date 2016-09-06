require 'rails_helper'

RSpec.describe "TempBirthdayParties", type: :request do
  describe "GET /temp_birthday_parties" do
    it "works! (now write some real specs)" do
      get temp_birthday_parties_path
      expect(response).to have_http_status(200)
    end
  end
end
