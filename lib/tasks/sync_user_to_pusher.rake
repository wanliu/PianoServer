namespace :db do
  desc "sync user to puhser server."
  task :sync_pusher_users => :environment do |task, args|
    pusher_url = Settings.pusher.pusher_url
    pusher_token = Settings.pusher.pusher_token
    pusher_url << 'users'
    User.all.each do |user|
      options = {id: "#{user.id}", token: pusher_token, login: user.username, sms_forward: user.sms_forward?,
          realname: user.username, avatar_url: user.avatar_url, mobile: user.mobile }

      if user.owner_shop.present?
        options.merge! shop_name: user.owner_shop.title
      end

      RestClient.post pusher_url, options
    end
  end
end
