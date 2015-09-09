# overwirte_model: A: overwrite, B: skip

namespace :db do
  desc "sync categories from es."
  task :sync_categories, [:overwrite_model] => :environment do |task, args|
    from = 0
    size = 1000


    loop do 
      sources = Category.search(size: size, from: from).results.to_a

      sources.each do |source|
        attributes = source._source
        id = attributes.id
        record = Category.find_by(id: id)

        params = ActionController::Parameters.new({
          category: attributes.except(:created_at, :updated_at, :deleted_at)
        })

        permited = params.require(:category).permit(:name, :ancestry, :ancestry_depth, :id)

        if record.present?
          record.update permited.except(:id) if args.overwrite_model == "overwrite"
        else
          Category.create permited
        end
      end

      break if sources.length < size

      from += size
    end

    ActiveRecord::Base.connection.reset_pk_sequence!('categories')
  end
end
