class TempBirthdayParty < ActiveRecord::Base

  acts_as_paranoid column: :actived_at

  mount_uploader :active_token_qrcode, ItemImageUploader

  attr_accessor :order, :order_item, :skip_order

  belongs_to :cake, -> { with_deleted }
  belongs_to :user

  # NOTE these is a user, not a sales_man
  belongs_to :sales_man, class_name: 'User'

  belongs_to :birthday_party

  validates :cake, presence: true
  validates :sales_man, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true
  validates :delivery_address, presence: true, unless: :skip_validation
  validates :delivery_time, presence: true, unless: :skip_validation
  validates :birth_day, presence: true
  validates :delivery_region_id, presence: true, unless: :skip_validation
  validates :receiver_phone, presence: true, unless: :skip_validation
  validates :active_token, presence: true
  validates :hearts_limit, numericality: { greater_than_or_equal_to: 1 }

  before_validation :generate_active_token_qrcode, on: :create
  before_validation :generate_access_token, on: :create
  before_validation :set_hearts_limit_from_cake, on: :create

  def generate_order_and_birthday_party(buyer)
    build_order_and_order_item(buyer)

    order.save_with_items(buyer) && update_column('birthday_party_id', self.birthday_party.id) && destroy
  end

  def build_order_and_order_item(buyer)
    self.order = build_order(buyer)
    self.order_item = build_order_item(order)
    self.birthday_party = build_birthday_party(order, buyer)
  end

  def create_party_without_order(buyer)
    party = BirthdayParty.create({
      user: buyer,
      message: message,
      cake: cake,
      birth_day: birth_day,
      birthday_person: birthday_person,
      sales_man_id: sales_man_id,
      person_avatar: person_avatar,
      skip_validates: true,
      data: {
        delivery_time: delivery_time,
        delivery_address: "#{ChinaCity.get(delivery_region_id.to_s, prepend_parent: true)}#{delivery_address}",
        receiver_name: birthday_person,
        receiver_phone: receiver_phone
      }
    })

    self.birthday_party = party
  end

  def skip_validation
    skip_order
  end

  private

  def set_hearts_limit_from_cake
    self.hearts_limit = cake.hearts_limit
  end

  def build_order(buyer)
    order = Order.new({
      buyer: buyer,
      supplier: cake.shop,
      delivery_address: "#{ChinaCity.get(delivery_region_id.to_s, prepend_parent: true)}#{delivery_address}",
      receiver_name: birthday_person,
      receiver_phone: receiver_phone
    })

    order
  end

  def build_order_item(order)
    order_item = order.items.build({
      orderable: cake.item,
      quantity: quantity,
      properties: properties || {}
    })

    order_item.set_initial_attributes

    order_item
  end

  def build_birthday_party(order, buyer)
    party = order.build_birthday_party({
      user: buyer,
      message: message,
      cake: cake,
      birth_day: birth_day,
      birthday_person: birthday_person,
      delivery_time: delivery_time,
      sales_man_id: sales_man_id
    })

    party[:person_avatar] = person_avatar

    party
  end

  def generate_active_token_qrcode
    generate_active_token
    generate_qrcode
  end

  def generate_access_token
    token = nil

    loop do
      token = Devise.friendly_token
      break token unless TempBirthdayParty.where(access_token: token).first
    end

    self.access_token = token
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
    url = if skip_order then
      "#{Settings.app.website}/parties/formalize/#{active_token}"
    else
      "#{Settings.app.website}/parties/active/#{active_token}"
    end

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
