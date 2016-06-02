require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe "class methods" do
    describe "available_with_shop 列出对商店适用的购物卷" do
      let(:shop) { FactoryGirl.create(:shop) }
      let(:shop_include) { FactoryGirl.create(:shop) }
      let(:shop_include2) { FactoryGirl.create(:shop) }
      let(:shop_exclude) { FactoryGirl.create(:shop) }

      let(:coupon_template_shop) { FactoryGirl.build(:coupon_template_shop, shop_id: shop.id) }
      let(:coupon_template_shop_include) { FactoryGirl.build(:coupon_template_shop, shop_id: shop_include.id) }
      let(:coupon_template_shop_include2) { FactoryGirl.build(:coupon_template_shop, shop_id: shop_include2.id) }
      let(:coupon_template_shop_exclude) { FactoryGirl.build(:coupon_template_shop, shop_id: shop_exclude.id) }

      let(:coupon_template_all_shop) { FactoryGirl.create(:coupon_template, issuer_type: 'System', apply_shops: CouponTemplate.apply_shops["all_shops"]) } 
      let(:coupon_template_include_shop) { FactoryGirl.create(:coupon_template, issuer_type: 'System', apply_shops: CouponTemplate.apply_shops["include_shops"], coupon_template_shops: [coupon_template_shop_include]) } 
      let(:coupon_template_include_shop2) { FactoryGirl.create(:coupon_template, issuer_type: 'System', apply_shops: CouponTemplate.apply_shops["include_shops"], coupon_template_shops: [coupon_template_shop_include2]) } 
      let(:coupon_template_exclude_shop) { FactoryGirl.create(:coupon_template, issuer_type: 'System', apply_shops: CouponTemplate.apply_shops["exclude_shops"], coupon_template_shops: [coupon_template_shop_exclude]) } 

      let!(:coupon) { FactoryGirl.create(:coupon, coupon_template: coupon_template_all_shop) }
      let!(:coupon_include) { FactoryGirl.create(:coupon, coupon_template: coupon_template_include_shop) }
      let!(:coupon_include2) { FactoryGirl.create(:coupon, coupon_template: coupon_template_include_shop2) }
      let!(:coupon_exclude) { FactoryGirl.create(:coupon, coupon_template: coupon_template_exclude_shop) }

      it "包含设置了所有商店可用的购物卷" do
        shop_id = shop_include.id
        coupons = Coupon.available_with_shop(shop_id)
        expect(coupons).to include(coupon)
      end

      it "包含设置了白名单，且本商店在白名单中的购物卷" do
        shop_id = shop_include.id
        coupons = Coupon.available_with_shop(shop_id)
        expect(coupons).to include(coupon_include)
      end

      it "排除设置了白名单，但白名单中不包含本商店的购物卷" do
        shop_id = shop_include.id
        coupons = Coupon.available_with_shop(shop_id)
        expect(coupons).not_to include(coupon_include2)
      end

      it "包含设置了黑名单，但是黑名单不包括本商店的购物卷" do
        shop_id = shop_include.id
        coupons = Coupon.available_with_shop(shop_id)
        expect(coupons).to include(coupon_include)
      end

      it "排除设置了黑名单，且将本商店列入黑名单的购物卷" do
        shop_id = shop_exclude.id
        coupons = Coupon.available_with_shop(shop_id)
        expect(coupons).not_to include(coupon_exclude)
      end
    end
  end
end
