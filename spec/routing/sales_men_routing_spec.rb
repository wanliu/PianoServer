require "rails_helper"

RSpec.describe SalesMenController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/sales_men").to route_to("sales_men#index")
    end

    it "routes to #new" do
      expect(:get => "/sales_men/new").to route_to("sales_men#new")
    end

    it "routes to #show" do
      expect(:get => "/sales_men/1").to route_to("sales_men#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/sales_men/1/edit").to route_to("sales_men#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/sales_men").to route_to("sales_men#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/sales_men/1").to route_to("sales_men#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/sales_men/1").to route_to("sales_men#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/sales_men/1").to route_to("sales_men#destroy", :id => "1")
    end

  end
end
