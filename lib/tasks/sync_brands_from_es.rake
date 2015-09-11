namespace :db do
  desc "sync categories from es. overwirte_model: overwrite/skip"
  task :sync_brands, [:overwrite_model] => :environment do |task, args|
    EsBrandsSync.sync(args.overwrite_model)
  end
end