class GenerateProductsGroupJob < ActiveJob::Base
  queue_as :default

  def perform(job, select_params)
    # logger.info "start job #{job.id}"

    @select_params = select_params
    categories = @select_params.map {|id, brands| id }
    @categories = Category.where(id: categories).order(:id)
    @all_categories = @categories.map {|cate| {"id" => cate.id, "title" => cate.title, "categories" => cate.descendants} }

    top_category_title = proc { |top, category_id| top["categories"].find {|c| c.id == category_id }.try(:title) }

    @products_group =
      @all_categories.map do |top|
        group = {}
        group["type"] = 'top'
        group["id"] = top["id"].to_s
        # top["categories"].first.tap { |c| group["title"] = c.title || c.name }
        # group["title"] = top["categories"].first.title
        group["title"] = top["title"]
        group["total"] = 0

        ids = top["categories"].map &:id


        brands = select_params[group["id"]].map { |key, brands| brands }.flatten
        results = Product.with_category_brands(ids, brands)
        aggregations = results.response.aggregations

        group["categories"] =
          (aggregations.try(:all_category).try(:buckets) || []).map do |category_bucket|
            category = {}

            category["type"] = 'category'
            category["id"] = category_bucket["key"]
            category["doc_count"] = category_bucket["doc_count"]
            category["title"] = top_category_title.call top, category["id"]
            category["total"] = 0
            # group["total"] += category["doc_count"]

            category["brands"] =
              (category_bucket.try(:all_brands).try(:buckets) || []).map do |brand_bucket|
                brand = {}
                _brand = Brand.where(id: brand_bucket["key"]).first
                brand["type"] = 'brand'
                brand["id"] = brand_bucket["key"]
                brand["doc_count"] = brand_bucket["doc_count"]
                brand["title"] = _brand.try :title
                brand["icon_url"] = _brand.try(:image).try(:url)
                brand["total"] = brand_bucket.all_products.hits.hits.count
                # brand["total"] += 1 if brand["total"] > Settings.after_registers.total.max_count || 10
                category["total"] += brand["total"]

                brand["products"] =
                  brand_bucket.try(:all_products).try(:hits).hits.map do |hit|
                    hit["_source"]
                  end
                brand
              end
            group["total"] += category["total"]
            category
          end
        group
      end

    job.output["products_group"] = @products_group
    job.status = "done"
    job.end_at = Time.now
    job.save
    # Do something later
  end
end
