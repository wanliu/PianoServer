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
every '30-59/5 10-23 * * *' do
  runner "Rails.logger.info 'Whenever start clear_expired_grabs'"
  # .info 'Every Task start clear_expired_grabs'
  rake "clear_expired_grabs"
end


every '30 2 * * 0-4' do
  rake "daily_cheap:create_tomorrow"
end
