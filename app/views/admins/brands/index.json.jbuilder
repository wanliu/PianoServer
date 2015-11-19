json.brands @brands, partial: 'brand', as: :brand
json.total @brands.total_count
json.set! :paginate, paginate(@brands)
