require 'rails/generators'

module SubjectService
  extend self

  def build(name)
    Rails::Generators.invoke 'subject', [ name ]
  end
end
