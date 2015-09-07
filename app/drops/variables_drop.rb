class VariablesDrop < Liquid::Drop

  def initialize(variables)
    @variables = variables
  end

  def before_method(name)
    @variables[name]
  end
end
