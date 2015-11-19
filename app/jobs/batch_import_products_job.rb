class BatchImportProductsJob < ActiveJob::Base
  queue_as :default

  def perform(job, shop, products, select_params)
    # pp products


    results =
    ids = products.select {|p| p["check"] && p["check"] == "1" }.map {|p| p["id"] }

    enum = EnumProducts.new do |start, size|
      Product.search query: { terms: { id: ids}}, from: start, size: size
    end

    job.output[:created] ||= []

    Item.skip_callback :save, :after, :store_attachment!
    index = Item.last_sid shop
    Item.transaction do
      enum.each do |product|
        @item = Item.where(product_id: product.id).first_or_create(
          shop_id: shop.id,
          title: product.name,
          product_id: product.id,
          public_price: product.price,
          on_sale: false,
          brand_id: product.brand_id,
          category_id: product.category_id,
          skip_batch: true) do |item|
          item.sid = index+=1
          item.write_attribute(:images, product.image_urls)
          job.output[:created].push(product.attributes) if item.valid?
        end
      end
    end
    Item.set_callback :save, :after, :store_attachment!

    # job.output[:products_group] = @products_group
    job.status = "done"
    job.end_at = Time.now
    job.save
    # Do something later
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
