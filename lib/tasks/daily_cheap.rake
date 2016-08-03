namespace :daily_cheap do
  desc "create a daily cheap"
  task :create_tomorrow => :environment do |task, args|
    create_daily_cheap DateTime.now + 1.day, false
  end

  def create_daily_cheap(date, overwrite = true)
    title_template = Settings.promotions.daily_cheap.title_template.dup

    unless overwrite
      OneMoney.all.reverse_each do |one| 
        exit if one.start_at.to_date == date.to_date
      end
    end
    # title = I18n.l(date) + ' 天天惠'
    start_hour = Settings.promotions.daily_cheap.start_hour || 10
    end_hour =  Settings.promotions.daily_cheap.end_hour || 22
    start_at = date.change(hour: start_hour, min: 0, sec: 0)
    end_at = date.change(hour: end_hour, min: 0, sec: 0)

    context = {
      year: date.year,
      month: "%02d" % date.month,
      day: "%02d" % date.day,
      weekday: I18n.l(date, :format => '%A'),
      start_hour: "%02d" % start_hour,
      start_minute: "%02d" % start_at.minute,
      end_hour: "%02d" % end_hour,
      end_minute: "%02d" %  end_at.minute
    }

    title = title_template.gsub /\$(\w+)/ do |m|
      key = $1.to_sym
      context[key]
    end

    options = {
      multi_item: Settings.promotions.daily_cheap.multi_item || 1,
      fare: Settings.promotions.daily_cheap.fare || 10,
      max_free_fare: Settings.promotions.daily_cheap.max_free_fare || 58.0,
      callback: Settings.promotions.daily_cheap.default_callback || "http://m.wanliu.biz/orders/yiyuan_confirm"
    }
    daily_cheap = OneMoney.create({:title => title, :type => :daily_cheap, :start_at => start_at, :end_at => end_at}.merge(options))
    name = "%04d-%02d-%02d" % [start_at.year, start_at.month, start_at.day]
    OneMoneyPublishWorker.perform_async daily_cheap.id, name, type: :daily_cheap
  end
end
