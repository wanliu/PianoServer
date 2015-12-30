class Cacher < Liquid::Block
  def initialize(tag_name, markup, tokens)
     super
    @key= markup.to_s.strip
  end

  def render(context)
    object_key, mark_key = @key.split(':')
    object = context[object_key]

    if object.present? && object.id && object.updated_at && mark_key
      key = "subject/#{object.class}/#{object.id}/#{object.updated_at}"

      Rails.cache.fetch([object, mark_key]) do
        super
      end
    else
      super
    end
  end
end

Liquid::Template.register_tag('cache', Cacher)