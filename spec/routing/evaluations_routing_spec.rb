require "rails_helper"

RSpec.describe EvaluationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/evaluations").to route_to("evaluations#index")
    end

    it "routes to #show" do
      expect(:get => "/evaluations/1").to route_to("evaluations#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/evaluations").to route_to("evaluations#create")
    end
  end
end
