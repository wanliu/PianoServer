module ThumbImages
  extend ActiveSupport::Concern

  included do
    include DynamicAssociationCallback
    cattr_accessor :thumb_association_options, :thumbimages_asset_host

    @@thumb_association_options = {}

  end

  module ClassMethods
    def thumb_association(association_name, field = :image, options = {})
      self.thumb_association_options[association_name.to_sym] = {
        association_name: association_name,
        field: field
      }.merge(options)

      init_thumbimages
    end

    def init_thumbimages
      self.thumb_association_options.each do |association_name, association_option|
        # after_add association_name, :_generate_thumbimages
        after_add_with_proc association_name do |callback, owner, item|
          associations = owner.send(association_name)
          owner.send(:_generate_thumbimages, associations, owner, association_option)
        end
      end
      # after_add self.
    end
  end

  private

  def _generate_thumbimages(association, owner, options)
    association = [association] unless association.is_a?(ActiveRecord::Associations::CollectionProxy)
    urls = association.map do |item|
      attribute_name = options[:field]
      image = (item.send(attribute_name) || {}).with_indifferent_access
      url = image[:avatar_url] || image[:preview_url]
    end

    store_field = options[:store_field] || options[:field]
    puts task_option(store_field)
    CombinationImagesJob.perform_later owner, urls, task_option(store_field)
  end

  def task_option(store_field, filename = nil, size = {"width" => 100, "height" => 100})
    {
      "store_field" => store_field.to_s,
      "size" => size,
      "filename" => filename,
      "asset_path" => self.class.thumbimages_asset_host || Thread.current[:default_asset_host]
    }
  end

  def _thumbs_association(name)
    self.thumb_association_options[name]
    # send(self.)
  end


end
