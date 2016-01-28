require 'rails_helper'

RSpec.describe "Thumbs", type: :request do
  describe "GET /thumbs" do
    it "works! (now write some real specs)" do
      get thumbs_path
      expect(response).to have_http_status(200)
    end
  end
end
