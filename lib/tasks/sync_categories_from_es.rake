# overwirte_model: A: overwrite, B: skip

namespace :db do
  desc "sync categories from es. overwirte_model: overwrite/skip"
  task :sync_categories, [:overwrite_model] => :environment do |task, args|
    EsCategoriesSync.sync(args.overwrite_model)
  end
end
