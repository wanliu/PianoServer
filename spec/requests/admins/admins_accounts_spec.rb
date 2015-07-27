require 'rails_helper'

RSpec.describe "Admins::Accounts", type: :request do
  describe "GET /admins_accounts" do
    it "works! (now write some real specs)" do
      get admins_accounts_path
      expect(response).to have_http_status(200)
    end
  end
end
