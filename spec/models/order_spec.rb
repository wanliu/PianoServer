require 'rails_helper'

RSpec.describe Order, type: :model do

  describe "class methods" do
    let!(:order) { FactoryGirl.create(:order) }

    describe "to_spreadsheet" do
      it "should works" do
        temp_sheet = StringIO.new
        expect(Order.count).to be > 0
        expect(Order.limit(1).to_spreadsheet).to be_a(Spreadsheet::Workbook)
      end
    end
  end
end
