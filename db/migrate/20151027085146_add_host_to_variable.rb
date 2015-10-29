class AddHostToVariable < ActiveRecord::Migration
  def up
    add_reference :variables, :host, polymorphic: true, index: true

    Variable.find_each do |variable|
      template = Template.find_by id: variable.try(:template_id)
      if template.present?
        variable.host_id = template.id
        variable.host_type = template.class.to_s
        variable.save
      end
    end

    remove_reference :variables, :template
  end

  def down
    add_reference :variables, :template

    Variable.find_each do |variable|
      if variable.host_type.try(:end_with?, "Template")
        host = Template.find_by(id: variable.host_id)
        if host.present?
          variable.template_id = variable.host_id
          variable.save
        end
      end
    end

    remove_reference :variables, :host, polymorphic: true
  end
end
