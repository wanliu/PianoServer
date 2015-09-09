# overwirte_model: A: overwrite, B: skip

namespace :db do
  desc "sync categories from es. overwirte_model: overwrite/skip"
  task :sync_categories, [:overwrite_model] => :environment do |task, args|
    from = 0
    size = 1000


    loop do 
      sources = Category.search(size: size, from: from).results.to_a

      sources.each do |source|
        attributes = source._source
        id = attributes.id
        record = Category.find_by(id: id)

        if record.present?
          update_attributes = attributes.except(:id, :created_at, :updated_at, :deleted_at).to_hash
          record.update update_attributes if args.overwrite_model == "overwrite"
        else
          update_attributes = attributes.except(:created_at, :updated_at, :deleted_at).to_hash
          Category.create update_attributes
        end
      end

      break if sources.length < size

      from += size
    end

    ActiveRecord::Base.connection.reset_pk_sequence!('categories')
  end
end
