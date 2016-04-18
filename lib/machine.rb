class Machine

  attr_accessor  :status, :code, :message, :options, :current_user
  attr_reader :context, :result, :env
  cattr_reader :setup_options

  def initialize(action_context, _options = {})
    @context = action_context
    @options = _options
  end

  def run(options, &block)
    reset

    before_run(options)

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
    after_run
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

  def before_run(options)
    # @one_money = _one_money
    # @item = _item
    @code = 200
    @env = {}
    @status = "success"
  end

  def after_run
  end

  def current_user
    @current_user ||= context.send(__user_method)
  end

  def __user_method
    @options[:user_method] || :current_user
  end

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
