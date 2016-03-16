require "rails_helper"

RSpec.describe SuggestionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/suggestions").to route_to("suggestions#index")
    end

    it "routes to #new" do
      expect(:get => "/suggestions/new").to route_to("suggestions#new")
    end

    it "routes to #show" do
      expect(:get => "/suggestions/1").to route_to("suggestions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/suggestions/1/edit").to route_to("suggestions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/suggestions").to route_to("suggestions#create")
    end

    it "routes to #update" do
      expect(:put => "/suggestions/1").to route_to("suggestions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/suggestions/1").to route_to("suggestions#destroy", :id => "1")
    end

  end
end
