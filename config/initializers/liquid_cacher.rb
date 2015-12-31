class Cacher < Liquid::Block
  # 在liquid模板中，当两个要用来做cache key的变量名称相同是，为了避免混淆缓存，在使用的时候加一个后缀使用，
  # 以‘:’隔开, 例如：{% cache promotion:index %} and {% cache promotion:headerpage %}
  def initialize(tag_name, markup, tokens)
     super
    @key= markup.to_s.strip
  end

  def render(context)
    object_key, mark_key = @key.split(':')
    mark_key = @key if mark_key.blank?

    object = context[object_key]

    if object.present? && object.id && object.updated_at
      key = "subject/#{object.class}/#{object.id}/#{object.updated_at}"

      Rails.cache.fetch([key, mark_key]) do
        super
      end
    else
      super
    end
  end
end

Liquid::Template.register_tag('cache', Cacher)