class AddHostToVariable < ActiveRecord::Migration
  def change
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
    add_column :variables, :template_id, :integer, index: true

    Variable.find_each do |variable|
      if variable.host_type.end_with? "Template"
        host = Template.find(id: variable.host_id)
        if host.present?
          variable.template_id = variable.host_id
          variable.save
        end
      end
    end

    remove_reference :variables, :host, polymorphic: true
  end
end
