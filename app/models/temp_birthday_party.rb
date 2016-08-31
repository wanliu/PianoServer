class TempBirthdayParty < ActiveRecord::Base

  mount_uploader :active_token_qrcode, ItemImageUploader

  belongs_to :cake, -> { with_deleted }
  belongs_to :user
  belongs_to :sales_man

  validates :cake, presence: true
  validates :sales_man, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true
  validates :delivery_address, presence: true
  validates :delivery_time, presence: true
  validates :birth_day, presence: true
  validates :delivery_region_id, presence: true
  validates :receiver_phone, presence: true
  validates :active_token, presence: true
  validates :hearts_limit, numericality: { greater_than_or_equal_to: 1 }

  before_validation :generate_active_token_qrcode, on: :create
  before_validation :set_hearts_limit_from_cake, on: :create

  def generate_order_and_birthday_party(buyer)
    @order = generate_order(buyer)
    @party = generate_birthday_party(@order, buyer)

    @order.save_with_items(buyer) && destroy
  end

  private

  def set_hearts_limit_from_cake
    self.hearts_limit = cake.hearts_limit
  end

  def generate_order(buyer)
    order = Order.new({
      buyer: buyer, 
      supplier: cake.shop, 
      delivery_address: delivery_address, 
      receiver_name: birthday_person, 
      receiver_phone: receiver_phone
    })

    order_item = order.items.build({
      orderable: cake.item,
      quantity: quantity
    })

    order_item.set_initial_attributes

    order
  end

  def generate_birthday_party(order, buyer)
    party = order.build_birthday_party({
      user: buyer, 
      message: message, 
      cake: cake, 
      birth_day: birth_day, 
      birthday_person: birthday_person,
      delivery_time: delivery_time
    })
    
    party[:person_avatar] = person_avatar

    party
  end

  def generate_active_token_qrcode
    generate_active_token
    generate_qrcode
  end

  def generate_active_token
    token = nil

    loop do
      token = Devise.friendly_token
      break token unless TempBirthdayParty.where(active_token: token).first
    end

    self.active_token = token
  end

  def generate_qrcode
    url = "#{Settings.app.website}/parties/active/#{active_token}"

    qrcode = RQRCode::QRCode.new(url)

    # With default options specified explicitly
    png = qrcode.as_png(
              resize_gte_to: false,
              resize_exactly_to: false,
              fill: 'white',
              color: 'black',
              size: 120,
              border_modules: 4,
              module_px_size: 6,
              file: nil # path to write
              )

    File.open("/tmp/#{active_token}.temppartytoken.png", 'wb') do |file|
      file.write png.to_s

      self.active_token_qrcode = file
    end
  end
end
