require 'rails_helper'
require 'functions/combination_images'

RSpec.describe CombinationImages, type: :job do
  include CombinationImages
  include ActiveJob::TestHelper

  let(:image_1) { Rails.root.join("spec/dummy/public/images/1.jpg") }
  let(:image_2) { Rails.root.join("spec/dummy/public/images/2.jpg") }
  let(:image_3) { Rails.root.join("spec/dummy/public/images/3.jpg") }
  let(:image_4) { Rails.root.join("spec/dummy/public/images/4.jpg") }
  let(:image_5) { Rails.root.join("spec/dummy/public/images/5.jpg") }
  let(:images_urls) { [image_1, image_2, image_3, image_4, image_5 ] }


  it "generation images algorithm 2" do 
    # time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
    # FileUtils.mkdir_p Rails.root.join('public/assets/generatings')
    # tmp = Tempfile.new(['test_' + time_str, '.jpg'], Rails.root.join('public/assets/generatings'))
    # puts "generating image file #{tmp.path}..."

    composite_images2 Rails.root.join('public/assets/generatings/output.jpg'), images_urls
    # tmp.close
    # `open #{tmp.path}`
    # tmp.unlink
  end

  it "generation images algorithm 3" do 
    # time_str = Time.now.strftime("%Y_%m_%d_%H_%M_%S")
    # FileUtils.mkdir_p Rails.root.join('public/assets/generatings')
    # tmp = Tempfile.new(['test_' + time_str, '.jpg'], Rails.root.join('public/assets/generatings'))
    # puts "generating image file #{tmp.path}..."

    composite_images3 Rails.root.join('public/assets/generatings/output.jpg'), images_urls
    # tmp.close
    # `open #{tmp.path}`
    # tmp.unlink
  end  
end
