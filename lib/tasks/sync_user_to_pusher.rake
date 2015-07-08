namespace :db do
  desc "sync user to puhser server."
  task :sync_pusher_users => :environment do |task, args|
    pusher_url = Settings.pusher.pusher_url
    pusher_token = Settings.pusher.pusher_token
    pusher_url << 'users'
    User.all.each do |user|
      options = {id: "w#{user.id}", token: pusher_token, login: user.username, realname: user.username, avatar_url: (user.image && user.image[:avatar_url]) }
      RestClient.post pusher_url, options
    end
  end
end
