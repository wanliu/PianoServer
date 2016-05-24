require "rails_helper"

RSpec.describe CouponsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/coupons").to route_to("coupons#index")
    end

    it "routes to #new" do
      expect(:get => "/coupons/new").to route_to("coupons#new")
    end

    it "routes to #show" do
      expect(:get => "/coupons/1").to route_to("coupons#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/coupons/1/edit").to route_to("coupons#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/coupons").to route_to("coupons#create")
    end

    it "routes to #update" do
      expect(:put => "/coupons/1").to route_to("coupons#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/coupons/1").to route_to("coupons#destroy", :id => "1")
    end

  end
end
