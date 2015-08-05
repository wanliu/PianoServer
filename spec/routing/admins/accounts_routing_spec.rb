require "rails_helper"

RSpec.describe Admins::AccountsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admins/accounts").to route_to("admins/accounts#index")
    end

    it "routes to #new" do
      expect(:get => "/admins/accounts/new").to route_to("admins/accounts#new")
    end

    it "routes to #show" do
      expect(:get => "/admins/accounts/1").to route_to("admins/accounts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admins/accounts/1/edit").to route_to("admins/accounts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admins/accounts").to route_to("admins/accounts#create")
    end

    it "routes to #update" do
      expect(:put => "/admins/accounts/1").to route_to("admins/accounts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/admins/accounts/1").to route_to("admins/accounts#destroy", :id => "1")
    end

  end
end
