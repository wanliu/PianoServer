require 'rails_helper'

RSpec.describe "Blesses", type: :request do
  describe "GET /blesses" do
    it "works! (now write some real specs)" do
      get blesses_path
      expect(response).to have_http_status(200)
    end
  end
end
