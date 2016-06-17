require "rails_helper"

RSpec.describe BlessesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/blesses").to route_to("blesses#index")
    end

    it "routes to #new" do
      expect(:get => "/blesses/new").to route_to("blesses#new")
    end

    it "routes to #show" do
      expect(:get => "/blesses/1").to route_to("blesses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/blesses/1/edit").to route_to("blesses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/blesses").to route_to("blesses#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/blesses/1").to route_to("blesses#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/blesses/1").to route_to("blesses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/blesses/1").to route_to("blesses#destroy", :id => "1")
    end

  end
end
