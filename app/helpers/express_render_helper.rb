module ExpressRenderHelper
  def express_render(order)
    html = ""

    order.discharge_for_express? do |discharge, fee, discharge_express_fee_on|
      html = if discharge
        "0元(满#{discharge_express_fee_on}元免运送费)"
      else
        "#{number_to_currency fee}元"
      end
    end

    html.html_safe
  end

  def render_express_template_desc(express_template)
    if express_template.free_shipping?
      "卖家包邮"
    else
      default = express_template.template["default"]
      others = express_template.template.except("default").map do |code, _|
        ChinaCity.get(code, prepend_parent: true)
      end

      html = <<-HTML
        首件：#{default["first_quantity"]}件
        首费：#{default["first_fee"]}元
        续件：#{default["next_quantity"].to_i}件
        续费：#{default["next_fee"].to_f}元
      HTML

      if others.present?
        html << <<-HTML
          <br>
          特定地区：[#{others.join('] [')}]
        HTML
      end

      sanitize html
    end
  end
end