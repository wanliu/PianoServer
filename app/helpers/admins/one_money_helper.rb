module Admins::OneMoneyHelper

  def status_label_full(status, title = nil)
    classes =
      case status
      when "started"
        "success"
      when "end"
        "danger"
      when "suspend"
        "warring"
      else
        "default"
      end

    title_or_block = if block_given? then yield else title end
    content_tag :span, title_or_block, class: [:label, "label-#{classes}"]
  end

  def status_label(status)
    status ||= 'invalid'
    status_label_full status, t(status, scope: 'promotions.status')
  end

  def best_in_place_item(item, *args)
    options = args.extract_options!
    options[:url] = update_item_admins_one_money_path(@one_money.id, item.id)
    default_options = {
       inner_class: 'form-control'
    }
    args.push options.merge(default_options)
    best_in_place OhmModel.new(item, model_name: item.class), *args
  end

  def time_prompt(item, time = Time.now, &block)
    flag, time_str, seconds =
      case item.status
      when "started"
        short_time(item.start_at, time) do |flag|
          if flag > 0
            "执行了 %s"
          else
            ""
          end
        end
      when "end"
        short_time(item.end_at, time) do |flag|
          if flag > 0
            "中止在 %s"
          else
            ""
          end
        end
      when "suspend"
        short_time(item.suspend_at, time) do |flag|
          if flag > 0
            "暂停 %s"
          else
            ""
          end
        end
      else
        # seconds = time - item.start_at
        short_time(item.start_at, time) do |flag|
          if flag > 0
            "过期了 %s"
          elsif flag < 0
            "等待 %s"
          else
            ""
          end
        end
      end

    if block_given? then yield(flag,time_str, seconds) else time_str end
  end

  def short_time(t1, t2, &block)
    fmt_time = proc {|seconds| Time.at(seconds).utc.strftime("%H:%M:%S")}
    seconds = t2 - t1
    flag = 0
    str = if seconds > 0
            flag = 1
            if seconds > 1.days
              (yield flag) % [time_ago_in_words(t1)]
            else
              (yield flag) % [fmt_time.call(seconds.abs)]
            end
          elsif seconds < 0
            flag = -1
            if seconds.abs > 1.days
              (yield flag) % [time_ago_in_words(t1)]
            else
              (yield flag) % [fmt_time.call(seconds.abs)]
            end
          end
    [flag, str, seconds]
  end

  def warning_with(condition)
    icon(:'exclamation-sign', class: 'text-danger') if condition
  end

  alias_method :b, :best_in_place_item

  class OhmModel < Delegator
    extend ActiveModel::Naming

    cattr_accessor :name_class

    def initialize(object, options = {})
      super(object)
      self.name_class = options[:model_name] if options[:model_name] && options[:model_name].is_a?(Class)
      @delegate_sd_obj = object
    end

    def __getobj__
      @delegate_sd_obj # return object we are delegating to, required
    end

    def __setobj__(obj)
      @delegate_sd_obj = obj # change delegation object,
                             # a feature we're providing
    end

    def persisted?
      !@delegate_sd_obj.new?
    end

    def self.model_name
      ActiveModel::Name.new(self.name_class)
    end

    # def self.model_name
    #   @delegate_sd_obj.class.name
    # end
  end
end
