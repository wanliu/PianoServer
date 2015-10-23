Dir[ Rails.root.join('lib/piano/liquid/filters/*.rb') ].map do |f|
  require f
end

Dir[ Rails.root.join('app/tags/*.rb') ].map do |f|
  require f
end
