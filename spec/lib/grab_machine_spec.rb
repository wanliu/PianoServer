require "rails_helper"
require "grab_machine"

class GrabController < ActionController::Base
  # class AccessDenied < StandardError; end

  # rescue_from AccessDenied, :with => :access_denied

  protected

  def current_user
    PmoUser.exists?(1) ? PmoUser[1] : PmoUser.create(id: 1, username: '测试', title: '测试')
  end
end

RSpec.describe GrabController, :type => :controller do

  before :each do
    # @one_money = one_money
    # @item = item
    # @item.one_money = @one_money
    # @item.save
  end

  after :each do
    # OneMoney[1].delete
    # PmoItem[1].delete
  end

  controller do
    def index

      @one_money = one_money(params[:one_money] || {})
      @item = item(params[:item] || {})

      @item.one_money = @one_money
      @item.save

      GrabMachine.run(self, @one_money, @item) do |context|
        # pp one_money

        render nothing: true
      end
      # raise ApplicationController::AccessDenied
    end

    protected

    def one_money(attributes = {})
      OneMoney[1].try(:delete)
      OneMoney.create(attributes.merge(id: 1, name: "test", title: "test一元够"))
    end

    def item(attributes = {})
      PmoItem[1].try(:delete)
      PmoItem.create(attributes.merge(id: 1, title: "测试商品", price: 1, ori_price: 99, shop_id: 1, shop_name: "测试商店"))
    end
  end

  describe "test grab action" do
    it "empty total_amount item" do
      get :index
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("total_amount_zero")
    end

    it "total_amount less zero" do
      get :index, item: { total_amount: -1 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("total_amount_zero")
    end

    it "empty quantity item" do
      get :index, item: { total_amount: 10 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("quantity_zero")
    end

    it "empty quantity item" do
      get :index, item: { total_amount: 10,  quantity: -1 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("quantity_zero")
    end
  end
end
