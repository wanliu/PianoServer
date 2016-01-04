module OhmTime
  TIME_FORMAT = /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/

  Ex = lambda do |t|
    _t = if t.is_a?(String) && TIME_FORMAT =~ t
           ::Time.parse(t)
         elsif t.is_a?(String) && t.to_i > 0
           Time.at(t.to_i)
         else
           t
         end

    Ohm::DataTypes::UnixTime.at(_t.to_i)
  end
end
