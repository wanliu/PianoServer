require "rails_helper"

RSpec.describe GiftsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/gifts").to route_to("gifts#index")
    end

    it "routes to #new" do
      expect(:get => "/gifts/new").to route_to("gifts#new")
    end

    it "routes to #show" do
      expect(:get => "/gifts/1").to route_to("gifts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/gifts/1/edit").to route_to("gifts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/gifts").to route_to("gifts#create")
    end

    it "routes to #update" do
      expect(:put => "/gifts/1").to route_to("gifts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/gifts/1").to route_to("gifts#destroy", :id => "1")
    end

  end
end
