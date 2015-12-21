module ContentManagement
  module LookupContext
    extend ActiveSupport::Concern

    included do
      register_detail(:template_object) {
        []
      }
    end
  end
end
