#!/usr/bin/env ruby

# set -e

# while read p; do
#   wechat custom_text $p "今日活动 10:00 开始，点击参与 http://m.wanliu.biz/daily_cheap/2016-05-23/" || true
# done < ~/Desktop/id.txt
require 'thread'

queue = Queue.new

news = ARGF.argv[0]


# producer = Thread.new do
output = `wechat users`
code = eval(output[('Using rails project config/wechat.yml default setting...'.length..-1)])
openids = code["data"]["openid"]
# openids = ["oKev-v4GiZS5ayocmIQVKKACK89k", "oKev-vxY1nr3oUsbbhdOP3zvRE88" ]

openids.each do |id|
  queue << id
  puts "#{id} produced"
end
# end

threads = []

30.times do
  threads << Thread.new do
    # loop until there are no more things to do
    until queue.empty?
      # pop with the non-blocking flag set, this raises
      # an exception if the queue is empty, in which case
      # work_unit will be set to nil
      id = queue.pop(true) rescue nil
      if id
        puts "#{id} command"
        `wechat custom_news #{id} #{news}`
      end
    end
    # when there is no more work, the thread will stop
  end
end

threads.each { |t| t.join }

# openids.each do |id|
#   `wechat custom_news #{id} #{news}`
# end
