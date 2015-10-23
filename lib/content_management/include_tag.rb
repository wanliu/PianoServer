module ContentManagement
  # class IncludeTag < ::Liquid::Include

  #   private

  #   def read_template_from_file_system(context)
  #     file_system = context.registers[:file_system] || ::Liquid::Template.file_system
  #     # make read_template_file call backwards-compatible.
  #     case file_system.method(:read_template_file).arity
  #     when 1
  #       file_system.read_template_file(context[@template_name])
  #     when 2
  #       file_system.read_template_file(context[@template_name], context)
  #     else
  #       raise ArgumentError, "file_system.read_template_file expects two parameters: (template_name, context)"
  #     end
  #   end
  # end

  # ::Liquid::Template.register_tag('include'.freeze, IncludeTag)
end
