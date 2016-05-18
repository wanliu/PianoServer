require 'rails_helper'

RSpec.describe Order, type: :model do

  describe "class methods" do
    let!(:order) { FactoryGirl.build(:solo_order) }
    
    describe "to_spreadsheet" do
      it "should works" do
        order.save(validate: false)
        expect(Order.count).to eq(1)
        expect(Order.limit(1).to_spreadsheet).to be_a(Spreadsheet::Workbook)
      end
    end

  end

  describe "validations" do
    let(:solo_order) { FactoryGirl.build(:solo_order) }
    let(:order) { FactoryGirl.create(:order) }
    let(:user) { FactoryGirl.create(:user) }

    it "should not be saved if no order items exist" do
      expect(solo_order).not_to be_valid
      expect(solo_order.errors).to have_key(:base)
      expect(solo_order.errors[:base]).to be_any { |error_msg| error_msg =~ /订单中没有商品/}
    end

    it "can not buy items from buyer's own shop" do
      solo_order.supplier_id = solo_order.buyer_id = user.id
      expect(solo_order).not_to be_valid
      expect(solo_order.errors).to have_key(:supplier_id)
      expect(solo_order.errors[:supplier_id]).to be_any { |error_msg| error_msg =~ /不能购买自己店里的商品/}
    end

    it "can not mofify total if order finished" do
      order.finish!
      expect(order).to be_valid
      order.total = order.total + 1

      expect(order).not_to be_valid
      expect(order.errors).to have_key(:base)
      expect(order.errors[:base]).to be_any { |err_msg| err_msg =~ /不能修改订单总价/ }
    end

    it "can not mofify total if order paid" do
      order.paid = true
      expect(order).to be_valid
      order.total = order.total + 1

      expect(order).not_to be_valid
      expect(order.errors).to have_key(:base)
      expect(order.errors[:base]).to be_any { |err_msg| err_msg =~ /不能修改订单总价/ }
    end

    it "status can not be changed from finish to initated" do
      order.finish!
      expect(order).to be_valid

      order.update(status: :initiated)
      expect(order).not_to be_valid
      expect(order.errors).to have_key(:base)
      expect(order.errors[:base]).to be_any { |err_msg| err_msg =~ /错误的操作/ }
    end
  end

  describe "composed value readers/writers" do
    describe "cart_item_gifts= method 用于实现购物车订单确定" do
      let(:shop) { FactoryGirl.create(:shop) }
      let(:cart_item) { FactoryGirl.create(:cart_item) }
      let(:solo_order) { FactoryGirl.build(:solo_order) }
      let(:present) { FactoryGirl.create(:item, shop: cart_item.cartable.shop) }
      let(:gift) { FactoryGirl.create(:gift, item: cart_item.cartable, present: present) }

      it "set up cart_item_ids" do
        cart_item_gifts = {}

        cart_item_gifts[cart_item.id] = {}

        solo_order.cart_item_gifts = cart_item_gifts

        expect(solo_order.cart_item_ids).to eq([cart_item.id])
      end

      it "set up order items and it's gifts to order" do
        cart_item_gifts = {}
        cart_item_gifts[cart_item.id] = {gift.id.to_s => 1}

        solo_order.cart_item_gifts = cart_item_gifts

        expect(solo_order.items).to be_present

        order_item = solo_order.items.first

        expect(order_item.price).to          eq(cart_item.price)
        expect(order_item.quantity).to       eq(cart_item.quantity)
        expect(order_item.title).to          eq(cart_item.title)
        expect(order_item.orderable_type).to eq(cart_item.cartable_type)
        expect(order_item.orderable_id).to   eq(cart_item.cartable_id)
        expect(order_item.properties).to     eq(cart_item.properties)
      end

      it "set up order item's gifts to order" do
        gift_options = {gift.id.to_s => 1}
        cart_item_gifts = {cart_item.id => gift_options}

        solo_order.cart_item_gifts = cart_item_gifts

        expect(solo_order.items).to be_present

        order_item = solo_order.items.first

        gift_setting = order_item.gifts.first

        expect(gift_setting["gift_id"]).to eq(gift.id.to_s)
        expect(gift_setting["item_id"]).to eq(present.id.to_s)
        expect(gift_setting["quantity"]).to eq('1')
      end
    end

    describe "item_gifts= method 用于实现立即购买" do

    end
  end
end