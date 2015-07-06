# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#   

system_agent = User.new do |u| 
  u.id = Settings.system.agent.id
  u.username = Settings.system.agent.username
  u.nickname = Settings.system.agent.nickname
  u.email = Settings.system.agent.email
  u.mobile = Settings.system.agent.mobile
  u.password = SecureRandom.hex
  u.save
end
