class ErrorRecord < ActiveRecord::Base
  # after_create :send_notification

  private

  def send_notification
    mobiles = Settings.error_receivers

    if mobiles.present? && Rails.env.production?
      mobiles.each do |mobile|
        NotificationSender.delay.send_sms("mobile" => mobile, "text" => name)
      end
    end
  end
end
