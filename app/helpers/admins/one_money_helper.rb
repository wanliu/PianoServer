module Admins::OneMoneyHelper

  def status_label_full(status, title = nil)
    classes =
      case status
      when "started"
        "success"
      when "end"
        "danger"
      when "susupend"
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
end
