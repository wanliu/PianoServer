require "rails_helper"
require "grab_machine"

class GrabController < ActionController::Base
  # class AccessDenied < StandardError; end

  # rescue_from AccessDenied, :with => :access_denied

  protected

  def current_user
    # PmoUser[1].update_attributes(params[:current_user] || {})
    PmoUser.exists?(1) ? PmoUser[1] : PmoUser.create(id: 1, username: '测试', title: '测试', user_id: 1)
  end

  def one_money(attributes = {})
    OneMoney[1].try(:delete)
    OneMoney.create({id: 1, name: "test", title: "test一元够"}.merge(attributes))
  end

  def item(attributes = {})
    PmoItem[1].try(:delete)
    PmoItem.create({id: 1, title: "测试商品", price: 1, ori_price: 99, shop_id: 1, shop_name: "测试商店"}.merge(attributes))
  end
end

RSpec.describe GrabController, :type => :controller do

  before :each do
    # OneMoney.create({id: 1, name: "test", title: "test一元够"}) # merge(attributes))
    # PmoItem.create({id: 1, title: "测试商品", price: 1, ori_price: 99, shop_id: 1, shop_name: "测试商店"})
    # PmoUser.create(id: 1, username: '测试', title: '测试', user_id: 1)
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

      GrabMachine.run(self, @one_money, @item) do |status, context|
        # pp one_money
        if status == "success"
          render nothing: true
        else
          render json: context.result, status: context.code
        end
      end
      # raise ApplicationController::AccessDenied
    end
  end

  describe "测试抢 Action" do

    it "Item 活动总量不能为 0" do
      get :index
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("total_amount_zero")
    end

    it "活动总量 不能小于 0" do
      get :index, item: { total_amount: -1 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("total_amount_zero")
    end

    it "单次计数不能为 0 " do
      get :index, item: { total_amount: 10 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("quantity_zero")
    end

    it "单次计数不能小于 0" do
      get :index, item: { total_amount: 10,  quantity: -1 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("quantity_zero")
    end

    it "活动价格可以为 0 (商议)" do
      get :index, item: { total_amount: 10,  quantity: 1, price: 0 }
      expect(response.status).to eql(200)
      # pp response.body
      # result = JSON.parse(response.body)
      # expect(result["status"]).to eql("quantity_zero")
    end

    it "但是不能大于原价" do
      get :index, item: { total_amount: 10,  quantity: 1, price: 1, ori_price: 0 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("price_too_large")
    end

    it "也不能小于 0" do
      get :index, item: { total_amount: 10,  quantity: 1, price: -1, ori_price: 0 }
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["status"]).to eql("price_zero")
    end

    describe GrabController, :type => :controller do
      controller do
        def index

          @one_money = one_money(params[:one_money] || {})
          @item = item(params[:item] || {})

          @one_money.winners.add(current_user)
          @one_money.save
          @item.winners.add(current_user)
          @item.save
          @item.one_money = @one_money
          @item.save

          GrabMachine.run(self, @one_money, @item) do |status, context|
            if status == "success"
              render nothing: true
            else
              render json: context.result, status: context.code
            end
          end
          # raise ApplicationController::AccessDenied
        end
      end

      it "用户已经赢得了奖励， 将返回 always 状态" do
        get :index, item: { total_amount: 10,  quantity: 1 }

        expect(response.status).to eql(400)
        result = JSON.parse(response.body)
        expect(result["status"]).to eql("always")
      end
    end

    describe GrabController, :type => :controller do
      controller do
        def index

          @one_money = one_money(params[:one_money] || {})
          @item = item(params[:item] || {})

          # @one_money.winners.add(current_user)
          # @one_money.save
          # @item.winners.add(current_user)
          # @item.save
          @item.one_money = @one_money
          @item.save

          GrabMachine.run(self, @one_money, @item) do |status, context|
            if status == "success"
              render nothing: true
            else
              render json: context.result, status: context.code
            end
          end
          # raise ApplicationController::AccessDenied
        end

        def show
          @one_money = one_money(params[:one_money] || {})
          @item = item(params[:item] || {})
          @item.incr :completes, 10
          # @one_money.winners.add(current_user)
          # @one_money.save
          # @item.winners.add(current_user)
          # @item.save
          @item.one_money = @one_money
          @item.save

          GrabMachine.run(self, @one_money, @item) do |status, context|
            if status == "success"
              render nothing: true
            else
              render json: context.result, status: context.code
            end
          end
        end
      end

      it "抢，用户就赢得奖励" do
        get :index, item: { total_amount: 10,  quantity: 1 }

        expect(response.status).to eql(200)
      end

      it "活动库存不足时，用户不能抢到奖励" do
        get :index, item: { total_amount: 10, quantity: 11 }

        expect(response.status).to eql(500)
        result = JSON.parse(response.body)
        expect(result["status"]).to eql("insufficient")
      end

      it "设置 完成量(completes) 也会导致库存不足(completes + quantity > total_amount)" do
        get :show, id: 1, item: { total_amount: 20, quantity: 11 }

        expect(response.status).to eql(500)
        result = JSON.parse(response.body)
        expect(result["status"]).to eql("insufficient")
      end

      it "但是库存充足时也没问题 (completes + quantity < total_amount)" do
        get :show, id: 1, item: { total_amount: 20, quantity: 2 }

        expect(response.status).to eql(200)
      end

      # it "item multiple support" do
      #   get :index, one_money: {multi_item: 2 }, item: { total_amount: 10,  quantity: 1 }
      #   expect(response.status).to eql(422)
      #   result = JSON.parse(response.body)
      #   expect(result["status"]).to eql("price_zero")
      # end
    end
  end
end
