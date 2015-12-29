class Cacher < Liquid::Block
  def initialize(tag_name, markup, tokens)
     super
    @key= markup.to_s.strip
  end

  def render(context)
    object = context[@key]

    if object.present? && object.id && object.updated_at
      key = "subject/#{object.class}/#{object.id}/#{object.updated_at}"
      puts '================> fetch'
      Rails.cache.fetch(key) do
        puts '=================> super'
        super
      end
    else
      super
    end
  end
end

Liquid::Template.register_tag('cache', Cacher)