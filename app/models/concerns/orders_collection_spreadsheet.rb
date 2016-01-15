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
      sheet[row += 1, 0] = "订单号：#{order.id}"
      sheet.merge_cells(row, 0, row, 3)
      sheet[row += 1, 0] = "创建时间：#{order.created_at.strftime("%Y/%m/%d %H:%M")}"
      sheet.merge_cells(row, 0, row, 3)
      sheet[row += 1, 0] = "收货人：#{order.receiver_name}"
      sheet.merge_cells(row, 0, row, 3)
      sheet[row += 1, 0] = "联系电话：#{order.receiver_phone}"
      sheet.merge_cells(row, 0, row, 3)
      sheet[row += 1, 0] = "收货地址：#{order.delivery_address}"
      sheet.merge_cells(row, 0, row, 3)

      sheet.row(row += 1).concat ["商品", "价格(元)", "数量(件)", "小计(元)"]
      order.items.each do |item|
        sheet.row(row += 1).concat ["#{item.title}#{item.properties_title}", "#{item.price.round(2)}", "#{item.quantity}", "#{(item.quantity * item.price).round(2)}"]
      end

      sheet[row += 1, 0] = "共#{order.items_count}件商品，合计：#{order.items_total.round(2)}元"
      sheet.merge_cells(row, 0, row, 3)
      sheet.row(row).default_format = format

      sheet[row += 1, 0] = "运费：#{(order.express_fee || 0).round(2)}元"
      sheet.merge_cells(row, 0, row, 3)
      sheet.row(row).default_format = format

      sheet[row += 1, 0] = "总计：#{order.total.round(2)}元"
      sheet.merge_cells(row, 0, row, 3)
      sheet.row(row).default_format = format

      sheet.row(row += 1).concat []
      sheet.row(row += 1).concat []
      sheet.row(row += 1).concat []
    end

    book
  end
end