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

  ISO8601 = lambda do |t|
    case t
    when ISO8601Time
      t
    when Date, Time, DateTime
      ISO8601Time.at(t.to_f)
    else
      Time.parse(t)
    end
  end
end

class ISO8601Time < Time
  def to_s
    iso8601
  end
end
