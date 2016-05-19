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

        expect(gift_setting["gift_id"]).to eq(gift.id)
        expect(gift_setting["item_id"]).to eq(present.id)
        expect(gift_setting["quantity"]).to eq(1)
      end
    end

    describe "item_gifts= and items_attributes= method 用于实现立即购买的礼品提交" do
      let(:shop) { FactoryGirl.create(:shop) }
      let(:solo_order) { FactoryGirl.build(:solo_order) }
      let(:present) { FactoryGirl.create(:item, shop: shop) }
      let(:item) { FactoryGirl.create(:item, shop: shop) }
      let(:gift) { FactoryGirl.create(:gift, item: item, present: present) }

      # "items_attributes"=>{"0"=>{"orderable_type"=>"Item", "orderable_id"=>"19", "quantity"=>"2"}}, 
      # "item_gifts"=>{"19"=>{"1"=>"1"}}
      it "asign order's order_items, and gifts to order's item gifts attrbute" do

        solo_order.items_attributes = {
          "0" => {orderable_id: item.id, orderable_type: "Item", quantity: 1}
        }

        solo_order.item_gifts = {item.id.to_s => {gift.id.to_s => 1}}

        expect(solo_order.items).to be_present

        order_item = solo_order.items.first
        expect(order_item.gifts).to be_present

        gift_setting = order_item.gifts.first
        expect(gift_setting["gift_id"]).to eq(gift.id)
        expect(gift_setting["item_id"]).to eq(present.id)
        expect(gift_setting["quantity"]).to eq(1)
      end
    end

    describe "address_id= 用于拷贝送货地址" do
      let(:location) { FactoryGirl.create(:location) }
      let(:solo_order) { FactoryGirl.build(:solo_order) }
      before { solo_order.address_id = location.id }

      it "copy location's address to order's delivery_address" do
        expect(solo_order.delivery_address).to eq(location.delivery_address_without_phone)
      end

      it "copy location's contact to order's receiver_name" do
        expect(solo_order.receiver_name).to eq(location.contact)
      end

      it "copy location's contact_phone to order's receiver_phone" do
        expect(solo_order.receiver_phone).to eq(location.contact_phone)
      end
    end
  end

  describe "Order Create methods" do
    describe "save_with_items" do
      let(:cart_item) { FactoryGirl.create(:cart_item) }
      let(:operator) { FactoryGirl.create(:user) }
      let(:order) { FactoryGirl.build(:order) }
      let(:present) { FactoryGirl.create(:item, shop: cart_item.cartable.shop) }
      let(:gift) { FactoryGirl.create(:gift, item: cart_item.cartable, present: present) }
      let(:location) { FactoryGirl.create(:location) }

      it "destroy cart items from order's cart_item_ids, if cart_item_ids exists" do
        order.cart_item_ids = [cart_item.id]

        expect {
          order.save_with_items(operator)
        }.to change { CartItem.count }.by(-1)
      end

      it "caculate express fee of the order and assign it to order's express_fee attribute if address_id present" do 
        order.cart_item_ids = [cart_item.id]
        order.address_id = location.id

        expect_any_instance_of(Item).to receive(:express_fee).and_return(10)
        order.save_with_items(operator)
      end

      it "deduct inventory of the gifts and items sold in order" do
        order.cart_item_ids = [cart_item.id]

        expect {
          order.save_with_items(operator)
        }.to change { StockChange.count }.by(1)
      end

      it "deduct inventory of the gifts" do
        cart_item_gifts = {}
        cart_item_gifts[cart_item.id] = {gift.id.to_s => 1}

        order.cart_item_gifts = cart_item_gifts

        expect {
          order.save_with_items(operator)
        }.to change { StockChange.count }.by(2)
      end
    end
  end
end