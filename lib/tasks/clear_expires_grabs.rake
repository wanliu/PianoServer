task :clear_expired_grabs, [:model] => :environment do |task, args|
  @one_moenies = OneMoney.all.select { | one | one.start_at < DateTime.now && one.end_at > DateTime.now }
  @one_moenies.each do |one|
    items = one.items.select { |i| i.status == "started" }
    items.map do |i|
      i.grabs.select {|grb| grb.expired? }.map do |grb|
        card_order = CardOrder.find_by(pmo_grab_id: grb.id)
        card_order.destroy if card_order.present?
        grb.delete
      end
    end
  end
end
