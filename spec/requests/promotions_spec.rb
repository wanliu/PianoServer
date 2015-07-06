require 'rails_helper'

RSpec.describe "Promotions", type: :request do
  describe "GET /promotions" do
    it "works! (now write some real specs)" do
      get promotions_path
      expect(response).to have_http_status(200)
    end
  end
end
