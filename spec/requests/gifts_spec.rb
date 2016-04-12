require 'rails_helper'

RSpec.describe "Gifts", type: :request do
  describe "GET /gifts" do
    it "works! (now write some real specs)" do
      get gifts_path
      expect(response).to have_http_status(200)
    end
  end
end
