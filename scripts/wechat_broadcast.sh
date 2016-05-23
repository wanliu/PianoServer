#!/bin/sh

set -e

while read p; do
  wechat custom_text $p "今日活动 10:00 开始，点击参与 http://m.wanliu.biz/daily_cheap/2016-05-23/" || true
done < ~/Desktop/id.txt
