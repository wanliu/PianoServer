require 'yaml'

namespace :wechat do
  desc 'sync wechat menu to config wechat_menu.yml'
  task :sync_wechat_menu => :environment do
    menu_str = `wechat menu`.to_s
    _, last_message = menu_str.split("\n")
    menu = eval(last_message)
    File.write('config/wechat_menu.yml', menu["menu"].to_yaml)
  end

  task :update_daily_cheap_menu, [:url, :title, :top, :level] => :environment do |task, args|
    wechat_menu = YAML.load_file('config/wechat_menu.yml')
    top  = args[:top] || 0
    level = args[:level] || 1
    first_menu = wechat_menu['button'][top]
    daily_cheap = first_menu['sub_button'][level]
    title = args[:title] || "天天惠"
    if daily_cheap.nil?
      first_menu['sub_button'].push({
        "type" => "view",
        "name" => title,
        "url" => args[:url],
        "sub_button" => []
      });
    else
      daily_cheap["name"] = title
      daily_cheap["url"] = args[:url]
    end
    File.write('config/wechat_menu.yml', wechat_menu.to_yaml)
    `wechat menu_create config/wechat_menu.yml`
  end
end
