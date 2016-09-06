require 'net/http'

class WxAvatarDownloader
  include Sidekiq::Worker

  def self.download(party)
    # perform_async(party)
    new.perform(party)
  end

  def perform(birthday_party_id)
    birthday_party = if birthday_party_id.is_a? BirthdayParty
      birthday_party_id
    else
      BirthdayParty.find(birthday_party_id)
    end

    if birthday_party.avatar_media_id.blank?
      Rails.logger.error "ID为 '#{birthday_party_id}' 的生日趴的属性为空，无法下载微信媒体！"
      return
    end

    media_url = wx_media_download_url(birthday_party.avatar_media_id)

    wx_uri = URI(media_url)
    r = Net::HTTP.get_response(wx_uri)

    # 正确情况下的返回HTTP头如下：
    # HTTP/1.1 200 OK
    # Connection: close
    # Content-Type: image/jpeg 
    # Content-disposition: attachment; filename="MEDIA_ID.jpg"
    # Date: Sun, 06 Jan 2013 10:20:18 GMT
    # Cache-Control: no-cache, must-revalidate
    # Content-Length: 339721

    if "200" == r.code && r.to_hash["content-disposition"].present?
      disposition = r.to_hash["content-disposition"][0]
      if disposition.present?
        start_str = end_str = "\""
        file_name = disposition[/#{start_str}(.*?)#{end_str}/m, 1]

        File.open("/tmp/#{file_name}", 'wb') do |file|
          file.write r.body

          if birthday_party.persisted?
            birthday_party.person_avatar = file

            saved = birthday_party.save

            result = saved ? "成功" : "失败"
            Rails.logger.info "ID为 '#{birthday_party.id}' 的生日趴下载微信媒体#{result}！ #{birthday_party.errors.full_messages.join(', ')}"
          else
            uploader = ItemImageUploader.new(birthday_party, :person_avatar)
            uploader.store! file
            birthday_party[:person_avatar] = uploader.filename
          end
        end
      end
    else
      Rails.logger.error "微信下载图片失败！#{r.body}"
    end

    birthday_party
  end

  def wx_media_download_url(media_id)
    %Q(http://file.api.weixin.qq.com/cgi-bin/media/get?access_token=#{access_token}&media_id=#{media_id})
  end

  def access_token
    Wechat.api.access_token.token
  end
end