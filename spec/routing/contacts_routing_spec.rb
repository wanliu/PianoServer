require "rails_helper"

RSpec.describe ContactsController, type: :routing do
  describe "routing" do

    # it "routes to #index" do
    #   expect(:get => "/contacts").to route_to("contacts#index")
    # end

    it "routes to #new" do
      expect(:get => "/contacts/new").to route_to("contacts#new")
    end

    it "routes to #create" do
      expect(:post => "/contacts").to route_to("contacts#create")
    end

    it "routes to #destroy" do
      expect(:delete => "/contacts/1").to route_to("contacts#destroy", :id => "1")
    end

  end
end
