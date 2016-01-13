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
end