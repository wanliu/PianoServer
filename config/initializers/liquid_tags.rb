Dir[ Rails.root.join('app/tags/*.rb') ].map do |f|
  require f
end
