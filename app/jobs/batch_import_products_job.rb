class BatchImportProductsJob < ActiveJob::Base
  queue_as :default

  def perform(job, shop, products, categories)
    results = ids = products.select {|p| p["check"] && p["check"] == "1" }.map {|p| p["id"] }

    enum = EnumProducts.new do |start, size|
      Product.search query: { terms: { id: ids}}, from: start, size: size
    end
    job.output["created"] = []

    shop.create_shop_category name: 'product_category', title: '商品分类', category_type: 'builtin'  if shop.shop_category.nil?
    Item.skip_callback :save, :after, :store_images!
    ShopCategory.skip_callback :save, :after, :store_image!
    categories_map = {}
    # ShopCategory.silence do
      categories.each do |category_attrs|
        category_attrs = ActionController::Parameters.new(category_attrs.merge(status: true, category: category_attrs["id"]))
        Rails.logger.info category_attrs.inspect
        category = shop.shop_category.children
          .where("data @> :data", data: {cateogry: category_attrs["id"]}.to_json)
          .first_or_create(category_attrs.permit("title", "image", "description", :status, :category))

        categories_map[category_attrs["id"]] = category.id
        (category_attrs["children"]||[]).each do |child_attrs|
          child_attrs = ActionController::Parameters.new(child_attrs.merge(status: true, category: child_attrs["id"]))
          Rails.logger.info child_attrs.inspect
          child = category.children
            .where("data @> :data", data: {cateogry: child_attrs["id"]}.to_json)
            .first_or_create(child_attrs.permit("title", "image", "description", :status, :category))

          categories_map[child_attrs["id"]] = child.id
        end
      end
    # end

    index = Item.last_sid shop
    Item.transaction do
      enum.each do |product|
        Rails.logger.silence do

          @item = Item.where(product_id: product.id, shop_id: shop.id).first_or_create(
            shop_id: shop.id,
            title: product.name,
            product_id: product.id,
            price: product.price,
            public_price: product.price,
            on_sale: Settings.shop.import.sale,
            brand_id: product.brand_id,
            category_id: product.category_id,
            shop_category_id: categories_map[product.category_id.to_s],
            skip_batch: true) do |item|
            item.sid = index+=1
            item.write_attribute(:images, product.image_urls)
            job.output["created"].push(product.attributes) if item.valid?
          end
        end
      end
    end

    Item.set_callback :save, :after, :store_images!
    ShopCategory.set_callback :save, :after, :store_image!

    # job.output[:products_group] = @products_group
    job.status = "done"
    job.end_at = Time.now
    job.save
  rescue => e
    job.status = "fail"
    job.end_at = Time.now
    job.output[:errors] = "#{e}" + e.backtrace.join("\n")
    job.save
  end
end


class EnumProducts
  include Enumerable

  def initialize(options = {}, &block)
    @options = options
    @options.merge! size: 1000
    @size = @options[:size]
    @block = block
    @start = 0
  end

  def each
    results = @block.call(@start, @size)
    @start += results.count
    if @start <= results.total
      results.each do |product|
        yield product
      end
    end
  end
end
