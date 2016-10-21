require 'rails_helper'

RSpec.describe "SalesMen", type: :request do
  describe "GET /sales_men" do
    it "works! (now write some real specs)" do
      get sales_men_path
      expect(response).to have_http_status(200)
    end
  end
end
