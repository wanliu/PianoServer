Dir[ Rails.root.join('app/tags/*.rb') ].map { |f| require(f) }
