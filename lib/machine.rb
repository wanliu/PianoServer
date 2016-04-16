class Machine

  attr_accessor  :status, :code, :message, :options
  attr_reader :context, :result, :env
  cattr_reader :setup_options

  def initialize(action_context, _options = {})
    @context = action_context
    @options = _options
  end

  def run(_one_money, _item, &block)
    reset

    @one_money = _one_money
    @item = _item
    @code = 200
    @env = {}
    @status = "success"

    conditions.each do |condition_method|
      # @one_money = one_money
      # @item = item

      next_if = begin
                  self.__send__(condition_method)
                rescue => exception
                  status "unknown"
                  @result = result.merge({
                    backtrace: exception.backtrace.join("\n")
                  }) unless Rails.env.production?
                  error exception.to_s
                end
      # pp condition_method, next_if, @code, status, error

      break unless next_if
    end

    yield status, self if block_given?
    self
  end

  def result(_result = nil)
    if _result.nil?
      @result ||= {}
      @result[:error] = error[:error]
      @result[:status] = status
      @result
    else
      @result = _result
    end
  end

  def self.run(context, one_money, item, &block)
    machine = self.new(context, self.setup_options)
    machine.run(one_money, item, &block)
  end

  def self.finalize(machine)
    proc { puts 'finalize'; machine.reset; machine.options = nil }
  end

  def self.setup(_options = {})
    @setup_options = _options
  end

  def self.setup_options
    @setup_options ||= {}
  end

  protected

  def reset
    # @one_money = nil
    # @item = nil
    # @current_user = nil
    @status = nil
    @code = nil
    @message = nil
    # @options = {}
  end

  def error(message = nil, _code = 500)
    if message.nil?
      @error || {}
    elsif message.is_a? String
      @error = {
        error:  message
      }
      @code = _code
      false
    elsif message.is_a? Hash
      @error = message
      @code = _code
      false
    else
      false
    end
  end

  def status(_status = nil)
    if _status.nil?
      @status
    else
      @status = _status
    end
  end
end
