require "rails_helper"

RSpec.describe PromotionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/promotions").to route_to("promotions#index")
    end

    it "routes to #new" do
      expect(:get => "/promotions/new").to route_to("promotions#new")
    end

    it "routes to #show" do
      expect(:get => "/promotions/1").to route_to("promotions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/promotions/1/edit").to route_to("promotions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/promotions").to route_to("promotions#create")
    end

    it "routes to #update" do
      expect(:put => "/promotions/1").to route_to("promotions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/promotions/1").to route_to("promotions#destroy", :id => "1")
    end

  end
end
