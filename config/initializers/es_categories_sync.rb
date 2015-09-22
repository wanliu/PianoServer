class EsCategoriesSync
  def self.sync(overwrite_model)
    from = 0
    size = 1000


    loop do 
      sources = Category.search(size: size, from: from).results.to_a

      sources.each do |source|
        attributes = source._source
        id = attributes.id
        record = Category.find_by(id: id)

        if record.present?
          update_attributes = attributes.slice(*Category.attribute_names).except(:id, :created_at, :updated_at).to_hash
          record.update update_attributes if overwrite_model == "overwrite"
        else
          update_attributes = attributes.slice(*Category.attribute_names).except(:created_at, :updated_at).to_hash
          Category.create update_attributes
        end
      end

      break if sources.length < size

      from += size
    end

    ActiveRecord::Base.connection.reset_pk_sequence!('categories')
  end
end