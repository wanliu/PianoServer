require 'csv'

namespace :one_money do
  desc "total all one_money status"
  task :total_status => :environment do |task, args|
    if args.extras.count > 0
      ids = args.extras
    else
      ids = OneMoney.all.ids
    end

    users = ids.map { |id|
      OneMoney[id.to_i].winners.to_a
    }.flatten

    group_users = users.group_by { |u| u.id }
    sorted_users = group_users.sort { |a,b| b[1].count <=> a[1].count }

    CSV.open("one_money_status.csv", "wb") do |csv|
      csv << [:id, :title, :username, :user_id, :count, :avatar_url]

      sorted_users.each do |id, ary|
        csv << [id, ary[0].title, ary[0].username, ary[0].user_id, ary.count, ary[0].avatar_url]
      end
    end
  end
end
