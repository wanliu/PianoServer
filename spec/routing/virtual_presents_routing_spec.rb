require "rails_helper"

RSpec.describe VirtualPresentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/virtual_presents").to route_to("virtual_presents#index")
    end

    it "routes to #new" do
      expect(:get => "/virtual_presents/new").to route_to("virtual_presents#new")
    end

    it "routes to #show" do
      expect(:get => "/virtual_presents/1").to route_to("virtual_presents#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/virtual_presents/1/edit").to route_to("virtual_presents#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/virtual_presents").to route_to("virtual_presents#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/virtual_presents/1").to route_to("virtual_presents#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/virtual_presents/1").to route_to("virtual_presents#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/virtual_presents/1").to route_to("virtual_presents#destroy", :id => "1")
    end

  end
end
