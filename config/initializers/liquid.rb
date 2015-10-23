Dir[ Rails.root.join('lib/piano/liquid/filters/*.rb') ].map do |f|
  require f
end

Dir[ Rails.root.join('app/tags/*.rb') ].map do |f|
  require f
end


Liquid::Template.file_system = ContentManagement::FileSystem.new("/", "_%s.html.liquid".freeze)
