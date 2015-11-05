class Attachment < ActiveRecord::Base
  include Liquid::Rails::Droppable

  NAME_FORMAT = /\A[a-z_][a-zA-Z_0-9]*\z/

  belongs_to :attachable, polymorphic: true

  before_validation :format_name, on: :create

  validates :name, format: { with: NAME_FORMAT,
    message: "'%{value}' 不是一个有效名称，必须是有效的Ruby变量名称" }

  mount_uploader :filename, ImageUploader

  private

  def format_name
    unless name.match NAME_FORMAT
      self.name = "attach_#{name.gsub(/\W/, '')}"
    end
  end
end
