require "rails_helper"

RSpec.describe TempBirthdayPartiesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/temp_birthday_parties").to route_to("temp_birthday_parties#index")
    end

    it "routes to #new" do
      expect(:get => "/temp_birthday_parties/new").to route_to("temp_birthday_parties#new")
    end

    it "routes to #show" do
      expect(:get => "/temp_birthday_parties/1").to route_to("temp_birthday_parties#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/temp_birthday_parties/1/edit").to route_to("temp_birthday_parties#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/temp_birthday_parties").to route_to("temp_birthday_parties#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/temp_birthday_parties/1").to route_to("temp_birthday_parties#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/temp_birthday_parties/1").to route_to("temp_birthday_parties#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/temp_birthday_parties/1").to route_to("temp_birthday_parties#destroy", :id => "1")
    end

  end
end
