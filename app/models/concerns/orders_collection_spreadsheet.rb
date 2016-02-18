module OrdersCollectionSpreadsheet
  def to_spreadsheet(title=nil)

    Spreadsheet.client_encoding = 'UTF-8'
    book ||= Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.column(0).width = 30
    format = Spreadsheet::Format.new horizontal_align: :right
    row = 0

    if title.present?
      header_format = Spreadsheet::Format.new weight: :bold, size: 18, horizontal_align: :center
      sheet.merge_cells(0, 0, 0, 3)
      sheet[0, 0] = title
      sheet.row(0).default_format = header_format
      sheet.row(0).height = 25
      row += 1
    end

    all.each do |order|
      sheet.row(row += 1).concat ["订单号：#{order.id}", 
        "创建时间：#{order.created_at.strftime("%Y/%m/%d %H:%M")}",
        "收货人：#{order.receiver_name}",
        "联系电话：#{order.receiver_phone}",
        "收货地址：#{order.delivery_address}",
        "支付状态：#{order.paid? ? '已支付' : '未支付'}"]
      # sheet.row(row += 1).concat ["商品", "价格(元)", "数量(件)", "小计(元)"]
      order.items.each do |item|
        sheet.row(row += 1).concat ["#{item.title}#{item.properties_title}", "#{item.price.round(2)}元", "#{item.quantity}件", "#{(item.quantity * item.price).round(2)}元"]
      end

      row_content = [nil, "共#{order.items_count}件商品#{order.items_total.round(2)}元",
        "运费：#{(order.express_fee || 0).round(2)}元"]

      discount = if order.paid_total && order.paid_total != order.origin_total
        "已优惠：#{order.origin_total - order.paid_total}元"
      elsif order.total != order.origin_total
        "已优惠：#{number_to_currency order.origin_total - order.total}元"
      end

      row_content << discount if discount.present?

      row_content << "总计：#{order.paid_total.round(2) || order.total.round(2)}元"

      sheet.row(row += 1).concat row_content

      sheet.row(row += 1).concat []
    end

    book
  end
end