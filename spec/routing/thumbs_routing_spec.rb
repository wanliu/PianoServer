require "rails_helper"

RSpec.describe ThumbsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/thumbs").to route_to("thumbs#index")
    end

    # it "routes to #new" do
    #   expect(:get => "/thumbs/new").to route_to("thumbs#new")
    # end

    it "routes to #show" do
      expect(:get => "/thumbs/1").to route_to("thumbs#show", :id => "1")
    end

    # it "routes to #edit" do
    #   expect(:get => "/thumbs/1/edit").to route_to("thumbs#edit", :id => "1")
    # end

    it "routes to #create" do
      expect(:post => "/thumbs").to route_to("thumbs#create")
    end

    it "routes to #update" do
      expect(:put => "/thumbs/1").to route_to("thumbs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/thumbs/1").to route_to("thumbs#destroy", :id => "1")
    end

  end
end
