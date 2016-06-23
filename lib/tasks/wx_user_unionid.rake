require 'rest-client'

namespace :wechat do
  desc 'sync wechat menu to config wechat_menu.yml'
  task :get_user_union_id => :environment do
    appid = Settings.weixin.app_id
    secret = Settings.weixin.secret

    puts appid, secret

    if appid.blank? || secret.blank?
      puts "ERROR: appid and secret needed!"
      return
    end

    frash_token_url = %Q(https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret})

    puts "正在刷新微信token..."

    r = RestClient::Request.execute({ method: :get, url:frash_token_url })
    access_token = JSON.parse(r)["access_token"]

    puts "获得token:#{access_token}"

    limit, page = 100, 1
    finish = false

    get_users_info_url = %Q(https://api.weixin.qq.com/cgi-bin/user/info/batchget?access_token=#{access_token})

    puts "开始请求用户数据..., url: #{get_users_info_url}"

    while !finish do
      payload = {user_list: []}

      fetch_limit, offset = limit * page, (page-1) * limit

      users = User.where("data ? 'weixin_openid'").limit(fetch_limit).offset(offset)

      if users.blank?
        finish = true
        break
      end

      users.each do |user|
        payload[:user_list] << { openid: user.data["weixin_openid"], lang: "zh-CN" }
      end

      puts "params: #{payload.to_json}"

      rs = RestClient::Request.execute({
        method: :post,
        url: get_users_info_url,
        payload: payload.to_json
      })

      user_list = JSON.parse(rs)["user_info_list"]

      if user_list.present?
        user_list.each do |user_infor|
          openid = user_infor["openid"]
          user = User.find_by("data @> ?", {weixin_openid: openid}.to_json)

          if user.present?
            user.data["weixin_unionid"] = user_infor["unionid"]
            user.save
          end
        end
      else
        puts "开始请求用户数据失败, 原因:#{JSON.parse(rs)["errmsg"]}, ERROR CODE: #{JSON.parse(rs)["errcode"]}", "任务失败!!"

        finish = true
        break
      end
    end
  end
end