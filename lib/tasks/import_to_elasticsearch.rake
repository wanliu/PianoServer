require "elasticsearch_import"

namespace :es do
  desc "导入/重置数据到elasticsearch"
  task :import, [:model] => :environment do |task, args|
    ElasticsearchImport.import(args.model)
  end
end