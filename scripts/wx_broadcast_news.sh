#!/usr/bin/env ruby

# set -e

# while read p; do
#   wechat custom_text $p "今日活动 10:00 开始，点击参与 http://m.wanliu.biz/daily_cheap/2016-05-23/" || true
# done < ~/Desktop/id.txt

news = ARGF.argv[0]

output = `wechat users`
code = eval(output[('Using rails project config/wechat.yml default setting...'.length..-1)])
openids = code["data"]["openid"]
openids.each do |id|
  `wechat custom_news #{id} #{news}`
end
