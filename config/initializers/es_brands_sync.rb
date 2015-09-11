class EsBrandsSync
  def self.sync(overwrite_model)
    from = 0
    size = 1000

    loop do 
      sources = Brand.search(size: size, from: from).results.to_a

      sources.each do |source|
        attributes = source._source
        id = attributes.id
        record = Brand.find_by(id: id)

        if record.present?
          update_attributes = attributes.except(:id, :created_at, :updated_at, :deleted_at, :custom_special).to_hash

          if overwrite_model == "overwrite"
            extract_chinese_name! update_attributes
            record.update update_attributes
          end
        else
          update_attributes = attributes.except(:created_at, :updated_at, :deleted_at, :custom_special).to_hash

          extract_chinese_name! update_attributes
          Brand.create update_attributes
        end
      end

      break if sources.length < size

      from += size
    end

    ActiveRecord::Base.connection.reset_pk_sequence!('categories')
  end

  def self.extract_chinese_name!(attributes)
    origin_name = attributes["name"]
    if origin_name.include?('/')
      attributes["name"], attributes["chinese_name"] = origin_name.split('/')
    end
  end
end