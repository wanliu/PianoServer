require "rails_helper"

RSpec.describe Shops::Admin::OrdersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/shops/admins").to route_to("shops/admins#index")
    end

    it "routes to #new" do
      expect(:get => "/shops/admins/new").to route_to("shops/admins#new")
    end

    it "routes to #show" do
      expect(:get => "/shops/admins/1").to route_to("shops/admins#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/shops/admins/1/edit").to route_to("shops/admins#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/shops/admins").to route_to("shops/admins#create")
    end

    it "routes to #update" do
      expect(:put => "/shops/admins/1").to route_to("shops/admins#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/shops/admins/1").to route_to("shops/admins#destroy", :id => "1")
    end

  end
end
