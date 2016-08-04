require 'rails_helper'

RSpec.describe BirthdayParty, type: :model do
  describe "build_unwithdrew_redpacks" do
    let!(:party) { FactoryGirl.create(:birthday_party) }
    let!(:virtual_present) { FactoryGirl.create(:virtual_present, value: 708, price: 2000) }
    let!(:bless) { FactoryGirl.create(:bless, virtual_present: virtual_present, birthday_party: party, paid: true) }

    it "为没有被分发到红包的余额创建红包，以单个红包最大金额为200进行切割" do
      expect {
        party.order.finish!
        party.send(:build_unwithdrew_redpacks)
      }.to change{ party.redpacks.count }.by(4)

      values = party.redpacks(true).map do |redpack|
        redpack.amount.to_f
      end

      expect(values).to eq([200, 200, 200, 108])
    end

    it "更新withdrew的值" do
      party.order.finish!
      party.send(:build_unwithdrew_redpacks)

      expect(party.withdrew).to eq(708)
    end
  end

  # describe "send_unsent_redpacks" do
  #   let!(:party) { FactoryGirl.create(:birthday_party) }
  #   let!(:virtual_present) { FactoryGirl.create(:virtual_present, value: 708, price: 2000) }
  #   let!(:bless) { FactoryGirl.create(:bless, virtual_present: virtual_present, birthday_party: party, paid: true) }

  #   it "对那些没有发送成功的红包，进行发送操作" do
  #     party.build_unwithdrew_redpacks

  #     Redpack.any_instance.should_receive(:send_redpack)

  #     party.order.finish!
  #     party.send_unsent_redpacks
  #   end

  #   it "对那些已经发送成功的红包，不会进行发送操作" do
  #     expect {

  #     }.not_to receive()

  #     party.order.finish!
  #     party.send_unsent_redpacks
  #   end
  # end
end
