# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, {:error => 'error.log', :standard => 'cron.log'}
job_type :rake, "cd :path && :environment_variable=:environment SECRET_KEY_BASE=XXX bundle exec rake :task --silent :output"
job_type :runner,  "cd :path && SECRET_KEY_BASE=XXX bin/rails runner -e :environment ':task' :output"

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every 3.minutes, :at => '10:30' do
  runner "Rails.logger.info 'Whenever start clear_expired_grabs'"
  # .info 'Every Task start clear_expired_grabs'
  rake "clear_expired_grabs"
end


every :day, :at => '2:30' do
  code = <<-RUBY
    tomorrow = DateTime.now + 1.day
    title = I18n.l(tomorrow) + ' 天天惠'
    start_hour = Settings.promotions.daily_cheap.start_hour || 10
    end_hour =  Settings.promotions.daily_cheap.end_hour || 22
    start_at = tomorrow.change(hour: start_hour, min: 0, sec: 0)
    end_at = tomorrow.change(hour: end_hour, min: 0, sec: 0)
    options = {
      multi_item: Settings.promotions.daily_cheap.multi_item || 1,
      fare: Settings.promotions.daily_cheap.fare || 10,
      max_free_fare: Settings.promotions.daily_cheap.max_free_fare || 58.0,
      callback: Settings.promotions.daily_cheap.default_callback || "http://m.wanliu.biz/orders/yiyuan_confirm"
    }
    OneMoney.create({:title => title, :type => :daily_cheap, :start_at => start_at, :end_at => end_at}.merge(options))
  RUBY
  runner code
end
