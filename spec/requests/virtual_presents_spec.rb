require 'rails_helper'

RSpec.describe "VirtualPresents", type: :request do
  describe "GET /virtual_presents" do
    it "works! (now write some real specs)" do
      get virtual_presents_path
      expect(response).to have_http_status(200)
    end
  end
end
