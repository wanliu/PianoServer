task :clear_expired_grabs, [:model] => :environment do |task, args|
  @one_moenies = OneMoney.all.select { | one | one.start_at < DateTime.now && one.end_at > DateTime.now }
  @one_moenies.each do |one|
    items = one.items.select { |i| i.status == "started" }
    items.each do |i|
      i.grabs.select {|grb| grb.expired? }.each do |grb|
        card_order = CardOrder.find_by(pmo_grab_id: grb.id)
        if card_order.present?
          unless card_order.paid
            card_order.destroy
            grb.delete
          end
        else 
          grb.delete
        end
      end
    end
  end
end
