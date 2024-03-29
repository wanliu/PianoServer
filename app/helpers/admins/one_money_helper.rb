module Admins::OneMoneyHelper

  def one_money_type
    params[:type] == :daily_cheap ? '天天惠' : '一元购'
  end

  def status_label_full(status, title = nil)
    classes =
      case status
      when "started"
        "success"
      when "end"
        "danger"
      when "suspend"
        "warning"
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

  def status_button(item)
    case item.status
    when nil, "", 'invalid'
      button_to "启动", state_item_admins_one_money_path(@one_money.id, item.id, status: "started"), context: :success, size: :xs
    when "started"
      button_to "暂停", state_item_admins_one_money_path(@one_money.id, item.id, status: "suspend"), context: :warning, size: :xs
    when "suspend"
      button_to "恢复", state_item_admins_one_money_path(@one_money.id, item.id, status: "started"), context: :warning, size: :xs
    when "end"
      button_to "重启", state_item_admins_one_money_path(@one_money.id, item.id, status: "started"), context: :success, size: :xs
    end
  end

  def status_control(item)
    status_action = proc do |status|
      state_item_admins_one_money_path(@one_money.id, item.id, status: status)
    end

    btn = proc do |icon, status, options = {} |
      disabled = options[:disabled]

      classes = %w(btn btn-default btn-xs)
      classes.push "disabled" if disabled
      default_options = {
        class: classes,
        remote: true,
        method: 'patch'
      }

      link_to status_action.call(status), default_options.merge(options || {}) do
        icon icon
      end
    end

    content_tag :span, class: 'btn-group' do
      case item.status
      when nil, "", 'invalid'
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end, disabled: true) +
        btn.call(:record, :timing, disabled: true)
      when "started"
        btn.call(:play, :started, disabled: true) +
        btn.call(:pause, :suspend) +
        btn.call(:stop, :end) +
        btn.call(:record, :timing, disabled: true)
      when "suspend"
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end) +
        btn.call(:record, :timing, disabled: true)
      when "end"
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end, disabled: true) +
        btn.call(:record, :timing, disabled: false)
      when "timing"
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end, disabled: true) +
        btn.call(:record, :timing, disabled: true)
      end
    end
  end

  def status_control_all(one_money)
    status_action = proc do |status|
      state_item_all_admins_one_money_path(one_money.id, status: status)
    end

    btn = proc do |icon, status, options = {} |
      disabled = options[:disabled]

      classes = %w(btn btn-default btn-xs)
      classes.push "disabled" if disabled
      default_options = {
        class: classes,
        remote: true,
        method: 'patch'
      }

      link_to status_action.call(status), default_options.merge(options || {}) do
        icon icon
      end
    end

    content_tag :span, class: 'btn-group' do
      case one_money.status
      when nil, "", 'invalid'
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end, disabled: true) +
        btn.call(:record, :timing, disabled: true)
      when "started"
        btn.call(:play, :started, disabled: true) +
        btn.call(:pause, :suspend) +
        btn.call(:stop, :end) +
        btn.call(:record, :timing, disabled: true)
      when "suspend"
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end) +
        btn.call(:record, :timing, disabled: true)
      when "end"
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end, disabled: true) +
        btn.call(:record, :timing, disabled: false)
      when "timing"
        btn.call(:play, :started) +
        btn.call(:pause, :suspend, disabled: true) +
        btn.call(:stop, :end, disabled: true) +
        btn.call(:record, :timing, disabled: true)
      end
    end
  end

  def exists_one_money_dir?(one_money)
    start_at = one_money.start_at
    name = "release/%04d-%02d-%02d" % [start_at.year, start_at.month, start_at.day]

    scripts =
      case one_money.type
      when :one_money, "one_money", ""
        Settings.promotions.one_money.scripts
      when :daily_cheap, "daily_cheap"
        Settings.promotions.daily_cheap.scripts
      else
        Settings.promotions.one_money.scripts
      end
    dir = File.join(scripts.publish.dir, name)
    File.exist?(dir)
  end

  def one_money_publish_url(one_money)
    start_at = one_money.start_at
    name = "%04d-%02d-%02d" % [start_at.year, start_at.month, start_at.day]
    enter_url =
      case one_money.type
      when :one_money, "one_money", ""
        Settings.promotions.one_money.enter_url
      when :daily_cheap, "daily_cheap"
        Settings.promotions.daily_cheap.enter_url
      else
        Settings.promotions.one_money.enter_url
      end

    File.join(enter_url, name)
  end

  def best_in_place_item(item, *args)
    options = args.extract_options!
    options[:url] ||= update_item_admins_one_money_path(@one_money.id, item.id)
    default_options = {
       inner_class: 'form-control'
    }
    args.push options.merge(default_options)
    best_in_place OhmModel.new(item, model_name: item.class), *args
  end

  def clear_over_link_to(name, item)
    url =  clear_overwrite_item_admins_one_money_path(@one_money.id, item.id, name: name )
    link_to url, remote: true, method: :delete do
      icon :repeat
    end
  end


  def time_prompt(item, time = item.now, &block)

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
    return [0, "无效的时间", 0 ] if t1.blank? || t2.blank?

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

  def warning_with(condition, options = {})
    icon(:'exclamation-sign', {class: 'text-danger'}.merge(options)) if condition
  end

  def warning_with_status(item)
    dict = {
      "start_at" => "开始时间",
      "end_at" => "结束时间",
      "suspend_at" => "暂停时间"
    }

    unless item.valid_status?
      messages = []
      item.valid_status_messages.each {|key, v| messages.push("%s %s" % [dict[key], v]) if v != true }
      text = messages.join(",")
      icon(:'exclamation-sign', {class: 'text-danger', title: text})
    end
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
