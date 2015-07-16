require 'rails_helper'

RSpec.describe CombinationImagesJob, type: :job do
  let(:order) { Order.create }
  let(:image_1) { { avatar_url: Rails.root.join("spec/dummy/public/images/1.jpg") } }
  let(:image_2) { { avatar_url: Rails.root.join("spec/dummy/public/images/2.jpg") } }
  let(:image_3) { { avatar_url: Rails.root.join("spec/dummy/public/images/3.jpg") } }
  let(:image_4) { { avatar_url: Rails.root.join("spec/dummy/public/images/1.jpg") } }
  let(:image_5) { { avatar_url: Rails.root.join("spec/dummy/public/images/1.jpg") } }


  it "generation images" do 
    order.items.create(image: { avatar_url: Rails.root.join("spec/dummy/public/images/1.jpg") })
  end
end
